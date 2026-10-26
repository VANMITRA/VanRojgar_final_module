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

test('payments: UPI is reported by the buyer and confirmed by the seller; cash on delivery is marked by the delivery partner', { skip: !rs }, async (t) => {
  process.env.MONGODB_URI = rs.getUri('vanrozgar_payments_test');
  process.env.SEED_DEMO_PASSWORD = '123456';
  process.env.UPI_ID = 'vanrozgar.team@okbank';
  process.env.UPI_PAYEE_NAME = 'VanRozgar Team';
  const { seed } = await import('../../src/seed/run.js');
  await seed();
  const { app } = await import('../../src/app.js');
  const { connectDB, disconnectDB } = await import('../../src/core/db.js');
  await connectDB();
  t.after(async () => { await disconnectDB(); await rs.stop(); });
  const { DeliveryPartner } = await import('../../src/models/DeliveryPartner.js');
  const { Order } = await import('../../src/models/Order.js');
  const auth = (token) => ({ Authorization: `Bearer ${token}` });
  const login = async (phone) => {
    const res = await request(app).post('/api/v1/auth/login').send({ phone, password: '123456' });
    assert.equal(res.status, 200, phone);
    return res.body.data.token;
  };

  const seller = await login('+919822011009'); // Devgaon Gram Sabha
  const buyer = await login('+919822033333');
  const farmer = await login('+919822022222'); // Devgaon villager, also the delivery partner

  const cats = await request(app).get('/api/v1/categories');
  const categoryId = (Array.isArray(cats.body.data) ? cats.body.data : cats.body.data.categories)[0]._id;
  const made = await request(app).post('/api/v1/listings').set(auth(seller)).send({
    titleMr: 'बांबू', titleEn: 'Bamboo poles', categoryId, quantityAvailable: 100, unit: 'piece',
    pricePerUnitRupees: 100, mode: 'sell', sustainableDeclared: true, fulfilment: 'both'
  });
  assert.equal(made.status, 201, JSON.stringify(made.body));
  const listingId = made.body.data._id;

  const order = async ({ paymentMethod, deliveryPref = 'pickup', quantity = 3 }) => {
    const req = await request(app).post('/api/v1/requests').set(auth(buyer))
      .send({ listingId, quantity, deliveryPref, paymentMethod, dropVillage: 'Devgaon' });
    assert.equal(req.status, 201, JSON.stringify(req.body));
    const ok = await request(app).patch(`/api/v1/requests/${req.body.data._id}/status`).set(auth(seller)).send({ action: 'approve' });
    assert.equal(ok.status, 200, JSON.stringify(ok.body));
    return ok.body.data.order;
  };

  // What the server offers
  const options = await request(app).get('/api/v1/orders/payment-options').set(auth(buyer));
  assert.deepEqual(options.body.data, { upi: true, cod: true });

  // ---- UPI ----
  const upi = await order({ paymentMethod: 'upi' });
  assert.equal(upi.paymentMethod, 'upi');
  assert.equal(upi.paymentStatus, 'awaiting_payment');

  // Only the buyer gets the link; it carries the team UPI ID, the amount in rupees and the order
  assert.equal((await request(app).get(`/api/v1/orders/${upi._id}/payment/upi-link`).set(auth(seller))).status, 403);
  const link = await request(app).get(`/api/v1/orders/${upi._id}/payment/upi-link`).set(auth(buyer));
  assert.equal(link.status, 200, JSON.stringify(link.body));
  const url = new URL(link.body.data.link);
  assert.equal(url.protocol, 'upi:');
  assert.equal(url.searchParams.get('pa'), 'vanrozgar.team@okbank');
  assert.equal(url.searchParams.get('pn'), 'VanRozgar Team');
  assert.equal(url.searchParams.get('am'), '300.00');
  assert.equal(url.searchParams.get('cu'), 'INR');
  assert.ok(url.searchParams.get('tn').endsWith(upi._id.slice(-8)));
  assert.ok(!link.body.data.link.includes('+'), 'spaces are %20, not +');

  // The seller cannot confirm before the buyer has reported; a bad reference is refused
  assert.equal((await request(app).post(`/api/v1/orders/${upi._id}/payment/confirm`).set(auth(seller))).status, 409);
  const bad = await request(app).post(`/api/v1/orders/${upi._id}/payment/report`).set(auth(buyer)).send({ reference: '12' });
  assert.equal(bad.status, 422, JSON.stringify(bad.body));
  assert.equal((await request(app).post(`/api/v1/orders/${upi._id}/payment/report`).set(auth(seller)).send({ reference: '123456789012' })).status, 403);

  // The buyer reports: this is NOT yet a confirmed payment
  const reported = await request(app).post(`/api/v1/orders/${upi._id}/payment/report`).set(auth(buyer)).send({ reference: '123456789012' });
  assert.equal(reported.status, 200, JSON.stringify(reported.body));
  assert.equal(reported.body.data.paymentStatus, 'payment_reported');
  assert.equal(reported.body.data.payment.confirmedAt, undefined);
  assert.equal((await request(app).post(`/api/v1/orders/${upi._id}/payment/report`).set(auth(buyer)).send({ reference: '123456789012' })).status, 409, 'cannot report twice');

  // Only the seller confirms, and only then is it confirmed
  assert.equal((await request(app).post(`/api/v1/orders/${upi._id}/payment/confirm`).set(auth(buyer))).status, 403);
  const confirmed = await request(app).post(`/api/v1/orders/${upi._id}/payment/confirm`).set(auth(seller));
  assert.equal(confirmed.status, 200, JSON.stringify(confirmed.body));
  assert.equal(confirmed.body.data.paymentStatus, 'payment_confirmed');
  assert.ok(confirmed.body.data.payment.confirmedAt);
  const statuses = confirmed.body.data.timeline.map((e) => e.status);
  assert.deepEqual(statuses.slice(-2), ['payment_reported', 'payment_confirmed']);
  // The link is gone once paid; the seller was told about the report and the buyer about the confirmation
  assert.equal((await request(app).get(`/api/v1/orders/${upi._id}/payment/upi-link`).set(auth(buyer))).status, 409);
  const inbox = await request(app).get('/api/v1/messages').set(auth(seller));
  assert.match(JSON.stringify(inbox.body), /Buyer reports a UPI payment/);

  // ---- Cash on delivery, pickup: the seller marks the cash ----
  const pickup = await order({ paymentMethod: 'cod' });
  assert.equal(pickup.paymentStatus, 'cod_pending');
  assert.equal((await request(app).post(`/api/v1/orders/${pickup._id}/payment/cash-received`).set(auth(buyer))).status, 403);
  assert.equal((await request(app).post(`/api/v1/orders/${pickup._id}/payment/report`).set(auth(buyer)).send({ reference: '123456789012' })).status, 409, 'COD has no UPI report');
  const cashPickup = await request(app).post(`/api/v1/orders/${pickup._id}/payment/cash-received`).set(auth(seller));
  assert.equal(cashPickup.status, 200, JSON.stringify(cashPickup.body));
  assert.equal(cashPickup.body.data.paymentStatus, 'cash_received');
  assert.equal((await request(app).post(`/api/v1/orders/${pickup._id}/payment/cash-received`).set(auth(seller))).status, 409, 'only once');

  // ---- Cash on delivery with a delivery partner ----
  const apply = await request(app).post('/api/v1/delivery-partners/applications').set(auth(farmer))
    .send({ vehicleType: 'bike', vehicleNumber: 'MH15AB1234', capacityKg: 100, licenceNumber: 'MH1520260001', serviceTalukas: ['Trimbakeshwar'] });
  assert.equal(apply.status, 201, JSON.stringify(apply.body));
  await DeliveryPartner.updateMany({}, { $set: { approvalStatus: 'approved' } });

  const cod = await order({ paymentMethod: 'cod', deliveryPref: 'delivery' });
  assert.equal(cod.paymentStatus, 'cod_pending');
  const stranger = await request(app).post(`/api/v1/orders/${cod._id}/payment/cash-received`).set(auth(farmer));
  assert.equal(stranger.status, 403, 'a partner who has not taken the job cannot take the cash');
  assert.equal((await request(app).post(`/api/v1/orders/${cod._id}/payment/cash-received`).set(auth(seller))).status, 403, 'for a delivery the partner takes the cash');

  const jobs = await request(app).get('/api/v1/delivery-partners/jobs').set(auth(farmer));
  const job = jobs.body.data.find((j) => j.orderId === cod._id);
  assert.ok(job, 'the job is open for the partner');
  assert.equal(job.collectCashPaise, 30000, 'the partner is told how much cash to collect');
  assert.equal((await request(app).post(`/api/v1/delivery-partners/jobs/${job._id}/accept`).set(auth(farmer))).status, 200);
  // Too early: the goods are not on the way yet
  assert.equal((await request(app).post(`/api/v1/orders/${cod._id}/payment/cash-received`).set(auth(farmer))).status, 409);
  for (const status of ['picked_up', 'on_the_way']) {
    const step = await request(app).patch(`/api/v1/delivery-partners/jobs/${job._id}/status`).set(auth(farmer)).send({ status });
    assert.equal(step.status, 200, JSON.stringify(step.body));
  }
  const cash = await request(app).post(`/api/v1/orders/${cod._id}/payment/cash-received`).set(auth(farmer));
  assert.equal(cash.status, 200, JSON.stringify(cash.body));
  assert.equal(cash.body.data.paymentStatus, 'cash_received');
  const mine = await request(app).get('/api/v1/deliveries/mine').set(auth(farmer));
  assert.equal(mine.body.data.find((j) => j._id === job._id).cashCollected, true);
  // ... the seller sees it on the order and in the inbox
  const seen = await request(app).get(`/api/v1/orders/${cod._id}`).set(auth(seller));
  assert.equal(seen.body.data.paymentStatus, 'cash_received');
  assert.ok(seen.body.data.payment.cashReceivedAt);
  assert.match(JSON.stringify((await request(app).get('/api/v1/messages').set(auth(seller))).body), /Cash received/);
  // ... and the order runs to the end
  await request(app).patch(`/api/v1/delivery-partners/jobs/${job._id}/status`).set(auth(farmer)).send({ status: 'delivered' });
  const done = await request(app).post(`/api/v1/orders/${cod._id}/confirm-received`).set(auth(buyer));
  assert.equal(done.status, 200, JSON.stringify(done.body));
  assert.equal((await Order.findById(cod._id)).orderStatus, 'closed');

  // Without a team UPI ID, UPI cannot be chosen
  const { config } = await import('../../src/core/config.js');
  config.UPI_ID = '';
  const off = await request(app).post('/api/v1/requests').set(auth(buyer))
    .send({ listingId, quantity: 1, deliveryPref: 'pickup', paymentMethod: 'upi' });
  assert.equal(off.status, 409, JSON.stringify(off.body));
  assert.deepEqual((await request(app).get('/api/v1/orders/payment-options').set(auth(buyer))).body.data, { upi: false, cod: true });
});
