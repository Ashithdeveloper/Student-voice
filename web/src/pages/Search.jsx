import React, { useState } from "react";
import { FaSearch, FaFilter } from "react-icons/fa";

export default function Search() {
  const [query, setQuery] = useState("");
  const [filters, setFilters] = useState({
    type: "All",
    date: "Anytime",
  });
  const [isExpanded, setIsExpanded] = useState(false);

  const handleSearch = (e) => {
    e.preventDefault();
    // Expand the search and hide other row content
    setIsExpanded(true);

    // TODO: Replace with API call or Redux dispatch
    console.log("Searching for:", query, "with filters:", filters);
  };

  const handleReset = () => {
    setIsExpanded(false);
    setQuery("");
    setFilters({ type: "All", date: "Anytime" });
  };

  return (
    <div className="flex font-serif flex-col gap-6 w-full max-w-3xl mx-auto">
      <h1 className="text-3xl md:text-4xl font-extrabold text-indigo-600 text-center">
        Search
      </h1>

      {/* Search Form */}
      <form
        onSubmit={handleSearch}
        className={`flex flex-col md:flex-row gap-4 items-center bg-white/60 backdrop-blur-lg p-4 rounded-2xl shadow-md transition-all duration-300 ${
          isExpanded ? "md:flex-col md:items-stretch" : ""
        }`}
      >
        {/* Input */}
        <div
          className={`relative w-full transition-all duration-300 ${
            isExpanded ? "md:w-full" : "md:flex-1"
          }`}
        >
          <FaSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-indigo-400"
            onFocus={() => setIsExpanded(true)}
          />
        </div>

        {/* Filters - hide when expanded for simplicity */}
        {!isExpanded && (
          <div className="flex gap-2">
            <select
              value={filters.type}
              onChange={(e) => setFilters({ ...filters, type: e.target.value })}
              className="px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-indigo-400"
            >
              <option>All</option>
              <option>Surveys</option>
              <option>Discussions</option>
              <option>Events</option>
            </select>

            <select
              value={filters.date}
              onChange={(e) => setFilters({ ...filters, date: e.target.value })}
              className="px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-indigo-400"
            >
              <option>Anytime</option>
              <option>Last 24 hours</option>
              <option>Last 7 days</option>
              <option>Last 30 days</option>
            </select>
          </div>
        )}

        {/* Action Button */}
        <div className="flex gap-2 md:w-full">
          {isExpanded && (
            <button
              type="button"
              onClick={handleReset}
              className="bg-gray-300 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-400 transition-all flex-1"
            >
              Reset
            </button>
          )}
          <button
            type="submit"
            className="bg-indigo-500 text-white px-4 py-2 rounded-lg hover:bg-indigo-600 transition-all flex-1"
          >
            <FaFilter className="inline mr-2" />
            {isExpanded ? "Apply Filters" : "Search"}
          </button>
        </div>
      </form>

      {/* Results Section */}
      {isExpanded && (
        <div className="bg-white/60 backdrop-blur-lg p-4 rounded-2xl shadow-md mt-4 transition-all duration-300">
          <p className="text-gray-500">Results will appear here...</p>
        </div>
      )}
    </div>
  );
}
