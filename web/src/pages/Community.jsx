import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { fetchDiscussions, createDiscussion, addTempPost } from "../slices/appSlice";
import DiscussionPost from "../components/DiscussionPost";
import CommentModal from "../components/CommentModal";

export default function Community() {
  const dispatch = useDispatch();
  const discussions = useSelector(state => state.app.discussions);
  const [newPost, setNewPost] = useState("");
  const [selectedPostId, setSelectedPostId] = useState(null);

  useEffect(() => {
    dispatch(fetchDiscussions());
  }, [dispatch]);

  const handleCreatePost = async () => {
    if (!newPost.trim()) return alert("Post cannot be empty");

    const tempPost = {
      _id: `temp-${Date.now()}`,
      text: newPost,
      user: { name: "You" },
      createdAt: new Date().toISOString(),
    };

    dispatch(addTempPost(tempPost));
    setNewPost("");

    try {
      await dispatch(createDiscussion({ content: tempPost.text }));
    } catch (err) {
      console.error("Failed to save post:", err);
    }
  };

  return (
    <div className="p-4 flex font-serif flex-col gap-4">
      <h1 className="text-2xl text-center font-bold">Community Discussions</h1>
      <textarea
        value={newPost}
        onChange={(e) => setNewPost(e.target.value)}
        placeholder="What's on your mind?"
        className="w-full p-2 border rounded"
      />
      <button
        onClick={handleCreatePost}
        className="px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700"
      >
        Post
      </button>

      <div className="flex flex-col gap-3 mt-4">
        {discussions.map(post => (
          <DiscussionPost
            key={post._id}
            postId={post._id}
            user={post.user?.name}
            text={post.text}
            time={post.createdAt}
            onComment={() => setSelectedPostId(post._id)}
          />
        ))}
      </div>

      {selectedPostId && (
        <CommentModal
          postId={selectedPostId}
          onClose={() => setSelectedPostId(null)}
        />
      )}
    </div>
  );
}
