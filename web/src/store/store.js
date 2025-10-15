import { configureStore } from "@reduxjs/toolkit";
import appReducer from "../slices/appSlice";
import authReducer from "../slices/authSlice";
import surveyReducer from "../slices/surveySlice";
import collegeAnalyticsReducer from "../slices/analyticsSlice";

const store = configureStore({
  reducer: {
    app: appReducer,
    auth: authReducer,
    survey: surveyReducer,
    collegeAnalytics: collegeAnalyticsReducer,
  },
});

export default store;
