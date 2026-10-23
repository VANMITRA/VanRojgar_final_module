import mongoose from 'mongoose';

const RateLimitSchema = new mongoose.Schema({
  key: { type: String, required: true, unique: true },
  count: { type: Number, default: 0 },
  expiresAt: { type: Date, required: true, expires: 0 } // TTL
});

export const RateLimit = mongoose.models.RateLimit || mongoose.model('RateLimit', RateLimitSchema);
