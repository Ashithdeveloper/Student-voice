import { useSelector } from "react-redux";

export function useViewer() {
  const userRole = useSelector((state) => state.auth.user?.role);
  const isViewer = userRole === "viewer";
  return isViewer;
}
