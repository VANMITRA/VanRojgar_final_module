import test from 'node:test';
import assert from 'node:assert/strict';
import { pricingOf, stockOf, minimumOrder, minimumOrderProblem } from '../../src/core/pricing.js';

test('discount: MRP 200 and price 120 is 40% off, 80 rupees', () => {
  assert.deepEqual(pricingOf({ pricePerUnitPaise: 12000, mrpPerUnitPaise: 20000 }),
    { mrpPerUnitPaise: 20000, discountPaise: 8000, discountPercent: 40 });
});

test('discount: an old listing with no MRP has no discount', () => {
  assert.deepEqual(pricingOf({ pricePerUnitPaise: 12000 }), { mrpPerUnitPaise: 12000, discountPaise: 0, discountPercent: 0 });
  assert.equal(pricingOf({ pricePerUnitPaise: 0 }).discountPercent, 0);
});

test('discount: an MRP below the price is ignored (never a negative discount)', () => {
  const p = pricingOf({ pricePerUnitPaise: 12000, mrpPerUnitPaise: 9000 });
  assert.equal(p.discountPaise, 0);
  assert.equal(p.mrpPerUnitPaise, 12000);
});

test('stock: 100 listed, 38 left is 62 sold', () => {
  assert.deepEqual(stockOf({ quantityTotal: 100, quantityAvailable: 38 }), { quantityTotal: 100, quantitySold: 62, soldPercent: 62 });
});

test('stock: an old listing with no total shows nothing sold', () => {
  assert.deepEqual(stockOf({ quantityAvailable: 30 }), { quantityTotal: 30, quantitySold: 0, soldPercent: 0 });
});

test('minimum order: default is 1; the last units left can always be bought whole', () => {
  assert.equal(minimumOrder({}), 1);
  const l = { minOrderQuantity: 20, quantityAvailable: 100, unit: 'kg' };
  assert.match(minimumOrderProblem(l, 5), /minimum order .* 20 kg/);
  assert.equal(minimumOrderProblem(l, 20), null);
  assert.equal(minimumOrderProblem({ ...l, quantityAvailable: 7 }, 7), null, 'buying all that is left is fine');
  assert.match(minimumOrderProblem({ ...l, quantityAvailable: 7 }, 5), /minimum/);
});
