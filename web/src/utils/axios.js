import axios from "axios";

const axiosInstance = axios.create({
  baseURL: "https://student-voice.onrender.com",
});

// Add token to headers automatically
axiosInstance.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default axiosInstance;
