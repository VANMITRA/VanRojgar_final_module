/**
 * Loads the cleaned CFR Nashik 2026 data (src/seed/data/cfr/*.json, made by scripts/cfr/clean_cfr_data.py) into the
 * database: one Gram Sabha record per village with claims, the claims themselves, and the MRSAC village profiles.
 *
 * Real villages are stored as UNCLAIMED Gram Sabhas (verificationStatus 'pending', no account). The first person to
 * register for a village files a claim that the team approves, exactly like a seeded village. Demo villages are never
 * touched. Running it twice gives the same result.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { GramSabha } from '../models/GramSabha.js';
import { CfrClaim } from '../models/CfrClaim.js';
import { VillageProfile } from '../models/VillageProfile.js';
import { buildSearchTokens } from '../core/normalise.js';
import { parseRightsString } from './rights.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const DATA_DIR = path.join(here, 'data/cfr');
export const SOURCE = 'cfr_2026';

const INVISIBLE = /[​‌‍﻿]/g;

/** Key that makes spelling variants of one village name equal (गांव / गाव, ळ / ल, extra spaces). */
export function normName(text) {
  return String(text ?? '')
    .replace(INVISIBLE, '')
    .replace(/ँ/g, 'ं').replace(/ळ/g, 'ल').replace(/ऱ/g, 'र')
    .replace(/[\s\-().]/g, '')
    .replace(/ां(?=व$)/u, 'ा');
}

export function loadCleanedData(dir = DATA_DIR) {
  const read = (f) => JSON.parse(fs.readFileSync(path.join(dir, f), 'utf-8'));
  return { claims: read('cfr_claims.json').claims, profiles: read('village_profiles.json').profiles };
}

/** Pure: groups claims by village and builds the records to store. No database access. */
export function buildRecords({ claims, profiles }) {
  const profileByCode = new Map(profiles.map((p) => [p.censusCode, p]));
  const villages = new Map();

  for (const c of claims) {
    const key = `${c.taluka}|${c.censusCode ?? normName(c.village)}`;
    if (!villages.has(key)) {
      villages.set(key, { taluka: c.taluka, censusCode: c.censusCode ?? null, villageMr: c.village, claims: [] });
    }
    villages.get(key).claims.push(c);
  }

  const gramSabhas = [];
  for (const v of villages.values()) {
    const profile = v.censusCode ? profileByCode.get(v.censusCode) : null;
    const approved = v.claims.filter((c) => c.decision === 'approved');
    const basis = approved.length ? approved : v.claims;
    const rights = [...new Set(basis.flatMap((c) => parseRightsString(c.rightsRaw ?? '')))].sort();
    const approvedAreaHa = Math.round(approved.reduce((s, c) => s + (c.areaApprovedHa ?? 0), 0) * 100) / 100;
    const villageEn = profile?.villageEn || null;
    gramSabhas.push({
      taluka: v.taluka,
      villageMr: v.villageMr,
      villageEn,
      censusCode: v.censusCode,
      rights,
      approvedAreaHa,
      claimCount: v.claims.length,
      approvedCount: approved.length,
      claims: v.claims,
      searchTerms: buildSearchTokens(v.villageMr, villageEn ?? '', v.taluka, 'ग्रामसभा', profile?.gramPanchayat ?? '')
    });
  }
  return gramSabhas;
}

export function summarise(records, profiles) {
  const claims = records.reduce((n, r) => n + r.claims.length, 0);
  return {
    villages: records.length,
    claims,
    approvedClaims: records.reduce((n, r) => n + r.approvedCount, 0),
    villagesWithRights: records.filter((r) => r.rights.length).length,
    villagesWithProfile: records.filter((r) => r.censusCode).length,
    profiles: profiles.length
  };
}

function profileDoc(p) {
  return {
    censusCode: p.censusCode,
    villageName: p.villageMr,
    villageNameEn: p.villageEn,
    gramPanchayat: p.gramPanchayat ?? undefined,
    taluka: p.taluka,
    district: 'Nashik',
    villageAreaHa: p.villageAreaHa ?? undefined,
    forestHa: p.forestHa ?? 0,
    waterBodiesCount: p.waterBodiesCount ?? 0,
    wellsTotal: p.wellsTotal ?? 0,
    waterConservationWorks: p.waterConservationWorks ?? 0,
    soilType: p.soilType ?? undefined,
    highlights: p.highlights ?? [],
    rawDetails: p.rawDetails ?? {},
    source: 'MRSAC geoportal, October 2026'
  };
}

/** Dry run by default: returns what it would do and writes nothing. Pass { apply: true } to write. */
export async function importCfr({ apply = false, dir = DATA_DIR, log = () => {} } = {}) {
  const data = loadCleanedData(dir);
  const records = buildRecords(data);
  const summary = summarise(records, data.profiles);
  if (!apply) return { applied: false, ...summary };

  // 1. MRSAC village profiles (upsert by census code)
  if (data.profiles.length) {
    await VillageProfile.bulkWrite(data.profiles.map((p) => ({
      updateOne: { filter: { censusCode: p.censusCode }, update: { $set: profileDoc(p) }, upsert: true }
    })));
  }

  // 2. Gram Sabhas. Demo villages and villages that have an account or a claim keep their own fields.
  const claimsToInsert = [];
  let created = 0;
  let refreshed = 0;
  let skipped = 0;
  let claimsSkipped = 0;
  for (const r of records) {
    const existing = await GramSabha.findOne({ taluka: r.taluka, 'village.mr': r.villageMr });
    if (existing && (existing.verificationStatus === 'verified_seed' || existing.isDemoData)) {
      skipped += 1;
      claimsSkipped += r.claims.length;
      continue;
    }
    const cfr = { rights: r.rights, approvedAreaHa: r.approvedAreaHa, claimCount: r.claimCount };
    let gs;
    if (existing) {
      existing.cfr = cfr;
      if (r.censusCode) existing.censusCode = r.censusCode;
      if (r.villageEn && !existing.village.en) existing.village.en = r.villageEn;
      existing.searchTerms = r.searchTerms;
      await existing.save();
      gs = existing;
      refreshed += 1;
    } else {
      gs = await GramSabha.create({
        name: { mr: `ग्रामसभा ${r.villageMr}`, en: r.villageEn ? `${r.villageEn} Gram Sabha` : undefined },
        village: { mr: r.villageMr, en: r.villageEn ?? undefined },
        taluka: r.taluka,
        district: 'Nashik',
        censusCode: r.censusCode ?? undefined,
        verificationStatus: 'pending',
        verificationNote: 'From the district CFR register (2026). No Gram Sabha has claimed this record yet.',
        cfr,
        isDemoData: false,
        searchTerms: r.searchTerms
      });
      created += 1;
    }
    for (const c of r.claims) {
      claimsToInsert.push({
        gramSabhaId: gs._id,
        caseNo: c.caseNo ?? '-',
        village: r.villageMr,
        taluka: r.taluka,
        district: 'Nashik',
        rights: parseRightsString(c.rightsRaw ?? ''),
        compartment: c.compartment ?? undefined,
        areaClaimedHa: c.areaClaimedHa ?? 0,
        areaApprovedHa: c.areaApprovedHa ?? 0,
        decision: c.decision ?? 'pending',
        decisionRecorded: Boolean(c.decision),
        cfrCommittee: Boolean(c.cfrCommittee),
        censusCode: r.censusCode ?? undefined,
        source: SOURCE
      });
    }
  }

  // 3. Claims: replace everything this importer wrote before, so a re-run never duplicates
  await CfrClaim.deleteMany({ source: SOURCE });
  if (claimsToInsert.length) await CfrClaim.insertMany(claimsToInsert, { ordered: false });
  log(`CFR import: ${created} created, ${refreshed} refreshed, ${skipped} demo villages left alone (${claimsSkipped} claims), ${claimsToInsert.length} claims written`);
  return { applied: true, created, refreshed, skipped, claimsSkipped, claimsWritten: claimsToInsert.length, ...summary };
}
