/**
 * Product codes shared with the livelihood module (docs/plan.md section 3).
 * A livelihood idea that is about produce carries one of these codes, and so does a marketplace listing,
 * which is how "List this on the marketplace" and "See what land near here can produce" find each other.
 */
export const PRODUCT_CODES = ['honey', 'bamboo', 'herb', 'preserve', 'seed', 'leaf-plate', 'fibre', 'dried-fruit'];

export const PRODUCT_CODE_PATTERN = /^[a-z][a-z-]{1,30}$/;

// Checked in order: the first match wins, so the specific words come before the general ones.
const RULES = [
  [/leaf plate|patraval|पत्रावळ/i, 'leaf-plate'],
  [/dried fruit|वाळवलेली फळे/i, 'dried-fruit'],
  [/honey|मध/i, 'honey'],
  [/bamboo|बांबू/i, 'bamboo'],
  [/preserve|मुरांबा/i, 'preserve'],
  [/herb|वनस्पती/i, 'herb'],
  [/seed|बियाणे/i, 'seed'],
  [/rope|fibre|fiber|दोरी/i, 'fibre']
];

/** Best guess from the English and Marathi titles, or null when nothing matches. */
export function inferProductCode(...titles) {
  const text = titles.filter(Boolean).join(' ');
  for (const [re, code] of RULES) {
    if (re.test(text)) return code;
  }
  return null;
}
