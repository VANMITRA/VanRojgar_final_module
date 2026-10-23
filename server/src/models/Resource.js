import mongoose from 'mongoose';

const ResourceSchema = new mongoose.Schema({
  gramSabhaId: { type: mongoose.Schema.Types.ObjectId, ref: 'GramSabha', required: true },
  name: {
    mr: { type: String, required: true, trim: true },
    en: { type: String, required: true, trim: true }
  },
  categoryId: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true },
  unit: {
    type: String,
    enum: ['kg', 'g', 'quintal', 'litre', 'piece', 'bundle', 'jar', 'bag'],
    default: 'kg'
  },
  seasonMonths: [{ type: Number, min: 1, max: 12 }],
  description: { type: String, trim: true },
  searchTerms: [{ type: String }]
}, {
  timestamps: true
});

ResourceSchema.index({ gramSabhaId: 1 });
ResourceSchema.index({ searchTerms: 1 });

export const Resource = mongoose.models.Resource || mongoose.model('Resource', ResourceSchema);
