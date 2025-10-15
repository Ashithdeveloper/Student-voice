import React, { useEffect } from "react";
import { useSelector, useDispatch } from "react-redux";
import { useParams } from "react-router-dom";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  PieChart,
  Pie,
  Cell,
  Legend,
  ResponsiveContainer,
} from "recharts";
import { fetchCollegeAnalytics } from "../slices/analyticsSlice";

export default function CollegeAnalytics() {
  const { collegeId } = useParams();
  const dispatch = useDispatch();

  const { data: analyticsData, loading, error } = useSelector(
    (state) => state.collegeAnalytics
  );
  const report = analyticsData[collegeId];

  useEffect(() => {
    dispatch(fetchCollegeAnalytics(collegeId));
  }, [dispatch, collegeId]);

  if (loading)
    return (
      <p className="text-center mt-10 text-gray-500 animate-pulse">
        Loading...
      </p>
    );

  if (error)
    return <p className="text-center mt-10 text-red-500">{error}</p>;

  if (!report)
    return (
      <p className="text-center mt-10 text-gray-500">No report available</p>
    );

  const mental = report.mental_health || 0;
  const placement = report.placement_training || 0;
  const skill = report.skill_training || 0;
  const total = report.total_score_college || 0;
  const overall = report.overall_explanation || "No explanation available";

  let pieDataCategory = [
    { name: "Mental", value: mental },
    { name: "Placement", value: placement },
    { name: "Skill", value: skill },
  ];

  pieDataCategory = pieDataCategory.sort((a, b) => a.value - b.value);

  const COLORS_CATEGORY = ["#4F46E5", "#EF4444", "#10B981"];

  const barData = [
    { category: "Mental", value: mental, color: "#4F46E5" },
    { category: "Placement", value: placement, color: "#EF4444" },
    { category: "Skill", value: skill, color: "#10B981" },
    { category: "Total", value: total, color: "#8B5CF6" },
  ];

  return (
    <div className="min-h-screen font-serif bg-gray-50 p-6 md:p-12">
      <div className="text-center mb-12 px-4">
        <h1 className="text-2xl sm:text-3xl md:text-4xl font-extrabold text-indigo-600 leading-tight">
          📊 <span className="block">{collegeId}</span>
          <span className="text-base sm:text-lg text-gray-600 font-medium mt-2 block">
            Survey Analytics Overview
          </span>
        </h1>

        <div className="mt-4 flex flex-wrap justify-center gap-4 text-sm sm:text-base">
          <span className="bg-green-100 text-green-800 px-3 py-1 rounded-full shadow-sm">
            Placement: {placement}
          </span>
          <span className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full shadow-sm">
            Mental Health: {mental}
          </span>
          <span className="bg-yellow-100 text-yellow-800 px-3 py-1 rounded-full shadow-sm">
            Skill Training: {skill}
          </span>
          <span className="bg-purple-100 text-purple-800 px-3 py-1 rounded-full shadow-sm">
            Total Score: {total}
          </span>
        </div>
      </div>

      {/* Pie Chart */}
      <div className="bg-white rounded-3xl shadow-md p-6 border border-gray-200 flex flex-col items-center mb-12 w-full max-w-4xl mx-auto">
        <h2 className="text-xl font-semibold mb-6 text-gray-800">
          Category Overview
        </h2>
        <div className="h-64 w-full">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              {pieDataCategory.map((entry, index) => (
                <Pie
                  key={index}
                  data={[entry]}
                  dataKey="value"
                  nameKey="name"
                  cx="50%"
                  cy="50%"
                  innerRadius={20 + index * 25}
                  outerRadius={39 + index * 25}
                  startAngle={45}
                  endAngle={405}
                  cornerRadius={20}
                  fill={COLORS_CATEGORY[index]}
                  label={false}
                  labelLine={false}
                />
              ))}

              <Tooltip
                formatter={(value, name) => [`${value}`, `${name}`]}
                contentStyle={{
                  backgroundColor: "#f9f9f9",
                  borderRadius: 10,
                  border: "1px solid #E5E7EB",
                }}
              />
              <Legend verticalAlign="bottom" height={36} />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Bar Chart */}
      <div className="bg-white rounded-3xl shadow-md p-6 border border-gray-200 flex flex-col items-center mb-12 w-full max-w-4xl mx-auto">
        <h2 className="text-xl font-semibold mb-4 text-indigo-700">
          Category Comparison
        </h2>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={barData}>
            <XAxis dataKey="category" stroke="#4B5563" />
            <YAxis stroke="#4B5563" />
            <Tooltip
              contentStyle={{
                backgroundColor: "#f9f9f9",
                borderRadius: "10px",
                border: "1px solid #E5E7EB",
              }}
            />
            <Bar dataKey="value">
              {barData.map((entry, index) => (
                <Cell key={index} fill={entry.color} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Detailed Summary */}
      <div className="bg-indigo-50 p-6 rounded-2xl shadow-md max-w-4xl mx-auto">
        <h3 className="text-2xl font-semibold text-indigo-700 mb-4">
          Detailed Summary
        </h3>
        <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
          <li>Mental Health Score: {mental}</li>
          <li>Placement Training Score: {placement}</li>
          <li>Skill Training Score: {skill}</li>
          <li>Total College Score: {total}</li>
        </ul>
        <div className="mt-4">
          <h3 className="text-xl font-semibold text-indigo-700">
            Overall Explanation
          </h3>
          <p>{overall}</p>
        </div>
      </div>
    </div>
  );
}
