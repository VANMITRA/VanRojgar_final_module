import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import { buildRecords, loadCleanedData, normName, summarise } from '../../src/seed/cfr.js';

const dir = new URL('../../src/seed/data/cfr/', import.meta.url);
const raw = (f) => fs.readFileSync(new URL(f, dir), 'utf-8');
const data = loadCleanedData(new URL(dir).pathname.replace(/^\/([A-Za-z]:)/, '$1'));
const records = buildRecords(data);

test('cleaned CFR data: 950 claim rows and 680 MRSAC village profiles', () => {
  assert.equal(data.claims.length, 950);
  assert.equal(data.profiles.length, 680);
});

test('cleaned CFR data holds no phone, bank or personal fields', () => {
  const text = raw('cfr_claims.json') + raw('village_profiles.json');
  assert.doesNotMatch(text, /\d{9,}/, 'a long number (phone or account) is present');
  assert.doesNotMatch(text, /ifsc|mobile|bank of/i);
  assert.doesNotMatch(text, /homestay:/i, 'a homestay owner name is present');
  for (const c of data.claims) {
    assert.deepEqual(Object.keys(c).sort(), [
      'areaApprovedHa', 'areaClaimedHa', 'caseNo', 'censusCode', 'cfrCommittee', 'compartment',
      'decision', 'rightsRaw', 'taluka', 'village'
    ]);
  }
});

test('cleaned CFR data: areas are plausible and decisions are known values', () => {
  for (const c of data.claims) {
    for (const a of [c.areaClaimedHa, c.areaApprovedHa]) assert.ok(a === null || (a >= 0 && a <= 5000), `${c.village}: ${a}`);
    assert.ok([null, 'approved', 'rejected', 'pending'].includes(c.decision));
  }
});

test('all 14 talukas are present with English names', () => {
  const talukas = new Set(data.claims.map((c) => c.taluka));
  assert.deepEqual([...talukas].sort(), [
    'Baglan', 'Chandwad', 'Deola', 'Dindori', 'Igatpuri', 'Kalwan', 'Malegaon',
    'Nandgaon', 'Nashik', 'Peth', 'Sinnar', 'Surgana', 'Trimbakeshwar', 'Yeola'
  ]);
});

test('normName: spelling variants of one village collapse to one key', () => {
  assert.equal(normName('दहेगांव'), normName('दहेगाव'));
  assert.equal(normName(' दहे‌गांव '), normName('दहेगाव'));
  assert.notEqual(normName('दहेगांव'), normName('देवरगांव'));
});

test('records: one per village, every claim kept, totals add up', () => {
  const s = summarise(records, data.profiles);
  assert.equal(s.claims, 950);
  assert.equal(records.reduce((n, r) => n + r.claims.length, 0), 950);
  assert.ok(s.villages > 700 && s.villages < 800, `villages: ${s.villages}`);
  const keys = new Set(records.map((r) => `${r.taluka}|${r.censusCode ?? normName(r.villageMr)}`));
  assert.equal(keys.size, records.length, 'a village appears twice');
});

test('records: a known village carries its real rights, area and census code', () => {
  const r = records.find((x) => x.taluka === 'Nashik' && x.censusCode === '550989');
  assert.ok(r, 'Dahegaon (census code 550989) not found');
  assert.equal(r.villageEn, 'Dahegaon');
  assert.ok(r.claimCount >= 1);
  assert.ok(r.approvedAreaHa >= 0);
  const profile = data.profiles.find((p) => p.censusCode === '550989');
  assert.equal(profile.forestHa, 271.5);
  assert.equal(profile.wellsTotal, 58);
});

test('records: rights are real FRA clauses and nothing is invented', () => {
  for (const r of records) {
    for (const right of r.rights) assert.match(right, /^3\(1\)\([a-m]\)$/);
    assert.ok(r.approvedAreaHa >= 0);
  }
  assert.ok(records.some((r) => r.rights.includes('3(1)(c)')), 'no village has the minor forest produce right');
});
