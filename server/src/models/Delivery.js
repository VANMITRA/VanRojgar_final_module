import mongoose from 'mongoose';

const DeliverySchema = new mongoose.Schema({
  orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
  partnerId: { type: mongoose.Schema.Types.ObjectId, ref: 'DeliveryPartner' },
  pickup: {
    village: { type: String, required: true },
    taluka: { type: String, required: true },
    location: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: [Number]
    }
  },
  drop: {
    village: { type: String, required: true },
    taluka: { type: String, required: true },
    location: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: [Number]
    }
  },
  goodsSummary: { type: String, required: true },
  weightKg: { type: Number, required: true },
  distanceKm: { type: Number, required: true },
  feePaise: { type: Number, required: true },
  // Cash on delivery: how much cash the partner collects from the buyer (0 = nothing to collect), and whether it was marked received
  collectCashPaise: { type: Number, default: 0 },
  cashCollected: { type: Boolean, default: false },
  status: {
    type: String,
    enum: ['available', 'accepted', 'picked_up', 'on_the_way', 'delivered', 'cancelled'],
    default: 'available'
  },
  timeline: [{
    status: { type: String, required: true },
    at: { type: Date, default: Date.now },
    note: String
  }]
}, {
  timestamps: true
});

DeliverySchema.index({ status: 1, 'pickup.taluka': 1 });
DeliverySchema.index({ partnerId: 1, status: 1 });

export const Delivery = mongoose.models.Delivery || mongoose.model('Delivery', DeliverySchema);
