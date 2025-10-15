import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axios from "axios";

// Fetch analytics for a college
export const fetchCollegeAnalytics = createAsyncThunk(
  "collegeAnalytics/fetch",
  async (collegeName, { rejectWithValue }) => {
    try {
      // Get token from localStorage (or wherever you store it)
      const token = localStorage.getItem("token");
      if (!token) throw new Error("No token found. Please login.");

      const response = await axios.get(
        `https://student-voice.onrender.com/api/questions/result/${encodeURIComponent(collegeName)}`,
        { headers: { Authorization: `Bearer ${token}` } }
      );

      // Ensure the data structure matches Flutter
      return { collegeName, data: response.data.result.results };
    } catch (error) {
      console.error("Fetch failed:", error);
      return rejectWithValue(
        error.response?.data?.message || error.message || "Failed to fetch college analytics"
      );
    }
  }
);

const analyticsSlice = createSlice({
  name: "collegeAnalytics",
  initialState: {
    data: {},       // { collegeName: { ...results } }
    loading: false,
    error: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchCollegeAnalytics.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchCollegeAnalytics.fulfilled, (state, action) => {
        state.loading = false;
        state.data[action.payload.collegeName] = action.payload.data;
      })
      .addCase(fetchCollegeAnalytics.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload || "Something went wrong";
      });
  },
});

export default analyticsSlice.reducer;
