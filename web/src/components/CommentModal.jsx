import React, { useEffect, useState } from "react";
import { useSelector, useDispatch } from "react-redux";
import {
  fetchComments,
  addComment,
  selectCommentsByPost,
  addTempComment,
} from "../slices/appSlice";
import { v4 as uuidv4 } from "uuid";

export default function CommentModal({ postId, onClose }) {
  const dispatch = useDispatch();
  const comments = useSelector((state) => selectCommentsByPost(state, postId));
  const [newComment, setNewComment] = useState("");
  const [loading, setLoading] = useState(false);

  // Fetch comments when modal opens
  useEffect(() => {
    if (postId) {
      dispatch(fetchComments(postId));
    }
  }, [dispatch, postId]);

  const handleAddComment = async () => {
    if (!newComment.trim()) return;

    // Optimistic UI: temporary comment
    const tempId = `temp-${uuidv4()}`;
    const tempComment = {
      _id: tempId,
      user: { name: "You", verified: true },
      text: newComment,
      time: new Date().toISOString(),
    };
    dispatch(addTempComment({ postId, comment: tempComment }));
    setNewComment("");

    try {
      setLoading(true);
      await dispatch(addComment({ postId, comment: tempComment.text })).unwrap();
    } catch (err) {
      console.error("Failed to add comment:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl shadow-lg p-6 w-full max-w-lg relative flex flex-col">
        <button
          className="absolute top-2 right-2 text-gray-500 hover:text-gray-700"
          onClick={onClose}
        >
          ✖
        </button>

        <h2 className="text-xl font-semibold mb-4">Comments</h2>

        <div className="flex-1 overflow-y-auto max-h-80 mb-4">
          {comments.length === 0 ? (
            <p className="text-gray-500 italic">No comments yet.</p>
          ) : (
            <ul className="divide-y divide-gray-200">
              {comments.map((c) => (
                <li key={c._id || c.id} className="py-2">
                  <div className="font-semibold text-indigo-700 flex items-center gap-1">
                    {c.user?.name || "Anonymous"} {c.user?.verified && <span className="text-yellow-400">✨</span>}
                  </div>
                  <div className="text-gray-700">{c.text}</div>
                  {c.time && (
                    <div className="text-xs text-gray-400">
                      {new Date(c.time).toLocaleString()}
                    </div>
                  )}
                </li>
              ))}
            </ul>
          )}
        </div>

        <div className="flex gap-2">
          <input
            type="text"
            placeholder="Add a comment..."
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
            className="flex-1 px-3 py-2 border rounded-lg border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400"
            onKeyDown={(e) => e.key === "Enter" && handleAddComment()}
          />
          <button
            onClick={handleAddComment}
            disabled={loading}
            className={`px-4 py-2 rounded-lg text-white ${
              loading ? "bg-gray-400 cursor-not-allowed" : "bg-indigo-600 hover:bg-indigo-700"
            }`}
          >
            {loading ? "Adding..." : "Add"}
          </button>
        </div>
      </div>
    </div>
  );
}
