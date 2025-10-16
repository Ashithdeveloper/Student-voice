import React, { useEffect, useRef } from "react";
import { useSelector } from "react-redux";
import { motion, useMotionValue, useTransform } from "framer-motion";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

// StatCard component (unchanged)
function StatCard({ label, value, icon, gradient, highlight, maxPoints }) {
  const motionValue = useMotionValue(0);
  const rounded = useTransform(motionValue, (latest) => Math.round(latest));

  useEffect(() => {
    motionValue.set(value);
  }, [value]);

  const filledStars = maxPoints ? Math.round((value / maxPoints) * 5) : 0;
  const stars = [];
  for (let i = 1; i <= 5; i++) {
    stars.push(
      <span key={i} className={`text-xl ${i <= filledStars ? "text-yellow-400" : "text-gray-300"}`}>★</span>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20, scale: 0.95 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{ duration: 0.6 }}
      className={`relative flex flex-col items-center justify-center p-5 sm:p-6 md:p-8 rounded-3xl shadow-2xl bg-gradient-to-br ${gradient} text-white transform hover:scale-105 transition-transform w-full`}
    >
      {highlight && (
        <div className="absolute top-0 left-0 w-full h-full bg-white/10 rounded-3xl pointer-events-none animate-pulse" />
      )}
      <div className="text-4xl sm:text-5xl md:text-6xl mb-2 sm:mb-3">{icon}</div>
      <motion.p className="text-2xl sm:text-3xl md:text-4xl font-extrabold">
        {rounded.get ? rounded.get().toLocaleString() : 0}
      </motion.p>
      <div className="flex gap-1 mt-2">{stars}</div>
      <p className="text-sm sm:text-base md:text-lg mt-1 sm:mt-2 tracking-wide text-center">{label}</p>
    </motion.div>
  );
}

export default function ProfileStats() {
  const user = useSelector((state) => state.auth.user);
  const discussions = useSelector((state) => state.app.discussions) || [];
  const surveys = useSelector((state) => state.app.surveys) || [];
  const points = useSelector((state) => state.points.pointsData) || {};

  const prevPointsRef = useRef({}); // track previous points to prevent duplicate toasts

  if (!user) return <p className="text-center mt-8 text-gray-500">Loading profile...</p>;

  // Points calculation
  const surveyPoints = surveys.filter((s) => s.completedBy?.includes(user._id)).length;
  const discussionPoints = discussions.filter((d) => d.likes?.includes(user._id)).length;
  const aiPoints = points.aiUsage || 0;

  const today = new Date().toDateString();
  const lastLogin = points.lastLoginDate || null;
  const dailyLoginPoints = lastLogin === today ? points.dailyLogin || 0 : 1;

  // Total points
  const totalPoints = surveyPoints + discussionPoints + aiPoints + dailyLoginPoints;

  const stats = [
    { label: "Surveys Completed", value: surveyPoints },
    { label: "Community Interaction", value: discussionPoints },
    { label: "Mentor AI Usage", value: aiPoints },
    { label: "Daily Login", value: dailyLoginPoints },
  ];

  // Toast only when a point actually increased
  useEffect(() => {
    stats.forEach((stat) => {
      const prevValue = prevPointsRef.current[stat.label] || 0;
      if (stat.value > prevValue) {
        toast.info(`You gained points in ${stat.label}! 🎉`);
      }
      prevPointsRef.current[stat.label] = stat.value;
    });
  }, [surveyPoints, discussionPoints, aiPoints, dailyLoginPoints]);

  return (
    <div className="w-full flex flex-col items-center px-4 sm:px-6 md:px-0 mt-8">
      <div className="w-full max-w-6xl mb-6">
        <StatCard
          label="Total Points"
          value={totalPoints}
          gradient="from-pink-400 via-purple-400 to-indigo-400"
          icon="⭐"
          highlight={false}
          maxPoints={200}
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 md:gap-8 max-w-6xl w-full">
        {stats.map((stat) => (
          <StatCard key={stat.label} {...stat} gradient={
            stat.label === "Daily Login"
              ? "from-yellow-400 via-orange-400 to-red-400"
              : stat.label === "Mentor AI Usage"
              ? "from-purple-400 via-pink-400 to-indigo-400"
              : stat.label === "Community Interaction"
              ? "from-green-400 via-teal-400 to-blue-400"
              : "from-indigo-400 via-purple-400 to-pink-400"
          } icon={
            stat.label === "Daily Login"
              ? "⏰"
              : stat.label === "Mentor AI Usage"
              ? "🤖"
              : stat.label === "Community Interaction"
              ? "💬"
              : "📊"
          } highlight={stat.label !== "Mentor AI Usage" && stat.label !== "Daily Login"} maxPoints={50} />
        ))}
      </div>

      <ToastContainer position="top-center" autoClose={1500} hideProgressBar />
    </div>
  );
}
