import { useEffect, useState, useRef } from "react";
import { useDispatch, useSelector } from "react-redux";
import { addComment, fetchComments } from "../slices/appSlice";
import { motion, AnimatePresence } from "framer-motion";
import { X } from "lucide-react";

export default function CommentModal({ postId, onClose }) {
  const dispatch = useDispatch();
  const comments = useSelector((state) => state.app.comments[postId] || []);
  const user = useSelector((state) => state.app.user);

  const [newComment, setNewComment] = useState("");
  const inputRef = useRef(null);

  // Fetch comments when modal opens
  useEffect(() => {
    if (postId) {
      dispatch(fetchComments(postId));
    }
  }, [dispatch, postId]);

  // Handle submitting a new comment
  const handleAddComment = () => {
    if (!newComment.trim()) return;
    dispatch(addComment({ postId, text: newComment }));
    setNewComment("");
    inputRef.current?.focus();
  };

  return (
    <motion.div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
    >
      <motion.div
        className="bg-white max-w-lg w-full mx-4 rounded-2xl shadow-lg p-5 relative flex flex-col max-h-[80vh]"
        initial={{ y: 30 }}
        animate={{ y: 0 }}
        exit={{ y: 30 }}
      >
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-3 right-3 text-gray-500 hover:text-gray-700"
        >
          <X size={20} />
        </button>

        <h2 className="text-xl font-semibold text-indigo-700 mb-4">
          💬 Comments
        </h2>

        {/* Comment List */}
        <div className="flex-1 overflow-y-auto mb-4 pr-2">
          <AnimatePresence>
            {comments.length > 0 ? (
              comments.map((c) => (
                <motion.div
                  key={c._id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="border-b border-gray-200 py-2 flex gap-3"
                >
                  <div className="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center font-bold text-indigo-700">
                    {c.user?.name?.[0]?.toUpperCase() || "A"}
                  </div>
                  <div>
                    <div className="font-semibold text-indigo-700">
                      {c.user?.name || "Anonymous"}
                    </div>
                    <div className="text-sm text-gray-600">{c.text}</div>
                    <div className="text-xs text-gray-400">
                      {new Date(c.createdAt).toLocaleString()}
                    </div>
                  </div>
                </motion.div>
              ))
            ) : (
              <div className="text-gray-400 text-center py-4">
                No comments yet. Be the first!
              </div>
            )}
          </AnimatePresence>
        </div>

        {/* Input Box */}
        <div className="flex items-center gap-2">
          <input
            ref={inputRef}
            type="text"
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
            placeholder="Write a comment..."
            className="flex-1 border rounded-full px-4 py-2 outline-none focus:ring-2 focus:ring-indigo-300"
          />
          <button
            onClick={handleAddComment}
            className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-full"
          >
            Send
          </button>
        </div>
      </motion.div>
    </motion.div>
  );
}
