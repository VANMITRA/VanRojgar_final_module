import mongoose from 'mongoose';

const OrderSchema = new mongoose.Schema({
  requestId: { type: mongoose.Schema.Types.ObjectId, ref: 'Request', required: true },
  buyerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  sellerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  gramSabhaId: { type: mongoose.Schema.Types.ObjectId, ref: 'GramSabha', required: true },
  line: {
    listingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Listing', required: true },
    title: {
      mr: { type: String, required: true },
      en: { type: String, required: true }
    },
    quantity: { type: Number, required: true },
    unit: { type: String, required: true },
    pricePerUnitPaise: { type: Number, required: true },
    totalPaise: { type: Number, required: true }
  },
  fulfilment: {
    method: { type: String, enum: ['pickup', 'delivery'], default: 'pickup' },
    dropVillage: String,
    dropLocation: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: [Number]
    }
  },
  orderStatus: {
    type: String,
    enum: [
      'approved',
      'delivery_assigned',
      'picked_up',
      'on_the_way',
      'handed_over',
      'delivered',
      'closed',
      'cancelled'
    ],
    default: 'approved'
  },
  // How the buyer pays: UPI (reported by the buyer, confirmed by the seller) or cash on delivery.
  paymentMethod: { type: String, enum: ['upi', 'cod'], default: 'cod' },
  paymentStatus: {
    type: String,
    enum: [
      'demo_pending', 'not_required', 'completed', // older orders and barter
      'awaiting_payment', 'payment_reported', 'payment_confirmed', // UPI
      'cod_pending', 'cash_received' // cash on delivery
    ],
    default: 'cod_pending'
  },
  payment: {
    reference: String, // UPI transaction reference typed by the buyer; nobody has verified it
    reportedAt: Date,
    confirmedAt: Date,
    confirmedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    cashReceivedAt: Date,
    cashReceivedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  },
  timeline: [{
    status: { type: String, required: true },
    at: { type: Date, default: Date.now },
    actorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    note: String
  }],
  deliveryId: { type: mongoose.Schema.Types.ObjectId, ref: 'Delivery' }
}, {
  timestamps: true
});

OrderSchema.index({ buyerId: 1, createdAt: -1 });
OrderSchema.index({ sellerId: 1, orderStatus: 1 });

export const Order = mongoose.models.Order || mongoose.model('Order', OrderSchema);
