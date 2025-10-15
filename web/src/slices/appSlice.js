import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../utils/axios";

// AI Mentor
export const askAI = createAsyncThunk(
  "app/askAI",
  async (question, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.post("/ai-mentor", { question });
      return res.data.answer;
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to get AI response");
    }
  }
);

export const fetchSurveys = createAsyncThunk(
  "app/fetchSurveys",
  async (_, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get("/user/getme");
      return res.data;
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch surveys");
    }
  }
);

export const fetchDiscussions = createAsyncThunk(
  "app/fetchDiscussions",
  async (_, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get("/discussions");
      return res.data;
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch discussions");
    }
  }
);

export const fetchEvents = createAsyncThunk(
  "app/fetchEvents",
  async (_, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get("/events");
      return res.data;
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch events");
    }
  }
);

const initialState = {
  surveys: [],
  discussions: [],
  events: [],
  aiResponse: null,
  loading: false,
  error: null,
};

const appSlice = createSlice({
  name: "app",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchSurveys.fulfilled, (state, action) => { state.surveys = action.payload; })
      .addCase(fetchDiscussions.fulfilled, (state, action) => { state.discussions = action.payload; })
      .addCase(fetchEvents.fulfilled, (state, action) => { state.events = action.payload; })
      .addCase(askAI.fulfilled, (state, action) => { state.aiResponse = action.payload; });
  },
});

export default appSlice.reducer;
