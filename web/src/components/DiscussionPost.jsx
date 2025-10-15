import { useState } from "react";
import { motion } from "framer-motion";

export default function DiscussionPost({
  user,
  time,
  text,
  initialLikes = 0,
  comments = [],
  showComments = false,
  onToggleComments,
  onLike,
  onAddComment,
}) {
  const [likes, setLikes] = useState(initialLikes);
  const [commentText, setCommentText] = useState("");

  const handleLike = () => {
    setLikes((prev) => prev + 1);
    onLike && onLike();
  };

  const handleSubmitComment = (e) => {
    e.preventDefault();
    if (!commentText.trim()) return;
    onAddComment && onAddComment(commentText);
    setCommentText("");
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: 10 }}
      className="mb-5 p-5 rounded-2xl bg-white border border-indigo-100 shadow-md hover:shadow-lg transition-all"
    >
      {/* Header */}
      <div className="flex justify-between items-center mb-3">
        <div className="font-semibold text-indigo-700 text-lg">{user}</div>
        <div className="text-xs text-gray-400">{time}</div>
      </div>

      {/* Content */}
      <p className="text-gray-700 text-sm md:text-base mb-4">{text}</p>

      {/* Actions */}
      <div className="flex gap-4 text-sm font-medium text-indigo-600 mb-3">
        <button
          onClick={handleLike}
          className="px-3 py-1 bg-indigo-100 hover:bg-indigo-200 rounded-full transition"
        >
          👍 Like ({likes})
        </button>
        <button
          onClick={onToggleComments}
          className="px-3 py-1 bg-indigo-100 hover:bg-indigo-200 rounded-full transition"
        >
          💬 {showComments ? "Hide Comments" : `Comments (${comments.length})`}
        </button>
      </div>

      {/* Comments */}
      {showComments && (
        <div className="mt-3 space-y-3">
          {comments.length === 0 && (
            <p className="text-gray-400 text-sm italic">No comments yet.</p>
          )}
          {comments.map((c, idx) => (
            <div
              key={idx}
              className="p-2 rounded-lg bg-indigo-50 text-indigo-800 text-sm md:text-base"
            >
              {c.text || c}
            </div>
          ))}

          <form onSubmit={handleSubmitComment} className="flex gap-2 mt-2">
            <input
              type="text"
              value={commentText}
              onChange={(e) => setCommentText(e.target.value)}
              placeholder="Write a comment..."
              className="flex-1 p-2 rounded-2xl border border-indigo-200 focus:outline-none focus:ring-2 focus:ring-indigo-300 text-sm md:text-base"
            />
            <button
              type="submit"
              className="px-4 py-1 bg-indigo-600 text-white rounded-2xl hover:bg-indigo-700 transition-all text-sm md:text-base font-semibold"
            >
              Post
            </button>
          </form>
        </div>
      )}
    </motion.div>
  );
}