import test from 'node:test';
import assert from 'node:assert/strict';
import { fetchLiveListings, mapServerListing, ServerListing } from './liveListings';

const honey: ServerListing = {
  _id: 'abc123',
  itemCode: 'vr-k7m2qx',
  title: { mr: 'मधपेटीतील मध', en: 'Managed-apiary honey (500 g jar)' },
  categoryId: { slug: 'forest-produce' },
  productCode: 'honey',
  quantityAvailable: 20,
  unit: 'jar',
  pricePerUnitPaise: 35000,
  mode: 'both',
  village: 'देवगाव',
  taluka: 'Trimbakeshwar',
  provenance: { sourceForestArea: 'CFR Boundary', sustainableDeclared: true },
  gramSabha: { _id: 'g1', village: { mr: 'देवगाव', en: 'Devgaon' }, verificationStatus: 'verified_seed' },
};

test('a server listing becomes a live website listing with its own item code', () => {
  const l = mapServerListing(honey)!;
  assert.equal(l.itemCode, 'VR-K7M2QX');
  assert.equal(l.source, 'live');
  assert.equal(l.title, 'Managed-apiary honey (500 g jar) (मधपेटीतील मध)');
  assert.equal(l.category, 'forest_produce');
  assert.equal(l.pricePerUnit, 350);
  assert.equal(l.iconType, 'honey');
  assert.equal(l.mode, 'both');
  assert.equal(l.isVerified, true);
});

test('nothing is invented for a live listing: no rating, no reviews', () => {
  const l = mapServerListing(honey)!;
  assert.equal(l.rating, 0);
  assert.equal(l.reviewCount, 0);
});

test('a listing without a valid item code is dropped', () => {
  assert.equal(mapServerListing({ ...honey, itemCode: undefined }), null);
  assert.equal(mapServerListing({ ...honey, itemCode: 'nonsense' }), null);
});

test('unknown category and mode fall back safely', () => {
  const l = mapServerListing({ ...honey, categoryId: { slug: 'x' }, mode: 'weird', productCode: null })!;
  assert.equal(l.category, 'others');
  assert.equal(l.mode, 'sell');
  assert.equal(l.iconType, 'herbs');
});

const reply = (body: unknown, ok = true) => (async () => ({ ok, json: async () => body })) as unknown as typeof fetch;

test('fetchLiveListings: no server set means no live data (the site keeps Sample)', async () => {
  assert.equal(await fetchLiveListings(''), null);
});

test('fetchLiveListings: maps the listings of a successful reply', async () => {
  const rows = await fetchLiveListings('https://api.example', reply({ data: { listings: [honey, { ...honey, itemCode: null }] } }));
  assert.equal(rows?.length, 1);
  assert.equal(rows?.[0].itemCode, 'VR-K7M2QX');
});

test('fetchLiveListings: an empty marketplace gives an empty list', async () => {
  assert.deepEqual(await fetchLiveListings('https://api.example', reply({ data: { listings: [] } })), []);
});

test('fetchLiveListings: errors, bad replies and network failures give null, never a crash', async () => {
  assert.equal(await fetchLiveListings('https://api.example', reply({}, false)), null);
  assert.equal(await fetchLiveListings('https://api.example', reply({ data: {} })), null);
  const down = (async () => {
    throw new Error('offline');
  }) as unknown as typeof fetch;
  assert.equal(await fetchLiveListings('https://api.example', down), null);
});

test('fetchLiveListings: asks the public search endpoint of the given server', async () => {
  let url = '';
  const spy = (async (u: string) => {
    url = u;
    return { ok: true, json: async () => ({ data: { listings: [] } }) };
  }) as unknown as typeof fetch;
  await fetchLiveListings('https://api.example', spy);
  assert.equal(url, 'https://api.example/api/v1/search?limit=50');
});
