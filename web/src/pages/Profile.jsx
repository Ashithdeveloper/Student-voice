import React, { useEffect } from "react";
import { useSelector, useDispatch } from "react-redux";
import { logout, fetchUserProfile } from "../slices/authSlice";
import ProfileStats from "../components/ProfileStats";
import { motion } from "framer-motion";
import { FaCheckCircle, FaTimesCircle, FaSignOutAlt } from "react-icons/fa";
import { toast } from "react-toastify";

export default function Profile() {
  const dispatch = useDispatch();
  const { user, token, loading } = useSelector((state) => state.auth);

  // Fetch user profile automatically if token exists and user is null
  useEffect(() => {
    if (token && !user) {
      dispatch(fetchUserProfile());
    }
  }, [token, user, dispatch]);

  const handleLogout = () => {
    dispatch(logout());
    toast.success("Logged out successfully!");
  };

  if (loading || !user) {
    return (
      <p className="text-center mt-10 text-gray-400 animate-pulse">
        Loading user data...
      </p>
    );
  }

  return (
    <div className="flex flex-col items-center gap-8 mt-10 px-4 sm:px-6 md:px-10 lg:px-0">
      {/* Profile Card */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="w-full max-w-md sm:max-w-lg md:max-w-xl lg:max-w-2xl bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50 p-6 sm:p-8 rounded-3xl shadow-2xl hover:shadow-3xl transition-shadow duration-500"
      >
        <div className="flex flex-col items-center gap-6 font-serif">
          {/* Name */}
          <h1 className="text-2xl sm:text-3xl font-extrabold text-indigo-600 text-center">
            {user.name || "Unnamed User"}
          </h1>

          {/* User Info Box */}
          <div className="w-full flex flex-col gap-3">
            <div className="flex flex-col sm:flex-row justify-between bg-white/50 p-3 rounded-lg shadow-sm">
              <span className="font-semibold text-gray-700">Role:</span>
              <span className="text-gray-900 capitalize">{user.role || "Viewer"}</span>
            </div>

            <div className="flex flex-col sm:flex-row justify-between bg-white/50 p-3 rounded-lg shadow-sm">
              <span className="font-semibold text-gray-700">Verification:</span>
              {user.isVerified ? (
                <span className="flex items-center gap-1 text-green-500 mt-1 sm:mt-0">
                  <FaCheckCircle /> Verified
                </span>
              ) : (
                <span className="flex items-center gap-1 text-red-500 mt-1 sm:mt-0">
                  <FaTimesCircle /> Not Verified
                </span>
              )}
            </div>

            <div className="flex flex-col sm:flex-row justify-between bg-white/50 p-3 rounded-lg shadow-sm">
              <span className="font-semibold text-gray-700">Email:</span>
              <span className="text-gray-900 mt-1 sm:mt-0">{user.email || "Not Provided"}</span>
            </div>

            <div className="flex flex-col sm:flex-row justify-between bg-white/50 p-3 rounded-lg shadow-sm">
              <span className="font-semibold text-gray-700">Last Login:</span>
              <span className="text-gray-900 mt-1 sm:mt-0">
                {user.lastLogin
                  ? new Date(user.lastLogin).toLocaleString()
                  : new Date(user.createdAt).toLocaleString()}
              </span>
            </div>
          </div>

          {/* Logout Button */}
          <button
            onClick={handleLogout}
            className="mt-4 px-6 py-2 w-full sm:w-auto bg-red-500 hover:bg-red-600 text-white rounded-full flex items-center justify-center gap-2 transition"
          >
            <FaSignOutAlt /> Logout
          </button>
        </div>
      </motion.div>

      {/* Profile Stats */}
      <ProfileStats />
    </div>
  );
}
