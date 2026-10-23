import mongoose from 'mongoose';

const RequestSchema = new mongoose.Schema({
  listingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Listing', required: true },
  requesterId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  requesterRole: {
    type: String,
    enum: ['gramsabha', 'villager', 'buyer'],
    required: true
  },
  sellerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  gramSabhaId: { type: mongoose.Schema.Types.ObjectId, ref: 'GramSabha', required: true },
  quantity: { type: Number, required: true, min: 0.1 },
  unit: { type: String, required: true },
  deliveryPref: {
    type: String,
    enum: ['pickup', 'delivery'],
    default: 'pickup'
  },
  dropVillage: { type: String, trim: true },
  dropLocation: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: [Number]
  },
  reason: { type: String, trim: true },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected', 'countered', 'cancelled'],
    default: 'pending'
  },
  decisionNote: { type: String, trim: true },
  counter: {
    quantity: Number,
    pricePerUnitPaise: Number,
    note: String,
    version: { type: Number, default: 1 }
  },
  history: [{
    status: { type: String, required: true },
    at: { type: Date, default: Date.now },
    by: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    note: String
  }]
}, {
  timestamps: true
});

RequestSchema.index({ sellerId: 1, status: 1, createdAt: -1 });
RequestSchema.index({ requesterId: 1, createdAt: -1 });

export const Request = mongoose.models.Request || mongoose.model('Request', RequestSchema);
