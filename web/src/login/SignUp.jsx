import React, { useState, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { registerUser, clearError } from "../slices/authSlice";
import { useNavigate } from "react-router-dom";
import { toast } from "react-toastify";
import { motion } from "framer-motion";

export default function CenteredSplitSignUpGradient() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [activeTab, setActiveTab] = useState("user"); // optional: if you have tabs

  const dispatch = useDispatch();
  const navigate = useNavigate();

  const loading = useSelector((state) => state.auth?.loading ?? false);
  const error = useSelector((state) => state.auth?.error ?? null);

  useEffect(() => {
    if (error) {
      toast.error(error);
      dispatch(clearError());
    }
  }, [error, dispatch]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name || !email || !password || !confirmPassword) {
      toast.warn("Please fill all fields");
      return;
    }
    if (password !== confirmPassword) {
      toast.error("Passwords do not match");
      return;
    }

    const resultAction = await dispatch(
      registerUser({ name, email, password, role: "viewer" })
    );
    if (registerUser.fulfilled.match(resultAction)) {
      toast.success("Signup successful!");
      navigate("/home", { replace: true });
    } else if (registerUser.rejected.match(resultAction)) {
      toast.error(resultAction.payload || "Signup failed");
    }
  };

  // Separate light gradients for tabs (or just use one for now)
  const gradientColors = {
    student:
      "linear-gradient(120deg, rgba(167,243,208,0.15), rgba(186,230,253,0.12), rgba(253,230,138,0.12))",
    user:
      "linear-gradient(120deg, rgba(255,193,227,0.15), rgba(255,214,165,0.12), rgba(217,191,255,0.12))",
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
            Welcome! ✨
          </h1>
          <p className="text-center text-white/90 mb-6 max-w-sm">
            Join our community to access exclusive resources, connect with
            professionals, and manage your profile effortlessly.
          </p>
          <div className="w-32 h-32 rounded-full bg-white/25 animate-pulse" />
        </div>

        {/* Right Section - Signup Form with light sliding gradient */}
        <div className="md:w-1/2 relative flex flex-col items-center justify-center p-12 overflow-hidden bg-white rounded-tr-3xl rounded-br-3xl">
          {/* Gradient overlay */}
          <motion.div
            className="absolute inset-0"
            style={{
              background: gradientColors[activeTab],
              backgroundSize: "400% 400%",
            }}
            animate={{ backgroundPosition: ["0% 50%", "100% 50%"] }}
            transition={{ repeat: Infinity, duration: 12, ease: "linear" }}
          />

          <div className="relative z-10 w-full max-w-md">
            <h2 className="text-3xl font-bold mb-2 text-gray-800 text-center">
              Create Account
            </h2>
            <p className="text-center mb-6 text-gray-500">
              Fill in your details to sign up
            </p>

            <form className="space-y-4 relative z-10" onSubmit={handleSubmit}>
              <input
                type="text"
                placeholder="Full Name"
                className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
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
              <input
                type="password"
                placeholder="Confirm Password"
                className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
              />
              <button
                type="submit"
                disabled={loading}
                className={`w-full py-3 rounded-lg bg-indigo-600 text-white font-semibold hover:bg-indigo-700 transition ${
                  loading ? "opacity-60 cursor-not-allowed" : ""
                }`}
              >
                {loading ? "Signing up..." : "Sign Up"}
              </button>
            </form>
          </div>
        </div>
      </motion.div>
    </div>
  );
}
