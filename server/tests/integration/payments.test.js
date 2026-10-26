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

test('payments: UPI needs the seller to confirm; cash on delivery is marked by the partner or seller', { skip: !rs }, async (t) => {
  process.env.MONGODB_URI = rs.getUri('vanrozgar_payments_test');
  process.env.SEED_DEMO_PASSWORD = '123456';
  process.env.UPI_ID = 'team@okaxis';
  const { seed } = await import('../../src/seed/run.js');
  await seed();
  const { app } = await import('../../src/app.js');
  const { connectDB, disconnectDB } = await import('../../src/core/db.js');
  await connectDB();
  t.after(async () => { await disconnectDB(); await rs.stop(); });
  const { Order } = await import('../../src/models/Order.js');
  const auth = (token) => ({ Authorization: `Bearer ${token}` });
  const login = async (phone) => (await request(app).post('/api/v1/auth/login').send({ phone, password: '123456' })).body.data.token;
  const sellerToken = await login('+919822011009'); // Devgaon Gram Sabha
  const buyerToken = await login('+919822033333');
  const strangerToken = await login('+919822022222');

  const cats = await request(app).get('/api/v1/categories');
  const categoryId = (Array.isArray(cats.body.data) ? cats.body.data : cats.body.data.categories)[0]._id;
  const listing = async (title) => (await request(app).post('/api/v1/listings').set(auth(sellerToken)).send({
    titleMr: 'मध', titleEn: title, categoryId, quantityAvailable: 50, unit: 'jar',
    pricePerUnitRupees: 100, mode: 'sell', sustainableDeclared: true, fulfilment: 'both'
  })).body.data;
  const makeOrder = async (title) => {
    const l = await listing(title);
    const req = await request(app).post('/api/v1/requests').set(auth(buyerToken)).send({ listingId: l._id, quantity: 3, deliveryPref: 'pickup' });
    assert.equal(req.status, 201, JSON.stringify(req.body));
    const ok = await request(app).patch(`/api/v1/requests/${req.body.data._id}/status`).set(auth(sellerToken)).send({ action: 'approve' });
    assert.equal(ok.status, 200, JSON.stringify(ok.body));
    return Order.findOne({ requestId: req.body.data._id });
  };

  // ---- UPI ----
  const o1 = await makeOrder('UPI honey');
  const url = `/api/v1/orders/${o1._id}`;
  assert.equal(o1.paymentMethod, undefined);
  assert.equal((await request(app).post(`${url}/payment/method`).set(auth(strangerToken)).send({ method: 'upi' })).status, 403);
  assert.equal((await request(app).post(`${url}/payment/method`).set(auth(sellerToken)).send({ method: 'upi' })).status, 403, 'the seller cannot pick for the buyer');
  assert.equal((await request(app).post(`${url}/payment/method`).set(auth(buyerToken)).send({ method: 'card' })).status, 422, 'no card option');
  const chose = await request(app).post(`${url}/payment/method`).set(auth(buyerToken)).send({ method: 'upi' });
  assert.equal(chose.status, 200, JSON.stringify(chose.body));
  assert.equal(chose.body.data.paymentStatus, 'awaiting_payment');
  assert.equal((await request(app).post(`${url}/payment/method`).set(auth(buyerToken)).send({ method: 'cod' })).status, 409, 'chosen once');

  const link = await request(app).get(`${url}/payment/upi`).set(auth(buyerToken));
  assert.equal(link.status, 200, JSON.stringify(link.body));
  const parsed = new URL(link.body.data.link);
  assert.equal(parsed.searchParams.get('pa'), 'team@okaxis');
  assert.equal(parsed.searchParams.get('am'), '300.00');
  assert.equal((await request(app).get(`${url}/payment/upi`).set(auth(sellerToken))).status, 403);

  assert.equal((await request(app).post(`${url}/payment/confirm`).set(auth(sellerToken))).status, 409, 'nothing to confirm before the buyer reports');
  assert.equal((await request(app).post(`${url}/payment/report`).set(auth(buyerToken)).send({ reference: '12' })).status, 422);
  const rep = await request(app).post(`${url}/payment/report`).set(auth(buyerToken)).send({ reference: '412345678901' });
  assert.equal(rep.status, 200, JSON.stringify(rep.body));
  assert.equal(rep.body.data.paymentStatus, 'payment_reported');
  assert.equal((await request(app).post(`${url}/payment/confirm`).set(auth(buyerToken))).status, 403, 'the buyer cannot confirm their own payment');
  const conf = await request(app).post(`${url}/payment/confirm`).set(auth(sellerToken));
  assert.equal(conf.status, 200, JSON.stringify(conf.body));
  assert.equal(conf.body.data.paymentStatus, 'payment_confirmed');
  assert.equal(conf.body.data.payment.reference, '412345678901');
  assert.equal((await request(app).post(`${url}/payment/confirm`).set(auth(sellerToken))).status, 409, 'confirming twice does nothing');

  // ---- Cash on delivery (pickup: the seller marks the cash) ----
  const o2 = await makeOrder('COD honey');
  const url2 = `/api/v1/orders/${o2._id}`;
  const cod = await request(app).post(`${url2}/payment/method`).set(auth(buyerToken)).send({ method: 'cod' });
  assert.equal(cod.body.data.paymentStatus, 'cod_pending');
  assert.equal((await request(app).get(`${url2}/payment/upi`).set(auth(buyerToken))).status, 409, 'no UPI link for a COD order');
  assert.equal((await request(app).post(`${url2}/payment/cash-received`).set(auth(sellerToken))).status, 409, 'goods not handed over yet');
  assert.equal((await request(app).post(`${url2}/handover`).set(auth(sellerToken))).status, 200);
  assert.equal((await request(app).post(`${url2}/payment/cash-received`).set(auth(buyerToken))).status, 403, 'the buyer cannot mark their own cash');
  const cash = await request(app).post(`${url2}/payment/cash-received`).set(auth(sellerToken));
  assert.equal(cash.status, 200, JSON.stringify(cash.body));
  assert.equal(cash.body.data.paymentStatus, 'cash_received');
  assert.equal((await request(app).post(`${url2}/payment/cash-received`).set(auth(sellerToken))).status, 409);
});
