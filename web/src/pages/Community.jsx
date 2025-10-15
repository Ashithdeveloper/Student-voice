import { useState, useEffect } from "react";
import { AnimatePresence, motion } from "framer-motion";
import DiscussionPost from "../components/DiscussionPost";
import { useSelector, useDispatch } from "react-redux";
import { fetchDiscussions, toggleLike, addComment, fetchComments } from "../slices/appSlice";

export default function Community() {
  const dispatch = useDispatch();
  const { discussions = [], loading } = useSelector((state) => state.app);

  const [commentsVisible, setCommentsVisible] = useState({});

  useEffect(() => {
    dispatch(fetchDiscussions());
  }, [dispatch]);

  const handleToggleComments = (postId) => {
    setCommentsVisible((prev) => ({ ...prev, [postId]: !prev[postId] }));
    if (!commentsVisible[postId]) dispatch(fetchComments(postId));
  };

  const handleLike = async (postId) => {
    await dispatch(toggleLike(postId));
  };

  const handleAddComment = async (postId, comment) => {
    if (!comment.trim()) return;
    await dispatch(addComment({ postId, comment }));
  };

  return (
    <div className="max-w-4xl mx-auto px-4 md:px-6 py-8">
      <h1 className="text-3xl md:text-4xl font-extrabold text-indigo-700 mb-8 text-center">
        Community Discussions
      </h1>

      <AnimatePresence mode="wait">
        <motion.div
          key="discussions"
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -20 }}
          className="space-y-6"
        >
          {loading.discussions && (
            <p className="text-center text-gray-500 animate-pulse">
              Loading discussions...
            </p>
          )}

          {!loading.discussions && discussions.length === 0 && (
            <p className="text-center text-gray-500 italic">
              No discussions available.
            </p>
          )}

          {!loading.discussions &&
            discussions.map((d) => (
              <DiscussionPost
                key={d._id}
                user={d.userName}
                time={d.timeAgo}
                text={d.content}
                initialLikes={d.likes}
                comments={d.comments || []}
                showComments={commentsVisible[d._id] || false}
                onToggleComments={() => handleToggleComments(d._id)}
                onLike={() => handleLike(d._id)}
                onAddComment={(comment) => handleAddComment(d._id, comment)}
              />
            ))}
        </motion.div>
      </AnimatePresence>
    </div>
  );
}