import mongoose from 'mongoose';
import { config } from './config.js';
import { logger } from './logger.js';

let cached = globalThis.__mongoose;

if (!cached) {
  cached = globalThis.__mongoose = { conn: null, promise: null };
}

export async function connectDB() {
  if (cached.conn) {
    return cached.conn;
  }

  if (!cached.promise) {
    const opts = {
      bufferCommands: false,
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
    };

    cached.promise = mongoose.connect(config.MONGODB_URI, opts).then((m) => {
      logger.info(' Connected to MongoDB Atlas / Local MongoDB instance');
      return m;
    }).catch((err) => {
      logger.error({ err }, ' MongoDB connection failed');
      cached.promise = null;
      throw err;
    });
  }

  try {
    cached.conn = await cached.promise;
  } catch (e) {
    cached.promise = null;
    throw e;
  }

  return cached.conn;
}

export async function disconnectDB() {
  if (cached.conn) {
    await mongoose.disconnect();
    cached.conn = null;
    cached.promise = null;
    logger.info(' Disconnected from MongoDB');
  }
}
