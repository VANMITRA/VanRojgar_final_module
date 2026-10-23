import mongoose from 'mongoose';

const VillageProfileSchema = new mongoose.Schema({
  censusCode: { type: String, required: true, unique: true, trim: true },
  villageName: { type: String, required: true, trim: true },
  taluka: { type: String, required: true, trim: true },
  district: { type: String, default: 'Nashik' },
  forestHa: { type: Number, default: 0 },
  waterBodiesCount: { type: Number, default: 0 },
  wellsTotal: { type: Number, default: 0 },
  waterConservationWorks: { type: Number, default: 0 },
  soilType: { type: String, trim: true },
  highlights: [{ type: String }],
  rawDetails: { type: Map, of: String }
}, {
  timestamps: true
});

VillageProfileSchema.index({ taluka: 1, villageName: 1 });

export const VillageProfile = mongoose.models.VillageProfile || mongoose.model('VillageProfile', VillageProfileSchema);
