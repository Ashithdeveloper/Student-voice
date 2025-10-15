import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { useSelector } from "react-redux";
import Navigation from "./components/Navigation"; 
import Login from "./login/Login";
import SignUp from "./login/SignUp";
import Home from "./pages/Home";
import Community from "./pages/Community";
import Surveys from "./pages/Surveys";
import Profile from "./pages/Profile";
import AIMentor from "./pages/AIMentor";
import Analytics from "./pages/Analytics";
import { MobileSignUpNotice } from "./pages/MobileSignupNotice";
import Search from "./pages/Search";
import { ToastContainer } from "react-toastify";

export default function App() {
  const auth = useSelector((state) => state.auth);
  const isAuthenticated = !!auth?.token; 
  const userRole = auth?.user?.role;

  return (
    <BrowserRouter>
      <div className="flex min-h-screen bg-gray-50 relative">
        {/* Sidebar for desktop / bottom navbar for mobile */}
        {isAuthenticated && <Navigation />}

        {/* Main content */}
        <main
          className={`flex-1 p-4 md:p-6 ${
            isAuthenticated ? "" : "flex justify-center items-center"
          }`}
        >
          {/* Toast notifications */}
          <ToastContainer
            position="top-center"
            autoClose={1000}
            hideProgressBar
            toastClassName={({ type }) =>
              `backdrop-blur-md border rounded-md p-3 m-2 shadow-lg max-w-lg w-full ` +
              (type === "error"
                ? "bg-red-600/40 border-red-400"
                : type === "success"
                ? "bg-green-600/40 border-green-400"
                : "bg-blue-600/40 border-gray-200")
            }
            bodyClassName={({ type }) =>
              type === "error" || type === "success" ? "text-white p-3" : "text-black p-3"
            }
          />

          <Routes>
            <Route
              path="/login"
              element={isAuthenticated ? <Navigate to="/home" /> : <Login />}
            />
            <Route
              path="/signup"
              element={isAuthenticated ? <Navigate to="/home" /> : <SignUp />}
            />
            <Route path="/mobilesignupnotice" element={<MobileSignUpNotice />} />
            {isAuthenticated ? (
              <>
                <Route path="/home" element={<Home />} />
                <Route path="/community" element={<Community />} />
                <Route path="/surveys" element={<Surveys />} />
                <Route path="/profile" element={<Profile />} />
                <Route path="/ai-mentor" element={<AIMentor />} />
                <Route path="/analytics/:collegeId" element={<Analytics />} />
                <Route path="/search" element={<Search />} />
              </>
            ) : (
              <Route path="*" element={<Navigate to="/login" />} />
            )}
            <Route
              path="*"
              element={<Navigate to={isAuthenticated ? "/home" : "/login"} />}
            />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}
