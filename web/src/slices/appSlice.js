import { createSlice, createAsyncThunk, createSelector } from "@reduxjs/toolkit";
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
      // Ensure likes & commentCount exist and user info
      return data.map(post => ({
        ...post,
        likes: post.likes || [],
        commentCount: post.commentCount || 0,
        user: post.user || { name: "Anonymous", verified: false },
      }));
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
      return {
        ...res.data,
        likes: res.data.likes || [],
        commentCount: res.data.commentCount || 0,
        user: res.data.user || { name: "Anonymous", verified: false },
      };
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
      return res.data;
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
    addTempPost: (state, action) => {
      state.discussions.unshift(action.payload);
    },
    clearTempPosts: (state) => {
      state.discussions = state.discussions.filter(p => !p._id?.startsWith("temp-"));
    },
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
      // Surveys
      .addCase(fetchSurveys.pending, (state) => { state.loading.surveys = true; })
      .addCase(fetchSurveys.fulfilled, (state, action) => {
        state.loading.surveys = false;
        state.surveys = action.payload;
      })
      .addCase(fetchSurveys.rejected, (state, action) => {
        state.loading.surveys = false;
        state.error = action.payload;
      })

      // Discussions
      .addCase(fetchDiscussions.pending, (state) => { state.loading.discussions = true; })
      .addCase(fetchDiscussions.fulfilled, (state, action) => {
        state.loading.discussions = false;
        const tempPosts = state.discussions.filter(p => p._id?.startsWith("temp-"));
        state.discussions = [...action.payload, ...tempPosts];
      })
      .addCase(fetchDiscussions.rejected, (state, action) => {
        state.loading.discussions = false;
        state.error = action.payload;
      })
      .addCase(createDiscussion.fulfilled, (state, action) => {
        state.discussions = state.discussions.filter(p => !p._id?.startsWith("temp-"));
        state.discussions.unshift(action.payload);
      })

      // Toggle Like
      .addCase(toggleLike.fulfilled, (state, action) => {
        const index = state.discussions.findIndex(p => p._id === action.payload._id);
        if (index !== -1) state.discussions[index] = action.payload;
      })

      // Comments
      .addCase(fetchComments.fulfilled, (state, action) => {
        const { postId, comments } = action.payload;
        state.comments[postId] = comments || [];
        const postIndex = state.discussions.findIndex(p => p._id === postId);
        if (postIndex !== -1) state.discussions[postIndex].commentCount = comments.length;
      })
      .addCase(addComment.fulfilled, (state, action) => {
        const { postId, comment } = action.payload;
        if (!state.comments[postId]) state.comments[postId] = [];
        state.comments[postId] = state.comments[postId].filter(c => !c._id?.startsWith("temp-"));
        state.comments[postId].push(comment);

        const postIndex = state.discussions.findIndex(p => p._id === postId);
        if (postIndex !== -1) {
          state.discussions[postIndex].commentCount =
            (state.discussions[postIndex].commentCount || 0) + 1;
        }
      })

      // AI
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

// ================= MEMOIZED SELECTORS ================= //
export const selectDiscussions = (state) => state.app.discussions || [];
export const selectCommentsState = (state) => state.app.comments || {};

export const selectCommentsByPost = createSelector(
  [selectCommentsState, (_, postId) => postId],
  (comments, postId) => comments[postId] || []
);

// Selector to get verified posts
export const selectVerifiedPosts = createSelector(
  [selectDiscussions],
  (discussions) => discussions.map(post => ({
    ...post,
    user: {
      ...post.user,
      verified: post.user?.verified || false,
    }
  }))
);

// ================= EXPORTS ================= //
export const {
  addTempPost,
  clearTempPosts,
  addTempComment,
  clearTempComments,
} = appSlice.actions;

export default appSlice.reducer;
