// [USER RUNS] Create labelled SAMPLE products, requests and orders through the app's own API (never the database).
//
//   node scripts/seed_sample_shop.js                                     dry run against http://localhost:3000/api/v1
//   node scripts/seed_sample_shop.js --api https://vanrozgar-api.onrender.com/api/v1 --apply
//
// Everything it makes is labelled Sample: the product titles end with "(Sample)", the listings carry isSample=true,
// and the requests say so. Prices and quantities are made up for the demo, small on purpose. The product and village
// pairs follow the village stock sheet (which villages could offer which produce); the real stock is entered later
// by each Gram Sabha. Safe to run again: a seller's product that already exists is skipped.
// Demo logins use the demo PIN (DEMO_PIN, default 123456).

const args = process.argv.slice(2);
const apply = args.includes('--apply');
const apiIdx = args.indexOf('--api');
const API = (apiIdx >= 0 ? args[apiIdx + 1] : 'http://localhost:3000/api/v1').replace(/\/+$/, '');
const PIN = process.env.DEMO_PIN || '123456';

const GS = (n) => `+9198220110${String(n).padStart(2, '0')}`;
const CFR_DEVGAON = '+919822044444';
const CFR_DEVGAON_2 = '+919822022222';
const BUYER = '+919822033333';

// [seller, category slug, product code, Marathi title, English title, unit, MRP rupees, price rupees, quantity, minimum order, description]
const PRODUCTS = [
  [GS(4), 'handicrafts-bamboo', 'bamboo', 'बांबू खांब', 'Bamboo poles', 'piece', 220, 180, 200, 20, 'Air-dried bamboo poles from the village forest'],
  [GS(6), 'handicrafts-bamboo', 'bamboo', 'बांबू खांब', 'Bamboo poles', 'piece', 200, 200, 150, 10, 'Bamboo poles, mixed lengths'],
  [GS(14), 'handicrafts-bamboo', 'bamboo', 'बांबू खांब', 'Bamboo poles', 'piece', 240, 170, 300, 50, 'Bamboo poles for building and fencing'],
  [CFR_DEVGAON, 'handicrafts-bamboo', 'bamboo', 'बांबू खांब', 'Bamboo poles', 'piece', 210, 190, 80, 10, 'Bamboo poles from our family forest land'],
  [GS(6), 'flowers', 'moh-flowers', 'मोह फुले', 'Moh flowers', 'kg', 160, 130, 120, 5, 'Dried moh (mahua) flowers'],
  [CFR_DEVGAON_2, 'flowers', 'moh-flowers', 'मोह फुले', 'Moh flowers', 'kg', 150, 150, 60, 5, 'Dried moh flowers'],
  [GS(7), 'flowers', 'moh-flowers', 'मोह फुले', 'Moh flowers', 'kg', 170, 140, 200, 10, 'Dried moh flowers'],
  [GS(2), 'fruit', 'mango', 'आंबा', 'Mango', 'kg', 90, 70, 300, 10, 'Village mangoes'],
  [GS(14), 'fruit', 'mango', 'आंबा', 'Mango', 'kg', 100, 100, 250, 10, 'Village mangoes'],
  [GS(2), 'fruit', 'awla', 'आवळा', 'Awla (amla)', 'kg', 80, 60, 150, 5, 'Fresh awla'],
  [GS(10), 'fruit', 'awla', 'आवळा', 'Awla (amla)', 'kg', 70, 70, 100, 5, 'Fresh awla'],
  [GS(6), 'fruit', 'jamun', 'जांभूळ', 'Jamun', 'kg', 140, 110, 90, 5, 'Jamun fruit'],
  [GS(1), 'fruit', 'tamarind', 'चिंच', 'Tamarind pods', 'kg', 100, 80, 200, 10, 'Tamarind pods'],
  [GS(4), 'fruit', 'tamarind', 'चिंच', 'Tamarind pods', 'kg', 85, 85, 120, 10, 'Tamarind pods'],
  [GS(1), 'fruit', 'custard-apple', 'सीताफळ', 'Custard apple', 'kg', 150, 120, 80, 5, 'Custard apple'],
  [GS(14), 'fruit', 'ber', 'बोर', 'Ber', 'kg', 90, 70, 80, 5, 'Ber fruit'],
  [GS(2), 'fruit', 'bael', 'बेल', 'Bael', 'kg', 60, 50, 60, 5, 'Bael fruit'],
  [GS(7), 'nuts-and-seeds', 'cashew', 'काजू (कच्चे)', 'Cashew nuts (raw)', 'kg', 800, 700, 40, 5, 'Raw cashew nuts'],
  [GS(13), 'nuts-and-seeds', 'karanj-seeds', 'करंज बिया', 'Karanj seeds', 'kg', 45, 45, 200, 10, 'Karanj seeds'],
  [GS(14), 'nuts-and-seeds', 'moh-seeds', 'मोह बिया', 'Moh seeds', 'kg', 75, 60, 150, 10, 'Moh seeds'],
  [GS(4), 'medicinal-plants', 'behda', 'बेहडा', 'Behda dry fruit', 'kg', 60, 60, 100, 5, 'Behda dry fruit'],
  [GS(7), 'medicinal-plants', 'hirda', 'हिरडा', 'Hirda dry fruit', 'kg', 110, 90, 60, 5, 'Hirda dry fruit'],
  [GS(10), 'medicinal-plants', 'ritha', 'रिठा', 'Ritha (soapnut)', 'kg', 130, 110, 80, 5, 'Dried ritha soapnuts'],
  [GS(13), 'forest-produce', 'babul-gum', 'बाभूळ डिंक', 'Babul gum', 'kg', 300, 260, 40, 2, 'Babul gum'],
  [GS(4), 'timber-trees', 'shisu', 'शिसू लाकूड', 'Shisu timber', 'piece', 900, 800, 20, 2, 'Shisu timber pieces, sold only with the forest department paperwork'],
  [GS(6), 'shade-trees', 'banyan-sapling', 'वड रोप', 'Banyan sapling', 'piece', 60, 50, 100, 5, 'Banyan saplings for planting']
];

// [buyer, seller, product code, quantity, what happens]
const ORDERS = [
  [BUYER, GS(14), 'bamboo', 50, 'approve'],
  [BUYER, GS(2), 'mango', 30, 'approve'],
  [BUYER, GS(6), 'moh-flowers', 20, 'pending'],
  [BUYER, GS(1), 'tamarind', 25, 'pending'],
  [CFR_DEVGAON, GS(2), 'awla', 20, 'pending']
];

async function call(method, path, token, body) {
  const res = await fetch(`${API}${path}`, {
    method,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined
  });
  const json = await res.json().catch(() => ({}));
  return { status: res.status, body: json };
}

const tokens = {};
async function login(phone) {
  if (!tokens[phone]) {
    const r = await call('POST', '/auth/login', null, { phone, password: PIN });
    if (r.status !== 200) throw new Error(`login failed for ${phone}: ${r.status}`);
    tokens[phone] = r.body.data.token;
  }
  return tokens[phone];
}

console.log(`mode: ${apply ? 'APPLY' : 'dry run'}  api: ${API}  products: ${PRODUCTS.length}  requests: ${ORDERS.length}`);
const cats = (await call('GET', '/categories')).body.data;
const catId = Object.fromEntries((Array.isArray(cats) ? cats : []).map((c) => [c.slug, c._id]));
const missing = [...new Set(PRODUCTS.map((p) => p[1]))].filter((s) => !catId[s]);
if (missing.length) throw new Error(`categories missing on the server: ${missing.join(', ')}. Run the seed first (npm run seed).`);

const made = {}; // seller + product code -> listing id
let created = 0, skipped = 0;
for (const [seller, slug, code, titleMr, titleEn, unit, mrp, price, qty, min, description] of PRODUCTS) {
  const title = `${titleEn} (Sample)`;
  if (!apply) { console.log(`  would list: ${title} by ${seller}  Rs ${price} (MRP ${mrp})  ${qty} ${unit}`); continue; }
  const token = await login(seller);
  const mine = (await call('GET', '/listings/mine', token)).body.data ?? [];
  const existing = mine.find((l) => l.title?.en === title);
  if (existing) { made[`${seller}|${code}`] = existing._id; skipped++; continue; }
  const r = await call('POST', '/listings', token, {
    titleMr: `${titleMr} (नमुना)`, titleEn: title, categoryId: catId[slug], productCode: code, description: `${description}. Sample listing for the demo.`,
    quantityAvailable: qty, unit, pricePerUnitRupees: price, mrpPerUnitRupees: mrp, minOrderQuantity: min,
    mode: 'sell', sustainableDeclared: true, fulfilment: 'both', isSample: true
  });
  if (r.status === 201) { made[`${seller}|${code}`] = r.body.data._id; created++; }
  else console.log(`  FAILED ${title} by ${seller}: ${r.status} ${r.body?.error?.message ?? ''}`);
}
console.log(apply ? `listings created: ${created}, already there: ${skipped}` : 'dry run only; add --apply to write');

if (apply) {
  let requests = 0;
  for (const [buyer, seller, code, quantity, outcome] of ORDERS) {
    const listingId = made[`${seller}|${code}`];
    if (!listingId) continue;
    const bt = await login(buyer);
    // do not repeat a sample request on a second run
    const mineReq = (await call('GET', '/requests?scope=mine', bt)).body.data ?? [];
    if (mineReq.some((r) => String(r.listingId?._id ?? r.listingId) === String(listingId))) continue;
    const r = await call('POST', '/requests', bt, { listingId, quantity, deliveryPref: 'pickup', paymentMethod: 'cod', reason: 'Sample request for the demo' });
    if (r.status !== 201) { console.log(`  request FAILED ${code}: ${r.status} ${r.body?.error?.message ?? ''}`); continue; }
    requests++;
    if (outcome === 'approve') {
      const a = await call('PATCH', `/requests/${r.body.data._id}/status`, await login(seller), { action: 'approve', note: 'Sample approval' });
      if (a.status !== 200) console.log(`  approve FAILED ${code}: ${a.status}`);
    }
  }
  console.log(`sample requests created: ${requests}`);
}
