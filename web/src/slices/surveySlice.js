import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../utils/axios";

// Fetch all colleges (backend + mock fallback)
export const fetchColleges = createAsyncThunk(
  "survey/fetchColleges",
  async (_, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get("/api/questions/allcollege");
      const backendColleges = res.data || [];

      // Mock colleges if backend returns empty
      const mockColleges = [
        "Bethlahem Institute of Engineering",
        "CSI Institute of Technology",
        "Nesamony Memorial Christian College",
        "Govt College of Engineering, Tirunelveli",
        "Udaya School of Engineering",
        "Loyola Institute of Technology",
        "Sethu Institute of Technology",
        "Xavier College of Arts & Science",
        "St. Joseph's College"
      ];

      const finalList = Array.from(new Set([...backendColleges, ...mockColleges]));
      return finalList;
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch colleges");
    }
  }
);

// Fetch questions for a college
export const fetchCollegeQuestions = createAsyncThunk(
  "survey/fetchCollegeQuestions",
  async (collegeName, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get(`/api/questions?college=${collegeName}`);
      return { collegeName, questions: res.data || [] };
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch questions");
    }
  }
);

// Fetch results for a college
export const fetchCollegeResults = createAsyncThunk(
  "survey/fetchCollegeResults",
  async (collegeName, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get(`/api/questions/result/${collegeName}`);
      return { collegeName, results: res.data || {} };
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch results");
    }
  }
);

const initialState = {
  colleges: [],
  questions: {}, // { collegeName: [] }
  results: {},   // { collegeName: {} }
  loading: { colleges: false, questions: false, results: false },
  error: { colleges: null, questions: null, results: null },
};

const surveySlice = createSlice({
  name: "survey",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    // Colleges
    builder
      .addCase(fetchColleges.pending, (state) => { state.loading.colleges = true; state.error.colleges = null; })
      .addCase(fetchColleges.fulfilled, (state, action) => { state.loading.colleges = false; state.colleges = action.payload; })
      .addCase(fetchColleges.rejected, (state, action) => { state.loading.colleges = false; state.error.colleges = action.payload; });

    // Questions
    builder
      .addCase(fetchCollegeQuestions.pending, (state) => { state.loading.questions = true; state.error.questions = null; })
      .addCase(fetchCollegeQuestions.fulfilled, (state, action) => { state.loading.questions = false; state.questions[action.payload.collegeName] = action.payload.questions; })
      .addCase(fetchCollegeQuestions.rejected, (state, action) => { state.loading.questions = false; state.error.questions = action.payload; });

    // Results
    builder
      .addCase(fetchCollegeResults.pending, (state) => { state.loading.results = true; state.error.results = null; })
      .addCase(fetchCollegeResults.fulfilled, (state, action) => { state.loading.results = false; state.results[action.payload.collegeName] = action.payload.results; })
      .addCase(fetchCollegeResults.rejected, (state, action) => { state.loading.results = false; state.error.results = action.payload; });
  },
});

export default surveySlice.reducer;
