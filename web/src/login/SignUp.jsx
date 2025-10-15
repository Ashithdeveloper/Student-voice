import React, { useState, useEffect, useRef } from "react";
import { useDispatch, useSelector } from "react-redux";
import { registerUser, clearError } from "../slices/authSlice";
import { useNavigate } from "react-router-dom";
import { toast } from "react-toastify";
import { motion } from "framer-motion";

export default function SignUp() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  const dispatch = useDispatch();
  const navigate = useNavigate();

  // Select primitives separately (prevents selector returning new object each render)
  const loading = useSelector((state) => state.auth?.loading ?? false);
  const user = useSelector((state) => state.auth?.user ?? null);
  const error = useSelector((state) => state.auth?.error ?? null);

  // Prevent multiple navigations
  const redirectedRef = useRef(false);

  // Handle errors (clear after showing)
  useEffect(() => {
    if (error) {
      toast.error(error);
      dispatch(clearError());
    }
  }, [error, dispatch]);

  // Redirect on signup success — guarded by ref
  useEffect(() => {
    if (user && !redirectedRef.current) {
      redirectedRef.current = true;
      toast.success("Signup successful!");
      navigate("/home", { replace: true });
    }
  }, [user, navigate]);

  const handleSubmit = (e) => {
    e.preventDefault();

    if (!name || !email || !password || !confirmPassword) {
      toast.warn("Please fill all fields");
      return;
    }
    if (password !== confirmPassword) {
      toast.error("Passwords do not match");
      return;
    }

    // Implicitly set role as "viewer"
    dispatch(registerUser({ name, email, password, role: "viewer" }));
  };

  const gradient = "from-pink-200 via-yellow-200 to-green-200";

  return (
    <div className="min-h-screen font-serif flex items-center justify-center px-4 bg-gray-50">
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.4 }}
        className={`w-full max-w-md p-[2px] rounded-3xl bg-gradient-to-br ${gradient} shadow-2xl`}
      >
        <div className="bg-white/60 backdrop-blur-lg rounded-3xl p-8 shadow-lg">
          <h2 className="text-2xl font-bold mb-6 text-center text-gray-800">
            User SignUp
          </h2>
          <form className="space-y-4" onSubmit={handleSubmit}>
            <input
              type="text"
              placeholder="Full Name"
              className="w-full px-4 py-3 rounded-lg bg-white/50 placeholder-gray-600 text-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-400"
              value={name}
              onChange={(e) => setName(e.target.value)}
            />
            <input
              type="email"
              placeholder="Email"
              className="w-full px-4 py-3 rounded-lg bg-white/50 placeholder-gray-600 text-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-400"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <input
              type="password"
              placeholder="Password"
              className="w-full px-4 py-3 rounded-lg bg-white/50 placeholder-gray-600 text-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-400"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            <input
              type="password"
              placeholder="Confirm Password"
              className="w-full px-4 py-3 rounded-lg bg-white/50 placeholder-gray-600 text-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-400"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
            />

            <button
              type="submit"
              disabled={loading}
              className={`w-full py-3 rounded-lg bg-white text-gray-800 font-semibold hover:bg-gray-100 transition ${
                loading ? "opacity-60 cursor-not-allowed" : ""
              }`}
            >
              {loading ? "Signing up..." : "Sign Up"}
            </button>
          </form>
        </div>
      </motion.div>
    </div>
  );
}
