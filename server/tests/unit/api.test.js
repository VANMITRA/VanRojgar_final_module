import test from 'node:test';
import assert from 'node:assert/strict';

function escapeRegex(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

test('search: regex escaping safely handles special characters without crashing', () => {
  const queryWithSymbols = '3(1)(c) + wild-honey? [organic]*';
  const tokens = queryWithSymbols.split(' ');

  for (const token of tokens) {
    assert.doesNotThrow(() => {
      const escaped = escapeRegex(token);
      new RegExp(`^${escaped}`, 'i');
    });
  }
});

test('trade: counter price calculation overrides default listing price', () => {
  const listing = { pricePerUnitPaise: 15000 }; // ₹150
  const requestWithCounter = {
    quantity: 10,
    counter: { pricePerUnitPaise: 12000 } // ₹120 agreed
  };

  const finalUnitPrice = (requestWithCounter.counter && requestWithCounter.counter.pricePerUnitPaise)
    ? requestWithCounter.counter.pricePerUnitPaise
    : listing.pricePerUnitPaise;

  const total = Math.round(requestWithCounter.quantity * finalUnitPrice);
  assert.equal(finalUnitPrice, 12000);
  assert.equal(total, 120000); // ₹1200
});

test('trade: coordinate privacy rounding to 2 decimal places (~1.1 km)', () => {
  const exactCoordinates = [73.7898421, 19.9975319];
  const rounded = [
    Math.round(exactCoordinates[0] * 100) / 100,
    Math.round(exactCoordinates[1] * 100) / 100
  ];

  assert.equal(rounded[0], 73.79);
  assert.equal(rounded[1], 20.00);
});

test('rateLimit: parseRateLimit correctly extracts count and window seconds', async () => {
  const { parseRateLimit } = await import('../../src/core/config.js');
  
  const rl1 = parseRateLimit('30/15m');
  assert.equal(rl1.max, 30);
  assert.equal(rl1.windowSeconds, 900);

  const rl2 = parseRateLimit('120/1m');
  assert.equal(rl2.max, 120);
  assert.equal(rl2.windowSeconds, 60);

  const rl3 = parseRateLimit('500/1h');
  assert.equal(rl3.max, 500);
  assert.equal(rl3.windowSeconds, 3600);
});

