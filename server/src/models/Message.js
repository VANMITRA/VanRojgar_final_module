import mongoose from 'mongoose';

const MessageSchema = new mongoose.Schema({
  recipientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  actorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  type: { type: String, required: true },
  orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
  requestId: { type: mongoose.Schema.Types.ObjectId, ref: 'Request' },
  barterId: { type: mongoose.Schema.Types.ObjectId, ref: 'BarterRequest' },
  title: { mr: String, en: String },
  body: { mr: String, en: String },
  params: { type: Map, of: String },
  readAt: { type: Date }
}, {
  timestamps: true
});

MessageSchema.index({ recipientId: 1, readAt: 1, createdAt: -1 });

export const Message = mongoose.models.Message || mongoose.model('Message', MessageSchema);
