import mongoose from 'mongoose';

const CategorySchema = new mongoose.Schema({
  slug: { type: String, required: true, unique: true, trim: true },
  name: {
    mr: { type: String, required: true, trim: true },
    en: { type: String, required: true, trim: true },
    hi: { type: String, trim: true }
  },
  iconKey: { type: String, default: 'forest' },
  order: { type: Number, default: 0 },
  description: {
    mr: { type: String, trim: true },
    en: { type: String, trim: true },
    hi: { type: String, trim: true }
  }

}, {
  timestamps: true
});

CategorySchema.index({ order: 1 });

export const Category = mongoose.models.Category || mongoose.model('Category', CategorySchema);
