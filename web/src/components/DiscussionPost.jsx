import { motion } from "framer-motion";
import { FaRegHeart, FaHeart } from "react-icons/fa";
import { useDispatch } from "react-redux";
import { toggleLike } from "../slices/appSlice";
import { useState, useMemo } from "react";

export default function DiscussionPost({
  postId,
  user,
  text,
  time,
  likes = [],
  commentCount = 0,
  currentUserId,
  onComment,
}) {
  const dispatch = useDispatch();

  // Safely get display name
  const displayName = (typeof user === "string" ? user : user?.name) || "Anonymous";

  // Local state for optimistic like updates
  const [optimisticLikes, setOptimisticLikes] = useState(null);

  // If no optimistic state, fallback to prop likes
  const displayedLikes = optimisticLikes ?? likes;

  // Determine if current user has liked
  const hasLiked = useMemo(
    () => currentUserId && displayedLikes.includes(currentUserId),
    [currentUserId, displayedLikes]
  );

  const handleLike = () => {
    if (!currentUserId) return;

    // Optimistic UI update
    setOptimisticLikes(
      hasLiked
        ? displayedLikes.filter((id) => id !== currentUserId)
        : [...displayedLikes, currentUserId]
    );

    // Update backend
    dispatch(toggleLike(postId));
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 15 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: 15 }}
      className="max-w-full p-4 rounded-2xl shadow-md border bg-white/80 border-indigo-200"
    >
      {/* User Info */}
      <div className="flex items-center gap-2 mb-2">
        <div
          className={`w-10 h-10 rounded-full flex items-center justify-center font-bold ${
            hasLiked ? "bg-pink-100 text-pink-600" : "bg-indigo-100 text-indigo-700"
          }`}
        >
          {displayName[0]?.toUpperCase()}
        </div>
        <div className="flex flex-col">
          <div className="font-semibold text-indigo-700">{displayName}</div>

          {/* ✔ Participated if user liked/joined */}
          {currentUserId && likes.includes(currentUserId) && (
            <div className="text-xs text-green-600">✔ Participated</div>
          )}

          <div className="text-gray-400 text-xs">
            {time ? new Date(time).toLocaleString() : ""}
          </div>
        </div>
      </div>

      {/* Post Text */}
      <p className="text-gray-700 mb-3">{text}</p>

      {/* Actions */}
      <div className="flex gap-4 text-sm items-center">
        {/* Like Button */}
        <button
          onClick={handleLike}
          className={`flex items-center gap-1 px-2 py-1 rounded transition ${
            hasLiked
              ? "bg-pink-100 text-pink-600 hover:bg-pink-200"
              : "bg-indigo-100 text-indigo-600 hover:bg-indigo-200"
          }`}
        >
          {hasLiked ? <FaHeart className="text-pink-500" /> : <FaRegHeart />}
          <span>{displayedLikes.length}</span>
        </button>

        {/* Comment Button */}
        {onComment && (
          <button
            onClick={onComment}
            className="px-2 py-1 bg-indigo-100 hover:bg-indigo-200 rounded flex items-center gap-1 text-indigo-600"
          >
            💬 <span>{commentCount} Comment{commentCount !== 1 ? "s" : ""}</span>
          </button>
        )}
      </div>
    </motion.div>
  );
}
