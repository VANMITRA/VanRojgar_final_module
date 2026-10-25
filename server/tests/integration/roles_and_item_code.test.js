import test from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';

// Needs a real MongoDB replica set (started in memory); skipped when the binary cannot be downloaded.
let rs = null;
try {
  const { MongoMemoryReplSet } = await import('mongodb-memory-server');
  rs = await MongoMemoryReplSet.create({ replSet: { count: 1 } });
} catch (err) {
  console.warn(`integration tests skipped: ${err.message.split('\n')[0]}`);
}

test('roles and item codes: CFR holder signs up, a new listing gets a code, the code finds it', { skip: !rs }, async (t) => {
  process.env.MONGODB_URI = rs.getUri('vanrozgar_roles_test');
  process.env.SEED_DEMO_PASSWORD = '123456';
  const { seed } = await import('../../src/seed/run.js');
  await seed();
  const { app } = await import('../../src/app.js');
  const { connectDB, disconnectDB } = await import('../../src/core/db.js');
  await connectDB();
  t.after(async () => { await disconnectDB(); await rs.stop(); });
  const { User } = await import('../../src/models/User.js');
  const { Listing } = await import('../../src/models/Listing.js');
  const jwt = (await import('jsonwebtoken')).default;
  const { config } = await import('../../src/core/config.js');
  const auth = (token) => ({ Authorization: `Bearer ${token}` });

  // A CFR holder can sign up and sign in, and the token carries the role the Python server reads
  const reg = await request(app).post('/api/v1/auth/register').send({
    role: 'cfrholder', name: 'Test CFR Holder', phone: '+919800000011', password: '654321',
    village: 'Devgaon', taluka: 'Trimbakeshwar'
  });
  assert.equal(reg.status, 201, JSON.stringify(reg.body));
  assert.equal(reg.body.data.user.role, 'cfrholder');
  assert.equal(jwt.verify(reg.body.data.token, config.JWT_SECRET).role, 'cfrholder');
  assert.ok((await User.findOne({ phone: '+919800000011' })).gramSabhaId, 'attached to the village Gram Sabha');
  const signin = await request(app).post('/api/v1/auth/login').send({ phone: '+919800000011', password: '654321' });
  assert.equal(signin.status, 200);
  assert.equal(signin.body.data.user.role, 'cfrholder');

  // The seeded demo CFR holder signs in; an old farmer account still works
  const demo = await request(app).post('/api/v1/auth/login').send({ phone: '+919822044444', password: '123456' });
  assert.equal(demo.status, 200);
  assert.equal(demo.body.data.user.role, 'cfrholder');
  const farmer = await request(app).post('/api/v1/auth/login').send({ phone: '+919822022222', password: '123456' });
  assert.equal(farmer.body.data.user.role, 'villager');

  // A CFR holder can apply as a delivery partner like a farmer; a buyer cannot
  const apply = { vehicleType: 'bike', vehicleNumber: 'MH15AB1234', capacityKg: 40, licenceNumber: 'MH1520260001', serviceTalukas: ['Trimbakeshwar'] };
  const okApply = await request(app).post('/api/v1/delivery-partners/applications').set(auth(demo.body.data.token)).send(apply);
  assert.equal(okApply.status, 201, JSON.stringify(okApply.body));
  const buyer = await request(app).post('/api/v1/auth/login').send({ phone: '+919822033333', password: '123456' });
  const noApply = await request(app).post('/api/v1/delivery-partners/applications').set(auth(buyer.body.data.token)).send(apply);
  assert.equal(noApply.status, 403);

  // A Gram Sabha lists a product: the listing gets an item code of its own
  const gs = await request(app).post('/api/v1/auth/login').send({ phone: '+919822011009', password: '123456' }); // Devgaon
  assert.equal(gs.status, 200);
  const cats = await request(app).get('/api/v1/categories');
  const list = Array.isArray(cats.body.data) ? cats.body.data : cats.body.data.categories;
  const categoryId = list[0]._id;
  assert.ok(categoryId, 'categories are seeded');
  const body = {
    titleMr: 'मधपेटीतील मध', titleEn: 'Managed-apiary honey (500 g jar)', categoryId, quantityAvailable: 20, unit: 'jar',
    pricePerUnitRupees: 350, mode: 'sell', sustainableDeclared: true, fulfilment: 'both'
  };
  const made = await request(app).post('/api/v1/listings').set(auth(gs.body.data.token)).send(body);
  assert.equal(made.status, 201, JSON.stringify(made.body));
  const code = made.body.data.itemCode;
  assert.match(code, /^VR-[2-9A-HJKMNP-Z]{6}$/);
  const second = await request(app).post('/api/v1/listings').set(auth(gs.body.data.token)).send({ ...body, titleEn: 'Bamboo planter', titleMr: 'बांबू कुंडी' });
  assert.equal(second.status, 201, JSON.stringify(second.body));
  assert.notEqual(second.body.data.itemCode, code, 'every listing has its own code');

  // The code finds exactly that listing in search, in any spelling, and by its own address
  for (const spelling of [code, code.toLowerCase(), code.replace('-', ' '), `  ${code.replace('-', '')} `]) {
    const found = await request(app).get('/api/v1/search').query({ q: spelling });
    assert.equal(found.status, 200);
    assert.equal(found.body.data.listings.length, 1, spelling);
    assert.equal(found.body.data.listings[0].itemCode, code);
    assert.equal(found.body.data.listings[0].title.en, 'Managed-apiary honey (500 g jar)');
  }
  const byCode = await request(app).get(`/api/v1/listings/code/${code.toLowerCase()}`);
  assert.equal(byCode.status, 200);
  assert.equal(byCode.body.data.itemCode, code);
  assert.equal((await request(app).get('/api/v1/listings/code/VR-ZZZZZZ')).status, 404);
  assert.equal((await request(app).get('/api/v1/listings/code/honey')).status, 404);

  // A paused listing is no longer found by its code
  await Listing.updateOne({ itemCode: code }, { $set: { status: 'paused' } });
  const paused = await request(app).get('/api/v1/search').query({ q: code });
  assert.equal(paused.body.data.listings.length, 0);
  assert.equal((await request(app).get(`/api/v1/listings/code/${code}`)).status, 404);
});
