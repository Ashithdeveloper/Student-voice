import React, { useEffect, useMemo } from "react";
import { useSelector, useDispatch } from "react-redux";
import { fetchColleges } from "../slices/surveySlice";
import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import { useViewer } from "../hooks/useViewer"; // centralized hook

export default function CollegeSurveyDashboard() {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { colleges = [], loading = {} } = useSelector((state) => state.survey || {});
  const isViewer = useViewer(); 

  useEffect(() => {
    dispatch(fetchColleges());
  }, [dispatch]);

  const uniqueColleges = useMemo(() => {
    const seen = new Set();
    return colleges.filter((college) => {
      const lower = college.toLowerCase();
      if (seen.has(lower)) return false;
      seen.add(lower);
      return true;
    });
  }, [colleges]);

  const handleTakeSurvey = (college) => {
    if (!isViewer) navigate(`/survey/${encodeURIComponent(college)}`);
  };

  const handleViewResults = (college) => navigate(`/analytics/${encodeURIComponent(college)}`);

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <h1 className="text-3xl font-extrabold text-indigo-600 text-center mb-6">
        🎓 College Surveys
      </h1>

      {loading.colleges ? (
        <p className="text-center text-gray-500 animate-pulse">Loading colleges...</p>
      ) : uniqueColleges.length === 0 ? (
        <p className="text-center text-gray-500">No colleges available.</p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {uniqueColleges.map((college, idx) => (
            <motion.div
              key={college}
              whileHover={{ scale: 1.03 }}
              className="bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50 rounded-3xl shadow-xl p-6 flex flex-col justify-between relative"
            >
              <h3 className="text-xl font-semibold text-indigo-700 mb-4">{college}</h3>

              <div className="flex flex-wrap gap-3 mt-auto">
                <button
                  onClick={() => handleTakeSurvey(college)}
                  disabled={isViewer}
                  className={`px-4 py-2 rounded-full font-medium transition ${
                    isViewer
                      ? "bg-gray-300 cursor-not-allowed text-gray-600 pointer-events-none"
                      : "bg-indigo-500 text-white hover:bg-indigo-600"
                  }`}
                  title={isViewer ? "Questions disabled for viewers" : ""}
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

              {isViewer && (
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
