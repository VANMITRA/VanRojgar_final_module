// Loads the cleaned CFR data into the database. Dry run unless --apply is given.
//   MONGODB_URI=... node scripts/import_cfr.js            (shows what it would do, writes nothing)
//   MONGODB_URI=... node scripts/import_cfr.js --apply    (writes)
import { connectDB, disconnectDB } from '../src/core/db.js';
import { importCfr } from '../src/seed/cfr.js';

const apply = process.argv.includes('--apply');
if (apply) await connectDB();
try {
  const result = await importCfr({ apply, log: console.log });
  console.log(JSON.stringify(result, null, 2));
  if (!apply) console.log('\nDry run only. Nothing was written. Add --apply to write.');
} finally {
  if (apply) await disconnectDB();
}
