import { useState } from "react";
import { motion } from "framer-motion";

export default function DiscussionPost({ user, time, text }){
  const [likes, setLikes] = useState(0);
  const [showCommentBox, setShowCommentBox] = useState(false);
  const [comment, setComment] = useState("");

  const handleLike = () => setLikes(prev => prev + 1);

  const handleCommentSubmit = e => {
    e.preventDefault();
    if (comment.trim()) {
      console.log(`Comment submitted: ${comment}`);
      setComment("");
      setShowCommentBox(false);
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: 10 }}
      className="mb-4 p-5 rounded-2xl bg-white/60 backdrop-blur-md border border-white/30 shadow-lg hover:shadow-xl transition-all"
    >
      {/* Header */}
      <div className="flex justify-between items-center mb-3">
        <div className="font-semibold text-gray-800">{user}</div>
        <div className="text-xs text-gray-500">{time}</div>
      </div>

      {/* Content */}
      <p className="text-gray-700 mb-4">{text}</p>

      {/* Actions */}
      <div className="flex space-x-6 text-sm font-medium text-blue-600">
        <button
          onClick={handleLike}
          className="flex items-center gap-1 hover:text-blue-800 transition-colors"
        >
          👍 Like ({likes})
        </button>
        <button
          onClick={() => setShowCommentBox(prev => !prev)}
          className="flex items-center gap-1 hover:text-blue-800 transition-colors"
        >
          💬 Comment
        </button>
      </div>

      {/* Comment Box */}
      {showCommentBox && (
        <form onSubmit={handleCommentSubmit} className="mt-4 space-y-2">
          <textarea
            value={comment}
            onChange={e => setComment(e.target.value)}
            placeholder="Write a comment..."
            className="w-full p-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-200 resize-none text-sm bg-white/70 backdrop-blur-sm"
            rows={3}
          />
          <button
            type="submit"
            className="px-5 py-2 bg-gradient-to-r from-blue-400 to-blue-600 text-white rounded-xl shadow-md hover:shadow-lg transition-all text-sm font-semibold"
          >
            Post Comment
          </button>
        </form>
      )}
    </motion.div>
  );
};
