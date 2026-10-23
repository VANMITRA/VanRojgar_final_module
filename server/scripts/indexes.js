import { connectDB, disconnectDB } from '../src/core/db.js';
import { logger } from '../src/core/logger.js';
import { User } from '../src/models/User.js';
import { GramSabha } from '../src/models/GramSabha.js';
import { Listing } from '../src/models/Listing.js';
import { Request } from '../src/models/Request.js';
import { Order } from '../src/models/Order.js';

async function syncAllIndexes() {
  logger.info('🔄 Synchronizing MongoDB database indexes...');
  await connectDB();

  await User.syncIndexes();
  await GramSabha.syncIndexes();
  await Listing.syncIndexes();
  await Request.syncIndexes();
  await Order.syncIndexes();

  logger.info('✅ All collection indexes synchronized successfully.');
  await disconnectDB();
}

syncAllIndexes().catch(err => {
  logger.error({ err }, 'Failed to sync indexes');
  process.exit(1);
});
