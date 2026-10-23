import test from 'node:test';
import assert from 'node:assert/strict';
import { sortListings, pageOf } from '../../src/services/search.service.js';

const mk = (id, distanceKm, price, day) => ({
  id, distanceKm, pricePerUnitPaise: price, createdAt: new Date(2026, 9, day).toISOString()
});
const sample = [mk('a', 9, 300, 1), mk('b', null, 100, 2), mk('c', 2, 200, 3), mk('d', 5, 100, 4)];

test('search: nearest sorts the whole set by distance, unknown distance last', () => {
  assert.deepEqual(sortListings(sample, 'nearest', true).map(l => l.id), ['c', 'd', 'a', 'b']);
});

test('search: nearest without a position falls back to newest', () => {
  assert.deepEqual(sortListings(sample, 'nearest', false).map(l => l.id), ['d', 'c', 'b', 'a']);
});

test('search: price sorts break ties by newest', () => {
  assert.deepEqual(sortListings(sample, 'price_asc', false).map(l => l.id), ['d', 'b', 'c', 'a']);
  assert.deepEqual(sortListings(sample, 'price_desc', false).map(l => l.id), ['a', 'c', 'd', 'b']);
});

test('search: cursor pages through every item exactly once', () => {
  const sorted = sortListings(sample, 'nearest', true);
  const seen = [];
  let cursor;
  do {
    const { items, nextCursor } = pageOf(sorted, cursor, 3);
    seen.push(...items.map(l => l.id));
    cursor = nextCursor;
  } while (cursor);
  assert.deepEqual(seen, ['c', 'd', 'a', 'b']);
});

test('search: a bad cursor starts from the first page', () => {
  assert.equal(pageOf(sample, 'nope', 2).items.length, 2);
  assert.equal(pageOf(sample, '-5', 2).items[0].id, 'a');
});
