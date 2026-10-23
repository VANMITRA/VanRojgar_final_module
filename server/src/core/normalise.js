/**
 * Normalises a string for matching and search indexing:
 * NFC Unicode normalisation, lowercase, trim, collapse whitespace.
 */
export function normaliseString(str) {
  if (!str || typeof str !== 'string') return '';
  return str
    .normalize('NFC')
    .toLowerCase()
    .replace(/[^\p{L}\p{M}\p{N}\s]/gu, '')
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Builds search tokens array for indexing
 */
export function buildSearchTokens(...inputs) {
  const set = new Set();
  for (const input of inputs) {
    if (!input) continue;
    if (Array.isArray(input)) {
      for (const item of input) {
        const norm = normaliseString(String(item));
        if (norm) {
          set.add(norm);
          norm.split(' ').forEach(w => w.length > 1 && set.add(w));
        }
      }
    } else if (typeof input === 'object') {
      for (const val of Object.values(input)) {
        const norm = normaliseString(String(val));
        if (norm) {
          set.add(norm);
          norm.split(' ').forEach(w => w.length > 1 && set.add(w));
        }
      }
    } else {
      const norm = normaliseString(String(input));
      if (norm) {
        set.add(norm);
        norm.split(' ').forEach(w => w.length > 1 && set.add(w));
      }
    }
  }
  return Array.from(set);
}
