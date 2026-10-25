// Loads the 14 villages of the Raah Foundation report. Dry run unless --apply is given.
//   MONGODB_URI=... node scripts/import_raah.js            (shows what it would do, writes nothing)
//   MONGODB_URI=... node scripts/import_raah.js --apply    (writes)
import { connectDB, disconnectDB } from '../src/core/db.js';
import { importRaah } from '../src/seed/raah.js';

const apply = process.argv.includes('--apply');
if (apply) await connectDB();
try {
  const result = await importRaah({ apply, log: console.log });
  console.log(JSON.stringify(result, null, 2));
  if (!apply) console.log('\nDry run only. Nothing was written. Add --apply to write.');
} finally {
  if (apply) await disconnectDB();
}
