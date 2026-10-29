/**
 * Item codes: what a listing shows here and what a person pastes into the app's search.
 * Same format as the server (server/src/core/itemCode.js): `VR-` plus 6 characters from an alphabet
 * without look-alikes (no 0, O, 1, I, L), e.g. `VR-K7M2QX`.
 */
export const ITEM_CODE_ALPHABET = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
export const ITEM_CODE_PATTERN = /^VR-[23456789ABCDEFGHJKMNPQRSTUVWXYZ]{6}$/;

/** The canonical code for what a person typed (`vr k7m2qx`, ` VRK7M2QX `), or null if it is not a code. */
export function normaliseItemCode(text: string | null | undefined): string | null {
  const t = String(text ?? '').trim().toUpperCase().replace(/[\s_-]+/g, '');
  const m = /^VR([A-Z0-9]{6})$/.exec(t);
  if (!m) return null;
  const code = `VR-${m[1]}`;
  return ITEM_CODE_PATTERN.test(code) ? code : null;
}

/**
 * A made-up code for a SAMPLE listing: the same id always gives the same code. It is valid in format but
 * belongs to no real listing, so the app will not find it. Real listings bring their own code from the server.
 */
export function sampleItemCode(id: string): string {
  // FNV-1a, then six base-31 digits of a small generator seeded by it
  let h = 0x811c9dc5;
  for (let i = 0; i < id.length; i++) {
    h ^= id.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  let tail = '';
  for (let i = 0; i < 6; i++) {
    h = (Math.imul(h, 1664525) + 1013904223) >>> 0;
    tail += ITEM_CODE_ALPHABET[(h >>> 16) % ITEM_CODE_ALPHABET.length];
  }
  return `VR-${tail}`;
}
