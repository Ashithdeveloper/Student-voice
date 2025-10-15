// face++.js
import { FormData, fetch } from "undici";
import { configDotenv } from "dotenv";
configDotenv(); // this loads process.env

const apikey = process.env.FACEPP_API_KEY;
const secret = process.env.FACEPP_SECRET;
const FACE_COMPARE_URL = "https://api-us.faceplusplus.com/facepp/v3/compare";


export const faceVerify = async (liveselfie, idCard) => {
  try {
    // liveselfie.buffer and idCard.buffer exist only if multer.memoryStorage is used
    
console.log("FACE++ KEY:", process.env.FACEPP_API_KEY);
console.log("FACE++ SECRET:", process.env.FACEPP_API_SECRET);
    const formData = new FormData();
    formData.append("api_key", apikey);
    formData.append("api_secret", secret);
    formData.append("image_base64_1", liveselfie.buffer.toString("base64"));
    formData.append("image_base64_2", idCard.buffer.toString("base64"));

    const response = await fetch(FACE_COMPARE_URL, {
      method: "POST",
      body: formData,
    });

    const result = await response.json();
    console.log("Face++ full response:", result);

    if (result.error_message) throw new Error(result.error_message);
    if (!result.confidence) return { matched: false, confidence: 0 };

    return {
      matched: result.confidence >= 75,
      confidence: result.confidence,
    };
  } catch (error) {
    console.error("Face++ API error:", error.message);
    return { matched: false, confidence: 0 };
  }
};
