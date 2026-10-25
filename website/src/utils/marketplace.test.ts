import test from 'node:test';
import assert from 'node:assert/strict';
import {
  checkIsLargeOrder,
  calculateFairPriceRange,
  evaluateBarterBalance,
  calculateDeliveryPay,
  calculateGroupSellingSplit,
  LARGE_ORDER_THRESHOLD,
} from './marketplace';

test('checkIsLargeOrder correctly flags orders at and above threshold', () => {
  assert.equal(checkIsLargeOrder(10), false);
  assert.equal(checkIsLargeOrder(24), false);
  assert.equal(checkIsLargeOrder(LARGE_ORDER_THRESHOLD), true);
  assert.equal(checkIsLargeOrder(50), true);
});

test('calculateFairPriceRange returns reasonable bounds for fair guidance', () => {
  const [min, max] = calculateFairPriceRange(500);
  assert.ok(min < 500, 'Min price should be below base price');
  assert.ok(max > 500, 'Max price should be above base price');
  assert.equal(min, 440);
  assert.equal(max, 570);
});

test('evaluateBarterBalance identifies balanced swaps accurately', () => {
  // ₹1000 offered vs ₹1000 requested -> balanced
  const res1 = evaluateBarterBalance(1000, 1000);
  assert.equal(res1.verdict, 'balanced');
  assert.equal(res1.ratio, 1.0);

  // ₹1000 offered vs ₹950 requested -> within ±15% -> balanced
  const res2 = evaluateBarterBalance(1000, 950);
  assert.equal(res2.verdict, 'balanced');

  // ₹1500 offered vs ₹1000 requested -> favorable to receiver
  const res3 = evaluateBarterBalance(1500, 1000);
  assert.equal(res3.verdict, 'favorable_to_receiver');

  // ₹600 offered vs ₹1000 requested -> favorable to offerer
  const res4 = evaluateBarterBalance(600, 1000);
  assert.equal(res4.verdict, 'favorable_to_offerer');
});

test('calculateDeliveryPay computes fair compensation based on distance and weight', () => {
  // 10km, 5kg -> 80 base + (10 * 12) = 200
  const pay1 = calculateDeliveryPay(10, 5);
  assert.equal(pay1, 200);

  // 25km, 30kg -> 80 base + (25 * 12) + (20 * 1.5) = 80 + 300 + 30 = 410
  const pay2 = calculateDeliveryPay(25, 30);
  assert.equal(pay2, 410);
});

test('calculateGroupSellingSplit fairly divides earnings according to pooled quantity', () => {
  const producers = [
    { id: 'p1', name: 'Gram Sabha Jawhar', quantity: 20 },
    { id: 'p2', name: 'Gram Sabha Mokhada', quantity: 15 },
    { id: 'p3', name: 'Gram Sabha Vikramgad', quantity: 15 },
  ];
  // Total 50kg sold at ₹400/kg -> ₹20,000 total
  const split = calculateGroupSellingSplit(producers, 50, 400);

  assert.equal(split.length, 3);
  assert.equal(split[0].sharePct, 40);
  assert.equal(split[0].earnings, 8000);

  assert.equal(split[1].sharePct, 30);
  assert.equal(split[1].earnings, 6000);

  assert.equal(split[2].sharePct, 30);
  assert.equal(split[2].earnings, 6000);

  const totalEarnings = split.reduce((acc, p) => acc + p.earnings, 0);
  assert.equal(totalEarnings, 20000);
});
