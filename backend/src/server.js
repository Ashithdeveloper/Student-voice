import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import connectDB from './db/Database.js';
import authRouter from "./Router/user.route.js"
// import job from './config/cors.js';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());
const port = process.env.PORT || 4000;

app.get("/", (req, res) => {
    res.send("Server is running");
})
//job.start();

//auth router 
app.use("/api/auth" , authRouter);

app.listen(port, () => {
    connectDB();
    console.log('Server is running on port 4000');
});