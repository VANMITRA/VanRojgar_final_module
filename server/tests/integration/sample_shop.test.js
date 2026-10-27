import test from 'node:test';
import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const run = promisify(execFile);
const script = path.join(path.dirname(fileURLToPath(import.meta.url)), '../../scripts/seed_sample_shop.js');

// Needs an in-memory MongoDB replica set; skipped when the binary cannot be downloaded.
let rs = null;
try {
  const { MongoMemoryReplSet } = await import('mongodb-memory-server');
  rs = await MongoMemoryReplSet.create({ replSet: { count: 1 } });
} catch (err) {
  console.warn(`integration tests skipped: ${err.message.split('\n')[0]}`);
}

test('sample data script: labelled Sample, several sellers per product, orders for each role, safe to run twice', { skip: !rs }, async (t) => {
  process.env.MONGODB_URI = rs.getUri('vanrozgar_sample_test');
  process.env.SEED_DEMO_PASSWORD = '123456';
  const { seed } = await import('../../src/seed/run.js');
  await seed();
  const { app } = await import('../../src/app.js');
  const { connectDB, disconnectDB } = await import('../../src/core/db.js');
  await connectDB();
  const server = app.listen(0);
  t.after(async () => { server.close(); await disconnectDB(); await rs.stop(); });
  const api = `http://127.0.0.1:${server.address().port}/api/v1`;
  const get = async (p, token) => (await fetch(`${api}${p}`, { headers: token ? { Authorization: `Bearer ${token}` } : {} })).json();
  const login = async (phone) => (await (await fetch(`${api}/auth/login`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ phone, password: '123456' })
  })).json()).data.token;

  const dry = await run('node', [script, '--api', api]);
  assert.match(dry.stdout, /dry run only/);
  assert.equal((await get('/shop/home')).data.openListings, 0, 'a dry run writes nothing');

  const first = await run('node', [script, '--api', api, '--apply']);
  assert.match(first.stdout, /listings created: 22, already there: 0/, first.stdout);
  assert.match(first.stdout, /sample requests created: 5/, first.stdout);
  assert.doesNotMatch(first.stdout, /FAILED/, first.stdout);

  const second = await run('node', [script, '--api', api, '--apply']);
  assert.match(second.stdout, /listings created: 0, already there: 22/, second.stdout);
  assert.match(second.stdout, /sample requests created: 0/, second.stdout);

  // everything is labelled Sample and the shop looks alive
  const products = (await get('/shop/products?limit=50')).data.products;
  assert.ok(products.length >= 14, `${products.length} products`);
  const bamboo = products.find((p) => p.productCode === 'bamboo');
  assert.equal(bamboo.sellerCount, 4, 'bamboo has several sellers');
  assert.ok(bamboo.bestDiscountPercent > 0);
  const home = (await get('/shop/home')).data;
  assert.ok(home.deals.length > 0 && home.bestSellers.length > 0 && home.newArrivals.length > 0, 'no empty rows on the home screen');
  assert.equal(home.categories.length, 5, 'the five categories that have sample products (honey and herbs have none yet)');
  assert.ok(home.categories.every((c) => c.listingCount > 0), 'every category has products');
  const all = (await get('/shop/products/bamboo/sellers')).data.sellers;
  assert.ok(all.every((s) => s.isSample === true && /\(Sample\)/.test(s.title.en)), 'every listing is labelled Sample');

  // each role has something on its screens
  const buyer = await login('+919822033333');
  assert.ok((await get('/requests?scope=mine', buyer)).data.length >= 4, 'the buyer has requests');
  assert.ok((await get('/orders?scope=buying', buyer)).data.length >= 2, 'the buyer has orders');
  const waghera = await login('+919822011014');
  assert.ok((await get('/orders?scope=selling', waghera)).data.length >= 1, 'a Gram Sabha has an approved order to hand over');
  const kochargaon = await login('+919822011006');
  assert.ok((await get('/requests?scope=incoming', kochargaon)).data.length >= 1, 'a Gram Sabha has a pending request');
  const cfr = await login('+919822044444');
  assert.ok((await get('/requests?scope=mine', cfr)).data.length >= 1, 'the CFR holder has a request of their own');
});
