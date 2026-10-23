import mongoose from 'mongoose';

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  phone: { type: String, required: true, unique: true, trim: true },
  email: { type: String, trim: true, lowercase: true },
  businessName: { type: String, trim: true },
  city: { type: String, trim: true },
  role: {
    type: String,
    enum: ['gramsabha', 'villager', 'buyer', 'team'],
    required: true
  },
  language: { type: String, enum: ['en', 'hi', 'mr'], default: 'en' },
  passwordHash: { type: String, required: true, select: false },
  gramSabhaId: { type: mongoose.Schema.Types.ObjectId, ref: 'GramSabha' },
  village: { type: String, trim: true },
  taluka: { type: String, trim: true },
  district: { type: String, default: 'Nashik', trim: true },
  isDeliveryApplicant: { type: Boolean, default: false },
  status: { type: String, enum: ['active', 'suspended'], default: 'active' }
}, {
  timestamps: true
});

UserSchema.index({ role: 1, gramSabhaId: 1 });

export const User = mongoose.models.User || mongoose.model('User', UserSchema);
