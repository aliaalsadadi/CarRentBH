import grpc from "@grpc/grpc-js";
import protoLoader from "@grpc/proto-loader";

const packageDefinition = protoLoader.loadSync("./product.proto", {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
});

const gRPCObject = grpc.loadPackageDefinition(packageDefinition);
const ProductService = gRPCObject.Product;

const client = new ProductService(
  "localhost:4000",
  grpc.credentials.createInsecure()
);

// Create a new product
client.CreateProduct(
  {
    name: "Smartphone X",
    description: "Latest model",
    price: 999.99,
    category: "SMARTPHONE",
  },
  (error, response) => {
    if (error) {
      console.error("Error creating product:", error);
    } else {
      console.log("Product created successfully:", response);
    }
  }
);

// Read a product by ID
client.ReadProduct({ id: 1 }, (error, response) => {
  if (error) {
    console.error("Error reading product:", error);
  } else {
    console.log("Product details:", response);
  }
});

// Read all products
client.ReadProducts({}, (error, response) => {
  if (error) {
    console.error("Error reading products:", error);
  } else {
    console.log("All products:", response.products);
  }
});

// Update a product by ID
