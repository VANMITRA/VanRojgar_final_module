import { randomInt } from 'node:crypto';

/**
 * The item code of a listing: what the website shows, and what a person pastes into the app's search.
 * Format `VR-` plus 6 characters from an alphabet without look-alikes (no 0, O, 1, I, L), e.g. `VR-K7M2QX`.
 */
export const ITEM_CODE_ALPHABET = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
export const ITEM_CODE_PATTERN = /^VR-[23456789ABCDEFGHJKMNPQRSTUVWXYZ]{6}$/;

export function generateItemCode() {
  let tail = '';
  for (let i = 0; i < 6; i++) tail += ITEM_CODE_ALPHABET[randomInt(ITEM_CODE_ALPHABET.length)];
  return `VR-${tail}`;
}

/**
 * The canonical item code for what a person typed (`vr k7m2qx`, `VR-K7M2QX`, ` vrk7m2qx `), or null
 * when the text is not an item code.
 */
export function normaliseItemCode(text) {
  const t = String(text ?? '').trim().toUpperCase().replace(/[\s_-]+/g, '');
  const m = /^VR([A-Z0-9]{6})$/.exec(t);
  if (!m) return null;
  const code = `VR-${m[1]}`;
  return ITEM_CODE_PATTERN.test(code) ? code : null;
}
