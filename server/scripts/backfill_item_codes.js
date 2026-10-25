// Gives every listing that has no item code one. Dry run unless --apply is given. A person runs it, not Claude.
//   MONGODB_URI=... node scripts/backfill_item_codes.js            (counts the listings, writes nothing)
//   MONGODB_URI=... node scripts/backfill_item_codes.js --apply    (writes)
// Run `npm run indexes` first so the unique index on itemCode exists.
import { connectDB, disconnectDB } from '../src/core/db.js';
import { Listing } from '../src/models/Listing.js';
import { generateItemCode } from '../src/core/itemCode.js';

const apply = process.argv.includes('--apply');
await connectDB();
try {
  const missing = await Listing.find({ $or: [{ itemCode: { $exists: false } }, { itemCode: null }, { itemCode: '' }] }).select('_id');
  console.log(`${missing.length} listing(s) have no item code.`);
  if (!apply) {
    console.log('Dry run only. Nothing was written. Add --apply to write.');
  } else {
    let done = 0;
    for (const { _id } of missing) {
      for (let attempt = 0; attempt < 6; attempt++) {
        try {
          await Listing.updateOne({ _id }, { $set: { itemCode: generateItemCode() } });
          done++;
          break;
        } catch (err) {
          if (err?.code !== 11000 || attempt === 5) throw err;
        }
      }
    }
    console.log(`Gave ${done} listing(s) an item code.`);
  }
} finally {
  await disconnectDB();
}
