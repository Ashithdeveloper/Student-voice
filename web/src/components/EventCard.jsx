import React from "react";

export default function EventCard({ event }) {
  return (
    <div className="border rounded p-4 shadow hover:shadow-lg transition">
      <h3 className="font-semibold text-lg">{event.name}</h3>
      <p className="text-gray-500">{new Date(event.date).toLocaleDateString()}</p>
      <p className="text-gray-600">{event.description}</p>
    </div>
  );
}
