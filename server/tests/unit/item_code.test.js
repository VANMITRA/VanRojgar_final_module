import test from 'node:test';
import assert from 'node:assert/strict';
import { generateItemCode, normaliseItemCode, ITEM_CODE_PATTERN, ITEM_CODE_ALPHABET } from '../../src/core/itemCode.js';
import { registerSchema } from '../../src/validators/auth.schema.js';
import { REGISTER_ROLES, FARMER_ROLES, canUseLivelihood, isFarmerRole } from '../../src/core/roles.js';

test('item code: generated codes match the format and use no look-alike characters', () => {
  const seen = new Set();
  for (let i = 0; i < 500; i++) {
    const code = generateItemCode();
    assert.match(code, ITEM_CODE_PATTERN);
    assert.ok(!/[01OIL]/.test(code.slice(3)), code);
    seen.add(code);
  }
  assert.ok(seen.size > 495, 'codes are random, not repeated');
  assert.ok(!/[01OIL]/.test(ITEM_CODE_ALPHABET));
});

test('item code: any spelling a person types or pastes normalises to the same code', () => {
  for (const text of ['VR-K7M2QX', 'vr-k7m2qx', ' VR K7M2QX ', 'vrk7m2qx', 'Vr_k7m2qx', 'VR-K7M2QX\n']) {
    assert.equal(normaliseItemCode(text), 'VR-K7M2QX', JSON.stringify(text));
  }
});

test('item code: ordinary words and malformed codes are not item codes', () => {
  for (const text of ['honey', 'bamboo basket', 'VR-K7M2Q', 'VR-K7M2QXX', 'VR-K0M2QX', 'XX-K7M2QX', '', null, undefined, 'wild honey vr']) {
    assert.equal(normaliseItemCode(text), null, JSON.stringify(text));
  }
});

test('roles: four sign-up roles; only a CFR holder gets the livelihood report', () => {
  assert.deepEqual([...REGISTER_ROLES].sort(), ['buyer', 'cfrholder', 'gramsabha', 'villager']);
  assert.ok(canUseLivelihood('cfrholder'));
  for (const r of ['villager', 'gramsabha', 'buyer', 'team', undefined]) assert.ok(!canUseLivelihood(r), String(r));
  assert.deepEqual(FARMER_ROLES, ['villager', 'cfrholder']);
  assert.ok(isFarmerRole('cfrholder') && isFarmerRole('villager') && !isFarmerRole('gramsabha') && !isFarmerRole('buyer'));
});

test('roles: a CFR holder signs up like a farmer (village needed, Nashik only)', () => {
  const base = { role: 'cfrholder', name: 'Sita Bhoye', phone: '9876543210', password: '123456', village: 'Devgaon', taluka: 'Trimbakeshwar' };
  assert.ok(registerSchema.safeParse(base).success);
  assert.ok(!registerSchema.safeParse({ ...base, village: undefined }).success, 'village is required');
  assert.ok(!registerSchema.safeParse({ ...base, district: 'Pune' }).success, 'Nashik pilot only');
  assert.ok(!registerSchema.safeParse({ ...base, role: 'officer' }).success, 'unknown roles are refused');
  assert.ok(registerSchema.safeParse({ ...base, role: 'villager' }).success, 'farmer keeps working');
});
