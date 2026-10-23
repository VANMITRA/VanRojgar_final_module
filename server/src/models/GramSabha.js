import mongoose from 'mongoose';

const GramSabhaSchema = new mongoose.Schema({
  name: {
    mr: { type: String, required: true, trim: true },
    en: { type: String, trim: true }
  },
  village: {
    mr: { type: String, required: true, trim: true },
    en: { type: String, trim: true }
  },
  taluka: { type: String, required: true, trim: true },
  district: { type: String, default: 'Nashik', trim: true },
  censusCode: { type: String, trim: true },
  location: {
    type: {
      type: String,
      enum: ['Point']
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      default: undefined,
      required: false
    }
  },
  verificationStatus: {
    type: String,
    enum: ['pending', 'verified', 'verified_seed', 'rejected'],
    default: 'pending'
  },
  verificationNote: { type: String, trim: true },
  cfr: {
    rights: [{ type: String, trim: true }], // e.g. ["3(1)(c)", "3(1)(d)", "3(1)(i)"]
    approvedAreaHa: { type: Number, default: 0 },
    claimCount: { type: Number, default: 1 }
  },
  contactPerson: { type: String, trim: true },
  phone: { type: String, trim: true },
  isDemoData: { type: Boolean, default: false },
  claim: {
    claimedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    claimantName: { type: String, trim: true },
    claimantPhone: { type: String, trim: true },
    designation: { type: String, trim: true },
    resolutionNo: { type: String, trim: true },
    status: {
      type: String,
      enum: ['none', 'pending', 'approved', 'rejected'],
      default: 'none'
    },
    note: { type: String, trim: true },
    claimedAt: { type: Date }
  },
  searchTerms: [{ type: String }],
  ratingAvg: { type: Number, default: 0 },
  ratingCount: { type: Number, default: 0 }
}, {
  timestamps: true
});

GramSabhaSchema.index({ taluka: 1, 'village.mr': 1 });
GramSabhaSchema.index({ location: '2dsphere' }, { sparse: true });
GramSabhaSchema.index({ searchTerms: 1 });
GramSabhaSchema.index({ verificationStatus: 1 });

export const GramSabha = mongoose.models.GramSabha || mongoose.model('GramSabha', GramSabhaSchema);
