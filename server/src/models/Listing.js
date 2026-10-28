import mongoose from 'mongoose';

const ListingSchema = new mongoose.Schema({
  ownerType: {
    type: String,
    enum: ['gramsabha', 'villager', 'cfrholder'],
    required: true
  },
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  gramSabhaId: { type: mongoose.Schema.Types.ObjectId, ref: 'GramSabha', required: true },
  resourceId: { type: mongoose.Schema.Types.ObjectId, ref: 'Resource' },
  title: {
    mr: { type: String, required: true, trim: true },
    en: { type: String, required: true, trim: true },
    hi: { type: String, trim: true }
  },

  categoryId: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true },
  description: { type: String, trim: true },
  itemCode: { type: String, trim: true, uppercase: true }, // `VR-` + 6 characters, see core/itemCode.js
  productCode: { type: String, trim: true, lowercase: true }, // shared with the livelihood module, see core/productCode.js
  quantityAvailable: { type: Number, required: true, min: 0 },
  unit: {
    type: String,
    enum: ['kg', 'g', 'quintal', 'litre', 'piece', 'bundle', 'jar', 'bag'],
    required: true
  },
  pricePerUnitPaise: { type: Number, required: true, min: 0 }, // integer paise
  mode: {
    type: String,
    enum: ['sell', 'barter', 'both'],
    default: 'sell'
  },
  barterWants: { type: String, trim: true },
  provenance: {
    sourceForestArea: { type: String, trim: true },
    collectionNote: { type: String, trim: true },
    sustainableDeclared: { type: Boolean, required: true, default: true }
  },
  fulfilment: {
    type: String,
    enum: ['pickup', 'delivery', 'both'],
    default: 'both'
  },
  location: {
    type: {
      type: String,
      enum: ['Point']
    },
    coordinates: {
      type: [Number], // [lng, lat]
      default: undefined
    }
  },
  village: { type: String, required: true, trim: true },
  taluka: { type: String, required: true, trim: true },
  district: { type: String, default: 'Nashik', trim: true },
  imageIds: [{ type: String }],
  imageUrl: { type: String, trim: true },
  searchTerms: [{ type: String }],
  status: {
    type: String,
    enum: ['active', 'paused', 'sold_out', 'rejected'],
    default: 'active'
  },
  flags: {
    rightsNotOnRecord: { type: Boolean, default: false }
  },
  ratingAvg: { type: Number, default: 0 },
  ratingCount: { type: Number, default: 0 }
}, {
  timestamps: true
});

ListingSchema.index({ status: 1, categoryId: 1, pricePerUnitPaise: 1 });
ListingSchema.index({ location: '2dsphere' }, { sparse: true });
ListingSchema.index({ searchTerms: 1 });
ListingSchema.index({ ownerId: 1, status: 1 });
ListingSchema.index({ productCode: 1, status: 1 }, { sparse: true });
ListingSchema.index({ taluka: 1, status: 1 });
ListingSchema.index({ itemCode: 1 }, { unique: true, sparse: true });

export const Listing = mongoose.models.Listing || mongoose.model('Listing', ListingSchema);
