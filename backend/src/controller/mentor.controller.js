import MentorChart from "../models/mentor.js";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { configDotenv } from "dotenv";
import User from "../models/user.model.js";
import Answer from "../models/answersave.js";
import LearningSchedule from "../models/scheduleMentor.js";

configDotenv();

const genai = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

export const createMentorChart = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { prompt } = req.body;

    if (!prompt) {
      return res
        .status(400)
        .json({ message: "Prompt is required", success: false });
    }

    const user = await User.findById(userId).select("-password");
    if (!user) {
      return res
        .status(404)
        .json({ message: "User not found", success: false });
    }

    const answer = await Answer.findOne({
      userId,
      collegename: user.collegename,
    });

    // Fetch previous mentor conversations for context
    const previousChats = await MentorChart.find({ userId }).sort({
      createdAt: -1,
    });

    const previousContext = previousChats
      .map(
        (chat, i) =>
          `#${i + 1} Prompt: ${chat.prompt}\nResponse: ${chat.aiResponse}`
      )
      .join("\n\n");

    // Construct contextual prompt for Gemini
    const contextPrompt = `
You are a professional AI Mentor. Use the user's data and past interactions to provide an insightful, actionable, and contextual response.

USER PROFILE:
${JSON.stringify(user, null, 2)}

USER ANSWERS (if available):
${JSON.stringify(answer || {}, null, 2)}

PREVIOUS MENTOR CONVERSATIONS:
${previousContext || "No previous mentor chats."}

NEW USER PROMPT:
"${prompt}"

Your response **must be valid JSON** with the following format:
{
  "advice": "string",
  "learningPlan": "array or string if relevant",
  "chartData": "optional chart or plan data",
  "youtubeLinks": ["list of YouTube links if helpful"]
}
If the prompt does not need all fields, include null or [] instead.
`;

    // Gemini request
    const model = genai.getGenerativeModel({ model: "gemini-2.0-flash" });
    const result = await model.generateContent(contextPrompt);
    const aiText = result.response.text();

    // Parse the response safely
    let parsedOutput;
    try {
      parsedOutput = JSON.parse(aiText);
    } catch {
      parsedOutput = {
        advice: aiText,
        chartData: null,
        learningPlan: null,
        youtubeLinks: [],
      };
    }

    // Save the mentor chart with user and response data
    const mentorChart = new MentorChart({
      userId,
      prompt,
      aiResponse: aiText,
      chartData: parsedOutput.chartData || null,
      learningPlan: parsedOutput.learningPlan || null,
      youtubeLinks: parsedOutput.youtubeLinks || [],
      userData: user, // optional field — ensure MentorChart schema supports this
      previousChats: previousChats.map((c) => ({
        prompt: c.prompt,
        aiResponse: c.aiResponse,
      })),
    });

    await mentorChart.save();

    return res.status(201).json({
      message: "Mentor chart created successfully",
      success: true,
      mentorChart,
    });
  } catch (error) {
    console.error("MentorChart Error:", error);
    return res.status(500).json({ message: "Server error", success: false });
  }
};

// Get all charts for a user
export const getMentorCharts = async (req, res) => {
  try {
    const userId = req.user.id;
    const charts = await MentorChart.find({ userId }).sort({ createdAt: -1 });
    return res.status(200).json({ success: true, charts });
  } catch (error) {
    console.error("GetMentorCharts Error:", error);
    return res.status(500).json({ message: "Server error", success: false });
  }
};

// Get a specific chart by ID 
export const scheduleMentorAI = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { topic } = req.body;

    // 1️⃣ Validate input
    if (!topic) {
      return res
        .status(400)
        .json({ message: "Topic is required", success: false });
    }

    // 2️⃣ Fetch user info
    const user = await User.findById(userId).select("-password");
    if (!user) {
      return res
        .status(404)
        .json({ message: "User not found", success: false });
    }

    // 3️⃣ Fetch previous mentor context
    const previousMentorData = await MentorChart.find({ userId }).sort({
      createdAt: -1,
    });

    const previousContext = previousMentorData
      .map((p, i) => `#${i + 1} Prompt: ${p.prompt}\nResponse: ${p.aiResponse}`)
      .join("\n\n");

    // 4️⃣ Construct Gemini prompt
    const fullPrompt = `
You are an expert AI Mentor creating a personalized, structured day-by-day learning schedule.

USER PROFILE:
${JSON.stringify(user, null, 2)}

PREVIOUS MENTOR INTERACTIONS:
${previousContext || "None"}

TASK:
Based on the topic: "${topic}", create a daily learning schedule in **valid JSON** format:

{
  "topic": "string",
  "totalDays": number,
  "schedule": [
    {
      "day": "Day 1",
      "learningGoal": "string",
      "details": "string describing what to do",
      "resources": ["YouTube/Article links if needed"]
    }
  ],
  "advice": "string"
}
`;

    // 5️⃣ Call Gemini API
    const model = genai.getGenerativeModel({ model: "gemini-2.0-flash" });
    const result = await model.generateContent(fullPrompt);
    const aiText = result.response.text();

    // 6️⃣ Safely parse Gemini’s output
    let parsedOutput;
    try {
      parsedOutput = JSON.parse(aiText);
    } catch {
      parsedOutput = {
        topic,
        totalDays: null,
        schedule: [],
        advice: aiText,
      };
    }

    // 7️⃣ Save schedule to LearningSchedule collection
    const savedSchedule = new LearningSchedule({
      userId,
      topic: parsedOutput.topic || topic,
      totalDays:
        parsedOutput.totalDays || parsedOutput.schedule?.length || null,
      schedule: parsedOutput.schedule || [],
      advice: parsedOutput.advice || "",
      aiResponse: aiText,
    });

    await savedSchedule.save();

    // 8️⃣ Also save minimal context in MentorChart (optional)
    const mentorChart = new MentorChart({
      userId,
      prompt: `Learning schedule for ${topic}`,
      aiResponse: aiText,
      learningPlan: parsedOutput.schedule || [],
      youtubeLinks:
        parsedOutput.schedule?.flatMap((s) => s.resources || []) || [],
    });

    await mentorChart.save();

    // 9️⃣ Return response to frontend
    return res.status(201).json({
      message: "Learning schedule created and saved successfully",
      success: true,
      schedule: savedSchedule,
    });
  } catch (error) {
    console.error("ScheduleMentorAI Error:", error);
    return res.status(500).json({ message: "Server error", success: false });
  }
};

// Get all schedules for a user
export const getMentorSchedule = async (req, res) => {
  try {
    const userId = req.user.id;
    const schedules = await LearningSchedule.find({ userId }).sort({
      createdAt: -1,
    });
    return res.status(200).json({ success: true, schedules });
  } catch (error) {
    console.error("GetMentorSchedule Error:", error);
    return res.status(500).json({ message: "Server error", success: false });
  }
};

//delete the schedule
export const deleteMentorSchedule = async (req, res) => {
  try {
    const scheduleId = req.params.id;
    const deletedSchedule = await LearningSchedule.findByIdAndDelete(scheduleId);
    if (!deletedSchedule) {
      return res
        .status(404)
        .json({ message: "Schedule not found", success: false });
    }
    return res.status(200).json({ success: true, message: "Schedule deleted" , });
  } catch (error) {
    console.error("DeleteMentorSchedule Error:", error);
    return res.status(500).json({ message: "Server error", success: false });
  }
};