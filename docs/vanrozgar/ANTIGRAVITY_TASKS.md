# VanRozgar — Work Order for Anti-Gravity

Baseline: `main` @ `e64864a`. Server unit tests 11/11 pass; `flutter analyze` = 2 infos, no errors.
Co-author every commit with: `Co-Authored-By: Ayush More <ayushmore27.am@gmail.com>`

## 0. Operating rules (read first — these prevent hallucination)
1. **Do the tasks in the order T1 → T6. One task per commit. After each task run the verification commands in that task. Do not start the next task if a check fails.**
2. **Only edit the files named in a task.** If a file or symbol is not named, `grep` for it before assuming it exists. Do not invent endpoints, fields or packages.
3. **Do not change** `server/src/services/trade.service.js` approval/transaction logic, `requestMachine.js`, rate limiting, auth, or the `/api/v1` response envelope `{success,data,meta}` / error envelope `{success:false,error:{code,message,fields?,requestId}}`.
4. **Do not invent data.** Use only the values in §T1. No coordinates exist for these villages: leave `location` unset (the schemas allow it).
5. **No-harm rule (hard requirement):** never create a listing for wild-hive honey, lac, wild-collected produce, anything from a conservation reserve, or any wildlife product. Honey is **"Managed-apiary honey" only**.
6. All user-visible strings are bilingual `मराठी • English` where the existing screens already do this. No new packages. Dart: use `context.vr` tokens and `Theme.of(context)`; **no raw hex or `Colors.white/black`** in feature code.
7. Local test stack (needs a MongoDB **replica set**, transactions): `cd server && cp .env.example .env` (set `MONGODB_URI=mongodb://127.0.0.1:27017/vanrozgar?replicaSet=rs0`) → `npm run seed` → `npm run dev`. App: `cd app && flutter pub get && flutter analyze && flutter test`.
   Real phone: `flutter run --dart-define=API_BASE_URL=http://<PC-LAN-IP>:3000/api/v1` (not `10.0.2.2`, that is emulator-only).

---

## 1. Audit — expected vs. actual

| Requirement (source) | Status | Evidence |
|---|---|---|
| 3 portals, no 4th; delivery option inside Villager; team via back office (Implementation Plan §2, §7) | ✅ | router has `/gs`,`/v`,`/b`; `/team` hidden |
| Gram Sabha: listings, requests with **Approve / Reject / Counter**, orders (Plan §4) | ⚠️ | Buttons exist, but **Reject takes no reason** (see T3) |
| Applicant sees what they applied for + status approved/rejected/countered (new requirement) | ⚠️ | `/v/requests`, `/b/requests` use `scope=mine` (`gs_requests_screen.dart:74`), but cards don't show the **rejection reason**, and home dashboards show no "my requests" summary (T4) |
| Pilot = **10 specific villages** (Sample Data doc) | ❌ | `village_points.json` has **16 other villages** (Amboli, Harsul, Peth, …); only 1 GS demo user; sample data doc not used (T1) |
| Forest focus: honey, bamboo, herb, preserve, leaf plates, fibre (Sample Data) | ❌ | `demo_listings.json` has wild honey, mahua, ashwagandha, gum — **violates the no-harm rule** (T1) |
| Marathi + English | ⚠️ | Hard-coded bilingual strings; `app_*.arb` exist but are unused (acceptable for demo) |
| VanMitra UI/UX language (Style Guide + screenshots) | ⚠️ | Tokens/header/hero/nav match; **7 deviations** listed in T5 |
| Search, trust tag, distance, bulk-reason, barter (Plan §9) | ✅/⚠️ | Works; distance blank for the 10 villages (no coordinates) → show "distance unknown" (T2) |
| Real CFR/MRSAC data (xlsx/docx) | ❌ (deferred) | Not imported; label as **Demo data** (T1 sets the chip) |
| Delivery, barter screens | ✅ | present (`delivery_*`, `barter_*`) |
| Deployed API + APK | ❌ | See `docs/APP_RETEST_REPORT.md` → "Deployment Runbook" (do not run until the owner says "deploy") |

---

## T1 — Replace seed data with the 10 pilot villages (server)
**Files:** `server/src/seed/data/village_points.json`, `demo_listings.json`, `demo_accounts.json`, `categories.json` (only if a slug is missing), `server/src/seed/run.js`.
**Goal:** after `npm run seed` on an empty DB: 10 Gram Sabhas, 50 listings, 13 users. Nothing else.

**1.1 Delete** all 16 existing villages and 5 existing listings. `run.js` must also remove stale seeded docs on re-run: `GramSabha.deleteMany({ verificationStatus:'verified_seed', 'village.en': { $nin: <the 10 names> } })` and `Listing.deleteMany({ _id-owned by seed users, not in new set })` (match listings by `{ 'title.en', village, taluka }` key).

**1.2 `village_points.json`** — exactly these 10 (field names unchanged: `taluka, villageMr, villageEn, source`; **omit `coordinates`**; set `taluka:"Nashik"`; `source:"Sample Data doc 13 Oct 2026 (demo label)"`). Update `run.js` so a missing `coordinates` leaves `location` unset.

| villageEn | villageMr (verify spelling with the owner) | circle |
|---|---|---|
| Matori | मातोरी | Makhmalabad |
| Jalalpur | जलालपूर | Makhmalabad |
| Mahadevpur | महादेवपूर | Makhmalabad |
| Chandshi | चांदशी | Makhmalabad |
| Govardhan | गोवर्धन | Makhmalabad |
| Mughsare | मुगसरे | Makhmalabad |
| Dari | दरी | Makhmalabad |
| Yashwantnagar | यशवंतनगर | Makhmalabad |
| Mahiravani | महिरावणी | Satpur |
| Vasali | वासाळी | Satpur |

Gram Sabha name = `{mr:"ग्रामसभा <villageMr>", en:"<villageEn> Gram Sabha (demo label)"}`. Keep `verificationStatus:'verified_seed'`, and set `verificationNote:"Demo label — confirm Gram Sabha boundary locally before live use"`. **Remove the invented `cfr.rights` / `approvedAreaHa: 45.5`**: set `cfr:{rights:[], approvedAreaHa:0, claimCount:0}`.

**1.3 Product catalogue** (price in whole ₹; `unit` must be one of `kg,g,quintal,litre,piece,bundle,jar,bag`; `mode:"sell"`; `fulfilment:"both"`; `description` = "Demo sample stock for interface testing — not verified local inventory."; `provenance.sourceForestArea:"Cultivated / approved source (demo)"`; `sustainableDeclared:true`):

| key | titleEn | titleMr | unit | ₹ | categorySlug |
|---|---|---|---|---|---|
| planter | Bamboo planter | बांबू कुंडी | piece | 450 | handicrafts-bamboo |
| basket | Bamboo utility basket | बांबू टोपली | piece | 350 | handicrafts-bamboo |
| stake | Bamboo garden-stake bundle (10) | बांबू काठ्यांचा गठ्ठा (१०) | bundle | 180 | handicrafts-bamboo |
| honey | Managed-apiary honey (500 g jar) | मधपेटीतील मध (५०० ग्रॅम बरणी) | jar | 350 | forest-produce |
| herb | Dried cultivated herb sachet (100 g) | वाळवलेली लागवडीची औषधी वनस्पती (१०० ग्रॅम) | bag | 80 | medicinal-plants |
| fruitpres | Fruit preserve (200 g jar) | फळांचा मुरांबा (२०० ग्रॅम बरणी) | jar | 120 | forest-produce |
| tamarind | Tamarind preserve (200 g jar) | चिंचेचा मुरांबा (२०० ग्रॅम बरणी) | jar | 110 | forest-produce |
| seed | Nursery seed packet (50 g) | रोपवाटिका बियाणे पाकीट (५० ग्रॅम) | bag | 40 | forest-produce |
| leaf | Leaf plates (pack of 25) | पत्रावळी (२५ नग) | bag | 100 | forest-produce |
| rope | Natural-fibre rope (10 m coil) | नैसर्गिक धाग्याची दोरी (१० मी.) | piece | 150 | handicrafts-bamboo |
| dfruit | Dried fruit pack (100 g) | वाळवलेली फळे (१०० ग्रॅम) | bag | 90 | forest-produce |

**1.4 Stock per village** (exactly these 50 rows; `—` = not listed):

| village | planter | basket | stake | honey | herb | fruitpres | tamarind | seed | leaf | rope | dfruit |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Matori | 8 | — | — | 10 | 12 | 12 | — | — | 10 | — | — |
| Jalalpur | — | 8 | — | 8 | — | — | 10 | 15 | — | 5 | — |
| Mahadevpur | 6 | — | — | 6 | 10 | 10 | — | — | 8 | — | — |
| Chandshi | — | — | 8 | 8 | 8 | 12 | — | — | — | 6 | — |
| Govardhan | — | 10 | — | 12 | — | — | 10 | 18 | 12 | — | — |
| Mughsare | — | 10 | — | 10 | 12 | — | — | — | — | 8 | 12 |
| Dari | 6 | — | — | 5 | 8 | 8 | — | — | 6 | — | — |
| Yashwantnagar | — | 6 | — | 5 | — | 8 | — | 12 | — | 5 | — |
| Mahiravani | 10 | — | — | 8 | 10 | — | — | — | 8 | — | 10 |
| Vasali | 8 | — | — | 7 | — | 9 | — | 14 | — | 6 | — |

Generate `demo_listings.json` from the two tables with a small script, not by hand. Each listing's owner = that village's Gram Sabha user (1.5). `searchTerms` already built by `buildSearchTokens` — keep. **Do not** add Lac, wild-hive honey, mahua, gum, ashwagandha. Water-to-farming "leafy greens/okra…" rows from the doc are **out of scope** (not forest products).

**1.5 `demo_accounts.json`** — 10 Gram Sabha secretaries + 3 others (passwords come from `SEED_DEMO_PASSWORD` / `SEED_TEAM_PASSWORD`, never in the file):
- `gramsabha`: phones `+919822011001` … `+919822011010` (order = village table above), `name:"सचिव, ग्रामसभा <villageMr>"`, `village=<villageMr>`, `taluka:"Nashik"`.
- `villager`: `+919822022222`, village `मातोरी`, taluka `Nashik`.
- `buyer`: `+919822033333`, businessName "Demo Herbal Co.", city "Nashik".
- `team`: `+919822099999`.
`run.js` must set each `gramSabhaId` from the matching village (`gsMap.get('Nashik:<villageMr>')`) and set listing `ownerId` to that village's user (replace the `userMap.get('gramsabha')` single-owner logic).

**1.6 Restrict the app to these 10** (server): in `server/src/validators/auth.schema.js` keep the schema, and in `AuthService.register` for roles `gramsabha` and `villager` reject a village that does not match an existing `GramSabha` (`village.mr` or `village.en`, `taluka:"Nashik"`) with `AppError(VALIDATION_ERROR, ..., 422, {village:'Select one of the 10 pilot villages'})`.

**Verify T1:**
```
npm run seed && npm run seed     # second run must not change counts
mongosh vanrozgar --eval 'db.gramsabhas.countDocuments()'           // 10
mongosh vanrozgar --eval 'db.listings.countDocuments()'             // 50
mongosh vanrozgar --eval 'db.listings.distinct("village").length'   // 10
mongosh vanrozgar --eval 'db.listings.countDocuments({"title.en":/wild|lac|mahua|gum|ashwagandha/i})' // 0
```
Add `server/tests/unit/seed-data.test.js` asserting 10 villages, 50 listings, no banned word, every price a positive integer, every unit in the enum.

---

## T2 — Pilot scope in the app (Flutter)
**Files:** `app/lib/features/auth/register_screen.dart`, `app/lib/features/search/search_screen.dart`, `app/lib/shared/widgets/listing_card.dart`.
1. **Register (Gram Sabha + Villager):** replace the free-text *village* and *taluka* `TextField`s with one `DropdownButtonFormField<GramSabhaModel>` filled from `GET /gramsabhas?limit=50`. On select, set `data['village']=gs.villageMr`, `data['taluka']='Nashik'`, and (villager only) `data['gramSabhaId']=gs.id`. Block submit if none selected. Show `ग्रामसभा <village> (demo)`.
2. **Search:** default `taluka=Nashik`; add a village filter chip row built from the same `/gramsabhas` list (query param `taluka` already supported; add client filter by `listing.village`).
3. **ListingCard:** if `distanceKm == null` show `अंतर माहीत नाही • Distance unknown` (no `null`/`0 km`). Add `DemoDataChip` (grey, `Icons.science_outlined`, "Demo data") when `gramSabha.verificationStatus == 'verified_seed'` — widget exists in `badges.dart` as the `verified_seed` branch.
**Verify:** `flutter analyze` clean; register as villager → dropdown shows exactly 10 entries.

---

## T3 — Reject with reason (server + Gram Sabha UI)
**Server** (`server/src/validators/trade.schema.js`, `server/src/services/trade.service.js` `updateStatus`, `server/src/models/Request.js`):
1. In `updateRequestStatusSchema` add `.superRefine`: if `action==='reject'` then `note` is required, trimmed length **5–300**; error path `['note']`, message `Reason is required (min 5 characters)`.
2. `Request.history[]` already stores `note`. Add top-level `decisionNote: String` and set it on `reject` (`request.decisionNote = note`). Keep the existing `Message` to the applicant (it already includes the note).
3. Serialize `decisionNote` and `history` in `GET /requests` and `GET /requests/:id` (they are already returned as the raw Mongoose doc; just ensure no `select` strips them).
**App** (`app/lib/shared/models/trade_request.dart`, `app/lib/features/gramsabha/gs_requests_screen.dart`, `gs_home_screen.dart`, `app/lib/shared/widgets/request_card.dart`):
1. Model: add `final String? decisionNote;` parse `json['decisionNote']`.
2. `onReject` (both screens): open `showModalBottomSheet` with a `TextField(maxLength:300, minLines:2)` + `Reject / नाकारा` (red) and `Cancel`. Disable the button until `trim().length>=5`. Send `api.patch('/requests/$id/status', data:{'action':'reject','note':text})`. On `AppException` with `fields['note']` show it under the field. After success invalidate `requestsProvider('incoming')` and `ordersProvider('selling')`.
3. `request_card.dart`: when `status=='rejected'` and `decisionNote!=null` render a red-tinted row `कारण • Reason: <decisionNote>` (use `tokens.chipErrorBg`, `tokens.error`).
**Verify (HTTP):** `PATCH /requests/:id/status {"action":"reject"}` → **422**; with `"note":"Stock reserved for local use"` → 200 and `GET /requests/:id` (as buyer) contains `decisionNote`.

---

## T4 — Applicant dashboard: "what I applied for + status"
**Files:** `app/lib/features/villager/villager_home_screen.dart`, `app/lib/features/buyer/buyer_home_screen.dart`, `app/lib/shared/widgets/request_card.dart`, `app/lib/shared/widgets/status_count_chips.dart`, `gs_requests_screen.dart`.
1. New widget `MyRequestsSummary` (put in `app/lib/shared/widgets/`): watches `requestsProvider('mine')`; shows `StatusCountChips` with counts **Pending / Approved / Rejected / Counter-offer** (map `countered`), then the 3 newest requests as compact rows: product title (`listing.titleMr/En` by locale), `qty unit`, village, **status pill with icon + text** (pending amber `Icons.schedule`, approved green `Icons.check_circle`, rejected red `Icons.cancel`, countered blue `Icons.swap_horiz`), and `View all →` → `/v/requests` or `/b/requests`. Empty state: use `EmptyState` ("अजून कोणतीही मागणी नाही").
2. Insert it under the search pill on both homes (replace any existing static "open requests" card).
3. `/v/requests` and `/b/requests` (same `GsRequestsScreen`, `scope='mine'`): tabs **Pending (प्रलंबित) / Approved (मंजूर) / Rejected (नाकारले) / Counter (प्रति-ऑफर)** instead of the 2 tabs; counter tab shows `Accept` / `Decline` → `POST /requests/:id/counter/respond {action}`; approved cards link to `/orders/:id` (use `GET /orders?scope=buying`, match by `requestId`).
4. Pull-to-refresh + refresh on app resume (`WidgetsBindingObserver`) so the applicant sees the Gram Sabha's decision without restart.
**Gram Sabha portal:** home "New Requests" tile must equal the count of `status=='pending'` in `requestsProvider('incoming')`; tapping opens `/gs/requests` on the Pending tab; Approve → existing flow (creates order), Reject → T3, Counter → existing sheet.
**Verify (end-to-end, two accounts):** buyer requests Matori honey ×2 → buyer dashboard shows *Pending 1*; Matori secretary rejects with a reason → buyer pull-to-refresh shows *Rejected 1* and the reason; repeat with approve → *Approved* + order link; stock drops by the quantity.

---

## T5 — UI/UX parity with VanMitra (Flutter)
Reference = VanMitra screenshots (1st image of this chat batch) + `VanMitra-AI_Theme_UI_Style_Guide.docx`. Current VanRozgar screens already match: green header + `EN ▾` pill, orange avatar hero card, floating 5-tab nav with orange active item, orange pill CTA. Fix **only** these deviations:

| # | Deviation (VanRozgar now → VanMitra) | Fix (file) |
|---|---|---|
| U1 | **Bottom overlap bug:** the "Add New Listing" button and last cards are hidden under the floating nav | Every scrollable body in portal shells gets `padding: EdgeInsets.only(bottom: 120)` (nav height 72 + margin 16 + safe area). Implement once in `PortalShell` (`app_router.dart`) by wrapping `child` in `Padding(bottom: 0)` + give each `ListView/SingleChildScrollView` `bottom: 120`; or add `MediaQuery.padding` override. Verify no widget is clipped on a 360×640 dp device |
| U2 | **No breadcrumb strip** under the header (VanMitra: light strip "डॅशबोर्ड"; plan: `Home › My Listings`) | Add the existing `Breadcrumb` widget to every portal **home/tab** screen (`gs_home`, `villager_home`, `buyer_home`, requests, orders, profile) as the first child, 36 dp tall, `tokens.surface` bg, bold last segment |
| U3 | **Notice strip** is a white rounded card; VanMitra uses a full-width light-blue tinted strip (`tokens.info` at 10 % alpha), megaphone icon, one-line marquee, `n/N` pager, ✕ | Restyle `notice_strip.dart`: `borderRadius: 0`, full width, bg `tokens.info.withValues(alpha:.10)`, bottom 1 px `tokens.outline`; remember dismissal per notice id in `shared_preferences`; load text from `GET /meta` → `data.notices[].text` instead of the hard-coded list |
| U4 | **Footer strip** (`Helpline … | वन हक्क कायदा 2006 | गोपनीयता धोरण`) renders as plain text on the page; VanMitra shows a **dark-green bar** (`tokens.brandPrimary`, text `tokens.onBrand`, 11 sp) docked directly above the nav | `footer_strip.dart`: give it a `Container(color: tokens.brandPrimary, height: 28)`; place it once in `PortalShell` between `body` and the nav (not per-screen) |
| U5 | **Hero banner** is a flat dark gradient with a sun; VanMitra has layered hills + house + sun on a lighter green and the profile card overlaps the banner | `hero_banner.dart`: 3 layered `CustomPainter` hills (`brandSecondary` @ 0.9/0.6/0.35), house icon, orange sun circle `actionPrimary` @ 0.9; height 140; profile card offset `-48` into the banner |
| U6 | **Dashboard cards**: VanMitra rows have a leading tinted icon tile, bold title, muted subtitle, **chevron `›`**, soft illustration on the right; VanRozgar stat cards are 2×2 with large numbers but no tap target | Keep the 2×2 stats but make every card tappable (`InkWell`): Active Listings → `/gs/listings`, New Requests → `/gs/requests`, Orders → `/gs/orders`; add chevron. Add one `PreferenceCard`-style row "Forest Produce & Trade → View All" |
| U7 | **Profile screen** lacks VanMitra's *diagnostics card* ("Offline queue · Synced" + orange "Sync now") | Add `SyncDiagnosticsCard` to `profile_screen.dart`: static "Synced" green pill + text "Offline queue is planned (phase F4)" + disabled orange button. Do **not** claim offline support |
Also: header title for portals must read `VanRozgar | वनरोजगार`, subtitle `<village>_<taluka>_<district>` (as VanMitra's `ozhar_jawhar_palghar`) — already so for Gram Sabha; do the same for villager/buyer (`user.village` or `user.city`).
**Verify:** golden/visual check on 360×800 and 411×914 dp; light mode only; `flutter analyze` clean; nothing clipped; no `Colors.white` / `Color(0x` outside `core/theme`.

---

## T6 — Cleanup & docs (small)
1. `flutter analyze` → fix the 2 infos (`activeColor` → `activeThumbColor` in `delivery_jobs_screen.dart`; add `const` in `satellite_alert_card.dart`). If `satellite_alert_card.dart` is VanMitra leftover and unused (`grep -rn SatelliteAlertCard app/lib`), delete it.
2. Remove the admin quick-login from `login_screen.dart` (`role=='team'` with `VanMitraAdmin@2026`); keep GS/Villager/Buyer quick-logins but update their phones to the T1 values (`+919822011001`, `+919822022222`, `+919822033333`) behind `AppConfig.devTools`.
3. `server/.env.example`: replace demo passwords/JWT secret with placeholders.
4. Update `docs/IMPLEMENTATION_STATUS.md` honestly (✅ only for what was tested).
5. Add API tests (`supertest`) for: reject-without-note → 422; reject-with-note → `decisionNote`; applicant `GET /requests?scope=mine` shows status; register with a non-pilot village → 422.

**Final acceptance (all must pass):**
`cd server && npm test` · `cd app && flutter analyze && flutter test` · the T4 two-account scenario · seed counts 10 / 50 / 13 users.

## Known open items (do not attempt now)
Real CFR/MRSAC import; village coordinates for distance; production deploy; Play-Store signing/app id. See `docs/APP_RETEST_REPORT.md`.
