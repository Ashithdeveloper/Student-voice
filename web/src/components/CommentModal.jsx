import { useEffect, useState, useRef } from "react";
import { useDispatch, useSelector } from "react-redux";
import {
  addComment,
  fetchComments,
  addTempComment,
  clearTempComments,
  selectCommentsByPost
} from "../slices/appSlice";

export default function CommentModal({ postId, onClose }) {
  const dispatch = useDispatch();
  const comments = useSelector((state) => selectCommentsByPost(state, postId));
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(false);
  const scrollRef = useRef();

  useEffect(() => {
    dispatch(clearTempComments(postId));
    dispatch(fetchComments(postId));
  }, [dispatch, postId]);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [comments]);

  const handleSend = async () => {
    const trimmed = text.trim();
    if (!trimmed) return;

    const tempComment = {
      _id: `temp-${Date.now()}`,
      text: trimmed,
      user: { name: "You" },
      createdAt: new Date().toISOString(),
    };

    dispatch(addTempComment({ postId, comment: tempComment }));
    setText("");
    setLoading(true);

    try {
      await dispatch(addComment({ postId, comment: trimmed }));
      onClose(); // close modal after sending
    } catch (err) {
      console.error("Failed to add comment:", err);
      dispatch(clearTempComments(postId));
    } finally {
      setLoading(false);
    }
  };

  const handleClickOutside = (e) => {
    if (e.target.id === "commentModalBackdrop") onClose();
  };

  return (
    <div
      id="commentModalBackdrop"
      onClick={handleClickOutside}
      className="fixed inset-0 z-50 bg-black/30 flex justify-center items-end sm:items-center px-3 sm:px-6"
    >
      <div className="bg-white w-full sm:max-w-2xl rounded-t-2xl sm:rounded-2xl flex flex-col max-h-[90vh]">
        <div className="w-12 h-1.5 bg-gray-400 rounded mx-auto my-2"></div>

        <div className="flex-1 overflow-y-auto px-4 py-2" ref={scrollRef}>
          {comments.length === 0 && <p className="text-gray-500 text-center mt-4">No comments yet</p>}
          {comments.map((c, index) => (
            <div key={c._id || index} className="flex gap-2 items-start mb-3">
              <div className="w-8 h-8 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-700 font-bold text-xs">
                {c.user?.name?.[0]?.toUpperCase() || "U"}
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-1 text-indigo-700 font-semibold text-sm">
                  {c.user?.name || "Anonymous"}
                </div>
                <p className="text-gray-700 text-sm">{c.text}</p>
                <p className="text-gray-400 text-xs">
                  {c.createdAt ? new Date(c.createdAt).toLocaleString() : ""}
                </p>
              </div>
            </div>
          ))}
        </div>

        <div className="flex gap-2 border-t p-2">
          <input
            type="text"
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="Add a comment..."
            className="flex-1 px-3 py-2 border rounded-lg focus:outline-none focus:ring focus:ring-indigo-200"
          />
          <button
            onClick={handleSend}
            disabled={loading}
            className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50"
          >
            Send
          </button>
        </div>
      </div>
    </div>
  );
}
