import React from "react";
import { useSelector } from "react-redux";
import { motion } from "framer-motion";

export default function ProfileStats() {
  const user = useSelector((state) => state.auth.user);
  if (!user) return null;

  // Dynamic stats
  const stats = [
    {
      label: "Surveys",
      value: user.surveysCompleted || 0,
      gradient: "from-indigo-400 via-purple-400 to-pink-400",
      icon: "📊",
    },
    {
      label: "Discussions",
      value: user.discussionsJoined || 0,
      gradient: "from-green-400 via-teal-400 to-blue-400",
      icon: "💬",
    },
    {
      label: "Points",
      value: user.points || 0,
      gradient: "from-pink-400 via-purple-400 to-indigo-400",
      icon: "⭐",
    },
  ];

  return (
    <div className="w-full flex justify-center mt-8">
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6 max-w-4xl">
        {stats.map((stat) => (
          <motion.div
            key={stat.label}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.1 }}
            className={`flex flex-col items-center justify-center p-6 rounded-3xl shadow-xl bg-gradient-to-br ${stat.gradient} text-white transform hover:scale-105 transition-transform`}
          >
            <div className="text-4xl mb-3">{stat.icon}</div>
            <p className="text-2xl sm:text-3xl md:text-4xl font-extrabold">
              {stat.value.toLocaleString()}
            </p>
            <p className="text-sm sm:text-base md:text-lg mt-1 tracking-wide">
              {stat.label}
            </p>
          </motion.div>
        ))}
      </div>
    </div>
  );
}
