// [USER RUNS] Move listings from the retired "Dry fruit" category into "Medicine and herbs" (behda and hirda are herbs).
//   node scripts/move_dry_fruit_listings.js           dry run: counts what it would change
//   node scripts/move_dry_fruit_listings.js --apply   writes the change
// Safe to run again. Run `npm run seed` first so the new categories exist. Needs MONGODB_URI in the environment.
import mongoose from 'mongoose';
import { config } from '../src/core/config.js';
import { Category } from '../src/models/Category.js';
import { Listing } from '../src/models/Listing.js';

const apply = process.argv.includes('--apply');
await mongoose.connect(config.MONGODB_URI);
const from = await Category.findOne({ slug: 'dry-fruit' });
const to = await Category.findOne({ slug: 'medicinal-plants' });
if (!to) {
  console.log('The "Medicine and herbs" category is missing. Run `npm run seed` first.');
} else if (!from) {
  console.log('No "Dry fruit" category found: nothing to move.');
} else {
  const count = await Listing.countDocuments({ categoryId: from._id });
  console.log(`mode: ${apply ? 'APPLY' : 'dry run'}  listings in Dry fruit: ${count}`);
  if (apply) {
    await Listing.updateMany({ categoryId: from._id }, { $set: { categoryId: to._id } });
    console.log('done');
  } else {
    console.log('dry run only; add --apply to write');
  }
}
await mongoose.disconnect();
