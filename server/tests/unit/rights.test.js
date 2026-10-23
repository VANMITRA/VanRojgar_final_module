import test from 'node:test';
import assert from 'node:assert/strict';
import { parseRightsString, DEVANAGARI_RIGHTS_MAP } from '../../src/seed/rights.js';

test('rights: parses standard Marathi FRA letter symbols', () => {
  const result = parseRightsString('3(1),(ग),(घ),(झ)');
  assert.ok(result.includes('3(1)(c)'));
  assert.ok(result.includes('3(1)(d)'));
  assert.ok(result.includes('3(1)(i)'));
  assert.equal(result.length, 3);
});

test('rights: parses direct latin clause codes', () => {
  const result = parseRightsString('Section 3(1)(c) and 3(1)(k)');
  assert.ok(result.includes('3(1)(c)'));
  assert.ok(result.includes('3(1)(k)'));
});

test('rights: handles blank or invalid inputs gracefully', () => {
  assert.deepEqual(parseRightsString(null), []);
  assert.deepEqual(parseRightsString(''), []);
});
