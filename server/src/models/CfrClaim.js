import mongoose from 'mongoose';

const CfrClaimSchema = new mongoose.Schema({
  gramSabhaId: { type: mongoose.Schema.Types.ObjectId, ref: 'GramSabha' },
  caseNo: { type: String, required: true, trim: true },
  claimant: { type: String, trim: true },
  village: { type: String, required: true, trim: true },
  taluka: { type: String, required: true, trim: true },
  district: { type: String, default: 'Nashik' },
  rights: [{ type: String }],
  compartment: { type: String, trim: true },
  areaClaimedHa: { type: Number, default: 0 },
  areaApprovedHa: { type: Number, default: 0 },
  decision: {
    type: String,
    enum: ['approved', 'rejected', 'pending'],
    default: 'approved'
  }
}, {
  timestamps: true
});

CfrClaimSchema.index({ taluka: 1, caseNo: 1 });
CfrClaimSchema.index({ gramSabhaId: 1 });

export const CfrClaim = mongoose.models.CfrClaim || mongoose.model('CfrClaim', CfrClaimSchema);
