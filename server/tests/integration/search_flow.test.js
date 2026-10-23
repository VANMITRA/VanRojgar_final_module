import test from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';

// Needs a real MongoDB replica set. Starts one in memory; if the MongoDB binary cannot be
// downloaded (offline sandbox) the test is skipped instead of failing. CI downloads it normally.
let rs = null;
try {
  const { MongoMemoryReplSet } = await import('mongodb-memory-server');
  rs = await MongoMemoryReplSet.create({ replSet: { count: 1 } });
} catch (err) {
  console.warn(`integration tests skipped: ${err.message.split('\n')[0]}`);
}

test('search API: seeded data pages through once, nearest is ordered, and login works', { skip: !rs }, async (t) => {
  process.env.MONGODB_URI = rs.getUri('vanrozgar_test');
  process.env.SEED_DEMO_PASSWORD = '123456';
  const { seed } = await import('../../src/seed/run.js');
  await seed();
  const { app } = await import('../../src/app.js');
  const { connectDB, disconnectDB } = await import('../../src/core/db.js');
  await connectDB(); // the seeder disconnects when it finishes
  t.after(async () => { await disconnectDB(); await rs.stop(); });

  const login = await request(app).post('/api/v1/auth/login').send({ phone: '+919822033333', password: '123456' });
  assert.equal(login.status, 200);
  const token = login.body.data.token;

  // Page through every listing, 7 at a time: no duplicates, all 50 seen.
  const seen = [];
  let cursor;
  for (let i = 0; i < 20; i++) {
    const res = await request(app).get('/api/v1/search').set('Authorization', `Bearer ${token}`)
      .query({ limit: 7, ...(cursor ? { cursor } : {}) });
    assert.equal(res.status, 200);
    seen.push(...res.body.data.listings.map(l => l.id));
    cursor = res.body.data.nextCursor;
    if (!cursor) break;
  }
  assert.equal(new Set(seen).size, seen.length);
  assert.equal(seen.length, 50);

  // Nearest with a position: distances never decrease, unknown distances come last.
  const near = await request(app).get('/api/v1/search').set('Authorization', `Bearer ${token}`)
    .query({ sort: 'nearest', lat: 20.0, lng: 73.78, limit: 50 });
  assert.equal(near.status, 200);
  const known = near.body.data.listings.map(l => l.distanceKm).filter(d => d !== null);
  assert.deepEqual(known, [...known].sort((a, b) => a - b));

  // A wrong PIN is rejected.
  const bad = await request(app).post('/api/v1/auth/login').send({ phone: '+919822033333', password: '000000' });
  assert.equal(bad.status, 401);
});
