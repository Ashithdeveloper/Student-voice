import React from "react";

export default function SurveyCard({ survey }) {
  return (
    <div className="border rounded font-serif p-4 shadow hover:shadow-lg transition">
      <h3 className="font-semibold text-lg">{survey.title}</h3>
      <p className="text-gray-600">{survey.description}</p>
    </div>
  );
}
