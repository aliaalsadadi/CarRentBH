import grpc from "@grpc/grpc-js";
import protoLoader from "@grpc/proto-loader";
import { getCarDoc } from "./firebase_methods.js";
// Import your other dependencies
import { ChromaClient, OpenAIEmbeddingFunction } from "chromadb";
import dotenv from "dotenv";
dotenv.config();
// Initialize your client and embedder using environment variables
const client = new ChromaClient();
const collection = await client.getOrCreateCollection({
  name: "cars",
});
const embedder = new OpenAIEmbeddingFunction({
  openai_api_key: process.env.OPENAI_API_KEY,
  openai_model: process.env.OPENAI_MODEL,
  openai_organization_id: process.env.OPENAI_ORG_ID,
});

const packageDefinition = protoLoader.loadSync("./protos/cars.proto", {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
});

const gRPCObject = grpc.loadPackageDefinition(packageDefinition);
const chromaPackage = gRPCObject.ChromaService;

async function AddCar(call, callback) {
  const data = call.request;
  const carDoc = await getCarDoc(data.id);
  const embedding = await embedder.generate([JSON.stringify(carDoc)]);
  await collection.add({
    ids: [data.id],
    embeddings: embedding,
  });
  console.log(data);
  return callback(null, { added: true });
}

async function SearchCars(call, callback) {
  const data = call.request;
  console.log(data.Query);
  const results = await collection.query({
    queryEmbeddings: await embedder.generate([data.Query]),
    nResults: 5,
  });
  console.log(results);
  return callback(null, { ids: results.ids });
}

const server = new grpc.Server();
server.addService(chromaPackage.service, {
  AddCar: AddCar,
  SearchCars: SearchCars,
});

server.bindAsync(
  "0.0.0.0:4000",
  grpc.ServerCredentials.createInsecure(),
  (_, p) => {
    console.log(`Server running on localhost:${p}`);
  }
);
