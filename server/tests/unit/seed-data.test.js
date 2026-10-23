import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
const d = (f) => JSON.parse(fs.readFileSync(new URL(`../../src/seed/data/${f}`, import.meta.url), 'utf-8'));
const UNITS = ['kg', 'g', 'quintal', 'litre', 'piece', 'bundle', 'jar', 'bag'];
test('seed: 10 pilot villages, 50 listings, 13 accounts', () => {
  assert.equal(d('village_points.json').length, 10);
  assert.equal(d('demo_listings.json').length, 50);
  assert.equal(d('demo_accounts.json').length, 13);
});
test('seed: no banned/wild products, valid prices and units', () => {
  for (const l of d('demo_listings.json')) {
    assert.ok(!/wild|lac\b|mahua|gum|ashwagandha/i.test(l.titleEn), l.titleEn);
    assert.ok(Number.isInteger(l.pricePerUnitRupees) && l.pricePerUnitRupees > 0);
    assert.ok(UNITS.includes(l.unit));
  }
});
test('seed: every listing village has a Gram Sabha account', () => {
  const gs = new Set(d('demo_accounts.json').filter((u) => u.role === 'gramsabha').map((u) => u.village));
  for (const l of d('demo_listings.json')) assert.ok(gs.has(l.village), l.village);
});
