import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import { toast } from "react-toastify";
import axiosInstance from "../utils/axios";

const initialState = {
  pointsData: { surveys: 0, community: 0, aiUsage: 0, dailyLogin: 0 },
  loading: false,
  error: null,
};

export const fetchUserPoints = createAsyncThunk(
  "points/fetchUserPoints",
  async (userId, { rejectWithValue }) => {
    try {
      const res = await axiosInstance.get(`/api/points/${userId}`);
      return res.data;
    } catch (err) {
      return rejectWithValue(err.response?.data?.message || "Failed to fetch points");
    }
  }
);

const pointsSlice = createSlice({
  name: "points",
  initialState,
  reducers: {
    addPoints: (state, action) => {
      const { category, value } = action.payload;
      if (state.pointsData[category] !== undefined) {
        state.pointsData[category] += value;
        toast.success(`+${value} points in ${category.replace(/([A-Z])/g, ' $1')}!`, {
          icon: "⭐",
        });
      }
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchUserPoints.pending, (state) => { state.loading = true; })
      .addCase(fetchUserPoints.fulfilled, (state, action) => {
        state.loading = false;
        state.pointsData = action.payload;
      })
      .addCase(fetchUserPoints.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

export const { addPoints } = pointsSlice.actions;
export default pointsSlice.reducer;
