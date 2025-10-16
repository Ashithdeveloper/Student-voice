import React, { useEffect } from "react";
import { NavLink, useLocation, useNavigate } from "react-router-dom";
import { FaHome, FaSearch, FaUser, FaRobot, FaUsers } from "react-icons/fa";

export default function Navigation() {
  const location = useLocation();
  const navigate = useNavigate();

  const navItems = [
    { to: "/", label: "Home", icon: <FaHome /> },
    { to: "/search", label: "Search", icon: <FaSearch /> },
    { to: "/profile", label: "Profile", icon: <FaUser /> },
    { to: "/ai-mentor", label: "AI Mentor", icon: <FaRobot /> },
    { to: "/community", label: "Community", icon: <FaUsers /> },
  ];

  // Redirect to home on login or initial load
  useEffect(() => {
    if (location.pathname === "/login" || location.pathname === "/") {
      navigate("/", { replace: true });
    }
  }, [location.pathname, navigate]);

  return (
    <>
      {/* Desktop Sidebar */}
      <aside className="hidden md:flex flex-col fixed top-0 left-0 h-full w-60
        bg-gradient-to-b from-[#eef2ff] via-[#e0e7ff] to-[#f0f9ff]
        backdrop-blur-md shadow-xl border-r border-white/20 p-5">
        <div className="mb-8">
          <h1 className="text-2xl italic font-extrabold text-indigo-600 tracking-wide">
            StudentVoice
          </h1>
          <p className="text-sm text-indigo-400">Empower your journey</p>
        </div>

        <nav className="flex flex-col gap-2">
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end
              className={({ isActive }) =>
                `flex items-center gap-3 p-3 rounded-lg transition-all duration-300 
                 ${isActive
                   ? "bg-indigo-500 text-white shadow-md scale-[1.02]"
                   : "text-gray-600 hover:bg-indigo-100 hover:text-indigo-600"}`
              }
            >
              <span className="text-xl">{item.icon}</span>
              <span className="font-semibold">{item.label}</span>
            </NavLink>
          ))}
        </nav>

        <div className="mt-auto pt-6 text-center text-xs text-indigo-400 opacity-70">
          © {new Date().getFullYear()} Student Voice
        </div>
      </aside>

      {/* Mobile Navbar */}
      <nav className="fixed bottom-0 left-0 right-0 z-40 flex justify-around
        bg-gradient-to-r from-[#eef2ff] via-[#e0e7ff] to-[#f0f9ff]
        backdrop-blur-md shadow-t-md md:hidden py-2">
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end
            className={({ isActive }) =>
              `flex flex-col items-center text-xs transition-all
               ${isActive
                 ? "text-indigo-600 font-semibold"
                 : "text-gray-600 hover:text-indigo-600"}`
            }
          >
            <span className="text-lg">{item.icon}</span>
            <span>{item.label}</span>
          </NavLink>
        ))}
      </nav>

      {/* Spacer */}
      <div className="pt-0 md:ml-64 pb-16 md:pb-0"></div>
    </>
  );
}
