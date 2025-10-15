import React, { useEffect } from "react";
import { useSelector, useDispatch } from "react-redux";
import { fetchColleges } from "../slices/surveySlice";
import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";

export default function CollegeSurveyDashboard() {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const { colleges = [], loading = {} } = useSelector((state) => state.survey || {});
  const { user } = useSelector((state) => state.auth || {});

  useEffect(() => {
    dispatch(fetchColleges());
  }, [dispatch]);

  const handleViewResults = (college) =>
    navigate(`/analytics/${encodeURIComponent(college)}`);

  const handleTakeSurvey = (college) => {
    if (user?.role !== "viewer") {
      navigate(`/survey/${encodeURIComponent(college)}`);
    }
  };

  if (loading.colleges) {
    return (
      <p className="text-center mt-10 text-gray-500 animate-pulse text-lg">
        Loading colleges...
      </p>
    );
  }

  return (
    <div className="p-4 sm:p-6 md:p-10 space-y-6 max-w-6xl mx-auto">
      <h1 className="text-3xl sm:text-4xl font-extrabold text-indigo-600 text-center mb-6">
        🎓 College Surveys
      </h1>

      {colleges.length === 0 ? (
        <p className="text-center text-gray-500 text-lg">No colleges available.</p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {colleges.map((college, idx) => (
            <motion.div
              key={`${college}-${idx}`}
              whileHover={{ scale: 1.03 }}
              className="bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50 rounded-3xl shadow-xl p-6 flex flex-col justify-between transition-transform duration-300 relative"
            >
              <h3 className="text-xl sm:text-2xl font-semibold text-indigo-700 mb-4">
                {college}
              </h3>

              <div className="flex flex-wrap gap-3 mt-auto">
                <button
                  onClick={() => handleTakeSurvey(college)}
                  disabled={user?.role === "viewer"}
                  title={user?.role === "viewer" ? "Questions disabled for viewers" : ""}
                  className={`px-4 py-2 rounded-full font-medium transition ${
                    user?.role === "viewer"
                      ? "bg-gray-300 cursor-not-allowed text-gray-600 pointer-events-none"
                      : "bg-indigo-500 text-white hover:bg-indigo-600"
                  }`}
                >
                  Questions
                </button>
                <button
                  onClick={() => handleViewResults(college)}
                  className="px-4 py-2 rounded-full font-medium bg-green-500 text-white hover:bg-green-600 transition"
                >
                  Results
                </button>
              </div>

              {/* Badge for viewers */}
              {user?.role === "viewer" && (
                <span className="absolute top-3 right-3 bg-gray-200 text-gray-700 text-xs font-semibold px-2 py-1 rounded-full">
                  Viewer
                </span>
              )}
            </motion.div>
          ))}
        </div>
      )}
    </div>
  );
}
