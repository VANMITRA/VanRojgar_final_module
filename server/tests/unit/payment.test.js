import test from 'node:test';
import assert from 'node:assert/strict';
import { buildUpiLink, isValidUpiId, isValidReference, describePayment } from '../../src/core/payment.js';

test('UPI ids: only real-looking ids pass', () => {
  assert.equal(isValidUpiId('vanrozgar@okhdfcbank'), true);
  assert.equal(isValidUpiId('9800000000@ybl'), true);
  for (const bad of ['', 'nope', '@ybl', 'a@', 'a b@ybl', undefined, null]) assert.equal(isValidUpiId(bad), false, String(bad));
});

test('UPI link carries payee, amount in rupees, note and INR', () => {
  const link = buildUpiLink({ upiId: 'team@okaxis', payeeName: 'Van Rozgar', totalPaise: 123450, orderId: '65f0c0ffee0123456789abcd' });
  const url = new URL(link);
  assert.equal(url.protocol, 'upi:');
  assert.equal(url.searchParams.get('pa'), 'team@okaxis');
  assert.equal(url.searchParams.get('pn'), 'Van Rozgar');
  assert.equal(url.searchParams.get('am'), '1234.50');
  assert.equal(url.searchParams.get('cu'), 'INR');
  assert.equal(url.searchParams.get('tn'), 'VanRozgar order 89abcd');
});

test('UPI link is null when the team UPI id is missing or malformed', () => {
  assert.equal(buildUpiLink({ upiId: '', totalPaise: 100, orderId: 'x' }), null);
  assert.equal(buildUpiLink({ upiId: 'not-an-id', totalPaise: 100, orderId: 'x' }), null);
});

test('payment references: 6 to 35 letters or digits', () => {
  assert.equal(isValidReference('412345678901'), true);
  assert.equal(isValidReference('AB12'), false);
  assert.equal(isValidReference('has space 1234'), false);
  assert.equal(isValidReference('x'.repeat(36)), false);
});

test('no state says "verified" before a person confirmed', () => {
  assert.doesNotMatch(describePayment({ paymentStatus: 'payment_reported' }), /confirmed the money arrived\.?$/i);
  assert.match(describePayment({ paymentStatus: 'payment_reported' }), /seller must confirm/);
  assert.match(describePayment({ paymentStatus: 'payment_confirmed' }), /Seller confirmed/);
});
