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

test('dataset: seeding loads only the 14 Raah villages, registration is limited to them, listings start empty', { skip: !rs }, async (t) => {
  process.env.MONGODB_URI = rs.getUri('vanrozgar_test');
  process.env.SEED_DEMO_PASSWORD = '123456';
  const { seed } = await import('../../src/seed/run.js');
  await seed();
  const { app } = await import('../../src/app.js');
  const { connectDB, disconnectDB } = await import('../../src/core/db.js');
  await connectDB(); // the seeder disconnects when it finishes
  t.after(async () => { await disconnectDB(); await rs.stop(); });

  const { GramSabha } = await import('../../src/models/GramSabha.js');
  const { Listing } = await import('../../src/models/Listing.js');
  const { User } = await import('../../src/models/User.js');
  const { importRaah } = await import('../../src/seed/raah.js');

  // Exactly the 14 villages, each with the report's figures
  assert.equal(await GramSabha.countDocuments(), 14);
  assert.deepEqual((await GramSabha.distinct('taluka')).sort(), ['Deola', 'Dindori', 'Trimbakeshwar']);
  const waghera = await GramSabha.findOne({ 'village.en': 'Waghera' });
  assert.equal(waghera.restoration.saplings, 27534);
  assert.equal(waghera.cfr.approvedAreaHa, 200);
  assert.equal(await Listing.countDocuments(), 0, 'no demo listings');
  assert.equal(await User.countDocuments({ role: 'gramsabha' }), 14);

  // The list a person picks their village from has these 14 and nothing else
  const all = await request(app).get('/api/v1/gramsabhas').query({ limit: 500 });
  assert.equal(all.status, 200);
  assert.equal(all.body.data.length, 14);

  // The village page returns the figures
  const detail = await request(app).get(`/api/v1/gramsabhas/${waghera._id}`);
  assert.equal(detail.status, 200);
  assert.equal(detail.body.data.gramSabha.restoration.species.length, 28);
  assert.equal(detail.body.data.gramSabha.claim?.claimantPhone, undefined, 'claimant phone is never public');

  // Importing again changes nothing
  const again = await importRaah({ apply: true });
  assert.equal(again.created, 0);
  assert.equal(await GramSabha.countDocuments(), 14);

  // Registering for a dataset village files a claim on THAT record; any other village is refused.
  const reg = await request(app).post('/api/v1/auth/register').send({
    role: 'gramsabha', name: 'Test Secretary', phone: '+919800000001', password: '654321',
    village: 'Kochargaon', taluka: 'Dindori'
  });
  assert.equal(reg.status, 201);
  assert.equal(await GramSabha.countDocuments(), 14, 'no duplicate Gram Sabha');
  const koch = await GramSabha.findOne({ 'village.en': 'Kochargaon' });
  assert.equal(koch.claim.status, 'pending');
  assert.equal(String((await User.findOne({ phone: '+919800000001' })).gramSabhaId), String(koch._id));

  const other = await request(app).post('/api/v1/auth/register').send({
    role: 'villager', name: 'Someone Else', phone: '+919800000002', password: '654321',
    village: 'मातोरी', taluka: 'Nashik'
  });
  assert.equal(other.status, 422);
  assert.equal(await User.countDocuments({ phone: '+919800000002' }), 0);

  // Demo login works, a wrong PIN is rejected, and the map layer is empty until someone lists
  const login = await request(app).post('/api/v1/auth/login').send({ phone: '+919822033333', password: '123456' });
  assert.equal(login.status, 200);
  const bad = await request(app).post('/api/v1/auth/login').send({ phone: '+919822033333', password: '000000' });
  assert.equal(bad.status, 401);
  const map = await request(app).get('/api/v1/listings/map');
  assert.equal(map.status, 200);
  assert.deepEqual(map.body.data.points, []);
});
