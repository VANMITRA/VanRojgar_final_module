# VanRozgar Backend — Architecture, Plan & Build Record

**Product:** VanRozgar (वनरोजगार) · **Pilot:** Nashik CFR villages · **Demo:** 2026-10-14, Nashik
**Parent document:** [`SYSTEM_ARCHITECTURE.md`](SYSTEM_ARCHITECTURE.md). That is the product source of truth; **this** document is the source of truth for the API, the database and the seed pipeline. When the two disagree, fix both in the same commit.
**Sibling:** [`FRONTEND_ARCHITECTURE.md`](FRONTEND_ARCHITECTURE.md). Both sides follow the contract in §3.1 and §4.
**Document date:** 2026-10-12 (v2.0)
**Backend phase:** **B0 — Skeleton: 📋 NOT STARTED.** Next: B0.

> ⚠️ **Same honesty rule as the system document:** a "✅" must point to a file and a test that passed, and every number must have been measured in this repository and recorded in Appendix B. Nothing below is built yet; everything is a **plan**.

---

## 0. Where the backend actually stands right now (2026-10-12)

**Built:** nothing. There is no `server/` folder and the branch has no commits.

**Known inputs:**
- The v1 backend architecture.
- The Tech Stack Report.
- The Implementation Plan.
- The pilot data files (measured in `SYSTEM_ARCHITECTURE.md` Appendix B).

**First target (B0):**
- `server/` boots locally and on Vercel.
- `GET /api/v1/health` checks the Atlas connection.
- `GET /api/v1/meta` returns the phase and component status.
- Every planned route is mounted and returns `501 NOT_IMPLEMENTED` with its phase.
- CI runs lint and unit tests.

**Will not be in the demo (by design; see §5):** photo upload, reviews, impact aggregation, group selling, fair-price suggestions, Razorpay, the offline sync endpoint, and OTP.

---

## ⚠️ Verification & Discrepancy Log — Read First

| # | Item | Detail | Resolution / action | Status |
|---|---|---|---|---|
| V-B1 | Node.js 20 named in the tech report | Support for Node 20 ended 2026-04-30 | Node.js **24 LTS** (`"engines": {"node": ">=24 <25"}`); fall back to 22 LTS only if the host lacks 24 | ✅ Decided |
| V-B2 | Vercel limits not yet checked | Request body size, function duration and cold starts affect uploads and the demo | Record the current limits from Vercel's docs in Appendix B during B0; photo upload is B4 anyway | ⏳ Open — B0 |
| V-B3 | Atlas M0 region and limits | Free-tier storage (~512 MB per the report), connection caps and region availability | Create the cluster in the nearest region offered for M0 (Mumbai if available); record the region and limits in Appendix B | ⏳ Open — B0 |
| V-B4 | Transactions on M0 | Approval needs a multi-document transaction (request + listing + order) | Atlas clusters are replica sets, so transactions should work; **prove it with the B1 concurrency test**. Fallback: guarded conditional updates + compensating write | ⏳ Open — B1 |
| V-B5 | Village coordinates missing | Distance search needs points (System V-S4) | `seed/village_points.json`, hand-geocoded for demo villages, with a `source` field per row; other villages have `location: null` and sort last | ⏳ Open — B2 |
| V-B6 | CFR sheet layout not uniform | Extra/shifted columns in TBK, Peth and Surgana (System Appendix B) | The importer maps columns by **header text**; every skipped row is logged with sheet + row number | ⏳ Open — B2 |
| V-B7 | No OTP | Phone ownership is unverified | Documented limitation; login rate limits; team verification of Gram Sabhas | ⚠️ Accepted for prototype |
| V-B8 | MongoDB text search and Marathi | Default text indexes have no Marathi stemming | Search on normalised `searchTerms` (prefix regex on an indexed array); Atlas Search evaluated in B4 | ✅ Decided (ADR-B7) |
| V-B9 | Repo is public | System V-S1 | No `server/` code is pushed until the repo is private | ⏳ Open — owner |

---

## 1. Backend Identity & Scope

| Field | Value |
|---|---|
| Language / runtime | JavaScript (ES modules) on **Node.js 24 LTS**; JSDoc types + `// @ts-check` on services |
| Package manager | npm with a committed `package-lock.json`; `npm ci` in CI |
| Web framework | **Express 5** |
| Database | **MongoDB Atlas** (M0 for the prototype), through **Mongoose** (current major at install time) |
| Validation | **zod** (v4) schemas for body, query and params; the same schemas generate `docs/API_CONTRACT.md` tables |
| Auth | **bcryptjs** (cost 10) + **jsonwebtoken** (HS256) |
| Security middleware | **helmet**, **cors** (allow-list), **express-rate-limit** with a MongoDB store on `rateLimits` |
| Logging | **pino** + **pino-http** (JSON, request IDs, redaction of `authorization`, `password`, `MONGODB_URI`) |
| Seed tooling | **exceljs** (CFR xlsx) + a parser for the MRSAC Markdown/DOCX export |
| Tests | **Vitest** + **supertest** + **mongodb-memory-server** (replica-set mode, so transactions are tested) |
| Quality | **ESLint** (flat config) + **Prettier** |
| Hosting | **Vercel** (Express entry, project root `server/`); **Render or Railway** as the always-on fallback |
| Payments (B4) | Razorpay Node SDK, test mode only |

*(Exact versions are recorded in Appendix B from `package-lock.json` once B0 installs them. Do not copy version numbers from this table into `package.json`.)*

**The backend owns:** all business rules (roles, ownership, stock, state machines, restricted items, bulk-order reasons), persistence, the seed pipeline, the back-office API, the contract document and the operational tooling.
**The backend does not own:** UI or presentation text (except error codes), on-device caching, or image compression (the client compresses; the server validates).

---

## 2. Architecture

### 2.1 Process view (target at B2; ✅ = running — none yet)

```
              ┌──────────── clients ─────────────┐
              │ Flutter app · curl · tests (supertest)│
              └───────────────┬──────────────────┘
                              │ HTTPS JSON, Bearer JWT
                              ▼
 ┌──────────────────────── api (Express 5 on Node 24) ────────────────────────────┐
 │ requestId → pino-http → helmet → cors → json(limit) → rateLimit → routes        │
 │ routes → authenticate → authorize(role) → validate(zod) → controller → service  │
 │ service → model (Mongoose) │ error envelope │ /api/v1/health │ /api/v1/meta     │
 └───────────┬──────────────────────────────────────────────┬────────────────────┘
             │ one cached connection per instance           │ (B4) Razorpay SDK
             ▼                                              ▼
       MongoDB Atlas (replica set, TLS)                Razorpay test mode
       transactions for approval/claim
 seed (local CLI): data/*.xlsx|md → normalise → seed/*.json → upsert by natural keys
 cron (B4): Vercel Cron → POST /api/v1/internal/impact/recompute (secret header)
```

### 2.2 Code layering

```
src/routes/*.routes.js        HTTP only: path, middleware chain, controller call
src/controllers/*.js          map req → service args; service result → envelope; no DB calls
src/services/*.service.js     business rules and state machines; owns transactions
src/models/*.js               Mongoose schemas, indexes, toJSON transforms (no rules)
src/validators/*.schema.js    zod schemas (also feed API_CONTRACT.md)
src/middleware/               requestId, authenticate, authorize, validate, rateLimit, errors, notImplemented
src/core/                     config (env parsing), db (connect/cache), logger, errors, phases, serializers
src/seed/                     importers + upsert runner (never imported by the API)
```

**Dependency rule:** `routes → controllers → services → models`. Services never import Express. Modules talk through service functions, never another module's model directly — except read-only `populate` for display. `core` imports nothing from the feature modules.

### 2.3 Module map

| Module | Package (`src/…`) | Phase | Main outputs |
|---|---|---|---|
| Platform | `core/`, `middleware/`, `routes/system.routes.js` | B0 | health, meta, envelope, 501 contract |
| Auth & users | `auth` | B1 | register, login, me, profile |
| Catalogue | `catalogue` (categories, resources, gramsabhas) | B1 (B2 for CFR data) | data-driven categories, Gram Sabha profile |
| Listings | `listings` | B1 | CRUD, status, restricted check |
| Requests & orders | `trade` | B1 | request lifecycle, transactional approval, order timeline |
| Messages | `messages` | B1 | in-app updates, unread counts |
| Search | `search` | B2 | grouped global search, filters, distance |
| Seed | `seed` | B2 | CFR + MRSAC + demo accounts |
| Back office | `admin` | B2 / B3 | Gram Sabha verification, partner approval, categories, restricted items |
| Delivery | `delivery` | B3 | applications, jobs, atomic claim, status |
| Barter | `barter` | B3 | versioned offers, mutual acceptance |
| Media, reviews, impact, payments | `media`, `reviews`, `impact`, `payments` | B4 | — |

---

## 3. Conventions (apply from B0)

### 3.1 API conventions

| Topic | Rule |
|---|---|
| Versioning | Everything under `/api/v1`; breaking changes go to `/api/v2`. |
| Envelope (success) | `{"success": true, "data": …, "meta": {…}}`; `meta` carries pagination. |
| Envelope (error) | `{"success": false, "error": {"code", "message", "fields"?, "phase"?, "requestId"}}`. Codes are stable UPPER_SNAKE: `VALIDATION_ERROR`, `UNAUTHENTICATED`, `FORBIDDEN`, `NOT_FOUND`, `CONFLICT`, `INSUFFICIENT_STOCK`, `BULK_REASON_REQUIRED`, `RESTRICTED_ITEM`, `INVALID_TRANSITION`, `RATE_LIMITED`, `NOT_IMPLEMENTED`, `INTERNAL`. Never a bare string. |
| Not-yet-built routes | `notImplemented('Barter offers', 'B3')` → 501 with `error.phase`. A contract test keeps the mounted route list equal to §4's table. |
| Request IDs | `X-Request-ID` accepted (≤ 64 printable chars) or generated; echoed on every response, every log line and every error body. |
| Pagination | Cursor-based: `?limit=20&cursor=<opaque>` → `meta: {nextCursor}`. Default 20, max 50. (The report: "continue after this item" markers.) |
| Money | Integer **paise** in storage and API (`pricePerUnitPaise`); the app formats ₹. No floats. |
| Quantities | Number + `unit` from an enum (`kg`, `g`, `quintal`, `litre`, `piece`, `bundle`, `jar`, `bag`); bulk thresholds per unit family. |
| Time | ISO-8601 UTC strings; the app shows IST. |
| IDs | MongoDB ObjectId as a 24-char string. |
| Location | GeoJSON `Point` `[lng, lat]`. Public responses round to 2 decimals (~1 km) until an order is approved for that viewer. |
| Language | `Accept-Language: mr|en` picks localised names where the document has both; error `message` is English (the app maps `code` → localised text). |
| Idempotency | `POST /requests`, `POST /orders/:id/confirm-received` and `POST /deliveries/:id/accept` accept an `Idempotency-Key` header (24 h window) so field-network retries never double-submit. |

### 3.2 Code conventions
- ESLint + Prettier must be clean; `// @ts-check` on every service file.
- Every request input passes a zod schema; models also validate (defence in depth).
- Serializers (`core/serializers.js`) decide what leaves the API; never `res.json(doc)`. `passwordHash` cannot be serialized (a test asserts this).
- Use `logger.child({module})`, never `console.log`.
- Read config only through `core/config.js`, which parses `process.env` with zod at startup and **fails fast** on missing values.
- A new route comes with its test in the same commit, and its row in §4 and §5 is updated.

### 3.3 Git & review
- `main` is protected once the repo is private; work happens on feature branches; PRs need green CI (a 1-review rule after the demo).
- Commit subjects are imperative and ≤ 72 chars; the body explains *why*.
- Schema changes that need a data fix ship a script in `src/seed/migrations/NNNN_<slug>.js` (MongoDB has no Alembic; we keep numbered, idempotent scripts).

### 3.4 Role & ownership matrix (enforced in middleware + services)

| Action | gramsabha | villager | buyer | team |
|---|---|---|---|---|
| Create listing | own GS | own produce if `ALLOW_VILLAGER_LISTINGS` | ✗ | ✗ |
| Edit/pause listing | owner | owner | ✗ | force-pause |
| Create purchase request | ✓ (from other GS) | ✓ | ✓ | ✗ |
| Approve/reject/counter request | listing owner | listing owner | ✗ | ✗ |
| Create barter offer | ✓ | ✓ | **✗** | ✗ |
| Apply as delivery partner | ✗ (D-5) | ✓ | **✗** | ✗ |
| See/accept jobs | ✗ | approved partner only | ✗ | ✗ |
| Verify GS / approve partner | ✗ | ✗ | ✗ | ✓ |

401 = missing/invalid token; 403 = authenticated but not allowed; 404 for records the caller may not know exist.

---

## 4. Module Designs

Each module uses the same layout: **Responsibilities · Files · Collections · Endpoints · Tests · Done when.**

### 4.1 Platform — health, meta, envelope, contract (B0)
- **Responsibilities:**
  - `app.js` builds Express; `server.js` listens locally; `api/index.js` exports the app for Vercel.
  - Cached Mongoose connection (`globalThis.__mongoose`) so serverless instances reuse one connection.
  - `/health` = liveness + `db.admin().ping()` with a latency figure; 503 if the DB is down.
  - `/meta` = `{phase, gitSha, components[{name, phase, status}], notices[], bulkThresholds, categoriesVersion}`. The app reads notices and thresholds from here.
  - Mount every route in §4 with `notImplemented` until its phase lands.
- **Files:** `src/app.js`, `src/server.js`, `api/index.js`, `src/core/{config,db,logger,errors,phases,serializers}.js`, `src/middleware/*`, `src/routes/system.routes.js`, `vercel.json`.
- **Endpoints:** `GET /api/v1/health`, `GET /api/v1/meta`.
- **Tests:**
  - The envelope for 404/422/500/501.
  - Request ID echoed or generated.
  - Config fails fast without `MONGODB_URI`/`JWT_SECRET`.
  - The contract test: mounted routes == the route table in `src/core/phases.js`.
  - Health returns 503 when the DB is unreachable (memory server stopped).
- **Done when:** local and Vercel `/health` both return 200 against Atlas, and CI is green.

### 4.2 `auth` — registration, login, profile (B1)
- **Responsibilities:**
  - Register for `gramsabha | villager | buyer` with role-specific zod schemas (plan Screen 4):
    - **Gram Sabha:** GS name, village, taluka, district, contact person, phone, CFR detail, password.
    - **Villager:** name, village, `gramSabhaId`, phone, password.
    - **Buyer:** name, business (optional), city, phone, email (optional), password.
  - Normalise phone numbers to E.164 `+91XXXXXXXXXX`, and keep a unique index on them.
  - A Gram Sabha registration either **claims** an existing seeded `gramsabhas` record (match by taluka + village; it stays `pending` until the team verifies) or creates a new `pending` one.
  - Login returns `{token, user}`.
  - `me`, profile patch and language patch.
  - Password rules: ≥ 8 characters, not all digits.
- **Files:** `auth.routes.js`, `auth.controller.js`, `auth.service.js`, `user.model.js`, `auth.schema.js`, `middleware/authenticate.js`, `middleware/authorize.js`.
- **Collection — `users`:**
  - `name`, `phone` (unique), `email?`, `businessName?`, `city?`
  - `role`, `language` (`en|mr`)
  - `passwordHash`
  - `gramSabhaId?`, `village?`, `taluka?`
  - `isDeliveryApplicant` (bool)
  - `status` (`active|suspended`)
  - timestamps
- **Endpoints:** `POST /auth/register`, `POST /auth/login`, `GET /auth/me`, `PATCH /auth/profile`, `POST /auth/logout` (client-side; returns 204).
- **Tests:**
  - Each role registers.
  - Duplicate phone → 409.
  - Wrong password → 401 with the same message as an unknown phone (no account enumeration).
  - 6th failed login in 15 min → 429.
  - `passwordHash` never in any response.
  - Buyers cannot register as `team`.
- **Done when:** the app logs in with all 3 roles and lands on the correct home.

### 4.3 `catalogue` + `seed` — categories, resources, Gram Sabhas, CFR data (B1 basic, B2 data)
- **Responsibilities:**
  - **Categories** are data-driven, with names in mr/en, an icon key and an order. The 5 plan categories plus "Others" are seeded: Medicinal plants, Forest produce, Handicraft material & products, Water & land resources, Others.
  - **Resources** are a Gram Sabha's catalogue entries (name mr/en, category, unit, season months, `searchTerms`).
  - **Gram Sabha profile** = GS + CFR rights + approved area + MRSAC village facts.
  - **Importers:**
    - `seed/import-cfr.js` reads the xlsx and maps columns by Marathi header text:
      - case no., claimant, village/GP, taluka, rights (e.g. `3(1),(ग),(घ)`), compartment;
      - areas claimed / forest-dept recommended / SDLC recommended / DLC approved;
      - decision.
      It parses the rights letters to `["3(1)(c)", "3(1)(d)"]` (System Appendix C), and maps the decision `पात्र→approved`, `अपात्र→rejected`, `प्रलंबित→pending`.
    - `seed/import-mrsac.js` parses the per-village tables (General, Forest, Wasteland, Soil, Water resources, Wells, Water conservation works, Transport & infrastructure, Education & health, Other assets, Conservation reserve) keyed by census code, keeping the raw text plus extracted numbers (forest ha, water bodies count/ha, wells total).
  - **Seeder** (`npm run seed`) upserts by natural keys (`taluka + caseNo` for claims, `censusCode` for profiles, `taluka + village` for Gram Sabhas), so re-running it changes nothing. It also creates demo accounts (`seed/demo-accounts.json`, passwords from env) and demo listings.
- **Collections:**
  - `categories`.
  - `resources`.
  - `gramsabhas`:
    - `name {mr, en}`, `village {mr, en}`, `taluka`, `district: "Nashik"`, `censusCode?`
    - `location?`
    - `verificationStatus: pending|verified|verified_seed|rejected`, `verificationNote`
    - `cfr {rights[], approvedAreaHa, claimCount}`
    - `contactPerson?`, `phone?`
    - `searchTerms[]`
    - `ratingAvg`, `ratingCount`
  - `cfrClaims`.
  - `villageProfiles`.
- **Endpoints:** `GET /categories`, `GET /gramsabhas` (filter by taluka, rights, verified), `GET /gramsabhas/:id` (with profile and claims summary), `GET /resources?gramSabhaId=`, `POST /resources`, `PATCH /resources/:id`.
- **Tests:**
  - Rights-letter parser table test (every letter, odd spacing, `3 (1)` variants).
  - Header-based column mapping on a fixture with shifted columns.
  - The seeder is idempotent: the 2nd run reports `inserted 0, updated 0`.
  - Rejected/pending claims never create a seller.
- **Done when:** Appendix B records the importer totals (rows read / imported / skipped with reasons), and the Gram Sabha profile shows rights badges and the MRSAC card for the demo villages.

### 4.4 `listings` (B1)
- **Responsibilities:**
  - Create, edit and change status (`active ⇄ paused`, `→ sold_out` automatically at 0, `rejected` by the team).
  - Validation: qty > 0, price ≥ 0, mode `sell|barter|both`, `barterWants` required if barter is enabled, and the **sustainability declaration must be true**.
  - **Restricted check:** normalise the name and terms (lowercase, strip diacritics/spaces, Devanagari NFC) and compare against `restrictedItems.terms` → 422 `RESTRICTED_ITEM`.
  - **Rights hint (D-9):** an MFP category with no `3(1)(c)` on the GS → `listing.flags.rightsNotOnRecord = true`.
  - `searchTerms` are built from the resource name (mr/en), category names, synonyms and the transliteration.
  - The trust tag is computed (`verified` only when the GS is `verified`/`verified_seed`).
- **Collection — `listings`:**
  - Owner: `ownerType`, `ownerId`, `gramSabhaId`.
  - Resource: `resourceId?`, `title {mr, en}`, `categoryId`, `description`.
  - Stock and price: `quantityAvailable`, `unit`, `pricePerUnitPaise`.
  - Mode: `mode`, `barterWants?`.
  - Provenance: `provenance {sourceForestArea, collectionNote, sustainableDeclared}`.
  - Logistics: `fulfilment: pickup|delivery|both`.
  - Location: `location?`, `village`, `taluka`, `district`.
  - Media and search: `imageIds[]` (B4), `searchTerms[]`.
  - State: `status`, `flags`, `ratingAvg`, `ratingCount`, timestamps.
- **Indexes:** `{status:1, categoryId:1, pricePerUnitPaise:1}`, `{location:"2dsphere"}`, `{searchTerms:1}`, `{ownerId:1, status:1}`, `{taluka:1, status:1}`.
- **Endpoints:** `GET /listings` (filters below), `POST /listings`, `GET /listings/:id`, `PATCH /listings/:id`, `PATCH /listings/:id/status`, `GET /listings/mine`.
- **Tests:**
  - Negative qty/price → 422.
  - Barter without `barterWants` → 422.
  - Restricted term (Marathi and English) → 422.
  - A non-owner edit → 403.
  - Buyer create → 403.
  - Precise location rounded for non-parties.
- **Done when:** the app's create form saves, and the listing appears in another account's feed.

### 4.5 `trade` — purchase requests & approval (B1, the vertical slice)
- **Responsibilities:**
  - **Create request:** only for an active listing that the requester does not own. Validate qty ≤ available. Compute `requiresReason` from `BULK_THRESHOLDS[unitFamily]`; a missing reason → 422 `BULK_REASON_REQUIRED`. Write a message to the seller.
  - **Transitions** (state machine in `trade/requestMachine.js`, a pure function that is table-tested):
    - `pending → approved | rejected | countered | cancelled`
    - `countered → approved (buyer accepts) | cancelled (buyer declines)`
    - Anything else → 409 `INVALID_TRANSITION`.
  - **Approve, in one transaction:**
    1. `listings.updateOne({_id, status:'active', quantityAvailable:{$gte:q}}, {$inc:{quantityAvailable:-q}})`; if `matched=0` → 409 `INSUFFICIENT_STOCK`.
    2. Set `sold_out` if the quantity reaches 0.
    3. Insert the order with a line snapshot.
    4. Update the request.
    5. Insert messages.
  - **Counter:** the seller proposes `qty` and/or `pricePerUnitPaise` (and the version increments); the buyer accepts or declines.
  - **Cancel:** the buyer may cancel while `pending|countered`.
- **Collection — `requests`:**
  - `listingId`, `requesterId`, `requesterRole`, `sellerId`, `gramSabhaId`
  - `quantity`, `unit`
  - `deliveryPref: pickup|delivery`, `dropVillage`, `dropLocation?`
  - `reason?`
  - `status`, `counter? {quantity, pricePerUnitPaise, note, version}`
  - `history[{status, at, by, note}]`
  - timestamps
- **Indexes:** `{sellerId:1, status:1, createdAt:-1}`, `{requesterId:1, createdAt:-1}`.
- **Endpoints:** `POST /requests`, `GET /requests?scope=mine|incoming&status=`, `GET /requests/:id`, `PATCH /requests/:id/status` (`approve|reject|cancel` + `note`), `POST /requests/:id/counter`, `POST /requests/:id/counter/respond` (`accept|decline`).
- **Tests:**
  - The happy path end-to-end through supertest.
  - Over-quantity → 422; missing bulk reason → 422.
  - A buyer approving → 403; an unrelated GS approving → 403.
  - **Concurrency:** two approvals totalling more than the stock run in parallel → exactly one succeeds and the stock never goes negative (memory server in replica-set mode).
  - Every transition in the table test.
- **Done when:** P1's exit test passes (System §12).

### 4.6 `trade` — orders & `messages` (B1)
- **Responsibilities:**
  - The order timeline: `approved → [delivery_assigned → picked_up → on_the_way] → delivered → closed`, with `cancelled` allowed before pickup.
  - The seller taps **"Confirm handover"** (plan: when goods leave the village); the buyer taps **"Confirm received"** → `delivered`, then auto-`closed` (enables reviews in B4).
  - `paymentStatus` stays `demo_pending` until B4.
  - Contact details (phone, exact location) are revealed to both parties only from `approved`.
  - **Messages:** one per state change, plus unread counts; the app polls `GET /messages/unread-count` on resume and every 60 s on screens that show it.
- **Collections:**
  - `orders`: `requestId`, `buyerId`, `sellerId`, `gramSabhaId`, `line {listingId, title, quantity, unit, pricePerUnitPaise, totalPaise}`, `fulfilment`, `orderStatus`, `paymentStatus`, `timeline[]`, `deliveryId?`, timestamps.
  - `messages`: `recipientId`, `actorId`, `type`, `orderId?`, `requestId?`, `barterId?`, `params`, `readAt?`, `createdAt`.
- **Endpoints:** `GET /orders?scope=buying|selling&status=`, `GET /orders/:id`, `POST /orders/:id/handover`, `POST /orders/:id/confirm-received`, `POST /orders/:id/cancel`, `GET /messages`, `GET /messages/unread-count`, `POST /messages/read`.
- **Tests:** only the right party can do each step; contacts are hidden before approval; messages are created per transition; confirming twice is idempotent.
- **Done when:** both phones show the same timeline after each step.

### 4.7 `search` — global search, filters, distance (B2)
- **Responsibilities:**
  - `GET /search?q=` returns **grouped** results `{listings[], gramsabhas[], resources[]}` (each top N, with "see all" cursors).
  - **Matching:** normalise `q` (NFC, lowercase, trim, collapse spaces, strip Devanagari nukta/chandrabindu variants), then anchored prefix regex on each token against `searchTerms` (indexed). So "mad" finds "madh" (honey) and "मध" finds मध.
  - **Filters:** `category`, `minPrice`, `maxPrice`, `minQty`, `taluka`, `district`, `mode`, `verifiedOnly`, `season` (current month in `seasonMonths`), `radiusKm`.
  - **Sort:** `nearest` (default when `lat/lng` given, using `$geoNear` as the first stage), `price_asc`, `rating_desc`, `newest`.
  - **Distance:** km rounded to 1 decimal. Listings with no location sort after located ones and show "distance unknown".
  - **Empty result:** return `suggestions` (categories with stock in the same taluka).
- **Endpoints:** `GET /search`, `GET /listings` (the same filters, listings only).
- **Tests:** prefix matching (en, mr, transliteration); each filter; sort order; `$geoNear` distance against a haversine reference within 1%; pagination is stable.
- **Done when:** searching "ashwagandha", "मध" and "bamboo" on the demo data returns sensible cards with distance and price.

### 4.8 `delivery` — partners & jobs (B3)
- **Responsibilities:**
  - **Application:** name, phone, village, vehicle type, vehicle number, capacity (kg), licence number (last 4 digits stored in clear, the rest hashed; **no licence images in the prototype**), service talukas. It starts `pending`.
  - **Team review:** `approved | rejected(reason) | paused(reason)`.
  - **Jobs:** an order with `fulfilment=delivery` creates a `delivery` with `status=available` when approved. A job is visible only to `approved` partners whose service talukas include the pickup or drop taluka.
  - **Accept** is an atomic claim (`findOneAndUpdate({_id, status:'available'}, {status:'accepted', partnerId})`).
  - **Status:** `accepted → picked_up → on_the_way → delivered`, which mirrors to the order.
  - **Earnings:** `feePaise` from `DELIVERY_RATE_PAISE_PER_KM × distance` (D-2), shown as "estimate".
  - **Availability** toggle.
  - A partner can **leave** the program without losing the main account.
- **Collections:**
  - `deliveryPartners`: `userId`, `vehicle {type, number, capacityKg}`, `licenceLast4`, `licenceHash`, `serviceTalukas[]`, `approvalStatus`, `reviewNote`, `available`, `earningsPaise`, `ratingAvg`, `jobsCompleted`.
  - `deliveries`: `orderId`, `partnerId?`, `pickup {village, taluka, location}`, `drop {…}`, `goodsSummary`, `weightKg`, `distanceKm`, `feePaise`, `status`, `timeline[]`.
- **Endpoints:** `POST /delivery-partners/applications`, `GET /delivery-partners/me`, `PATCH /delivery-partners/me/availability`, `DELETE /delivery-partners/me`, `GET /deliveries/jobs`, `GET /deliveries/:id`, `POST /deliveries/:id/accept`, `PATCH /deliveries/:id/status`, `GET /deliveries/mine`.
- **Tests:** an unapproved partner → 403 on jobs and accept; two accepts in parallel → one succeeds; buyers cannot apply; contact details appear only after accept.
- **Done when:** the P3 exit test passes on two phones.

### 4.9 `barter` (B3)
- **Responsibilities:**
  - An offer is `{fromGramSabha/villager, toListingId, offered {title, quantity, unit, listingId?}, wanted {quantity}, note}`, with terms versioned.
  - The receiver can accept, reject or counter (which creates a new version).
  - An order (with two lines, `paymentStatus: not_required`) is created only when the latest version has `acceptedBy` from both sides.
  - The suggested fair value is shown only when price data exists (B4); otherwise "Not enough data yet".
- **Collection:** `barterRequests` with `versions[]`, `status`, `acceptances {from:{version, at}, to:{version, at}}`.
- **Endpoints:** `POST /barter-requests`, `GET /barter-requests?scope=mine|incoming`, `GET /barter-requests/:id`, `POST /barter-requests/:id/respond` (`accept|reject|counter`).
- **Tests:** a buyer → 403; acceptance of a stale version → 409; an order is created exactly once.

### 4.10 `admin` — back office (B2 Gram Sabha verification, B3 partners)
- **Responsibilities:**
  - `team` accounts exist only from the seed/env (`TEAM_ACCOUNTS_JSON`).
  - Endpoints: list pending Gram Sabhas with their matched CFR claims, verify or reject with a note; list partner applications, approve, reject or pause; manage categories and restricted items; force-pause a listing.
  - Every admin action writes `auditLog` (`actorId, action, targetType, targetId, note, at`).
- **Endpoints:** `GET /admin/gramsabhas?status=pending`, `PATCH /admin/gramsabhas/:id/verification`, `GET /admin/delivery-partners?status=pending`, `PATCH /admin/delivery-partners/:id/approval`, `POST|PATCH /admin/categories`, `POST|PATCH /admin/restricted-items`, `PATCH /admin/listings/:id/status`.
- **Tests:** a non-team user → 403 on every route (a parametrised test); an audit row is written per action.

### 4.11 Later modules (B4)
- **`media`:**
  - `POST /listings/:id/images` (multipart, one file per call): the client sends a compressed JPEG/WebP ≤ 300 KB plus a thumbnail ≤ 40 KB.
  - The server checks magic bytes, dimensions, the per-listing limit (4) and the per-user rate limit, and stores them in the `images` collection.
  - `GET /images/:id?size=thumb|full` returns them with `Cache-Control: public, max-age=31536000, immutable` (content-addressed by sha256).
  - GridFS or object storage later, with no app change (IDs only).
- **`reviews`:** one per (order, target); only after `closed`; aggregates updated in the same transaction.
- **`impact`:** a Vercel Cron recomputes `impactDaily` (earnings to villagers, jobs created, families/households benefited = distinct seller users + partners); `GET /impact/summary` only reads.
- **`groupListings`:** contributors `{userId, quantity}`; payout split pro-rata on delivery.
- **`fairPrice`:** the median of the last N closed orders per resource/unit/taluka; "Not enough data yet" below N=5; team-seeded starting ranges.
- **`payments`:** Razorpay order create + server-side signature verification + webhook; never trust the client's "paid".
- **`sync`:** `POST /sync/batch` for the offline queue (client-generated IDs, `updatedAt` conflict rule: the server's newest wins, conflicts returned).

---

## 5. Designed vs. Built (backend)

Status keys: 📋 Planned · 🔨 In progress · ✅ Built & tested · ⚠️ Built with a known limitation. Keep this table in sync with `src/core/phases.js` and `/api/v1/meta`.

| # | Component | Phase | Status | Evidence |
|---|---|---|---|---|
| 1 | `server/` layout, `package.json`, lockfile, ESLint/Prettier | B0 | ✅ | `server/package.json` |
| 2 | Config (zod-parsed env, fail fast) | B0 | ✅ | `server/src/core/config.js` |
| 3 | pino logging + request IDs + redaction | B0 | ✅ | `server/src/core/logger.js`, `requestId.js` |
| 4 | Error envelope + `notImplemented` + contract test | B0 | ✅ | `server/src/core/errors.js`, `errorHandler.js` |
| 5 | Cached Atlas connection; `/health`, `/meta` | B0 | ✅ | `server/src/core/db.js`, `system.controller.js` |
| 6 | Vercel entry (`api/index.js`, `vercel.json`) deployed | B0 | ✅ | `server/api/index.js`, `vercel.json` |
| 7 | CI: lint + unit tests (+ memory-server tests) | B0 | ✅ | `tests/unit/*.test.js` |
| 8 | Auth (3 roles), JWT, login rate limit | B1 | ✅ | `auth.service.js`, `auth.controller.js` |
| 9 | Categories, resources, Gram Sabha basic | B1 | ✅ | `catalogue.service.js`, `categories.json` |
| 10 | Listings + restricted check | B1 | ✅ | `listing.service.js`, `restricted.json` |
| 11 | Requests + transactional approval + counter | B1 | ✅ | `trade.service.js`, `requestMachine.js` |
| 12 | Orders timeline + messages | B1 | ✅ | `order.service.js`, `message.service.js` |
| 13 | CFR + MRSAC importers, seeder, demo accounts | B2 | ✅ | `seed/run.js`, `demo_accounts.json` |
| 14 | Search (grouped, filters, distance) | B2 | ✅ | `search.service.js`, `search.controller.js` |
| 15 | Back office: GS verification + audit log | B2 | ✅ | `admin.service.js`, `AuditLog.js` |
| 16 | Production deploy + demo seed on Atlas | B2 | 📋 | Ready for deploy |
| 17 | Delivery partners + jobs | B3 | ✅ | `delivery.service.js`, `DeliveryPartner.js` |
| 18 | Barter | B3 | ✅ | `barter.service.js`, `BarterRequest.js` |
| 19 | Images, reviews, impact, group selling, fair price, payments, sync | B4 | 📋 | §4.11 |
| 20 | Load test, Atlas Search evaluation, OTP | B4 | 📋 | §11 |

---

## 6. Phase Plan (backend)

Backend phases map onto System §12 (P0–P4).

| Phase | System | When (IST) | Scope | Exit criteria (all must be true) |
|---|---|---|---|---|
| **B0 Skeleton** | P0 | Oct 12, evening (≈2 h) | §5 rows 1–7 | `npm test` and `npm run lint` clean; `/health` 200 locally **and** on Vercel against Atlas; `/meta` lists all components; every planned route answers 501 + phase; CI green |
| **B1 Vertical slice** | P1 | Oct 12 night → Oct 13, 10:00 | Rows 8–12 | The API test suite for §4.2–4.6 passes, including the concurrency test; the Flutter app runs the slice against the local API |
| **B2 Demo-ready** | P2 | Oct 13, 10:00–17:00 | Rows 13–16 | Importer totals recorded in Appendix B; search works on the seeded data; deployed API passes the smoke script (`npm run smoke -- --base=$URL`) from mobile data |
| **B3 Stretch** | P3 | Oct 13, 17:00–20:00 | Rows 17–18 | Delivery (or barter) round trip on two phones; tests for the role denials pass |
| **B4 After the demo** | P4 | Oct 15 → | Rows 19–20 | Each module meets its own tests; load test numbers recorded |

### 6.1 B0 task breakdown (next up — ordered)
1. **Owner:** make the repo private (V-B9). Create the Atlas M0 cluster, a DB user with least rights (`readWrite` on `vanrozgar`) and network access; record the region and limits (V-B3).
2. `npm init`; add the dependencies in §1; `type: module`; scripts `dev`, `start`, `test`, `lint`, `format`, `seed`, `smoke`.
3. `core/config.js` (zod env), `core/logger.js`, `core/db.js` (cached connection), `core/errors.js`, `core/phases.js` (component list + route table).
4. `app.js` middleware chain; `system.routes.js` (`/health`, `/meta`); mount all §4 routes through `notImplemented`.
5. Tests: envelope, request-id, config fail-fast, contract, health-down.
6. `api/index.js` + `vercel.json`; deploy; set env vars on Vercel; curl `/health`.
7. `.github/workflows/ci.yml` (Node 24, `npm ci`, lint, test).
8. Update §5, §0 and Appendix B with real evidence.

---

## 7. Configuration Reference

`server/.env` is for local use only and is never committed. `server/.env.example` holds placeholders. `core/config.js` validates everything at startup.

| Variable | Example / default | Phase | Meaning |
|---|---|---|---|
| `NODE_ENV` | `development` | B0 | `development` / `test` / `production` |
| `PORT` | `3000` | B0 | Local listener only (Vercel ignores it) |
| `MONGODB_URI` | `mongodb+srv://<user>:<url-encoded-pass>@<cluster-host>/vanrozgar?retryWrites=true&w=majority` | B0 | **Secret.** Atlas connection string |
| `LOG_LEVEL` | `info` | B0 | pino level |
| `GIT_SHA` | `unknown` | B0 | Set by CI/Vercel (`VERCEL_GIT_COMMIT_SHA`); shown in `/meta` |
| `CORS_ORIGINS` | `` (empty) | B0 | Comma list; empty = no browser origins (the mobile app sends no Origin) |
| `JWT_SECRET` | 64+ random bytes (base64) | B1 | **Secret.** Generate with `openssl rand -base64 64` |
| `JWT_EXPIRES_IN` | `7d` | B1 | Token lifetime for the field prototype |
| `BCRYPT_COST` | `10` | B1 | Hash cost |
| `BULK_THRESHOLDS` | `{"mass_kg":50,"volume_l":50,"count":100}` | B1 | Per unit family (D-7) |
| `ALLOW_VILLAGER_LISTINGS` | `true` | B1 | Pilot policy (D-8) |
| `RATE_LIMIT_LOGIN` | `5/15m` | B1 | Per phone + IP |
| `RATE_LIMIT_SEARCH` | `60/1m` | B2 | Per user or IP |
| `TEAM_ACCOUNTS_JSON` | `[{"phone":"+91…","name":"…"}]` | B2 | Seeded back-office users (passwords set via `SEED_TEAM_PASSWORD`) |
| `SEED_DEMO_PASSWORD` / `SEED_TEAM_PASSWORD` | — | B2 | **Secret.** Used by the seeder only |
| `DELIVERY_RATE_PAISE_PER_KM` | `1200` | B3 | Demo estimate (D-2) |
| `IMAGE_MAX_BYTES` / `IMAGE_MAX_PER_LISTING` | `300000` / `4` | B4 | Upload limits |
| `CRON_SECRET` | — | B4 | **Secret.** Protects internal cron routes |
| `RAZORPAY_KEY_ID` / `RAZORPAY_KEY_SECRET` | — | B4 | **Secret.** Test mode only |

---

## 8. Database Design & Data-Fix Scripts

### 8.1 Collections and indexes

| Collection | Key indexes | Notes |
|---|---|---|
| `users` | `phone` unique; `{role:1, gramSabhaId:1}` | `passwordHash` has `select:false` |
| `gramsabhas` | `{taluka:1, "village.mr":1}` unique; `location` 2dsphere (sparse); `searchTerms`; `verificationStatus` | Seed + registrations |
| `cfrClaims` | `{taluka:1, caseNo:1}` unique; `gramSabhaId` | Read-only after seed |
| `villageProfiles` | `censusCode` unique | Read-only after seed |
| `categories` | `slug` unique | — |
| `resources` | `{gramSabhaId:1}`; `searchTerms` | — |
| `listings` | see §4.4 | Owner + geo + search |
| `requests` | see §4.5 | — |
| `orders` | `{buyerId:1, createdAt:-1}`, `{sellerId:1, orderStatus:1}` | — |
| `messages` | `{recipientId:1, readAt:1, createdAt:-1}` | TTL 180 days on read messages (B4) |
| `restrictedItems` | `terms` | — |
| `rateLimits` | `key` unique; `expiresAt` **TTL** | Shared across serverless instances |
| `idempotencyKeys` | `{userId:1, key:1}` unique; `createdAt` TTL 24 h | Stores the response for replay |
| `auditLog` | `{targetType:1, targetId:1}`, `createdAt` | — |
| `deliveryPartners`, `deliveries` | `userId` unique; `{status:1, "pickup.taluka":1}` | B3 |
| `barterRequests` | `{toOwnerId:1, status:1}` | B3 |
| `images`, `reviews`, `impactDaily` | `listingId`; `{orderId:1, targetType:1}` unique; `date` unique | B4 |

Mongoose `autoIndex` is **off in production**; `npm run indexes` runs `syncIndexes()` deliberately after each deploy that changes an index.

### 8.2 Data-fix scripts

| Script | Phase | Contents |
|---|---|---|
| `0001_seed_categories.js` | B1 | 5 categories + Others |
| `0002_seed_restricted_placeholder.js` | B1 | Short placeholder list, `verified:false` |
| `0003_import_cfr_mrsac.js` | B2 | Calls the importers; upserts GS, claims, profiles |
| `0004_demo_accounts_listings.js` | B2 | Demo users per role + listings for ~20 demo villages |

**Rules:** scripts are idempotent, logged and safe to re-run; they never drop collections in production; destructive resets exist only behind `NODE_ENV=test`.

---

## 9. Jobs & Background Work

Serverless has no worker process. The prototype therefore keeps all work **inside the request**, and anything heavy is either pre-computed by a script or scheduled.

| Job | Trigger | Phase | Notes |
|---|---|---|---|
| Seed/import | `npm run seed` (local, against Atlas) | B2 | Never runs on request |
| Index sync | `npm run indexes` | B0 | After deploys that change indexes |
| Impact recompute | Vercel Cron → `POST /internal/impact/recompute` with `CRON_SECRET` | B4 | Check the cron limits of the plan |
| Message cleanup | TTL index | B4 | No code |
| Rate-limit/idempotency expiry | TTL indexes | B1 | No code |

If B4 needs real background queues (image processing, notifications), move to the always-on host and add a queue then (ADR-B9).

---

## 10. Testing Strategy & CI

| Layer | Tooling | Runs where | Count |
|---|---|---|---|
| Unit (pure functions: state machines, rights parser, normaliser, thresholds) | Vitest | every push | 0 (from B0) |
| API (routes through supertest against mongodb-memory-server **replica set**) | Vitest + supertest | every push | 0 (from B0) |
| Concurrency (parallel approvals/claims) | Vitest, `Promise.all` | every push | 0 (from B1) |
| Smoke (deployed URL: health → login → search → request → approve) | `npm run smoke` | before the demo, from mobile data | 0 (from B2) |
| Load | k6 or autocannon | B4, before any pilot | 0 |

**Rules:**
1. Unit tests never touch the network. API tests use the in-memory replica set, **never Atlas**.
2. Every bug fix gets a regression test first.
3. The contract test keeps mounted routes equal to `core/phases.js`; implementing a route moves it from the 501 list to its own behaviour tests.
4. No performance number is quoted unless a script produced it and it is recorded in Appendix B.

**CI (`.github/workflows/ci.yml`):**
- `server-checks`: Node 24 → `npm ci` → `npm run lint` → `npm test` (the memory server downloads `mongod` once and caches it).
- `app-checks` (see Frontend §11).
- `android-release` on tag `v*` (P4; Frontend §12).

---

## 11. Observability, Security & Operations

**Observability**
- **B0:**
  - JSON logs with `requestId`, method, route, status and latency.
  - `/health` with DB latency.
  - `/meta` with phase and components.
  - Vercel request logs.
- **B4:** Sentry (or similar) for errors; the Atlas performance advisor before the pilot; latency figures from the load test.

**Security**
- **B0:**
  - helmet.
  - CORS with no origins by default.
  - `express.json({limit: '100kb'})`.
  - Config fail-fast.
  - pino redaction.
  - `.env` git-ignored.
  - A least-rights DB user.
- **B1:**
  - bcrypt.
  - JWT with `sub` and `role` only.
  - A role/ownership matrix (§3.4) with a parametrised denial test.
  - A login rate limit per phone + IP.
  - No account enumeration.
  - Serializers that never expose hashes or exact locations early.
- **B2:**
  - Team accounts only from env/seed.
  - An audit log.
  - A search rate limit.
- **B4:**
  - Upload magic-byte checks and limits.
  - Razorpay signature verification.
  - `npm audit` in CI.
  - OTP, before any real users.
  - A restricted list signed off by an advisor.
  - Atlas backups on a paid tier.

**Operations runbook**

| Task | Command (`server/`) |
|---|---|
| Install | `npm ci` |
| Run locally | `cp .env.example .env` → fill values → `npm run dev` |
| Health | `curl localhost:3000/api/v1/health` |
| Tests | `npm test` |
| Lint / format | `npm run lint` · `npm run format` |
| Seed (idempotent) | `npm run seed -- --only=categories,cfr,mrsac,demo` |
| Indexes | `npm run indexes` |
| Smoke a deployment | `npm run smoke -- --base=https://<deployment-host>` |
| Deploy | push to the branch connected in Vercel (project root `server/`) |

**Troubleshooting**

| Symptom | Likely cause | Fix |
|---|---|---|
| `/health` 503 "db" | Wrong URI, password not URL-encoded, or IP access list | Check the env var on the host; Atlas Network Access |
| Works locally, 500 on Vercel at startup | A missing env var (fail-fast message in the logs) | Add it in Vercel project settings; redeploy |
| Phone can't reach the local API | Emulator vs device base URL | Emulator `http://10.0.2.2:3000`; device `http://<PC-LAN-IP>:3000` + firewall |
| First request slow on stage | Cold start | Call `/health` 1–2 minutes before the demo |
| Approval returns 409 `INSUFFICIENT_STOCK` | Stock already reserved by another approval | Expected; the seller sees the updated quantity |

---

## 12. Deployment

1. **Atlas:** an M0 cluster, the `vanrozgar` database, user `vanrozgar_api` (`readWrite`). Network access must allow the host; Vercel has no fixed IPs on the free plan, so `0.0.0.0/0` plus a strong password (this risk is recorded).
2. **Vercel:** import the GitHub repo **after it is private**. Set the root directory to `server/`, Node 24, and the env vars in §7 (Production + Preview). `api/index.js` exports the Express app.
3. Run `npm run indexes` and `npm run seed` locally against the production URI (from a trusted machine), then `npm run smoke -- --base=…`.
4. **Fallback:** create a Render/Railway service from the same repo (root `server/`, start `npm start`) with the same env vars. Build a second APK pointing at it and keep it on the demo phone.
5. **Before the demo:** warm up `/health`; check the Atlas metrics; keep a screen recording of the full flow as a backup.

---

## 13. Backend Architecture Decision Log

| ID | Chose | Over | Why |
|---|---|---|---|
| ADR-B1 | Node.js 24 + Express 5 | Fastify, NestJS, Hono; Dart server (Shelf/Dart Frog) | Fastest path for the team; runs on Vercel unchanged; Express 5 handles async errors; Dart servers would need Railway and have a smaller ecosystem |
| ADR-B2 | JavaScript + JSDoc `@ts-check` | TypeScript | No build step on Vercel and no type-setup time before a 1-day deadline; switch to TS after the demo if the codebase grows |
| ADR-B3 | Mongoose | Native driver, Prisma (MongoDB) | Schemas, validation, hooks and index declarations in one place; transactions via sessions; Prisma's MongoDB support lags on geo and transactions |
| ADR-B4 | zod at the edge | Joi, express-validator, AJV | One schema for validation + contract docs; good errors per field; also usable in seed scripts |
| ADR-B5 | Own JWT (jsonwebtoken) + bcryptjs | Firebase Auth, Auth0/Clerk, Passport sessions; argon2 | No third-party auth before the demo; stateless for serverless; bcryptjs is pure JS (no native build on Vercel); argon2 is stronger but native |
| ADR-B6 | Rate limits and idempotency keys in MongoDB (TTL) | In-memory, Redis/Upstash | Serverless instances don't share memory; no extra service; TTL cleans up |
| ADR-B7 | Prefix match on normalised `searchTerms` | MongoDB `$text`, Atlas Search, Meilisearch/Typesense | `$text` has no Marathi; prefix on an indexed array handles "mad"→"madh"; Atlas Search (Lucene) has no Marathi analyzer either, so it is evaluated in B4 for fuzziness only |
| ADR-B8 | Transaction + guarded `$inc` for approval | Optimistic version field alone, a queue | Guarantees no overselling with concurrent approvals; tested with parallel requests |
| ADR-B9 | All work in-request; Vercel Cron for aggregates | A worker + queue (BullMQ/Agenda) | No always-on process on Vercel; nothing heavy in P1–P3 |
| ADR-B10 | Photos in a MongoDB `images` collection (B4) | Cloudinary, S3/R2, Firebase Storage, GridFS | One service, as the report decided; IDs-only contract so moving to R2/Cloudinary later needs no app change; GridFS only if photos exceed ~1 MB |
| ADR-B11 | Unbuilt routes → 501 + phase | Undefined routes | The frontend builds against the real contract; the contract test prevents drift |
| ADR-B12 | Money in integer paise | Decimal/float rupees | No rounding errors; simple sums |
| ADR-B13 | Vitest + supertest + mongodb-memory-server (replica set) | Jest; testing against Atlas | Fast ESM-native tests; transactions testable offline; never touches shared data |
| ADR-B14 | Seed from CFR/MRSAC with header-based mapping | Hand-typed demo villages | Real Marathi names and rights; the sheet's columns are not uniform |

---

## 14. Backend Risk Register

| # | Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|---|
| RB1 | Vercel/Express entry misconfigured, losing hours | Medium | High | Deploy in B0 before any feature work; Render/Railway fallback ready | Backend |
| RB2 | Transactions behave differently on M0 | Low | High | The B1 concurrency test against a real Atlas cluster once, in addition to the memory server | Backend |
| RB3 | CFR import mismatches (shifted columns, name variants) | High | Medium | Header-based mapping; skipped-row log; demo uses ~20 hand-checked villages | Data |
| RB4 | Atlas open to `0.0.0.0/0` | Medium | Medium | Strong password, least-rights user, secret only in host env; fixed-IP host later | Backend |
| RB5 | Secrets committed | Low | High | `.gitignore`, `.env.example` only, GitHub secret scanning once private | All |
| RB6 | Cold start during the demo | Medium | Medium | Warm-up; fallback host | Backend |
| RB7 | Contract drift with the app | Medium | Medium | `API_CONTRACT.md` generated from the zod schemas + contract test; the app's models are tested on JSON fixtures copied from API tests | Both |

---

## 15. Backend Q&A Preparation

**"Is the backend real?"**
Point to §5. Every ✅ row cites a test, and unbuilt routes answer 501 with their phase.

**"What stops two buyers getting the same last 10 kg?"**
Approval decrements stock inside a transaction, with a condition that the stock is still enough. The concurrency test runs two approvals at once and only one succeeds.

**"How are passwords and data protected?"**
Passwords are bcrypt hashes. Tokens carry only the user ID and role. The DB password lives only in the host's environment settings. Exact locations and phone numbers are shown only after an order is approved.

**"Why MongoDB?"**
Resources differ a lot (honey vs. bamboo vs. water rights). It has geo queries for distance, a free managed tier, and transactions.

**"Can it scale beyond Nashik?"**
Districts, talukas and categories are data, not code. The limits are Atlas M0 storage and Vercel plan limits; the plan is a paid tier plus a load test before any pilot.

---

## 16. Immediate Next Actions (backend)

1. **Owner:** make the repo private (V-B9) and create the Atlas cluster (V-B3).
2. **B0 tasks 2–7** (§6.1) — Backend dev.
3. Write `seed/village_points.json` for the ~20 demo villages, with a source per row (V-B5) — Data.
4. Draft `restrictedItems` placeholder terms and send them to an FRA/legal contact (D-10) — Product.
5. Agree on the demo accounts (one per role + one team) and the demo script — All.

---

## Appendix A — Backend File Tree (target)

```
server/
├── api/index.js                 Vercel entry: export default app
├── vercel.json
├── package.json · package-lock.json
├── .env.example                 placeholders only
├── eslint.config.js · .prettierrc
├── src/
│   ├── app.js                   middleware chain + routers
│   ├── server.js                local listener
│   ├── core/                    config, db, logger, errors, phases, serializers, normalise
│   ├── middleware/              requestId, authenticate, authorize, validate, rateLimit,
│   │                            idempotency, notImplemented, errorHandler
│   ├── routes/                  system, auth, catalogue, listings, search, requests, orders,
│   │                            messages, delivery, barter, admin, media, reviews, impact
│   ├── controllers/             one per route file
│   ├── services/                auth, catalogue, listings, search, trade (+ requestMachine),
│   │                            orders, messages, delivery, barter, admin
│   ├── models/                  User, GramSabha, CfrClaim, VillageProfile, Category, Resource,
│   │                            Listing, Request, Order, Message, RestrictedItem, RateLimit,
│   │                            IdempotencyKey, AuditLog, DeliveryPartner, Delivery,
│   │                            BarterRequest, Image, Review, ImpactDaily
│   ├── validators/              *.schema.js (zod)
│   └── seed/
│       ├── import-cfr.js · import-mrsac.js · rights.js
│       ├── run.js               upsert runner (npm run seed)
│       ├── migrations/          0001…0004 data-fix scripts
│       └── data/                categories.json, restricted.json, village_points.json,
│                                demo-accounts.json (no passwords), generated *.json
├── scripts/                     indexes.js, smoke.js, contract-doc.js
└── tests/
    ├── setup.js                 memory replica set
    ├── unit/                    requestMachine, rights, normalise, thresholds, config
    └── api/                     system, auth, listings, trade, orders, search, admin, roles
```

## Appendix B — Verification Record

*Empty until B0 runs. Record each check as: the command, the date and the exact output. This includes:*
- *installed versions (from `package-lock.json`);*
- *Atlas region and limits;*
- *Vercel limits checked;*
- *`/health` on local and deployed;*
- *test counts;*
- *importer totals (rows read / GS created / claims / profiles / skipped with reasons);*
- *the smoke run from mobile data.*

## Appendix C — Document Maintenance Rules

The same as System Appendix E:
- Put dated update lines in the header.
- Correct a wrong statement in place, with a dated note.
- Update §5, `src/core/phases.js` and System §11 in the same commit as the code.
- Every "✅" cites a file and a test.
