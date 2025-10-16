import { useEffect, useState } from "react";
import { toast } from "react-toastify";
import { useDispatch, useSelector } from "react-redux";
import {
  fetchDiscussions,
  createDiscussion,
  addTempPost,
} from "../slices/appSlice";
import DiscussionPost from "../components/DiscussionPost";
import CommentModal from "../components/CommentModal";

export default function Community() {
  const dispatch = useDispatch();
  const discussions = useSelector((state) => state.app.discussions);
  const currentUser = useSelector((state) => state.auth.user);

  const [newPost, setNewPost] = useState("");
  const [selectedPostId, setSelectedPostId] = useState(null);

  useEffect(() => {
    dispatch(fetchDiscussions());
  }, [dispatch]);

  const handleCreatePost = async () => {
    if (!newPost.trim()) return toast.warn("Post cannot be empty");

    // Optimistic Post
    const tempPost = {
      _id: `temp-${Date.now()}`,
      text: newPost,
      user: {
        name: currentUser?.name || "You",
        verified: currentUser?.verified || false,
      },
      likes: [],
      commentCount: 0,
      createdAt: new Date().toISOString(),
    };

    dispatch(addTempPost(tempPost));
    setNewPost("");

    try {
      await dispatch(createDiscussion({ text: tempPost.text })).unwrap();
    } catch (err) {
      console.error("Failed to save post:", err);
    }
  };

  return (
    <div className="p-4 flex flex-col gap-4 font-serif">
      <h1 className="text-2xl text-center font-bold">Community Discussions</h1>

      {/* New Post Input */}
      <textarea
        value={newPost}
        onChange={(e) => setNewPost(e.target.value)}
        placeholder="What's on your mind?"
        className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-400"
      />
      <button
        onClick={handleCreatePost}
        className="px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700"
      >
        Post
      </button>

      {/* Discussion Posts */}
      <div className="flex flex-col gap-3 mt-4">
        {discussions.map((post) => (
          <DiscussionPost
            key={post._id}
            postId={post._id}
            user={post.user}
            text={post.text}
            time={post.createdAt}
            likes={post.likes}
            commentCount={post.commentCount || 0}
            currentUserId={currentUser?._id}
            onComment={() => setSelectedPostId(post._id)}
          />
        ))}
      </div>

      {/* Comment Modal */}
      {selectedPostId && (
        <CommentModal
          postId={selectedPostId}
          onClose={() => setSelectedPostId(null)}
        />
      )}
    </div>
  );
}
