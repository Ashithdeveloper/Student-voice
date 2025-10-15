import React, { useEffect } from "react";
import { motion } from "framer-motion";
import { useNavigate } from "react-router-dom";

export const MobileSignUpNotice = ({ type = "student" }) => {
  const navigate = useNavigate();

  // Automatically redirect after 3 seconds
  useEffect(() => {
    const timer = setTimeout(() => {
      navigate("/"); // go back to login or home
    }, 3000);

    return () => clearTimeout(timer);
  }, [navigate]);

  // Different gradient for Student and User
  const gradient =
    type === "student"
      ? "from-pink-400 via-red-400 to-orange-400" // Student gradient
      : "from-teal-400 via-blue-500 to-indigo-500"; // User gradient

  return (
    <div className="fixed inset-0 font-serif bg-black/30 backdrop-blur-sm flex items-center justify-center z-50">
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.8, opacity: 0 }}
        transition={{ duration: 0.5 }}
        className={`relative max-w-md w-full rounded-xl p-[2px] bg-gradient-to-r ${gradient} shadow-2xl`}
      >
        {/* Inner frosted-glass card */}
        <div className="bg-white/40 backdrop-blur-lg rounded-xl p-8 text-center shadow-lg">
          <p className="text-black font-semibold text-lg">
            📱 Student signup is only available in the mobile application.
          </p>
          <p className="text-sm text-gray-800 mt-2">
            You will be redirected shortly...
          </p>
        </div>

        {/* Optional glow effect */}
        <div
          className={`absolute inset-0 rounded-xl pointer-events-none bg-gradient-to-r ${gradient} blur-2xl opacity-30`}
        ></div>
      </motion.div>
    </div>
  );
};
