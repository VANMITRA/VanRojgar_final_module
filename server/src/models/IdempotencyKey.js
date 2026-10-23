import mongoose from 'mongoose';

const IdempotencyKeySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  key: { type: String, required: true },
  response: {
    status: Number,
    body: mongoose.Schema.Types.Mixed
  },
  createdAt: { type: Date, default: Date.now, expires: 86400 } // TTL 24h
});

IdempotencyKeySchema.index({ userId: 1, key: 1 }, { unique: true });

export const IdempotencyKey = mongoose.models.IdempotencyKey || mongoose.model('IdempotencyKey', IdempotencyKeySchema);
