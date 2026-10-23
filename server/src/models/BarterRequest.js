import mongoose from 'mongoose';

const BarterRequestSchema = new mongoose.Schema({
  fromUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  toOwnerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  toListId: { type: mongoose.Schema.Types.ObjectId, ref: 'Listing', required: true },
  fromListId: { type: mongoose.Schema.Types.ObjectId, ref: 'Listing' },
  offered: {
    title: { type: String, required: true },
    quantity: { type: Number, required: true },
    unit: { type: String, required: true }
  },
  wanted: {
    quantity: { type: Number, required: true }
  },
  note: { type: String, trim: true },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'rejected', 'countered'],
    default: 'pending'
  },
  versions: [{
    version: { type: Number, required: true },
    offered: {
      title: String,
      quantity: Number,
      unit: String
    },
    wanted: {
      quantity: Number
    },
    proposedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    note: String,
    at: { type: Date, default: Date.now }
  }],
  acceptances: {
    from: { version: Number, at: Date },
    to: { version: Number, at: Date }
  }
}, {
  timestamps: true
});

BarterRequestSchema.index({ toOwnerId: 1, status: 1 });
BarterRequestSchema.index({ fromUserId: 1, createdAt: -1 });

export const BarterRequest = mongoose.models.BarterRequest || mongoose.model('BarterRequest', BarterRequestSchema);
