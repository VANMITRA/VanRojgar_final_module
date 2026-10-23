import mongoose from 'mongoose';

const RestrictedItemSchema = new mongoose.Schema({
  name: {
    mr: { type: String, required: true },
    en: { type: String, required: true }
  },
  terms: [{ type: String, required: true, lowercase: true, trim: true }],
  reason: {
    mr: { type: String, required: true },
    en: { type: String, required: true }
  },
  schedule: { type: String, default: 'Wildlife Protection Act / Forest Act' },
  verified: { type: Boolean, default: false }
}, {
  timestamps: true
});

RestrictedItemSchema.index({ terms: 1 });

export const RestrictedItem = mongoose.models.RestrictedItem || mongoose.model('RestrictedItem', RestrictedItemSchema);
