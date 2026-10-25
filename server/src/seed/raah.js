/**
 * The village dataset: the 14 Community Forest Resource villages of the Raah Foundation report (Deola, Dindori and
 * Trimbakeshwar blocks of Nashik district), from src/seed/data/raah/raah_villages.json. No other village is loaded.
 *
 * Each village becomes one Gram Sabha record carrying the report's restoration figures. Positions are the block
 * town's (the report has none) and are labelled approximate. Running it twice gives the same result.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { GramSabha } from '../models/GramSabha.js';
import { buildSearchTokens } from '../core/normalise.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const FILE = path.join(here, 'data/raah/raah_villages.json');
export const SOURCE = 'Raah Foundation report, 1 October 2026';

export function loadRaah(file = FILE) {
  return JSON.parse(fs.readFileSync(file, 'utf-8'));
}

/** The 14 villages as { taluka, nameMr, nameEn } for anything that only needs the list. */
export function raahVillageList(data = loadRaah()) {
  return data.villages.map((v) => ({ taluka: v.taluka, nameMr: v.nameMr, nameEn: v.nameEn }));
}

export function restorationOf(v) {
  return {
    cfrAreaHa: v.cfrAreaHa,
    saplings: v.saplings,
    forestPonds: v.forestPonds,
    waterCapacityLitres: v.waterCapacityLitres,
    looseBoulderStructures: v.looseBoulderStructures,
    labourDays: v.labourDays,
    cfrmcMeetings: v.cfrmcMeetings,
    wildlifeSessions: v.wildlifeSessions,
    species: v.species,
    source: SOURCE
  };
}

/** Pure: the Gram Sabha fields for one village. */
export function gramSabhaFields(v, blockTowns) {
  const town = blockTowns[v.taluka];
  return {
    name: { mr: `ग्रामसभा ${v.nameMr}`, en: `${v.nameEn} Gram Sabha` },
    village: { mr: v.nameMr, en: v.nameEn },
    taluka: v.taluka,
    district: 'Nashik',
    ...(town ? { location: { type: 'Point', coordinates: [town.lng, town.lat] } } : {}),
    cfr: { rights: [], approvedAreaHa: v.cfrAreaHa, claimCount: 0 },
    restoration: restorationOf(v),
    searchTerms: buildSearchTokens(v.nameMr, v.nameEn, v.taluka, 'ग्रामसभा')
  };
}

/** Dry run by default. With { apply: true } writes the 14 villages and removes every other Gram Sabha that no account has claimed. */
export async function importRaah({ apply = false, file = FILE, log = () => {} } = {}) {
  const data = loadRaah(file);
  const summary = { villages: data.villages.length, talukas: [...new Set(data.villages.map((v) => v.taluka))].sort() };
  if (!apply) return { applied: false, ...summary };

  let created = 0;
  let refreshed = 0;
  for (const v of data.villages) {
    const fields = gramSabhaFields(v, data.blockTowns);
    const existing = await GramSabha.findOne({ taluka: v.taluka, 'village.mr': v.nameMr });
    if (existing) {
      existing.set(fields);
      await existing.save();
      refreshed += 1;
    } else {
      await GramSabha.create({
        ...fields,
        verificationStatus: 'pending',
        verificationNote: `${SOURCE}. Position is the block town's (approximate). No Gram Sabha has claimed this record yet.`,
        isDemoData: false
      });
      created += 1;
    }
  }

  // Nothing but these 14 villages may exist: drop the rest (old register or demo villages) unless someone registered for it.
  const keep = data.villages.map((v) => v.nameMr);
  const stale = await GramSabha.deleteMany({
    'village.mr': { $nin: keep },
    $or: [{ 'claim.status': { $in: [null, 'none'] } }, { claim: { $exists: false } }]
  });
  log(`Raah import: ${created} created, ${refreshed} refreshed, ${stale.deletedCount} other villages removed`);
  return { applied: true, created, refreshed, removed: stale.deletedCount, ...summary };
}
