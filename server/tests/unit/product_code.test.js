import test from 'node:test';
import assert from 'node:assert/strict';
import { inferProductCode, PRODUCT_CODES, PRODUCT_CODE_PATTERN } from '../../src/core/productCode.js';
import { toMapPoint } from '../../src/services/listing.service.js';
import { createListingSchema } from '../../src/validators/listing.schema.js';

// Typical titles a Gram Sabha would give each product (the app ships no demo listings any more)
const titles = [
  ['Bamboo planter', 'बांबू कुंडी'], ['Bamboo utility basket', 'बांबूची टोपली'], ['Managed-apiary honey (500 g jar)', 'मधपेटीतील मध'],
  ['Dried cultivated herb sachet (100 g)', 'वाळवलेली औषधी वनस्पती'], ['Fruit preserve (200 g jar)', 'फळांचा मुरांबा'],
  ['Nursery seed packet', 'रोपवाटिका बियाणे'], ['Leaf plates (pack of 25)', 'पत्रावळी'], ['Natural-fibre rope', 'नैसर्गिक दोरी'],
  ['Dried fruit pack (100 g)', 'सुकामेवा']
];

test('product code: every typical title gets a known code', () => {
  for (const [en, mr] of titles) {
    const code = inferProductCode(en, mr);
    assert.ok(PRODUCT_CODES.includes(code), `${en} -> ${code}`);
  }
});

test('product code: specific words win over general ones', () => {
  assert.equal(inferProductCode('Leaf plates (pack of 25)'), 'leaf-plate');
  assert.equal(inferProductCode('Dried fruit pack (100 g)'), 'dried-fruit');
  assert.equal(inferProductCode('Managed-apiary honey (500 g jar)'), 'honey');
  assert.equal(inferProductCode('मधपेटीतील मध'), 'honey');
  assert.equal(inferProductCode('Tamarind preserve (200 g jar)'), 'preserve');
  assert.equal(inferProductCode('Something unrelated'), null);
});

test('product code: the listing schema accepts valid codes and rejects bad ones', () => {
  const base = {
    titleMr: 'मध', titleEn: 'Honey', categoryId: 'abc', quantityAvailable: 1, unit: 'jar',
    pricePerUnitRupees: 100, sustainableDeclared: true
  };
  assert.equal(createListingSchema.parse({ ...base, productCode: ' Leaf-Plate ' }).productCode, 'leaf-plate');
  assert.equal(createListingSchema.parse(base).productCode, undefined);
  assert.throws(() => createListingSchema.parse({ ...base, productCode: 'Honey; drop' }));
  assert.ok(PRODUCT_CODE_PATTERN.test('dried-fruit'));
});

test('map point: coordinates are rounded to 2 decimals and a missing position gives no point', () => {
  const p = toMapPoint({
    _id: 'a1', title: { mr: 'मध', en: 'Honey' }, village: 'मातोरी', taluka: 'Nashik',
    categoryId: { slug: 'forest-produce' }, productCode: 'honey', pricePerUnitPaise: 35000, unit: 'jar',
    location: { type: 'Point', coordinates: [73.78456, 20.01234] }
  });
  assert.equal(p.lat, 20.01);
  assert.equal(p.lng, 73.78);
  assert.equal(p.category, 'forest-produce');
  assert.equal(p.productCode, 'honey');
  assert.equal(toMapPoint({ _id: 'a2', title: {}, location: undefined }), null);
});
