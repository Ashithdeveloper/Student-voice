import React, { useState, useEffect } from "react";
import { FaUserGraduate, FaUserTie } from "react-icons/fa";
import { motion } from "framer-motion";
import { useDispatch, useSelector } from "react-redux";
import { loginUser, clearError, fetchUserProfile } from "../slices/authSlice";
import { useNavigate } from "react-router-dom";
import { toast } from "react-toastify";

export default function LoginSplitGradient() {
  const [activeTab, setActiveTab] = useState("student");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { loading, error } = useSelector((state) => state.auth || {});

  useEffect(() => {
    if (error) {
      toast.error(error);
      dispatch(clearError());
    }
  }, [error, dispatch]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!email || !password) {
      toast.warn("Please enter both email and password");
      return;
    }

    if (activeTab === "student") {
      navigate("/mobilesignupnotice");
      return;
    }

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

  // Completely independent light gradients
  const gradientColors = {
    student:
      "linear-gradient(120deg, rgba(72,219,251,0.15), rgba(147,233,255,0.12), rgba(167,243,208,0.12))",
    user:
      "linear-gradient(120deg, rgba(255,183,197,0.15), rgba(255,218,185,0.12), rgba(194,176,255,0.12))",
  };

  return (
    <div className="min-h-screen font-serif flex items-center justify-center bg-gray-50 p-4">
      <motion.div
        className="flex flex-col md:flex-row w-full max-w-4xl shadow-2xl rounded-3xl overflow-hidden"
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.5 }}
      >
        {/* Left Section - Welcome */}
        <div className="md:w-1/2 bg-gradient-to-tr from-indigo-500 via-purple-500 to-pink-500 text-white flex flex-col items-center justify-center p-12">
          <h1 className="text-4xl font-extrabold mb-4 text-center">
            Welcome Back! 👋
          </h1>
          <p className="text-center text-white/90 mb-6 max-w-sm">
            Login to access your dashboard and continue your journey with
            StudentVoice.
          </p>
          <div className="w-32 h-32 rounded-full bg-white/20 animate-pulse" />
        </div>

        {/* Right Section - Login Form with gradient overlay */}
        <div className="md:w-1/2 relative flex flex-col items-center justify-center p-12 overflow-hidden bg-white rounded-tr-3xl rounded-br-3xl">
          {/* Sliding gradient overlay */}
          <motion.div
            className="absolute inset-0"
            style={{
              background: gradientColors[activeTab],
              backgroundSize: "400% 400%",
            }}
            animate={{ backgroundPosition: ["0% 50%", "100% 50%"] }}
            transition={{ repeat: Infinity, duration: 10, ease: "linear" }}
          />

          <div className="relative z-10 w-full max-w-md">
            <h2 className="text-3xl font-bold mb-2 text-gray-800 text-center">
              {activeTab === "student" ? "Student Login" : "User Login"}
            </h2>
            <p className="text-center mb-6 text-gray-500">
              Enter your credentials to continue
            </p>

            {/* Tabs */}
            <div className="flex justify-center mb-6 space-x-4">
              <button
                onClick={() => setActiveTab("student")}
                className={`flex items-center gap-2 px-6 py-2 rounded-full transition ${
                  activeTab === "student"
                    ? "bg-teal-500 text-white font-semibold"
                    : "bg-gray-100 text-teal-600 hover:bg-gray-200"
                }`}
              >
                <FaUserGraduate /> Student
              </button>

              <button
                onClick={() => setActiveTab("user")}
                className={`flex items-center gap-2 px-6 py-2 rounded-full transition ${
                  activeTab === "user"
                    ? "bg-pink-500 text-white font-semibold"
                    : "bg-gray-100 text-pink-500 hover:bg-gray-200"
                }`}
              >
                <FaUserTie /> User
              </button>
            </div>

            {/* Form */}
            <form className="space-y-4 relative z-10" onSubmit={handleSubmit}>
              <input
                type="email"
                placeholder="Email"
                className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
              <input
                type="password"
                placeholder="Password"
                className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
              <button
                type="submit"
                disabled={loading}
                className={`w-full py-3 rounded-lg ${
                  activeTab === "student"
                    ? "bg-teal-500 hover:bg-teal-600 text-white"
                    : "bg-pink-500 hover:bg-pink-600 text-white"
                } font-semibold transition ${
                  loading ? "opacity-60 cursor-not-allowed" : ""
                }`}
              >
                {loading ? "Logging in..." : "Login"}
              </button>
            </form>

            <div className="mt-6 text-center relative z-10">
              {activeTab === "student" ? (
                <button
                  onClick={handleStudentSignup}
                  className="text-sm text-teal-600 hover:underline hover:text-teal-700 transition"
                >
                  Don’t have an account? Sign up
                </button>
              ) : (
                <button
                  onClick={handleUserSignup}
                  className="text-sm text-pink-500 hover:underline hover:text-pink-700 transition"
                >
                  Don’t have an account? Sign up
                </button>
              )}
            </div>
          </div>
        </div>
      </motion.div>
    </div>
  );
}
