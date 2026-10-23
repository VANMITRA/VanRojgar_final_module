import test from 'node:test';
import assert from 'node:assert/strict';
import { assertValidTransition, RequestTransitions } from '../../src/services/requestMachine.js';

test('requestMachine: allows valid transitions', () => {
  assert.doesNotThrow(() => assertValidTransition('pending', 'approved'));
  assert.doesNotThrow(() => assertValidTransition('pending', 'rejected'));
  assert.doesNotThrow(() => assertValidTransition('pending', 'countered'));
  assert.doesNotThrow(() => assertValidTransition('pending', 'cancelled'));
  assert.doesNotThrow(() => assertValidTransition('countered', 'approved'));
  assert.doesNotThrow(() => assertValidTransition('countered', 'cancelled'));
});

test('requestMachine: rejects invalid transitions', () => {
  assert.throws(() => assertValidTransition('approved', 'pending'));
  assert.throws(() => assertValidTransition('rejected', 'approved'));
  assert.throws(() => assertValidTransition('cancelled', 'approved'));
  assert.throws(() => assertValidTransition('approved', 'rejected'));
});
