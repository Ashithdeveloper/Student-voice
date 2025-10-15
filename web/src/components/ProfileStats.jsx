import React from "react";
import { useSelector } from "react-redux";
import { motion } from "framer-motion";

export default function ProfileStats() {
  const user = useSelector((state) => state.auth.user);

  if (!user) return null;

  const stats = [
    {
      label: "Surveys",
      value: user.surveysCompleted || 0,
      gradient: "from-indigo-100 via-purple-100 to-pink-100",
    },
    {
      label: "Discussions",
      value: user.discussionsJoined || 0,
      gradient: "from-green-100 via-teal-100 to-blue-100",
    },
    {
      label: "Events",
      value: user.eventsAttended || 0,
      gradient: "from-yellow-100 via-orange-100 to-red-100",
    },
    {
      label: "Points",
      value: user.points || 0,
      gradient: "from-pink-100 via-purple-100 to-indigo-100",
    },
  ];

  return (
    <div className="grid grid-cols-2 sm:grid-cols-2 md:grid-cols-4 gap-4 w-full max-w-5xl mx-auto">
      {stats.map((stat) => (
        <motion.div
          key={stat.label}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className={`p-4 rounded-2xl shadow-md bg-gradient-to-br ${stat.gradient} text-gray-800 flex flex-col items-center justify-center hover:scale-105 transition-transform`}
        >
          <p className="text-xl sm:text-2xl md:text-3xl font-extrabold">{stat.value}</p>
          <p className="text-xs sm:text-sm md:text-base mt-1">{stat.label}</p>
        </motion.div>
      ))}
    </div>
  );
}
