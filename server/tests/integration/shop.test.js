import test from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';

// Needs an in-memory MongoDB replica set; skipped when the binary cannot be downloaded.
let rs = null;
try {
  const { MongoMemoryReplSet } = await import('mongodb-memory-server');
  rs = await MongoMemoryReplSet.create({ replSet: { count: 1 } });
} catch (err) {
  console.warn(`integration tests skipped: ${err.message.split('\n')[0]}`);
}

test('shop: guest browsing, MRP and discount, many sellers, minimum order, live stock, cart checkout, roles', { skip: !rs }, async (t) => {
  process.env.MONGODB_URI = rs.getUri('vanrozgar_shop_test');
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
  const api = (path) => request(app).get(`/api/v1${path}`);

  const devgaon = await login('+919822011009');     // Gram Sabha
  const dongargaon = await login('+919822011001');  // another Gram Sabha
  const cfr = await login('+919822044444');         // CFR holder (Devgaon)
  const buyer = await login('+919822033333');

  const cats = await api('/categories');
  const catList = Array.isArray(cats.body.data) ? cats.body.data : cats.body.data.categories;
  const categoryId = catList[0]._id;
  const list = (token, body) => request(app).post('/api/v1/listings').set(auth(token)).send({
    titleMr: 'बांबू', titleEn: 'Bamboo poles', categoryId, productCode: 'bamboo', quantityAvailable: 100, unit: 'piece',
    pricePerUnitRupees: 200, mode: 'sell', sustainableDeclared: true, fulfilment: 'both', ...body
  });

  // ---- roles: a buyer never sells; an old app that sends `villager` signs up as a CFR holder
  assert.equal((await list(buyer, {})).status, 403, 'a buyer cannot sell');
  const reg = await request(app).post('/api/v1/auth/register').send({
    role: 'villager', name: 'Old Build User', phone: '+919800000077', password: '123456', village: 'Devgaon', taluka: 'Trimbakeshwar'
  });
  assert.equal(reg.status, 201, JSON.stringify(reg.body));
  assert.equal(reg.body.data.user.role, 'cfrholder');

  // ---- MRP rules
  assert.equal((await list(devgaon, { pricePerUnitRupees: 250, mrpPerUnitRupees: 200 })).status, 422, 'price above MRP is refused');
  const a = await list(devgaon, { pricePerUnitRupees: 120, mrpPerUnitRupees: 200, minOrderQuantity: 20 });
  assert.equal(a.status, 201, JSON.stringify(a.body));
  assert.equal(a.body.data.discountPercent, 40);
  assert.equal(a.body.data.discountPaise, 8000);
  assert.equal(a.body.data.quantityTotal, 100);
  assert.equal(a.body.data.minOrderQuantity, 20);
  const b = await list(dongargaon, { pricePerUnitRupees: 150 });          // no MRP: no discount
  const c = await list(cfr, { pricePerUnitRupees: 140, mrpPerUnitRupees: 160, quantityAvailable: 50 }); // a CFR holder sells too
  assert.equal(b.status, 201); assert.equal(c.status, 201);
  assert.equal(b.body.data.discountPercent, 0);

  // lowering the price keeps the MRP: that is the discount
  const lowered = await request(app).patch(`/api/v1/listings/${b.body.data._id}`).set(auth(dongargaon)).send({ pricePerUnitRupees: 100 });
  assert.equal(lowered.status, 200, JSON.stringify(lowered.body));
  assert.equal(lowered.body.data.mrpPerUnitPaise, 15000);
  assert.equal(lowered.body.data.discountPercent, 33);
  assert.equal((await request(app).patch(`/api/v1/listings/${b.body.data._id}`).set(auth(dongargaon)).send({ pricePerUnitRupees: 400 })).status, 422, 'raising the price above the MRP is refused');

  // ---- guests browse with no token
  const home = await api('/shop/home');
  assert.equal(home.status, 200, JSON.stringify(home.body));
  assert.ok(home.body.data.deals.length >= 2, 'deals show the discounted listings');
  assert.ok(home.body.data.deals[0].discountPercent >= home.body.data.deals[1].discountPercent, 'biggest discount first');
  assert.ok(home.body.data.categories.length >= 1 && home.body.data.categories.every((c) => c.listingCount > 0) && home.body.data.openListings >= 3);

  // ---- many sellers for one product
  const products = await api('/shop/products?q=bamboo');
  assert.equal(products.status, 200);
  const bamboo = products.body.data.products.find((p) => p.productCode === 'bamboo');
  assert.equal(bamboo.sellerCount, 3);
  assert.equal(bamboo.minPricePaise, 10000);
  assert.equal(bamboo.maxPricePaise, 14000);
  assert.equal(bamboo.bestDiscountPercent, 40);
  const sellers = await api('/shop/products/bamboo/sellers');
  assert.equal(sellers.status, 200);
  assert.deepEqual(sellers.body.data.sellers.map((s) => s.pricePerUnitPaise), [10000, 12000, 14000], 'cheapest first');
  assert.equal(sellers.body.data.sellers[0].isLowestPrice, true);
  assert.equal(sellers.body.data.sellers[2].isLowestPrice, false);
  assert.deepEqual([...new Set(sellers.body.data.sellers.map((s) => s.seller.type))].sort(), ['cfrholder', 'gramsabha']);
  assert.equal((await api('/shop/products/nothing-here/sellers')).status, 404);

  // ---- minimum order and part quantity with live stock (seller A: 100 pieces, minimum 20)
  const buy = (token, listingId, quantity) => request(app).post('/api/v1/requests').set(auth(token)).send({ listingId, quantity, deliveryPref: 'pickup', paymentMethod: 'cod' });
  assert.equal((await buy(buyer, a.body.data._id, 5)).status, 422, 'below the seller minimum');
  const part = await buy(buyer, a.body.data._id, 30);
  assert.equal(part.status, 201, JSON.stringify(part.body));
  const approved = await request(app).patch(`/api/v1/requests/${part.body.data._id}/status`).set(auth(devgaon)).send({ action: 'approve' });
  assert.equal(approved.status, 200, JSON.stringify(approved.body));
  const stock = await api(`/shop/stock?ids=${a.body.data._id},${b.body.data._id}`);
  assert.equal(stock.status, 200);
  const sa = stock.body.data.find((s) => s.id === a.body.data._id);
  assert.deepEqual([sa.quantityTotal, sa.quantitySold, sa.quantityAvailable, sa.soldPercent], [100, 30, 70, 30]);
  assert.equal((await api('/shop/stock?ids=nope')).status, 422);

  // ---- cart: two products, one cannot be requested (more than is left); the other goes through
  const cart = await request(app).post('/api/v1/shop/cart/checkout').set(auth(buyer)).send({
    items: [{ listingId: c.body.data._id, quantity: 10 }, { listingId: b.body.data._id, quantity: 5000 }],
    deliveryPref: 'pickup', paymentMethod: 'cod'
  });
  assert.equal(cart.status, 201, JSON.stringify(cart.body));
  assert.equal(cart.body.data.created.length, 1);
  assert.equal(cart.body.data.failed.length, 1);
  assert.equal(cart.body.data.failed[0].listingId, b.body.data._id);
  const incomingCfr = await request(app).get('/api/v1/requests?scope=incoming').set(auth(cfr));
  assert.ok((Array.isArray(incomingCfr.body.data) ? incomingCfr.body.data : []).length >= 1, 'the CFR holder seller gets the request');
  // nothing can be requested: refused with the reason per product
  const none = await request(app).post('/api/v1/shop/cart/checkout').set(auth(buyer)).send({ items: [{ listingId: b.body.data._id, quantity: 5000 }] });
  assert.equal(none.status, 409);
  // two sellers in one cart: each seller gets their own request
  const two = await request(app).post('/api/v1/shop/cart/checkout').set(auth(buyer)).send({
    items: [{ listingId: c.body.data._id, quantity: 5 }, { listingId: b.body.data._id, quantity: 5 }]
  });
  assert.equal(two.status, 201, JSON.stringify(two.body));
  assert.equal(two.body.data.created.length, 2);
  assert.notEqual(two.body.data.created[0].request.sellerId, two.body.data.created[1].request.sellerId);
  // guests must sign in at checkout; the same product twice is refused
  assert.equal((await request(app).post('/api/v1/shop/cart/checkout').send({ items: [{ listingId: c.body.data._id, quantity: 1 }] })).status, 401);
  assert.equal((await request(app).post('/api/v1/shop/cart/checkout').set(auth(buyer)).send({ items: [{ listingId: c.body.data._id, quantity: 1 }, { listingId: c.body.data._id, quantity: 1 }] })).status, 422);
  assert.equal((await request(app).post('/api/v1/shop/cart/checkout').set(auth(buyer)).send({ items: [] })).status, 422);
});
