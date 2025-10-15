import React, { useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { askAI } from "../slices/appSlice";
import { motion, AnimatePresence } from "framer-motion";

export default function MentorPanel() {
  const [question, setQuestion] = useState("");
  const dispatch = useDispatch();

  const answer = useSelector((state) => state.app.aiResponse);
  const userRole = useSelector((state) => state.auth.user?.role); // assuming role is stored in auth slice

  const isViewer = userRole === "viewer"; // adjust based on your role naming

  const handleAsk = () => {
    if (!isViewer && question.trim()) {
      dispatch(askAI(question));
      setQuestion("");
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6 }}
      className="bg-white/60 font-serif backdrop-blur-md rounded-3xl shadow-2xl p-6 md:p-8 border border-indigo-100"
    >
      <h3 className="text-xl md:text-2xl font-bold text-indigo-600 mb-4 text-center">
        Ask Your AI Mentor
      </h3>

      <textarea
        value={question}
        onChange={(e) => setQuestion(e.target.value)}
        placeholder={isViewer ? "AI Mentor is disabled for your account." : "Type your question here..."}
        className={`w-full p-4 rounded-xl border focus:ring-2 focus:outline-none resize-none mb-4 transition shadow-sm hover:shadow-md 
          ${isViewer ? "bg-gray-100 cursor-not-allowed" : "border-gray-200 focus:ring-indigo-300"}`}
        rows={4}
        disabled={isViewer}
      />

      <button
        onClick={handleAsk}
        disabled={isViewer}
        className={`w-full py-3 rounded-2xl font-semibold transition-transform shadow-lg hover:shadow-xl
          ${isViewer 
            ? "bg-gray-300 text-gray-500 cursor-not-allowed" 
            : "bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 text-white hover:scale-105"}`}
      >
        Ask
      </button>

      <AnimatePresence>
        {answer && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 10 }}
            transition={{ duration: 0.4 }}
            className="mt-6 p-4 bg-indigo-50/80 rounded-xl shadow-inner border-l-4 border-indigo-500 text-gray-800 font-medium text-sm md:text-base"
          >
            {answer}
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
