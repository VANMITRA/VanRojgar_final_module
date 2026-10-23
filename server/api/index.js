import { app } from '../src/app.js';
import { connectDB } from '../src/core/db.js';

export default async function handler(req, res) {
  try {
    await connectDB();
    return app(req, res);
  } catch (err) {
    console.error('Database connection failed in serverless handler:', err);
    return res.status(503).json({
      error: {
        code: 'SERVICE_UNAVAILABLE',
        message: 'Database connection failed. Please ensure MONGODB_URI is configured correctly in Vercel environment variables.'
      }
    });
  }
}

