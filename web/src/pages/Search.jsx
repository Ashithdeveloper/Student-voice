import React, { useState, useEffect, useMemo } from "react";
import { useSelector, useDispatch } from "react-redux";
import { fetchColleges } from "../slices/surveySlice";
import { FaSearch } from "react-icons/fa";

export default function CollegeSearch() {
  const dispatch = useDispatch();
  const { colleges = [], loading = {} } = useSelector((state) => state.survey || {});

  const [query, setQuery] = useState("");
  const [filters, setFilters] = useState({ type: "All", date: "Anytime" });

  // Fetch colleges once
  useEffect(() => {
    dispatch(fetchColleges());
  }, [dispatch]);

  // Filtered results
  const results = useMemo(() => {
    if (!colleges || colleges.length === 0) return [];

    return colleges.filter((item) => {
      const name = (item?.collegename || item?.name || "").toLowerCase();
      const type = (item?.type || "other").toLowerCase();
      const itemDate = item?.date ? new Date(item.date) : null;

      // Query filter
      const matchesQuery = name.includes(query.toLowerCase());

      // Type filter
      const matchesType = filters.type === "All" ? true : type === filters.type.toLowerCase();

      // Date filter
      let matchesDate = true;
      if (filters.date !== "Anytime" && itemDate) {
        const today = new Date();
        let days = 0;
        if (filters.date === "Last 24 hours") days = 1;
        else if (filters.date === "Last 7 days") days = 7;
        else if (filters.date === "Last 30 days") days = 30;
        else if (filters.date === "Last 90 days") days = 90;

        const pastDate = new Date(today.getTime() - days * 24 * 60 * 60 * 1000);
        matchesDate = itemDate >= pastDate;
      }

      return matchesQuery && matchesType && matchesDate;
    });
  }, [colleges, query, filters]);

  const handleReset = () => {
    setQuery("");
    setFilters({ type: "All", date: "Anytime" });
  };

  return (
    <div className="flex flex-col font-serif gap-6 w-full max-w-7xl mx-auto p-4">
      <h1 className="text-3xl sm:text-4xl font-extrabold text-indigo-600 text-center">
        Search Colleges, Surveys, and Discussions
      </h1>

      {/* Search & Filters */}
      <div className="flex flex-col sm:flex-row flex-wrap gap-3 items-center bg-white/80 backdrop-blur-lg p-4 rounded-2xl shadow-md">
        {/* Search Input */}
        <div className="relative flex-1 w-full sm:w-auto">
          <FaSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search by name..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-indigo-400 transition"
          />
        </div>

        {/* Type Filter */}
        <select
          value={filters.type}
          onChange={(e) => setFilters({ ...filters, type: e.target.value })}
          className="w-full sm:w-auto px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-indigo-400 transition"
        >
          <option>All</option>
          <option>College</option>
          <option>Survey</option>
          <option>Discussion</option>
        </select>

        {/* Date Filter */}
        <select
          value={filters.date}
          onChange={(e) => setFilters({ ...filters, date: e.target.value })}
          className="w-full sm:w-auto px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-indigo-400 transition"
        >
          <option>Anytime</option>
          <option>Last 24 hours</option>
          <option>Last 7 days</option>
          <option>Last 30 days</option>
          <option>Last 90 days</option>
        </select>

        <button
          onClick={handleReset}
          className="bg-gray-300 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-400 transition-all mt-2 sm:mt-0"
        >
          Reset
        </button>
      </div>

      {/* Results */}
      <div className="bg-white/70 backdrop-blur-lg p-4 rounded-2xl shadow-md mt-4 transition-all duration-300 min-h-[150px]">
        {loading.colleges ? (
          <p className="text-center text-gray-500 animate-pulse">Loading data...</p>
        ) : query === "" ? (
          <p className="text-center text-gray-500 text-lg">
            Start typing to see results.
          </p>
        ) : results.length === 0 ? (
          <p className="text-center text-gray-500 italic text-lg">
            No results found. Try another keyword or adjust filters.
          </p>
        ) : (
          <ul className="divide-y divide-gray-200">
            {results.map((item) => (
              <li
                key={item._id || item.id || item.name}
                className="py-3 px-3 hover:bg-indigo-50 rounded-lg transition-all flex flex-col sm:flex-row sm:justify-between sm:items-center"
              >
                <div className="font-semibold text-indigo-700 text-sm sm:text-base">
                  {item.collegename || item.name || "Unnamed"}
                </div>
                <div className="flex gap-4 mt-1 sm:mt-0 text-gray-500 text-xs sm:text-sm flex-wrap">
                  {item.type && <span className="capitalize">{item.type}</span>}
                  {item.date && <span>{new Date(item.date).toLocaleDateString()}</span>}
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
