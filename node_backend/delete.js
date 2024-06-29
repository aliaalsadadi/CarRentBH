import { ChromaClient, DefaultEmbeddingFunction } from "chromadb";
const client = new ChromaClient();
await client.deleteCollection({
  name: "cars",
});
