import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import bcrypt from 'bcryptjs';
import { connectDB, disconnectDB } from '../core/db.js';
import { logger } from '../core/logger.js';
import { config } from '../core/config.js';
import { Category } from '../models/Category.js';
import { RestrictedItem } from '../models/RestrictedItem.js';
import { GramSabha } from '../models/GramSabha.js';
import { User } from '../models/User.js';
import { Listing } from '../models/Listing.js';
import { importRaah } from './raah.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export async function seed() {
  logger.info('🌱 Starting VanRozgar idempotent database seeder...');
  await connectDB();

  // 1. Categories
  const categoriesRaw = JSON.parse(fs.readFileSync(path.join(__dirname, 'data/categories.json'), 'utf-8'));
  for (const cat of categoriesRaw) {
    await Category.findOneAndUpdate(
      { slug: cat.slug },
      { $set: cat },
      { upsert: true, new: true }
    );
  }
  logger.info(`✅ Synced ${categoriesRaw.length} categories`);

  // 2. Restricted Items
  const restrictedRaw = JSON.parse(fs.readFileSync(path.join(__dirname, 'data/restricted.json'), 'utf-8'));
  for (const item of restrictedRaw) {
    await RestrictedItem.findOneAndUpdate(
      { 'name.en': item.name.en },
      { $set: item },
      { upsert: true, new: true }
    );
  }
  logger.info(`✅ Synced ${restrictedRaw.length} restricted items`);

  // 3. The dataset: the 14 villages of the Raah Foundation report, and nothing else
  const raahResult = await importRaah({ apply: true, log: (m) => logger.info(m) });
  logger.info(`✅ Dataset: ${raahResult.villages} villages (${raahResult.talukas.join(', ')}), ${raahResult.removed} others removed`);
  const gsMap = new Map();
  for (const gs of await GramSabha.find({})) gsMap.set(`${gs.taluka}:${gs.village.mr}`, gs);
  // A demo login (below) owns each Gram Sabha record, so mark them as seeded; the facts on them are the report's.
  await GramSabha.updateMany({ _id: { $in: [...gsMap.values()].map((g) => g._id) } }, { $set: { verificationStatus: 'verified_seed', verificationNote: 'Village facts: Raah Foundation report (1 Oct 2026). The login attached to this record is a demo account; position is the block town (approximate).' } });

  // 4. Demo Accounts
  const demoUsersRaw = JSON.parse(fs.readFileSync(path.join(__dirname, 'data/demo_accounts.json'), 'utf-8'));
  const userMap = new Map();

  for (const u of demoUsersRaw) {
    // The back-office account has a known demo password: never create it in production unless one is set.
    if (u.role === 'team' && config.NODE_ENV === 'production' && !process.env.SEED_TEAM_PASSWORD) continue;
    const pass = u.role === 'team' ? config.SEED_TEAM_PASSWORD : config.SEED_DEMO_PASSWORD;
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(pass, salt);

    let gramSabhaId = null;
    if (u.village && u.taluka) {
      const gs = gsMap.get(`${u.taluka}:${u.village}`);
      if (gs) gramSabhaId = gs._id;
    }

    const user = await User.findOneAndUpdate(
      { phone: u.phone },
      {
        $set: {
          name: u.name,
          phone: u.phone,
          businessName: u.businessName,
          city: u.city,
          email: u.email,
          role: u.role,
          language: u.language || 'mr',
          passwordHash,
          village: u.village,
          taluka: u.taluka,
          gramSabhaId,
          isDeliveryApplicant: u.isDeliveryApplicant || false,
          status: 'active'
        }
      },
      { upsert: true, new: true }
    );
    userMap.set(u.role === 'gramsabha' ? `gs:${u.village}` : u.role, user);
  }
  // Remove stale demo Gram Sabha secretaries (and their listings) from earlier seeds
  const newPhones = demoUsersRaw.map((u) => u.phone);
  const staleUsers = await User.find({ role: 'gramsabha', phone: { $regex: /^\+91982201/, $nin: newPhones } });
  if (staleUsers.length) {
    const ids = staleUsers.map((u) => u._id);
    await Listing.deleteMany({ ownerId: { $in: ids } });
    await User.deleteMany({ _id: { $in: ids } });
  }
  logger.info(`✅ Synced ${demoUsersRaw.length} demo accounts (passwords initialized)`);

  // 5. No demo listings, requests or orders: the marketplace starts empty and holds only what people list.
  const seedOwners = [...userMap.keys()].filter((k) => k.startsWith('gs:')).map((k) => userMap.get(k)._id);
  const removedListings = await Listing.deleteMany({ ownerId: { $in: seedOwners } });
  logger.info(`✅ Demo listings removed: ${removedListings.deletedCount}`);

  logger.info('🎉 Seed completed successfully!');

  await disconnectDB();
}

import { pathToFileURL } from 'url';
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  seed().catch((err) => {
    logger.error({ err }, '❌ Seed script failed');
    process.exit(1);
  });
}
