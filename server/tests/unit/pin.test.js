import { test } from 'node:test';
import assert from 'node:assert/strict';
import { registerSchema, loginSchema } from '../../src/validators/auth.schema.js';

const base = { role: 'villager', name: 'Sita Bhoye', phone: '9876543210', village: 'Harsul', taluka: 'Trimbak' };

test('a new user must choose a 6-digit PIN', () => {
  assert.equal(registerSchema.safeParse({ ...base, password: '246810' }).success, true);
  for (const bad of ['12345', '1234567', 'abcdef', '12 456', 'ValidPassword123', '']) {
    assert.equal(registerSchema.safeParse({ ...base, password: bad }).success, false, bad);
  }
});

test('Hindi, Marathi and English are all accepted languages, English is the default', () => {
  for (const language of ['en', 'hi', 'mr']) {
    const r = registerSchema.safeParse({ ...base, password: '246810', language });
    assert.equal(r.success, true, language);
  }
  const r = registerSchema.safeParse({ ...base, password: '246810' });
  assert.equal(r.data.language, 'en');
  assert.equal(registerSchema.safeParse({ ...base, password: '246810', language: 'kn' }).success, false);
});

test('login accepts any non-empty secret, so back-office accounts with a longer password still sign in', () => {
  assert.equal(loginSchema.safeParse({ phone: '9876543210', password: 'VanMitraAdmin@2026' }).success, true);
  assert.equal(loginSchema.safeParse({ phone: '9876543210', password: '' }).success, false);
});
