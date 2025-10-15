import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { fetchSurveys } from "../slices/appSlice";
import SurveyCard from "../components/SurveyCard";

export default function Surveys() {
  const dispatch = useDispatch();
  const surveys = useSelector((state) => state.app.surveys);

  useEffect(() => {
    dispatch(fetchSurveys());
  }, [dispatch]);

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Surveys</h1>
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {surveys.map((survey) => <SurveyCard key={survey.id} survey={survey} />)}
      </div>
    </div>
  );
}
