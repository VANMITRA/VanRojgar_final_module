import test from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';

// Who receives a request and an order, and who must not see it. Needs an in-memory MongoDB replica set;
// skipped when the binary cannot be downloaded.
let rs = null;
try {
  const { MongoMemoryReplSet } = await import('mongodb-memory-server');
  rs = await MongoMemoryReplSet.create({ replSet: { count: 1 } });
} catch (err) {
  console.warn(`integration tests skipped: ${err.message.split('\n')[0]}`);
}

test('a request reaches only the Gram Sabha it is for; the order reaches only the buyer and the seller', { skip: !rs }, async (t) => {
  process.env.MONGODB_URI = rs.getUri('vanrozgar_visibility_test');
  process.env.SEED_DEMO_PASSWORD = '123456';
  const { seed } = await import('../../src/seed/run.js');
  await seed();
  const { app } = await import('../../src/app.js');
  const { connectDB, disconnectDB } = await import('../../src/core/db.js');
  await connectDB();
  t.after(async () => { await disconnectDB(); await rs.stop(); });
  const auth = (token) => ({ Authorization: `Bearer ${token}` });
  const login = async (phone) => {
    const res = await request(app).post('/api/v1/auth/login').send({ phone, password: '123456' });
    assert.equal(res.status, 200, phone);
    return res.body.data.token;
  };
  const get = (path, token) => request(app).get(`/api/v1${path}`).set(auth(token));
  const list = (res) => (Array.isArray(res.body.data) ? res.body.data : res.body.data.items ?? []);

  const devgaon = await login('+919822011009');  // the seller
  const dongargaon = await login('+919822011001'); // another village's Gram Sabha
  const buyer = await login('+919822033333');
  const farmer = await login('+919822022222');   // Devgaon villager
  const cfr = await login('+919822044444');      // Devgaon CFR holder

  const cats = await request(app).get('/api/v1/categories');
  const categoryId = (Array.isArray(cats.body.data) ? cats.body.data : cats.body.data.categories)[0]._id;
  const made = await request(app).post('/api/v1/listings').set(auth(devgaon)).send({
    titleMr: 'बांबू', titleEn: 'Bamboo poles', categoryId, quantityAvailable: 20, unit: 'piece',
    pricePerUnitRupees: 100, mode: 'sell', sustainableDeclared: true, fulfilment: 'both'
  });
  assert.equal(made.status, 201, JSON.stringify(made.body));

  // --- the buyer sends a request
  const req = await request(app).post('/api/v1/requests').set(auth(buyer))
    .send({ listingId: made.body.data._id, quantity: 4, deliveryPref: 'pickup', paymentMethod: 'cod' });
  assert.equal(req.status, 201, JSON.stringify(req.body));
  const requestId = req.body.data._id;

  // the right Gram Sabha receives it, and gets a notification
  const incoming = list(await get('/requests?scope=incoming', devgaon));
  assert.ok(incoming.some((r) => r._id === requestId), 'the seller sees the incoming request');
  const sellerMessages = list(await get('/messages', devgaon));
  assert.ok(sellerMessages.length >= 1, 'the seller has a notification about the request');

  // nobody else receives it
  for (const [who, token] of [['another village', dongargaon], ['a farmer', farmer], ['a CFR holder', cfr]]) {
    const theirs = list(await get('/requests?scope=incoming', token));
    assert.equal(theirs.some((r) => r._id === requestId), false, `${who} must not see the request`);
  }
  // the buyer sees it under their own requests
  assert.ok(list(await get('/requests?scope=mine', buyer)).some((r) => r._id === requestId));
  // a stranger cannot open it by id
  assert.notEqual((await get(`/requests/${requestId}`, dongargaon)).status, 200);
  // a buyer cannot approve their own request, and another village cannot approve it
  const tryApprove = (token) => request(app).patch(`/api/v1/requests/${requestId}/status`).set(auth(token)).send({ action: 'approve' });
  assert.equal((await tryApprove(buyer)).status, 403);
  assert.equal((await tryApprove(dongargaon)).status, 403);

  // --- the seller approves: an order exists for both, and the buyer is told
  const ok = await tryApprove(devgaon);
  assert.equal(ok.status, 200, JSON.stringify(ok.body));
  const orderId = ok.body.data.order._id;
  assert.ok(list(await get('/orders?scope=buying', buyer)).some((o) => o._id === orderId), 'the buyer has the order');
  assert.ok(list(await get('/orders?scope=selling', devgaon)).some((o) => o._id === orderId), 'the seller has the order');
  const buyerMessages = list(await get('/messages', buyer));
  assert.ok(buyerMessages.some((m) => String(m.orderId) === orderId), 'the buyer is told the order was approved');

  // nobody else can see or open the order
  for (const [who, token] of [['another village', dongargaon], ['a farmer', farmer], ['a CFR holder', cfr]]) {
    assert.equal(list(await get('/orders?scope=selling', token)).some((o) => o._id === orderId), false, `${who}: not in selling`);
    assert.equal(list(await get('/orders?scope=buying', token)).some((o) => o._id === orderId), false, `${who}: not in buying`);
    assert.equal((await get(`/orders/${orderId}`, token)).status, 403, `${who} cannot open the order`);
  }
  // stock went down by the quantity ordered
  const after = await request(app).get(`/api/v1/listings/${made.body.data._id}`);
  assert.equal(after.body.data.quantityAvailable, 16);

  // --- the order moves along, and each side sees the same state
  assert.equal((await request(app).post(`/api/v1/orders/${orderId}/handover`).set(auth(buyer))).status, 403, 'only the seller hands over');
  assert.equal((await request(app).post(`/api/v1/orders/${orderId}/handover`).set(auth(devgaon))).status, 200);
  assert.equal((await get(`/orders/${orderId}`, buyer)).body.data.orderStatus, 'handed_over');
  assert.equal((await request(app).post(`/api/v1/orders/${orderId}/confirm-received`).set(auth(devgaon))).status, 403, 'only the buyer confirms receipt');
  assert.equal((await request(app).post(`/api/v1/orders/${orderId}/confirm-received`).set(auth(buyer))).status, 200);
  assert.equal((await get(`/orders/${orderId}`, devgaon)).body.data.orderStatus, 'closed');
});
