import test from 'node:test';
import assert from 'node:assert/strict';
import { ITEM_CODE_ALPHABET, ITEM_CODE_PATTERN, normaliseItemCode, sampleItemCode } from './itemCode';
import { initialListings } from '../data/mockData';

test('normaliseItemCode accepts any spelling of a code', () => {
  for (const text of ['VR-K7M2QX', 'vr-k7m2qx', ' VR K7M2QX ', 'vrk7m2qx', 'Vr_k7m2qx']) {
    assert.equal(normaliseItemCode(text), 'VR-K7M2QX', JSON.stringify(text));
  }
});

test('normaliseItemCode rejects words, short, long and look-alike codes', () => {
  for (const text of ['honey', 'VR-K7M2Q', 'VR-K7M2QXX', 'VR-K0M2QX', 'XX-K7M2QX', '', null, undefined]) {
    assert.equal(normaliseItemCode(text as string | null | undefined), null, JSON.stringify(text));
  }
});

test('sampleItemCode is valid in format, stable, and has no look-alike characters', () => {
  const a = sampleItemCode('list-1');
  assert.match(a, ITEM_CODE_PATTERN);
  assert.equal(sampleItemCode('list-1'), a, 'the same id always gives the same code');
  assert.ok(!/[01OIL]/.test(a.slice(3)));
  assert.ok(!/[01OIL]/.test(ITEM_CODE_ALPHABET));
});

test('every sample listing has its own valid code and is labelled sample', () => {
  const codes = initialListings.map((l) => l.itemCode);
  assert.equal(new Set(codes).size, codes.length, 'codes are unique');
  for (const l of initialListings) {
    assert.match(l.itemCode, ITEM_CODE_PATTERN);
    assert.equal(l.source, 'sample');
  }
});

test('the code format matches the server (same pattern as server/src/core/itemCode.js)', () => {
  // A code the server generates must be accepted here, and the other way round
  const serverExample = 'VR-K7M2QX';
  assert.ok(ITEM_CODE_PATTERN.test(serverExample));
  assert.equal(ITEM_CODE_ALPHABET.length, 31);
});
