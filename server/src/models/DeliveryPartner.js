import mongoose from 'mongoose';

const DeliveryPartnerSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  vehicle: {
    type: { type: String, enum: ['bike', 'tempo', 'pickup', 'tractor'], required: true },
    number: { type: String, required: true, trim: true },
    capacityKg: { type: Number, required: true }
  },
  licenceLast4: { type: String, required: true, trim: true },
  licenceHash: { type: String, required: true },
  serviceTalukas: [{ type: String, required: true }],
  approvalStatus: {
    type: String,
    enum: ['pending', 'approved', 'rejected', 'paused'],
    default: 'pending'
  },
  reviewNote: { type: String, trim: true },
  available: { type: Boolean, default: true },
  earningsPaise: { type: Number, default: 0 },
  ratingAvg: { type: Number, default: 0 },
  jobsCompleted: { type: Number, default: 0 }
}, {
  timestamps: true
});

DeliveryPartnerSchema.index({ approvalStatus: 1, available: 1 });

export const DeliveryPartner = mongoose.models.DeliveryPartner || mongoose.model('DeliveryPartner', DeliveryPartnerSchema);
