import React, { useState, useEffect } from "react";
import { useSelector, useDispatch } from "react-redux";
import { fetchColleges } from "../slices/surveySlice";
import { FaSearch } from "react-icons/fa";

export default function CollegeSearch() {
  const dispatch = useDispatch();
  const { colleges = [], loading = {} } = useSelector((state) => state.survey || {});

  const [query, setQuery] = useState("");
  const [filters, setFilters] = useState({ type: "All", date: "Anytime" });
  const [results, setResults] = useState([]);

  useEffect(() => {
    dispatch(fetchColleges());
  }, [dispatch]);

  useEffect(() => {
    if (!colleges || colleges.length === 0) return setResults([]);

    const filtered = colleges.filter((item) => {
      const displayName = (
        item?.collegename || item?.name || item?.title || item?.label || ""
      ).toLowerCase();
      const itemType = (item?.type || "other").toLowerCase();
      const itemDate = item?.date ? new Date(item.date) : null;

      // Check query match
      const matchesQuery = displayName.includes(query.toLowerCase());

      // Check type filter
      const filterType = filters.type.toLowerCase();
      const matchesType = filterType === "all" ? true : itemType === filterType;

      // Check date filter
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

    setResults(filtered);
  }, [colleges, query, filters]);

  const handleReset = () => {
    setQuery("");
    setFilters({ type: "All", date: "Anytime" });
    setResults(colleges);
  };

  return (
    <div className="flex flex-col gap-6 w-full max-w-6xl mx-auto p-4 font-serif">
      <h1 className="text-3xl md:text-4xl font-extrabold text-indigo-600 text-center">
        Search Colleges, Surveys, and Events
      </h1>

      {/* Search & Filters */}
      <div className="flex flex-col md:flex-wrap md:flex-row gap-4 items-center bg-white/80 backdrop-blur-lg p-4 rounded-2xl shadow-md">
        <div className="relative w-full md:flex-1">
          <FaSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search by name..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-indigo-400"
          />
        </div>

        <select
          value={filters.type}
          onChange={(e) => setFilters({ ...filters, type: e.target.value })}
          className="w-full md:w-auto px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-indigo-400"
        >
          <option>All</option>
          <option>College</option>
          <option>Survey</option>
          <option>Discussion</option>
          <option>Event</option>
        </select>

        <select
          value={filters.date}
          onChange={(e) => setFilters({ ...filters, date: e.target.value })}
          className="w-full md:w-auto px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-indigo-400"
        >
          <option>Anytime</option>
          <option>Last 24 hours</option>
          <option>Last 7 days</option>
          <option>Last 30 days</option>
          <option>Last 90 days</option>
        </select>

        <button
          onClick={handleReset}
          className="bg-gray-300 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-400 transition-all mt-2 md:mt-0"
        >
          Reset
        </button>
      </div>

      {/* Results */}
      <div className="bg-white/60 backdrop-blur-lg p-4 rounded-2xl shadow-md mt-4 transition-all duration-300">
        {loading.colleges ? (
          <p className="text-center text-gray-500 animate-pulse">Loading data...</p>
        ) : results.length === 0 ? (
          <p className="text-center text-gray-500 italic text-lg">
            No results found. Try another keyword or adjust filters.
          </p>
        ) : (
           <div className="text-center text-gray-500 text-lg p-4 bg-indigo-50/50 rounded-lg shadow-md">
                No search has been performed yet. Please enter a query to see results.
            </div>
        )}
      </div>
    </div>
  );
}
