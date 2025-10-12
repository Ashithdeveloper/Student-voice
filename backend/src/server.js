import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import connectDB from './db/Database.js';
// import job from './config/cors.js';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());
const port = process.env.PORT || 4000;
//job.start();

app.listen(port, () => {
    connectDB();
    console.log('Server is running on port 3001');
});