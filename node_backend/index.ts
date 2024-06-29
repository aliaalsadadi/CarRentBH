import { ChromaClient, DefaultEmbeddingFunction } from "chromadb";
const client = new ChromaClient();
const embedder = new DefaultEmbeddingFunction();
async function main() {
  try {
    const collection = await client.getOrCreateCollection({
      name: "cars",
    });
    const cars = [
      {
        brand: "mercedes",
        model: "G-class",
        yearModel: 2020,
        rate: 200,
        color: "Bhite",
        description:
          "mercedes G-class  416-hp 4.0L V8,fuel consumption: 16.0 L/100 km, 4 doors, sun roof, off road, luxurious, 5 seater",
      },
      {
        brand: "mercedes",
        model: "G-class",
        yearModel: 2018,
        rate: 220,
        color: "Black",
        description:
          "mercedes G-class Number of cylinders V8,fuel consumption: 16.0, 4 doors, sun roof, off road, luxurious, 5 seater, boxy design",
      },
      {
        brand: "Honda",
        model: "Accord",
        year: 2016,
        price: 100,
        color: "blue",
        description:
          "Engine Displacement 1993 cc, Number of cylinders 4, 4 doors, sun roof, 5 seater,fuel consumption: 7.8, body type: sedan, sport",
      },
      {
        brand: "Honda",
        model: "Accord",
        year: 2017,
        price: 110,
        color: "red",
        description:
          "Engine Displacement 1993 cc, Number of cylinders 4, 4 doors, sun roof, 5 seater,fuel consumption: 7.8, body type: sedan, sport",
      },
      {
        brand: "Toyota",
        model: "Land cruiser",
        year: 2020,
        price: 150,
        color: "white",
        description:
          "Engine Displacement3346 cc, Number of cylinders V8, 4 doors, sun roof, 8 seater, fuel consumption: 11, body type: SUV, family friendly",
      },
      {
        brand: "Toyota",
        model: "Land cruiser",
        year: 2019,
        price: 130,
        color: "dark blue",
        description:
          "Engine Displacement3346 cc, Number of cylinders V6, 4 doors, sun roof, 8 seater, fuel consumption: 11, body type: SUV, family friendly",
      },
      {
        brand: "Toyota",
        model: "Camry",
        year: 2023,
        price: 120,
        color: "white",
        description:
          "Engine Displacement2487 cc hyrbrid, Number of cylinders 4, 5 seater, fuel consumption: 10, body type: sedan",
      },
    ];
    const ids = cars.map((_, index) => `car_${index + 1}`);
    const docs = cars.map((car) => JSON.stringify(car));
    const embeddings = await embedder.generate(docs);
    await collection.add({
      ids: ids,
      embeddings: embeddings,
    });
    const allItems = await collection.get();
    console.log(allItems);
  } catch (error) {
    console.log("Error: ", error);
  }
}
main();