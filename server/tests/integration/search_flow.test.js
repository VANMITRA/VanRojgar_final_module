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
    seen.push(...res.body.data.listings.map(l => l._id));
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

  // Every seeded listing carries a product code; the map layer lists only listings that have a position.
  const { Listing } = await import('../../src/models/Listing.js');
  assert.equal(await Listing.countDocuments({ productCode: { $exists: true, $ne: null } }), 50);
  const map = await request(app).get('/api/v1/listings/map');
  assert.equal(map.status, 200);
  const points = map.body.data.points;
  assert.ok(points.length > 0, 'seeded villages with coordinates appear on the map');
  for (const pt of points) {
    assert.equal(Math.round(pt.lat * 100) / 100, pt.lat, 'latitude is rounded to 2 decimals');
    assert.equal(Math.round(pt.lng * 100) / 100, pt.lng, 'longitude is rounded to 2 decimals');
  }
  const bamboo = await request(app).get('/api/v1/listings/map').query({ product: 'bamboo' });
  assert.ok(bamboo.body.data.points.length > 0);
  assert.ok(bamboo.body.data.points.every((pt) => pt.productCode === 'bamboo'));
  const unknown = await request(app).get('/api/v1/listings/map').query({ product: 'nothing-here' });
  assert.deepEqual(unknown.body.data.points, []);

  // The real villages from the CFR register are loaded as unclaimed Gram Sabhas, with claims and MRSAC profiles.
  const { GramSabha } = await import('../../src/models/GramSabha.js');
  const { CfrClaim } = await import('../../src/models/CfrClaim.js');
  const { VillageProfile } = await import('../../src/models/VillageProfile.js');
  const { importCfr } = await import('../../src/seed/cfr.js');
  const real = await GramSabha.countDocuments({ verificationStatus: 'pending', isDemoData: false });
  assert.ok(real > 700, `real villages loaded: ${real}`);
  assert.equal(await GramSabha.countDocuments({ verificationStatus: 'verified_seed' }), 10, 'the 10 demo villages are untouched');
  const first = await importCfr({ apply: true });
  assert.ok(first.claimsSkipped < 10, `claims skipped because a demo village has the same name: ${first.claimsSkipped}`);
  assert.equal(await CfrClaim.countDocuments({ source: 'cfr_2026' }), 950 - first.claimsSkipped);
  assert.equal(await VillageProfile.countDocuments(), 680);

  const dahe = await GramSabha.findOne({ taluka: 'Nashik', censusCode: '550989' });
  const detail = await request(app).get(`/api/v1/gramsabhas/${dahe._id}`);
  assert.equal(detail.status, 200);
  assert.equal(detail.body.data.villageProfile.forestHa, 271.5);
  assert.equal(detail.body.data.villageProfile.wellsTotal, 58);
  assert.ok(detail.body.data.claims.length >= 1);
  assert.ok(detail.body.data.gramSabha.cfr.rights.length >= 1);
  assert.equal(detail.body.data.gramSabha.claim?.claimantPhone, undefined, 'claimant phone is never public');

  // Importing again changes nothing.
  const again = await importCfr({ apply: true });
  assert.equal(again.created, 0);
  assert.equal(await CfrClaim.countDocuments({ source: 'cfr_2026' }), 950 - first.claimsSkipped);
  assert.equal(await GramSabha.countDocuments({ verificationStatus: 'pending', isDemoData: false }), real);

  // Registering for an existing village files a claim on THAT record and does not create a second one.
  const before = await GramSabha.countDocuments();
  const reg = await request(app).post('/api/v1/auth/register').send({
    role: 'gramsabha', name: 'Test Secretary', phone: '+919800000001', password: '654321',
    village: dahe.village.mr, taluka: 'Nashik'
  });
  assert.equal(reg.status, 201);
  assert.equal(await GramSabha.countDocuments(), before, 'no duplicate Gram Sabha');
  const claimed = await GramSabha.findById(dahe._id);
  assert.equal(claimed.claim.status, 'pending');
  const { User } = await import('../../src/models/User.js');
  const newUser = await User.findOne({ phone: '+919800000001' });
  assert.equal(String(newUser.gramSabhaId), String(dahe._id));

  // A wrong PIN is rejected.
  const bad = await request(app).post('/api/v1/auth/login').send({ phone: '+919822033333', password: '000000' });
  assert.equal(bad.status, 401);
});
