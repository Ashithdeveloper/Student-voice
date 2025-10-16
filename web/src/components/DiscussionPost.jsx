import { useState } from "react";
import { motion } from "framer-motion";
import { FaRegHeart, FaHeart } from "react-icons/fa";

export default function DiscussionPost({
  postId,
  user,
  text,
  time,
  onComment
}) {
  const displayName = user || "Anonymous";

  // Like toggle state
  const [liked, setLiked] = useState(false);
  const [likeCount, setLikeCount] = useState(0);

  const handleLike = () => {
    if (liked) {
      setLikeCount((prev) => prev - 1);
    } else {
      setLikeCount((prev) => prev + 1);
    }
    setLiked(!liked);
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
        <div className="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-700 font-bold">
          {displayName[0].toUpperCase()}
        </div>
        <div className="flex flex-col">
          <div className="font-semibold text-indigo-700">{displayName}</div>
          <div className="text-gray-400 text-xs">
            {time ? new Date(time).toLocaleString() : ""}
          </div>
        </div>
      </div>

      {/* Post Text */}
      <p className="text-gray-700 mb-3">{text}</p>

      {/* Actions */}
      <div className="flex gap-4 text-indigo-600 text-sm items-center">
        {/* Like Button */}
        <button
          onClick={handleLike}
          className={`flex items-center gap-1 px-2 py-1 rounded transition ${
            liked ? "bg-pink-100 text-pink-600" : "bg-indigo-100 hover:bg-indigo-200"
          }`}
        >
          {liked ? <FaHeart className="text-pink-500" /> : <FaRegHeart />}
          <span>{likeCount}</span>
        </button>

        {/* Comment Button */}
        {onComment && (
          <button
            onClick={onComment}
            className="px-2 py-1 bg-indigo-100 hover:bg-indigo-200 rounded flex items-center gap-1"
          >
            💬 <span>Comment</span>
          </button>
        )}
      </div>
    </motion.div>
  );
}
