import { ChromaClient, DefaultEmbeddingFunction } from "chromadb";
const client = new ChromaClient();
// const collection = await client.getCollection({
//   name: "cars",
// });
async function search(query, collection, embedder) {
  let qembed = await embedder.generate(query);
  const results = await (
    await collection
  ).query({
    queryEmbeddings: qembed,
  });
  console.log(results);
}
// await search("white", collection);
export { search };
