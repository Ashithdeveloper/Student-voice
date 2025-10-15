import User from "../models/user.model.js";
import { configDotenv } from "dotenv";
configDotenv();
import { GoogleGenerativeAI } from "@google/generative-ai";
import fs from "fs/promises"; // Use fs.promises for async file operations
import { generateToken } from "../Token/genToken.js";
import { hashPassword, comparePassword } from "../config/passwordencrypt.js";
import { generatequestion } from "./question.controller.js";

// Initialize Google Gemini client
const genai = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Helper: convert file to Gemini Base64 part
async function fileToGenerativePart(filePath, mimeType) {
  try {
    const fileData = await fs.readFile(filePath);
    return {
      inlineData: {
        data: Buffer.from(fileData).toString("base64"),
        mimeType,
      },
    };
  } catch (error) {
    console.error("Error reading file:", error);
    throw new Error("Failed to process uploaded file.");
  }
}

// Cleanup uploaded files
async function cleanUpFiles(files = []) {
  for (const file of files) {
    if (file?.path) {
      await fs.unlink(file.path).catch(() => {});
    }
  }
}

// ------------------------ SIGNUP ------------------------
export const signup = async (req, res) => {
  const liveselfie = req.files?.liveselfie?.[0];
  const idCard = req.files?.idCard?.[0];

  try {
    const { name, password, collegeId, collegename, email } = req.body;

    console.log("Received Data:", {
      name,
      email,
      collegeId,
      collegename,
      idCardPath: idCard?.path,
      selfiePath: liveselfie?.path,
    });

    // Check required fields
    if (!name || !password || !collegeId || !collegename || !email) {
      await cleanUpFiles([liveselfie, idCard]);
      return res
        .status(400)
        .json({ message: "All fields are required", success: false });
    }

    // Check uploaded files
    if (!liveselfie || !idCard) {
      return res
        .status(400)
        .json({
          message: "Both ID card and selfie are required",
          success: false,
        });
    }

    // Check existing user
    const existingUser = await User.findOne({
      $or: [{ email }, { collegeId }],
    });
    if (existingUser) {
      await cleanUpFiles([liveselfie, idCard]);
      return res
        .status(400)
        .json({ message: "User already exists", success: false });
    }

    // Convert files to Gemini-compatible parts
    let liveselfiePart, idCardPart;
    try {
      liveselfiePart = await fileToGenerativePart(
        liveselfie.path,
        liveselfie.mimetype
      );
      idCardPart = await fileToGenerativePart(idCard.path, idCard.mimetype);
    } catch (err) {
      await cleanUpFiles([liveselfie, idCard]);
      return res
        .status(500)
        .json({ message: "Failed to process uploaded files", success: false });
    }

    // AI verification prompt
    const verificationPrompt = `
You are an identity verification expert. Verify whether the provided text details match the college student ID card and the live selfie image.

Check for:
1. Confirm that the provided ID card is a college student ID card. If not, reject it.
2. Name consistency
3. College ID correctness
4. College name accuracy
5. Face comparison between ID card photo and live selfie
6. Any other discrepancies 

Details to verify:
- Name: "${name}"
- College ID: "${collegeId}"
- College Name: "${collegename}"

Respond only in valid JSON format:
{
  "verified": true,
  "verifiedDetails": {
    "name": "Matched or Not",
    "collegeId": "Matched or Not",
    "collegeName": "Matched or Not",
    "faceMatch": "Matched or Not"
  }
}

If any mismatch occurs, respond:
{
  "verified": false,
  "reason": "Explain the exact discrepancy",
  "verifiedDetails": {
    "name": "...",
    "collegeId": "...",
    "collegeName": "...",
    "faceMatch": "..."
  }
}
`;

    // Send multimodal request to Gemini
    let parsedOutput;
    try {
      const model = genai.getGenerativeModel({ model: "gemini-2.0-flash" });
      const result = await model.generateContent({
        contents: [
          {
            role: "user",
            parts: [
              { text: verificationPrompt },
              { text: "Live Selfie Image:" },
              liveselfiePart,
              { text: "ID Card Image:" },
              idCardPart,
            ],
          },
        ],
      });

      const aiResponseText = result.response.text();
      const cleanText = aiResponseText
        .replace(/```json/g, "")
        .replace(/```/g, "")
        .trim();
      parsedOutput = JSON.parse(cleanText);
      console.log("Parsed AI Output:", parsedOutput);
    } catch (err) {
      console.error("Failed to parse AI response:", err);
      await cleanUpFiles([liveselfie, idCard]);
      return res
        .status(500)
        .json({
          message: "AI verification failed or returned invalid format",
          success: false,
        });
    }

    // Verification check
    if (!parsedOutput.verified) {
      await cleanUpFiles([liveselfie, idCard]);
      return res.status(400).json({
        message: parsedOutput.reason || "Verification failed",
        success: false,
      });
    }

    // Hash password
    const hashedPassword = await hashPassword(password);

    // Create user
    const user = new User({
      name,
      password: hashedPassword,
      collegeId,
      email,
      collegename,
      isVerified: true,
    });
    await user.save();

    // Generate default questions for the college
    await generatequestion(collegename);

    // Cleanup uploaded files
    await cleanUpFiles([liveselfie, idCard]);

    // Generate token
    const token = generateToken(user._id);

    return res.status(201).json({
      message: "Student registered and verified successfully",
      success: true,
      user,
      token,
    });
  } catch (error) {
    console.error("Signup Error:", error);
    await cleanUpFiles([liveselfie, idCard]);
    return res
      .status(500)
      .json({ message: "Server error during signup", success: false });
  }
};

// ------------------------ USER LOGIN ------------------------
export const userLogin = async (req, res) => {
  try {
    const { email, password, name, role } = req.body;
    if (!email || !password || !name || !role) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    const hashedPassword = await hashPassword(password);
    const newUser = new User({ name, email, password: hashedPassword, role });
    await newUser.save();

    const token = generateToken(newUser._id);
    return res.status(200).json({
      message: "User created successfully",
      success: true,
      token,
      user: newUser,
    });
  } catch (error) {
    console.error("UserLogin Error:", error);
    return res.status(500).json({ message: "Server error", success: false });
  }
};

// ------------------------ GET ME ------------------------
export const getme = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");
    if (!user)
      return res
        .status(404)
        .json({ message: "User not found", success: false });
    return res.status(200).json({ success: true, user });
  } catch (error) {
    console.error("GetMe Error:", error);
    return res.status(500).json({ message: "Server error", success: false });
  }
};

// ------------------------ LOGIN ------------------------
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res
        .status(400)
        .json({ message: "All fields are required", success: false });

    const user = await User.findOne({ email });
    if (!user)
      return res
        .status(400)
        .json({ message: "User not found", success: false });

    const isMatch = await comparePassword(password, user.password);
    if (!isMatch)
      return res
        .status(400)
        .json({ message: "Invalid email or password", success: false });

    const token = generateToken(user._id);
    return res
      .status(200)
      .json({
        message: "User logged in successfully",
        success: true,
        token,
        user,
      });
  } catch (error) {
    console.error("Login Error:", error);
    return res.status(500).json({ message: "Server error", success: false });
  }
};
