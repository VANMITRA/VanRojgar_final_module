// [USER RUNS] Turn every old `villager` (Farmer) account into a `cfrholder`.
//   node scripts/migrate_villager_to_cfrholder.js           dry run: counts what it would change
//   node scripts/migrate_villager_to_cfrholder.js --apply   writes the change
// Safe to run again. Needs MONGODB_URI (and JWT_SECRET in production) in the environment.
import mongoose from 'mongoose';
import { config } from '../src/core/config.js';
import { User } from '../src/models/User.js';
import { Listing } from '../src/models/Listing.js';
import { Request } from '../src/models/Request.js';

const apply = process.argv.includes('--apply');
await mongoose.connect(config.MONGODB_URI);
const counts = {
  users: await User.countDocuments({ role: 'villager' }),
  listings: await Listing.countDocuments({ ownerType: 'villager' }),
  requests: await Request.countDocuments({ requesterRole: 'villager' })
};
console.log(`mode: ${apply ? 'APPLY' : 'dry run'}  villager users: ${counts.users}  listings: ${counts.listings}  requests: ${counts.requests}`);
if (apply) {
  await User.updateMany({ role: 'villager' }, { $set: { role: 'cfrholder' } });
  await Listing.updateMany({ ownerType: 'villager' }, { $set: { ownerType: 'cfrholder' } });
  await Request.updateMany({ requesterRole: 'villager' }, { $set: { requesterRole: 'cfrholder' } });
  console.log('done');
} else {
  console.log('dry run only; add --apply to write');
}
await mongoose.disconnect();
