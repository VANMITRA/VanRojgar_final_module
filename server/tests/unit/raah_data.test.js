import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import { loadRaah, raahVillageList, gramSabhaFields, restorationOf } from '../../src/seed/raah.js';
import { findDatasetVillage, isDatasetVillage } from '../../src/services/auth.service.js';

const d = (f) => JSON.parse(fs.readFileSync(new URL(`../../src/seed/data/${f}`, import.meta.url), 'utf-8'));
const raah = loadRaah();
const sum = (key) => raah.villages.reduce((s, v) => s + v[key], 0);

test('dataset: exactly the 14 villages of the Raah report, in 3 blocks', () => {
  assert.equal(raah.villages.length, 14);
  assert.deepEqual([...new Set(raah.villages.map((v) => v.taluka))].sort(), ['Deola', 'Dindori', 'Trimbakeshwar']);
  assert.deepEqual(raahVillageList(raah).map((v) => v.nameEn), [
    'Dongargaon', 'Kanchane', 'Kumbharde', 'Varshi', 'Bhatode', 'Kochargaon', 'Ambai',
    'Chakore', 'Devgaon', 'Met Chandrachi', 'Pahine', 'Take Harsh', 'Talwade', 'Waghera'
  ]);
});

test('dataset: the village figures add up to the totals printed in the report', () => {
  assert.equal(sum('cfrAreaHa'), 2019);
  assert.equal(sum('saplings'), 217708);
  assert.equal(sum('forestPonds'), 11);
  assert.equal(sum('waterCapacityLitres'), 53092000);
  assert.equal(sum('looseBoulderStructures'), 794);
  assert.equal(sum('labourDays'), 12710);
  assert.equal(sum('cfrmcMeetings'), 19);
  assert.equal(sum('wildlifeSessions'), 4);
});

test('dataset: species lists are only where the report has them, and hold no personal data', () => {
  const withList = raah.villages.filter((v) => v.species.length).map((v) => v.nameEn);
  assert.equal(withList.length, 12);
  assert.ok(!withList.includes('Kumbharde') && !withList.includes('Bhatode'));
  assert.doesNotMatch(JSON.stringify(raah), /\d{9,}/);
});

test('dataset: every Gram Sabha record carries its figures and a block-town position', () => {
  for (const v of raah.villages) {
    const f = gramSabhaFields(v, raah.blockTowns);
    assert.equal(f.village.mr, v.nameMr);
    assert.equal(f.restoration.saplings, v.saplings);
    assert.equal(f.cfr.approvedAreaHa, v.cfrAreaHa);
    assert.equal(f.location.coordinates.length, 2);
    assert.equal(restorationOf(v).source, 'Raah Foundation report, 1 October 2026');
  }
});

test('registration: only the dataset villages are accepted, by either name', () => {
  assert.ok(isDatasetVillage('देवगाव', 'Trimbakeshwar'));
  assert.ok(isDatasetVillage('  devgaon ', 'trimbakeshwar'));
  assert.equal(findDatasetVillage('Waghera', 'Trimbakeshwar').nameMr, 'वाघेरा');
  assert.ok(!isDatasetVillage('Devgaon', 'Deola'), 'right name, wrong block');
  assert.ok(!isDatasetVillage('मातोरी', 'Nashik'));
  assert.ok(!isDatasetVillage('', 'Deola'));
});

test('demo logins: one demo Gram Sabha per village, a villager and a buyer, all inside the dataset', () => {
  const accounts = d('demo_accounts.json');
  const gs = accounts.filter((u) => u.role === 'gramsabha');
  assert.equal(gs.length, 14);
  for (const u of accounts.filter((u) => u.village)) assert.ok(isDatasetVillage(u.village, u.taluka), u.village);
  assert.equal(accounts.filter((u) => u.role === 'villager').length, 1);
  assert.equal(accounts.filter((u) => u.role === 'buyer').length, 1);
  assert.ok(gs[0].phone === '+919822011001' && accounts.some((u) => u.phone === '+919822022222'));
});

test('seed folder: no demo listings and no other village list are left behind', () => {
  const files = fs.readdirSync(new URL('../../src/seed/data/', import.meta.url));
  assert.ok(!files.includes('demo_listings.json') && !files.includes('village_points.json') && !files.includes('cfr'));
});
