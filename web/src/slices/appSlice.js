import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../utils/axios";

// ==================== ASYNC THUNKS ==================== //

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

// Fetch Surveys
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

// Fetch Discussions
export const fetchDiscussions = createAsyncThunk(
  "app/fetchDiscussions",
  async (_, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get("/api/post/allpostlist");
      // Ensure it's always an array
      return Array.isArray(res.data) ? res.data : res.data.posts || [];
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch discussions");
    }
  }
);

// Toggle Like
export const toggleLike = createAsyncThunk(
  "app/toggleLike",
  async (postId, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.post(`/api/post/${postId}/like`);
      return res.data;
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to like post");
    }
  }
);

// Add Comment
export const addComment = createAsyncThunk(
  "app/addComment",
  async ({ postId, comment }, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.post(`/api/post/${postId}/comment`, { comment });
      return { postId, comment: res.data };
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to add comment");
    }
  }
);

// Fetch Comments
export const fetchComments = createAsyncThunk(
  "app/fetchComments",
  async (postId, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get(`/api/get/${postId}/comment`);
      return { postId, comments: res.data };
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch comments");
    }
  }
);

// ==================== SLICE ==================== //
const initialState = {
  surveys: [],
  discussions: [],
  comments: {},        
  loading: {
    surveys: false,
    discussions: false,
    ai: false,
  },
  aiResponse: null,
  error: null,
};

const appSlice = createSlice({
  name: "app",
  initialState,
  reducers: {
    clearError: (state) => { state.error = null; },
  },
  extraReducers: (builder) => {
    builder
      // ==================== Surveys ==================== //
      .addCase(fetchSurveys.pending, (state) => { state.loading.surveys = true; })
      .addCase(fetchSurveys.fulfilled, (state, action) => {
        state.loading.surveys = false;
        state.surveys = action.payload || [];
      })
      .addCase(fetchSurveys.rejected, (state, action) => {
        state.loading.surveys = false;
        state.error = action.payload;
      })

      // ==================== Discussions ==================== //
      .addCase(fetchDiscussions.pending, (state) => { state.loading.discussions = true; })
      .addCase(fetchDiscussions.fulfilled, (state, action) => {
        state.loading.discussions = false;
        state.discussions = Array.isArray(action.payload) ? action.payload : [];
      })
      .addCase(fetchDiscussions.rejected, (state, action) => {
        state.loading.discussions = false;
        state.error = action.payload;
      })

      // ==================== AI ==================== //
      .addCase(askAI.pending, (state) => { state.loading.ai = true; })
      .addCase(askAI.fulfilled, (state, action) => {
        state.loading.ai = false;
        state.aiResponse = action.payload;
      })
      .addCase(askAI.rejected, (state, action) => {
        state.loading.ai = false;
        state.error = action.payload;
      })

      // ==================== Toggle Like ==================== //
      .addCase(toggleLike.fulfilled, (state, action) => {
        const index = state.discussions.findIndex(p => p._id === action.payload._id);
        if (index !== -1) state.discussions[index] = action.payload;
      })

      // ==================== Add Comment ==================== //
      .addCase(addComment.fulfilled, (state, action) => {
        const { postId, comment } = action.payload;
        if (!state.comments[postId]) state.comments[postId] = [];
        state.comments[postId].push(comment);
      })

      // ==================== Fetch Comments ==================== //
      .addCase(fetchComments.fulfilled, (state, action) => {
        const { postId, comments } = action.payload;
        state.comments[postId] = comments;
      });
  },
});

export const { clearError } = appSlice.actions;
export default appSlice.reducer;
