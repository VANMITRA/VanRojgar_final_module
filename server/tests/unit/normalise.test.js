import test from 'node:test';
import assert from 'node:assert/strict';
import { normaliseString, buildSearchTokens } from '../../src/core/normalise.js';

test('normalise: handles Marathi Devanagari text variations and trim', () => {
  const norm1 = normaliseString('  मध (Wild Honey)  ');
  assert.equal(norm1, 'मध wild honey');

  // Must preserve Devanagari vowel signs (matras) so words don't collapse
  const moh = normaliseString('मोह');
  assert.equal(moh, 'मोह');

  const norm2 = normaliseString('त्र्यंबकेश्वर');
  assert.ok(norm2.length > 0);
});

test('normalise: buildSearchTokens extracts words and variations', () => {
  const tokens = buildSearchTokens('Pure Wild Honey', 'शुद्ध मध');
  assert.ok(tokens.includes('honey'));
  assert.ok(tokens.includes('मध'));
});
