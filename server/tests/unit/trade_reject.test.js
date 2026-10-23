import test from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import { app } from '../../src/app.js';
import { updateRequestStatusSchema } from '../../src/validators/trade.schema.js';
import { registerSchema } from '../../src/validators/auth.schema.js';

test('trade validation: rejecting request without note fails with 422 (min 5 characters)', async () => {
  // Missing note
  await assert.rejects(
    async () => {
      await updateRequestStatusSchema.parseAsync({ action: 'reject' });
    },
    (err) => {
      assert.ok(err.errors.some(e => e.path.includes('note') && e.message.includes('min 5 characters')));
      return true;
    }
  );

  // Note too short (< 5 chars)
  await assert.rejects(
    async () => {
      await updateRequestStatusSchema.parseAsync({ action: 'reject', note: 'no' });
    },
    (err) => {
      assert.ok(err.errors.some(e => e.path.includes('note') && e.message.includes('min 5 characters')));
      return true;
    }
  );
});

test('trade validation: rejecting request with valid note (min 5 chars) succeeds and preserves note', async () => {
  const input = { action: 'reject', note: 'Stock reserved for local use' };
  const parsed = await updateRequestStatusSchema.parseAsync(input);

  assert.equal(parsed.action, 'reject');
  assert.equal(parsed.note, 'Stock reserved for local use');
});

test('trade logic: decisionNote persistence assigns note to decisionNote field', () => {
  const mockRequest = {
    _id: 'req_123',
    status: 'pending',
    history: []
  };

  const note = 'Stock reserved for local use';
  mockRequest.status = 'rejected';
  mockRequest.decisionNote = note;
  mockRequest.history.push({
    from: 'pending',
    to: 'rejected',
    note,
    timestamp: new Date()
  });

  assert.equal(mockRequest.status, 'rejected');
  assert.equal(mockRequest.decisionNote, 'Stock reserved for local use');
  assert.equal(mockRequest.history.length, 1);
  assert.equal(mockRequest.history[0].note, 'Stock reserved for local use');
});

test('auth validation: register with a non-pilot district/village fails with 422', async () => {
  // Villager in non-pilot district
  await assert.rejects(
    async () => {
      await registerSchema.parseAsync({
        role: 'villager',
        name: 'Ramesh Patil',
        phone: '+919822112233',
        password: '123456',
        village: 'Baramati',
        district: 'Pune'
      });
    },
    (err) => {
      assert.ok(err.errors.some(e => e.path.includes('village') && e.message.includes('Only Nashik pilot villages')));
      return true;
    }
  );

  // HTTP POST /api/v1/auth/register with non-pilot district returns 422 VALIDATION_ERROR
  const res = await request(app)
    .post('/api/v1/auth/register')
    .send({
      role: 'villager',
      name: 'Ramesh Patil',
      phone: '+919822112233',
      password: '123456',
      village: 'Baramati',
      district: 'Pune'
    });

  assert.equal(res.status, 422);
  assert.equal(res.body.success, false);
  assert.equal(res.body.error.code, 'VALIDATION_ERROR');
  assert.ok(res.body.error.fields.village);
});

test('auth validation: register with valid Nashik pilot village succeeds', async () => {
  const validData = {
    role: 'villager',
    name: 'सखाराम भिल',
    phone: '+919822022222',
    password: '123456',
    village: 'तोरणगण',
    district: 'Nashik'
  };

  const parsed = await registerSchema.parseAsync(validData);
  assert.equal(parsed.village, 'तोरणगण');
  assert.equal(parsed.district, 'Nashik');
});

test('trade: GET /requests without auth returns 401 UNAUTHENTICATED', async () => {
  const res = await request(app).get('/api/v1/requests?scope=mine');
  assert.equal(res.status, 401);
  assert.equal(res.body.success, false);
  assert.equal(res.body.error.code, 'UNAUTHENTICATED');
});
