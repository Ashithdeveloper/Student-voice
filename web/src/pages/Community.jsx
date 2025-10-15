import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { fetchDiscussions } from "../slices/appSlice";
import DiscussionPort from "../components/DiscussionPost";

export default function Community() {
  const dispatch = useDispatch();
  const discussions = useSelector((state) => state.app.discussions);

  useEffect(() => {
    dispatch(fetchDiscussions());
  }, [dispatch]);

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Community Discussions</h1>
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {discussions.map((discussion) => (
          <DiscussionPort key={discussion.id} discussion={discussion} />
        ))}
      </div>
    </div>
  );
}
