/**
 * Maps Devanagari rights characters found in CFR registers to standard FRA Section 3(1) clauses.
 * Based on Appendix C of SYSTEM_ARCHITECTURE.md.
 */
export const DEVANAGARI_RIGHTS_MAP = {
  'क': '3(1)(a)',
  'ख': '3(1)(b)',
  'ग': '3(1)(c)', // Minor Forest Produce (MFP)
  'घ': '3(1)(d)', // Water bodies, fishing, grazing
  'ङ': '3(1)(e)', // PVTG Habitat
  'च': '3(1)(f)',
  'छ': '3(1)(g)',
  'ज': '3(1)(h)',
  'झ': '3(1)(i)', // CFR management & conservation
  'ञ': '3(1)(j)',
  'ट': '3(1)(k)', // Biodiversity & traditional knowledge
  'ठ': '3(1)(l)', // Other traditional rights
  'ड': '3(1)(m)'
};

export function parseRightsString(raw) {
  if (!raw || typeof raw !== 'string') return [];
  const found = new Set();

  for (const [char, clause] of Object.entries(DEVANAGARI_RIGHTS_MAP)) {
    if (raw.includes(char)) {
      found.add(clause);
    }
  }

  // Also check direct clause strings e.g. "3(1)(c)"
  const regex = /3\(1\)\([a-m]\)/gi;
  let match;
  while ((match = regex.exec(raw)) !== null) {
    found.add(match[0].toLowerCase());
  }

  return Array.from(found);
}
