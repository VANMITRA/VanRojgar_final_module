import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { logger } from './logger.js';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const PORT = 27018;

/**
 * Starts a private MongoDB replica set (transactions need one) that stores its files in
 * server/.data, so the API runs without installing or starting MongoDB manually.
 * The first run downloads the MongoDB binary once; data survives restarts.
 * Seeds the 10 pilot villages automatically when the database is empty.
 */
export async function startEmbeddedDb() {
  const { MongoMemoryReplSet } = await import('mongodb-memory-server');
  const dbPath = path.join(root, '.data', 'mongo');
  fs.mkdirSync(dbPath, { recursive: true });

  logger.info('Starting embedded MongoDB (first run downloads the MongoDB binary, please wait)...');
  const rs = await MongoMemoryReplSet.create({
    replSet: { count: 1, storageEngine: 'wiredTiger', dbName: 'vanrozgar' },
    instanceOpts: [{ port: PORT, dbPath, storageEngine: 'wiredTiger' }]
  });
  const uri = rs.getUri('vanrozgar');

  const mongoose = (await import('mongoose')).default;
  const conn = await mongoose.createConnection(uri).asPromise();
  const users = await conn.db.collection('users').countDocuments();
  await conn.close();
  if (users === 0) {
    logger.info('Empty database: seeding the 10 pilot villages...');
    const { config } = await import('./config.js');
    config.MONGODB_URI = uri;
    const { seed } = await import('../seed/run.js');
    await seed();
  }

  const stop = async () => { await rs.stop(); };
  process.once('exit', () => { rs.stop().catch(() => {}); });
  return { uri, stop };
}
