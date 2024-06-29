import { initializeApp } from "firebase/app";
import {
  getFirestore,
  getDoc,
  collection,
  doc,
  updateDoc,
} from "firebase/firestore";
import { getStorage, ref, getDownloadURL } from "firebase/storage";
import dotenv from "dotenv";
import { getCarColor } from "./get_color.js";
dotenv.config();
const app = initializeApp({
  apiKey: process.env.FIREBASE_API_KEY,
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.BUCKET_URL,
  messagingSenderId: process.env.FIREBASE_SENDER_ID,
  appId: process.env.FIREBASE_APP_ID,
  measurementId: process.env.FIREBASE_MEASUREMENT_ID,
});
export const db = getFirestore(app);
export const store = getStorage(app);
// const fileRef = ref(store, "Mercedes-Benz_W463_G_350_BlueTEC_01.jpg");
export async function getImageUrl(url) {
  const imageRef = ref(store, url);
  const downloadUrl = await getDownloadURL(imageRef);
  return downloadUrl;
}
export async function getCarDoc(id) {
  const docRef = doc(db, "car_listings", id);
  const docSnap = await getDoc(docRef);
  const data = docSnap.data();
  const fileRef = ref(store, `listings/${data.sellerID}/${id}`);
  await updateDoc(docRef, { color: await getCarColor(fileRef) });
  if (docSnap.exists()) {
    console.log("Document data:", docSnap.data());
    return docSnap.data();
  } else {
    // docSnap.data() will be undefined in this case
    return "No such document!";
  }
}
