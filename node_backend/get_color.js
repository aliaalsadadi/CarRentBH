import OpenAI from "openai";
import dotenv from "dotenv";
import axios from "axios";
import { getImageUrl } from "./firebase_methods.js";
dotenv.config();

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
  organizationId: process.env.OPENAI_ORG_ID,
});

export async function getCarColor(imagePath) {
  try {
    const imageUrl = await getImageUrl(imagePath);

    // Send the image as part of the prompt
    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: "What’s the color of the car in this image? Please provide a three-word maximum answer.",
            },
            {
              type: "image_url",
              image_url: {
                url: imageUrl,
              },
            },
          ],
        },
      ],
      max_tokens: 300,
    });

    console.log(response.choices[0]);
    return response.choices[0].message.content;
  } catch (error) {
    console.error("Error fetching the image description:", error);
  }
}
// getCarColor(
//   "listings/KhaJcfi0vrZwQx74orKQ1Pw7voz2/4361a250-b5ef-1031-93ca-bf4b80f626b7"
// );
