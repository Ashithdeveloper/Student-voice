import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../utils/axios";

// ================= ASYNC THUNKS ================= //

// 📊 Fetch Surveys
export const fetchSurveys = createAsyncThunk(
  "app/fetchSurveys",
  async (_, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get("/api/surveys");
      return res.data;
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch surveys");
    }
  }
);

// 💬 Fetch Discussions
export const fetchDiscussions = createAsyncThunk(
  "app/fetchDiscussions",
  async (_, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get("/api/post/allpostlist");
      const data = Array.isArray(res.data) ? res.data : res.data.posts || [];
      return data;
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch discussions");
    }
  }
);

// ✍️ Create Discussion
export const createDiscussion = createAsyncThunk(
  "app/createDiscussion",
  async ({ text }, { rejectWithValue }) => {
    if (!text?.trim()) return rejectWithValue("Post content is required.");
    try {
      const res = await axiosInstance.post("/api/post/postcreate", { text: text.trim() });
      return res.data;
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to create discussion");
    }
  }
);

// ❤️ Toggle Like
export const toggleLike = createAsyncThunk(
  "app/toggleLike",
  async (postId, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.post(`/api/post/${postId}/like`);
      return res.data; // should return updated post object with likes
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to like post");
    }
  }
);

// 💬 Fetch Comments
export const fetchComments = createAsyncThunk(
  "app/fetchComments",
  async (postId, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get(`/api/post/${postId}/comment`);
      return { postId, comments: Array.isArray(res.data) ? res.data : [] };
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch comments");
    }
  }
);

// ➕ Add Comment
export const addComment = createAsyncThunk(
  "app/addComment",
  async ({ postId, comment }, { rejectWithValue }) => {
    if (!comment?.trim()) return rejectWithValue("Comment text is required.");
    try {
      const res = await axiosInstance.post(`/api/post/${postId}/comment`, { text: comment.trim() });
      return { postId, comment: res.data };
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to add comment");
    }
  }
);

// 🤖 Ask AI
export const askAI = createAsyncThunk(
  "app/askAI",
  async (question, { rejectWithValue }) => {
    if (!question?.trim()) return rejectWithValue("Question text is required.");
    try {
      const res = await axiosInstance.post("/api/ai/ask", { question: question.trim() });
      return res.data;
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to ask AI");
    }
  }
);

// ================= INITIAL STATE ================= //
const initialState = {
  surveys: [],
  discussions: [],
  comments: {}, // { [postId]: [] }
  aiResponse: null,
  loading: { surveys: false, discussions: false, ai: false },
  error: null,
};

// ================= SLICE ================= //
const appSlice = createSlice({
  name: "app",
  initialState,
  reducers: {
    // Temp Post Handling (Optimistic UI)
    addTempPost: (state, action) => {
      state.discussions.unshift(action.payload);
    },
    clearTempPosts: (state) => {
      state.discussions = state.discussions.filter(p => !p._id?.startsWith("temp-"));
    },

    // Temp Comments Handling
    addTempComment: (state, action) => {
      const { postId, comment } = action.payload;
      if (!state.comments[postId]) state.comments[postId] = [];
      state.comments[postId].push(comment);
    },
    clearTempComments: (state, action) => {
      const postId = action.payload;
      if (state.comments[postId]) {
        state.comments[postId] = state.comments[postId].filter(c => !c._id?.startsWith("temp-"));
      }
    },
  },

  extraReducers: (builder) => {
    builder
      // 📊 Surveys
      .addCase(fetchSurveys.pending, (state) => { state.loading.surveys = true; })
      .addCase(fetchSurveys.fulfilled, (state, action) => {
        state.loading.surveys = false;
        state.surveys = action.payload;
      })
      .addCase(fetchSurveys.rejected, (state, action) => {
        state.loading.surveys = false;
        state.error = action.payload;
      })

      // 💬 Discussions
      .addCase(fetchDiscussions.pending, (state) => { state.loading.discussions = true; })
      .addCase(fetchDiscussions.fulfilled, (state, action) => {
        state.loading.discussions = false;
        const tempPosts = state.discussions.filter(p => p._id?.startsWith("temp-"));
        // merge temp posts on top
        state.discussions = [...action.payload, ...tempPosts];
      })
      .addCase(fetchDiscussions.rejected, (state, action) => {
        state.loading.discussions = false;
        state.error = action.payload;
      })
      .addCase(createDiscussion.fulfilled, (state, action) => {
        // remove temp and prepend new post
        state.discussions = state.discussions.filter(p => !p._id?.startsWith("temp-"));
        state.discussions.unshift(action.payload);
      })

      // ❤️ Toggle Like (update specific post)
      .addCase(toggleLike.fulfilled, (state, action) => {
        const index = state.discussions.findIndex(p => p._id === action.payload._id);
        if (index !== -1) state.discussions[index] = action.payload;
      })

      // 💬 Comments
      .addCase(fetchComments.fulfilled, (state, action) => {
        const { postId, comments } = action.payload;
        state.comments[postId] = comments || [];
        // also sync comment count into post list if available
        const postIndex = state.discussions.findIndex(p => p._id === postId);
        if (postIndex !== -1) {
          state.discussions[postIndex].commentsCount = comments.length;
        }
      })
      .addCase(addComment.fulfilled, (state, action) => {
        const { postId, comment } = action.payload;
        if (!state.comments[postId]) state.comments[postId] = [];
        state.comments[postId] = state.comments[postId].filter(c => !c._id?.startsWith("temp-"));
        state.comments[postId].push(comment);

        // increment comment count in discussions list
        const postIndex = state.discussions.findIndex(p => p._id === postId);
        if (postIndex !== -1) {
          state.discussions[postIndex].commentsCount =
            (state.discussions[postIndex].commentsCount || 0) + 1;
        }
      })

      // 🤖 AI
      .addCase(askAI.pending, (state) => { state.loading.ai = true; })
      .addCase(askAI.fulfilled, (state, action) => {
        state.loading.ai = false;
        state.aiResponse = action.payload;
      })
      .addCase(askAI.rejected, (state, action) => {
        state.loading.ai = false;
        state.error = action.payload;
      });
  },
});

// ================= SELECTORS ================= //
const emptyArray = [];
export const selectCommentsByPost = (state, postId) => state.app.comments[postId] || emptyArray;

// ================= EXPORTS ================= //
export const {
  addTempPost,
  clearTempPosts,
  addTempComment,
  clearTempComments,
} = appSlice.actions;

export default appSlice.reducer;
