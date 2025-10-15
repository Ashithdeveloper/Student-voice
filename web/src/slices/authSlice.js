import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../utils/axios";

// ================= LOGIN =================
export const loginUser = createAsyncThunk(
  "auth/login",
  async ({ email, password }, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.post("/api/user/login", { email, password });
      return res.data; // { token, user }
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || "Login failed");
    }
  }
);

// ================= REGISTER =================
export const registerUser = createAsyncThunk(
  "auth/registerUser",
  async ({ name, email, password, role = "viewer" }, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.post("/api/user/userlogin", { name, email, password, role });
      return res.data; // { token, user }
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || "Signup failed");
    }
  }
);

// ================= GET CURRENT USER =================
export const fetchUserProfile = createAsyncThunk(
  "auth/fetchUserProfile",
  async (_, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get("/api/user/getme"); // getme returns user object
      return res.data.user; 
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || "Failed to fetch user data");
    }
  }
);

// ================= SLICE =================
const authSlice = createSlice({
  name: "auth",
  initialState: {
    user: null,
    token: localStorage.getItem("token") || null,
    loading: false,
    error: null,
  },
  reducers: {
    clearError: (state) => { state.error = null; },
    logout: (state) => {
      state.user = null;
      state.token = null;
      localStorage.removeItem("token");
    },
  },
  extraReducers: (builder) => {
    builder
      // Login
      .addCase(loginUser.pending, (state) => { state.loading = true; state.error = null; })
      .addCase(loginUser.fulfilled, (state, action) => {
        state.loading = false;
        state.token = action.payload.token;
        state.user = action.payload.user; // save user after login
        localStorage.setItem("token", action.payload.token);
      })
      .addCase(loginUser.rejected, (state, action) => { state.loading = false; state.error = action.payload; })

      // Register
      .addCase(registerUser.pending, (state) => { state.loading = true; state.error = null; })
      .addCase(registerUser.fulfilled, (state, action) => {
        state.loading = false;
        state.token = action.payload.token;
        state.user = action.payload.user; // save user after signup
        localStorage.setItem("token", action.payload.token);
      })
      .addCase(registerUser.rejected, (state, action) => { state.loading = false; state.error = action.payload; })

      // Fetch current user
      .addCase(fetchUserProfile.pending, (state) => { state.loading = true; state.error = null; })
      .addCase(fetchUserProfile.fulfilled, (state, action) => { state.loading = false; state.user = action.payload; })
      .addCase(fetchUserProfile.rejected, (state, action) => { state.loading = false; state.error = action.payload; });
  },
});

export const { clearError, logout } = authSlice.actions;
export default authSlice.reducer;
