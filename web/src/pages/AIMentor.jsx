import React from "react";
import MentorPanel from "../components/MentorPanel";

export default function AIMentor() {
  return (
    <div className="p-6 md:p-10 font-serif bg-gradient-to-r from-indigo-50 via-purple-50 to-pink-50 min-h-screen">
      <h1 className="text-3xl md:text-4xl font-extrabold text-indigo-700 mb-8 text-center">
        AI Mentor
      </h1>
      <div className="max-w-3xl mx-auto">
        <MentorPanel />
      </div>
    </div>
  );
}
