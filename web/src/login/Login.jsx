import React, { useState, useEffect } from "react";
import { FaUserGraduate, FaUserTie } from "react-icons/fa";
import { motion } from "framer-motion";
import { useDispatch, useSelector } from "react-redux";
import { loginUser, clearError, fetchUserProfile } from "../slices/authSlice";
import { useNavigate } from "react-router-dom";
import { toast } from "react-toastify";

export default function Login() {
  const [activeTab, setActiveTab] = useState("student");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { loading, user, error, token } = useSelector((state) => state.auth || {});

  // Handle errors from slice
  useEffect(() => {
    if (error) {
      toast.error(error);
      dispatch(clearError());
    }
  }, [error, dispatch]);

  // Submit login
  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!email || !password) {
      toast.warn("Please enter both email and password");
      return;
    }

    // Student tab redirects to mobile notice
    if (activeTab === "student") {
      navigate("/mobilesignupnotice");
      return;
    }

    // Dispatch login
    const resultAction = await dispatch(loginUser({ email, password }));

    if (loginUser.fulfilled.match(resultAction)) {
      toast.success("Login successful!");
      await dispatch(fetchUserProfile());
      navigate("/home");
    } else if (loginUser.rejected.match(resultAction)) {
      toast.error(resultAction.payload || "Login failed");
    }
  };

  const handleStudentSignup = () => navigate("/mobilesignupnotice");
  const handleUserSignup = () => navigate("/signup");

  const boxGradient =
    activeTab === "student"
      ? "bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500"
      : "bg-gradient-to-br from-green-400 via-blue-400 to-purple-400";

  return (
    <div className="min-h-screen font-serif flex items-center justify-center px-4 bg-gray-50">
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.4 }}
        className={`${boxGradient} w-full max-w-md backdrop-blur-xl rounded-3xl shadow-2xl p-8 text-white`}
      >
        {/* Tabs */}
        <div className="flex justify-center mb-8 space-x-4">
          <button
            onClick={() => setActiveTab("student")}
            className={`flex items-center gap-2 px-6 py-2 rounded-full transition ${
              activeTab === "student"
                ? "bg-white text-indigo-600 font-semibold"
                : "bg-white/20 hover:bg-white/30"
            }`}
          >
            <FaUserGraduate /> Student
          </button>
          <button
            onClick={() => setActiveTab("user")}
            className={`flex items-center gap-2 px-6 py-2 rounded-full transition ${
              activeTab === "user"
                ? "bg-white text-indigo-600 font-semibold"
                : "bg-white/20 hover:bg-white/30"
            }`}
          >
            <FaUserTie /> User
          </button>
        </div>

        {/* Form */}
        <motion.div
          key={activeTab}
          initial={{ x: 50, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ duration: 0.4 }}
        >
          <h2 className="text-2xl font-bold mb-6 text-center">
            {activeTab === "student" ? "Student Login" : "User Login"}
          </h2>
          <form className="space-y-4" onSubmit={handleSubmit}>
            <input
              type="email"
              placeholder="Email"
              className="w-full px-4 py-3 rounded-lg bg-white/20 placeholder-white/70 focus:outline-none focus:ring-2 focus:ring-white"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <input
              type="password"
              placeholder="Password"
              className="w-full px-4 py-3 rounded-lg bg-white/20 placeholder-white/70 focus:outline-none focus:ring-2 focus:ring-white"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            <button
              type="submit"
              disabled={loading}
              className={`w-full py-3 rounded-lg text-indigo-600 font-semibold bg-white hover:bg-indigo-600 hover:text-white transition duration-300 ${
                loading ? "opacity-60 cursor-not-allowed" : ""
              }`}
            >
              {loading ? "Logging in..." : "Login"}
            </button>
          </form>

          <div className="mt-6 text-center">
            {activeTab === "student" ? (
              <button
                onClick={handleStudentSignup}
                className="text-sm hover:underline hover:text-white/80 transition"
              >
                Don’t have an account? Sign up
              </button>
            ) : (
              <button
                onClick={handleUserSignup}
                className="text-sm hover:underline hover:text-white/80 transition"
              >
                Don’t have an account? Sign up
              </button>
            )}
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
}
