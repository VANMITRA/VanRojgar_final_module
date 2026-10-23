# VanRozgar — System Architecture & Master Plan

**Product:** VanRozgar (वनरोजगार), a forest-resource marketplace and livelihood module for the VanMitra-AI family of CFR apps
**Pilot geography:** Nashik district, Maharashtra (14 talukas; CFR villages from *CFR Nashik 2026*)
**Team:** 3 members · **Demo:** Nashik, 2026-10-14 · **Prototype freeze:** 2026-10-13, 20:00 IST
**Child documents:** [`BACKEND_ARCHITECTURE.md`](BACKEND_ARCHITECTURE.md) (source of truth for the API and database) and [`FRONTEND_ARCHITECTURE.md`](FRONTEND_ARCHITECTURE.md) (source of truth for the Flutter app). **This** document is the source of truth for the product, the roles, the cross-cutting rules and the phase plan. When two documents disagree, fix all of them in the same commit.
**Document date:** 2026-10-12 (v2.0, restructured from v1 and reconciled with the Implementation Plan of 2026-10-07, the Flutter Tech Stack Report, the VanMitra-AI Theme & UI Style Guide and the CFR Nashik 2026 data files)
**Project phase:** **P0 — Baseline: 📋 NOT STARTED.** The repository has no commits yet.
**Confidentiality:** Internal. Do not push these documents to a public repository (see V-S1).

> ⚠️ **Honesty rule (applies to all three documents):** a "✅" must point to a file and a test or command that passed. A number may be quoted only if it was measured, and the measurement must be recorded in an appendix. Everything marked 📋 is a **plan**. A feature that runs on mock or seeded data is labelled ⚠️, never ✅.

---

## 0. Where the project actually stands right now (2026-10-12)

**Built:** nothing yet. `git log` on branch `claude/clever-ptolemy-8zcyf0` reports "does not have any commits yet".

**What exists:**
- **Product and design documents:**
  - Implementation Plan (updated 2026-10-07).
  - Flutter Tech Stack Report (2026-10-07).
  - VanMitra-AI Theme & UI Style Guide.
  - VanMitra app screenshots: Claims, Gram Sabha, Profile.
  - v1 of these three architecture files.
- **Pilot data**, with figures measured on 2026-10-12 and recorded in Appendix B:
  - *CFR Nashik 2026..xlsx* has 14 taluka sheets plus `Summary`, `Sheet17` (villages with no claim filed) and `MPR` (June 2024 progress report).
    - Parsing every row that carries a section 3(1) rights entry gives **899 community-claim rows**.
    - **835** are *पात्र* (eligible/approved), **55** *अपात्र* (rejected), **8** *प्रलंबित* (pending) and 1 is blank.
    - **876** of the 899 rows include right **3(1)(c) — ownership of minor forest produce (MFP)**.
  - *CFR Nashik 2026 MRSAC Resources.docx* covers **680 portal villages**, matched to CFR rows by name within each taluka. For each village it lists:
    - General: area and land parcels.
    - Forest: compartments and administration.
    - Wasteland, soil, water resources, wells, water-conservation works.
    - Transport & infrastructure, education & health, other assets.
  - Neither file contains **latitude/longitude** (checked: 0 matches for latitude, longitude, ° N or centroid). See V-S4.

**Not decided yet:** the open questions in §16.

---

## ⚠️ Verification & Discrepancy Log — Read First

| # | Item | Detail | Resolution / action | Status |
|---|---|---|---|---|
| V-S1 | GitHub repo is **public** | `api.github.com/repos/ayushmore007/VanRozgar-Module` returns `"private": false` (checked 2026-10-12). The owner wants the project confidential | Make the repo private, or move it, **before** the first push. Until then, nothing is committed | ⏳ Open — owner action |
| V-S2 | Login method | Plan: phone **or email** + password **or SMS one-time code**, plus "Forgot password". Tech report: phone + password, **no OTP** | MVP: phone + password, no OTP; "Forgot password" shows "contact your Gram Sabha / VanRozgar team" (D-3) | ✅ Decided in this doc |
| V-S3 | Launch languages | Plan: English, Hindi, Marathi. Tech report: English, Marathi | MVP ships **English + Marathi**; Hindi is a later string file, with no redesign needed (D-4) | ✅ Decided |
| V-S4 | No coordinates in the pilot data | Distance search needs a point per village; the CFR sheet and MRSAC export have none | Demo: hand-geocode the ~20 demo villages into `seed/village_points.json` (source noted per row). Later: centroid of the MRSAC village boundary, or LGD/Census village points | ⏳ Open — B2 task |
| V-S5 | Row count mismatch | The MRSAC doc says it matched "853 of the 950 CFR rows"; our parse finds 899 rows with a 3(1) entry | The seed importer must log every skipped row with its sheet and row number, and the totals go in Appendix B of the backend doc | ⏳ Open — B2 task |
| V-S6 | Section 3(1) letter mapping | The sheet writes rights in Marathi letters, e.g. `3(1),(ग),(घ),(झ),(ट),(ठ)`. We map क→a, ख→b, ग→c, घ→d, ङ→e, च→f, छ→g, ज→h, झ→i, ञ→j, ट→k, ठ→l, ड→m (Appendix C) | The mapping drives rights badges and the MFP listing rule (D-9). **Confirm with an FRA advisor before the demo** | ⏳ Open — needs domain check |
| V-S7 | Bottom-nav active colour | The Style Guide says active = green in light mode. The supplied VanMitra screenshots show **orange** active items in light mode | Follow the screenshots (owner's instruction); token `navSelected = accent.primary` in both modes | ✅ Decided (D-11) |
| V-S8 | Node.js version | The tech report names Node.js 20, whose support ended 2026-04-30 | Use the current **Node.js 24 LTS**; fall back to 22 LTS only if the host lacks 24 (ADR-S5) | ✅ Decided |
| V-S9 | Offline package | The report picks Hive and notes the original package is unmaintained | Use **hive_ce** (the community-maintained fork; same API as VanMitra's Hive) — Phase F4 only | ✅ Decided |
| V-S10 | Delivery tab vs 5-item nav | The plan adds a "My Deliveries" tab; the VanMitra pattern allows exactly 5 tabs | Approved partners get **Home · Search · Orders · Deliveries · Profile**; Requests moves into a segmented control inside Orders (D-12) | ✅ Decided |
| V-S11 | Payments | The report wants Razorpay test mode; the plan lists payment settlement as an open question | No money moves in the demo; `paymentStatus = demo_pending`, labelled "Payment: settled offline (demo)" | ✅ Decided |

---

## 1. Product Identity & Scope

| Field | Value |
|---|---|
| One-liner | An Amazon-style marketplace where CFR Gram Sabhas sell or barter forest resources, villagers and outside buyers buy them, and villagers with vehicles earn by delivering them |
| Motto (splash) | "Trade resources. Create livelihoods." / "संसाधनांचा व्यापार. रोजगाराची निर्मिती." |
| Client | One Flutter (Dart 3) Android app holding all three portals |
| API | Node.js 24 LTS + Express 5 + Mongoose, under `/api/v1` |
| Database | MongoDB Atlas (M0 for the prototype) |
| Hosting | Vercel first; Render/Railway fallback (ADR-S6) |
| Look and feel | VanMitra-AI design language: forest-green header, orange actions, illustrated village banner, 5-tab floating bottom nav, bilingual labels |
| Languages | English + Marathi (Hindi later) |
| Pilot data | Nashik CFR claims + MRSAC village resource profiles |

**In scope for the 2026-10-14 demo (P1–P2):**
- Registration and login for the 3 portals.
- Gram Sabha listings.
- Search with filters.
- Purchase request → approve, reject or counter → order.
- Order status timeline.
- Seeded Nashik Gram Sabhas with CFR rights badges and resource profiles.
- Deployed API and a release APK.

**Stretch (P3):**
- Delivery-partner application, team approval and job flow.
- Simple barter.

**After the demo (P4+):** photos upload, reviews, impact dashboard, group selling, fair-price suggestions, offline queue, Razorpay, dark-mode QA, Hindi.

---

## 2. Users, Portals & Permissions

There are **exactly three login portals**. Delivery is an *option inside* the Villager portal, and the VanRozgar team works through a *restricted back office*, never a fourth portal card.

| Portal | Who | Main goal | Can | Cannot |
|---|---|---|---|---|
| **Gram Sabha** | Office bearers of a CFR village council | Sell or barter the village's resources | Manage own resource catalogue and listings; approve/reject/counter requests; confirm handover; barter with other Gram Sabhas; see earnings | List before team verification *with a "Verified" tag* (they can list, tagged "Verification pending") |
| **Landowner / Villager** | A person living in or owning land in a CFR village | Get resources from other Gram Sabhas; optionally earn with delivery | Search, request to buy, offer barter where the listing allows, confirm receipt, rate; list own produce (pilot policy flag); apply as delivery partner | See or accept delivery jobs before approval |
| **General Buyer** | A person or business outside CFR villages (e.g. an Ayurvedic brand) | Buy raw material, often in bulk | Search, compare by distance and price, request with a reason for large orders, track, rate | Barter; apply for delivery |
| *Back office (team)* | VanRozgar team members (seeded accounts) | Keep the marketplace trustworthy | Verify Gram Sabhas; approve/reject/pause delivery partners with reason; manage categories and restricted items | Be registered through the public app |

**Rule:** hiding a button is UX. The API enforces every permission (`BACKEND_ARCHITECTURE.md` §3.4).

---

## 3. Architecture

### 3.1 System context (target at P2; nothing is running yet)

```
 ┌──────────────── Android phone ────────────────┐
 │ VanRozgar Flutter app (Dart 3)                 │
 │  presentation → Riverpod → repository → Dio    │
 │  flutter_secure_storage (JWT)                  │
 │  hive_ce cache + sync queue (F4)               │
 └───────────────┬────────────────────────────────┘
                 │ HTTPS · JSON · Bearer JWT · /api/v1
                 ▼
 ┌──────────── API (Node.js 24 + Express 5) ─────────────┐
 │ request-id → helmet/cors → rate limit → auth → zod     │
 │ routes → controllers → services → Mongoose models      │
 │ /api/v1/health · /api/v1/meta (phase + component status)│
 └───────┬─────────────────────────────┬──────────────────┘
         │ mongodb+srv (TLS)           │ Razorpay server SDK (P4, test mode)
         ▼                             ▼
 ┌──── MongoDB Atlas (M0) ────┐   Razorpay (optional)
 │ users, gramsabhas,          │
 │ resources, listings, images,│
 │ requests, orders, barter,   │   Back office: protected /api/v1/admin/*
 │ deliveryPartners, deliveries│   used by seeded team accounts through a
 │ reviews, messages,          │   hidden "Team tools" screen (not a portal)
 │ restrictedItems, rateLimits,│
 │ cfrClaims, villageProfiles  │
 └─────────────────────────────┘
 Seed pipeline (one-off, local): CFR xlsx + MRSAC profiles → server/seed/*.json → `npm run seed`
 CI (GitHub Actions): server lint+tests · flutter analyze+tests · tagged APK release (P4)
```

### 3.2 Main rules
1. **The app never talks to MongoDB.** It knows only the API base URL, which is not a secret.
2. **The API is the only authority** for identity, role, ownership, stock and state transitions.
3. **One response envelope** everywhere (`BACKEND_ARCHITECTURE.md` §3.1).
4. **Unbuilt routes return `501 NOT_IMPLEMENTED` with the phase that builds them.** They are never silently missing and never faked (ADR-S9).
5. **Seeded or demo data is labelled** in the UI with a small "Demo data" chip wherever it appears.

### 3.3 Runtime responsibilities

| Part | Owns |
|---|---|
| Flutter app | Navigation, VanMitra-style UI, form validation (first pass), API calls, token storage, language, location permission, image compression (P4), offline cache (P4) |
| Express API | Auth, roles and ownership, validation, restricted-item checks, stock and overselling guards, state machines, messages, rate limits, logs |
| MongoDB Atlas | All persistent state including password hashes and (P4) compressed photos |
| Seed pipeline | Turns CFR and MRSAC files into Gram Sabha, CFR-claim and village-profile documents |
| GitHub Actions | Checks on every push; signed APK on version tags (P4) |

---

## 4. Repository Structure (target — nothing exists yet)

One repository, so the app, the API and the contract are versioned together.

```
VanRozgar/
├── app/                      Flutter app        → FRONTEND_ARCHITECTURE.md Appendix A
├── server/                   Express API        → BACKEND_ARCHITECTURE.md Appendix A
│   └── seed/                 importers + generated JSON (CFR, MRSAC, demo accounts, categories)
├── docs/
│   ├── SYSTEM_ARCHITECTURE.md      this document
│   ├── BACKEND_ARCHITECTURE.md
│   ├── FRONTEND_ARCHITECTURE.md
│   ├── API_CONTRACT.md             generated/maintained from the route table (B1)
│   ├── IMPLEMENTATION_STATUS.md    session hand-off log (§17)
│   └── DEMO_RUNBOOK.md             P2
├── .github/workflows/        ci.yml (P1) · android-release.yml (P4)
├── .gitignore                .env, *.jks, key.properties, build outputs
└── README.md
```

---

## 5. Core Workflows & State Machines

### 5.1 Purchase (P1 — the vertical slice)
```
buyer/villager: listing (active) ─► POST /requests {qty, deliveryPref, reason?}
   request: pending ──approve──► approved ──► order: approved (stock decremented in a transaction)
                    ├─reject───► rejected (reason)
                    ├─counter──► countered ──buyer accepts──► approved ─► order
                    │                       └─buyer declines─► cancelled
                    └─buyer cancels─► cancelled
order: approved → [delivery_assigned → picked_up → on_the_way] → delivered → closed
                                              (P3; self-pickup skips straight to handed_over → delivered)
```
- Requests above `BULK_ORDER_THRESHOLD` (configurable, per unit family) **must** include a reason (the plan's sustainability rule).
- Approval runs in a MongoDB transaction with a guarded `quantityAvailable >= qty` update, so two approvals cannot oversell.
- Every transition writes a `messages` row for the other party (in-app updates; no push in the MVP).

### 5.2 Delivery partner (P3)
`villager applies → pending → (team) approved | rejected(reason) | paused`. Only `approved` partners can list or accept jobs. Accepting is an atomic claim (`status: available → accepted` with a filter on `available`), so two drivers cannot take the same job.

### 5.3 Barter (P3, Gram Sabha ↔ Gram Sabha or villager)
`offer → pending → accepted | rejected | countered`. An order is formed **only when both sides have accepted the same terms version**. General Buyers have no barter routes.

### 5.4 Listing creation (P1)
Validate → **restricted-item check** (normalised name and synonyms against `restrictedItems`) → **rights hint** (D-9) → save as `active` → the trust tag reflects the Gram Sabha's `verificationStatus` (never "Verified" before team review).

---

## 6. Data Model Summary

The full schemas are in `BACKEND_ARCHITECTURE.md` §4 and §8. The collections are:

| Collection | Phase | Purpose |
|---|---|---|
| `users` | B1 | Account, role, language, password hash, links to Gram Sabha/village |
| `gramsabhas` | B1 | Name (mr/en), taluka, village, census code, `location` (GeoJSON), verification, CFR summary |
| `cfrClaims` | B2 | One row per CFR claim from the Nashik sheet: case no., rights letters, compartment, areas claimed/recommended/approved, decision |
| `villageProfiles` | B2 | MRSAC facts per census village (forest ha, water bodies, wells, soil, works) for the Gram Sabha profile page |
| `categories` | B1 | Data-driven resource categories (mr/en), managed from the back office |
| `resources` | B1 | A Gram Sabha's catalogue entries with multilingual `searchTerms` |
| `listings` | B1 | For sale/barter: owner, resource snapshot, qty, unit, price, mode, provenance, location, status |
| `requests` | B1 | Purchase requests and their status history |
| `orders` | B1 | Approved transactions, line snapshots, order/payment status, timeline |
| `messages` | B1 | In-app updates per user |
| `restrictedItems` | B1 | Banned/protected items (starting list needs legal review) |
| `rateLimits` | B1 | TTL counters for login/search/upload limits |
| `deliveryPartners`, `deliveries` | B3 | Applications and jobs |
| `barterRequests` | B3 | Offers with versioned terms |
| `images` | B4 | Compressed photo + thumbnail per document |
| `reviews` | B4 | One per (order, target) after confirmed receipt |
| `impactDaily` | B4 | Pre-computed impact totals |

---

## 7. Pilot Data Integration (CFR Nashik 2026 + MRSAC)

**Why it matters:** the demo shows *real Nashik CFR villages*, with rights and resource facts the audience can recognise, instead of invented sellers.

| Source | Becomes | Shown where |
|---|---|---|
| CFR sheet rows with decision *पात्र* | `gramsabhas` (one per village) + `cfrClaims` | Gram Sabha search results, profile "CFR rights" badges, "Approved CFR area: 24 ha" |
| *अपात्र* / *प्रलंबित* rows | `cfrClaims` only (status kept) | Not offered as sellers; the team can see them in the back office |
| Rights letters, e.g. `(ग)` | `rights: ["3(1)(c)", …]` (Appendix C) | Badges such as "MFP rights 3(1)(c)" and "Water bodies 3(1)(d)" |
| MRSAC village facts | `villageProfiles` keyed by census code | "Village resources" card: forest ha, water bodies, wells, conservation works |
| `Sheet17` (no claim filed) | Not imported | — |

**Rules:**
- **D-9 (rights hint, not a block):** a minor-forest-produce listing from a Gram Sabha without `3(1)(c)` shows the seller a warning and the buyer a "Rights not on record" chip. The team decides later whether to block it, after the FRA advisor confirms (V-S6).
- Seeded Gram Sabhas start as `verificationStatus: verified_seed`, with a visible "Demo data" chip in the demo. They have **no login** until a real office bearer registers and claims the record (B2).
- Village names are stored in Marathi as written in the sheet, plus a transliterated `nameEn` (from the MRSAC doc where it matched). `searchTerms` include both.

---

## 8. API Contract (summary)

The full table, request/response shapes and phases are in `BACKEND_ARCHITECTURE.md` §4 and `docs/API_CONTRACT.md`. The groups are:

| Group | Prefix | First phase |
|---|---|---|
| System | `/health`, `/meta` | B0 |
| Auth & profile | `/auth/*` | B1 |
| Catalogue | `/categories`, `/gramsabhas`, `/resources` | B1 (gramsabha profile + CFR data B2) |
| Listings & search | `/listings`, `/search` | B1 / B2 |
| Requests & orders | `/requests`, `/orders` | B1 |
| Messages | `/messages` | B1 |
| Delivery | `/delivery-partners`, `/deliveries` | B3 |
| Barter | `/barter-requests` | B3 |
| Reviews, images, impact | `/reviews`, `/images`, `/impact` | B4 |
| Back office | `/admin/*` | B2 (Gram Sabha verification), B3 (partners) |

---

## 9. UI / UX Design System (VanMitra-derived)

The full component specification is in `FRONTEND_ARCHITECTURE.md` §5. The summary:

| Element | VanMitra source | VanRozgar use |
|---|---|---|
| Header | Forest-green `#1A4331` bar: back arrow, "VanMitra-AI \| VanMitra", location subtitle, sync dot, `EN ▾` language pill | "VanRozgar \| वनरोजगार", subtitle = user's village/taluka, connection dot, language pill |
| Notice strip | Blue-tinted announcement ticker with `3/4` pager and ✕ | Marketplace notices (e.g. "Tendu season opens…"), served by `/meta` |
| Breadcrumb | `Dashboard › My Claims` | `Home › My Listings` |
| Banner | Illustrated hills, trees, village hut, sun | Same illustration family, one per portal home |
| Search | Rounded pill + kebab menu | Global search pill + filter/sort menu |
| Status chips | `0 Approved` green · `0 Pending` amber · `0 Rejected` red + total | Requests/orders summary chips |
| Empty state | Round icon on a leaf motif, bold title, helper line, orange pill CTA | "No listings yet" + "Add Listing" |
| FAB | Orange pill "+ File New Claim" | "+ Add Listing" (Gram Sabha), "+ New Request" where relevant |
| Tabs | Underlined orange tab with bilingual label "Upcoming (येणारी बैठक)" | "Requests (विनंत्या) / Orders (ऑर्डर)" |
| Profile hero | Green card, orange avatar initial, role pill, location pin | Same; role pill "GRAM SABHA" / "VILLAGER" / "BUYER" + verification state |
| Diagnostics card | "Hive Local Queue State · Synced" + orange "Trigger Immediate Cloud Sync" | "Offline queue · Synced" + "Sync now" (F4) |
| Footer strip | Dark green "Helpline · Forest Rights Act 2006 · Privacy Policy" | Same pattern with VanRozgar helpline |
| Bottom nav | White floating rounded bar, 5 items, orange active | Same; 5 items per portal (D-12) |

Colour tokens follow the Style Guide (`brand.primary #1A4331`, `accent.primary #FF8D20`, status colours, and dark-mode surfaces). Light mode ships first; dark-mode tokens are defined from day one and QA'd in F4.

---

## 10. Security, Privacy & Safe-Selling Rules

| Rule | Where enforced |
|---|---|
| Passwords hashed (bcrypt cost 10+); never logged or returned | API |
| JWT: `sub` + `role` only; 7-day expiry for the field prototype; stored only in secure storage | API + app |
| Role + ownership checked on every protected route | API middleware + services |
| zod validation on body, query and params | API |
| Restricted-item check on listing create/update | API service |
| Bulk orders above the threshold need a reason | API (+ app hint) |
| Exact seller location and phone hidden until an order is approved; village shown before | API serializers |
| Rate limits on login (per phone + IP), search and upload; counters in MongoDB | API |
| Secrets only in `.env` (git-ignored) or host settings; `.env.example` holds placeholders | Repo + host |
| No OTP in the prototype: phone ownership is **unverified** (stated in the README and the Q&A) | Known limitation |
| Back office reachable only by seeded `team` accounts; no public route creates them | API |
| Pilot data is government CFR records; keep the repo private (V-S1) | Owner |

---

## 11. Designed vs. Built (whole project)

Status keys: 📋 Planned · 🔨 In progress · ✅ Built & tested · ⚠️ Built with a known limitation (or on demo data). Detailed rows live in each child document's §5.

| # | Capability | Phase | Status | Evidence |
|---|---|---|---|---|
| 1 | Private repo, layout, `.gitignore`, CI | P0 | ✅ | `.gitignore`, `README.md`, `package.json` |
| 2 | API skeleton, health/meta, 501 contract | P0 | ✅ | `server/src/app.js`, `system.controller.js` |
| 3 | Flutter shell, VanMitra theme, router, 3 portal homes | P0 | ✅ | `app/lib/core/theme/`, `app_router.dart` |
| 4 | Register/login (3 roles) | P1 | ✅ | `auth.service.js`, `login_screen.dart`, `register_screen.dart` |
| 5 | Listings create/browse/detail | P1 | ✅ | `listing.service.js`, `add_edit_listing_screen.dart` |
| 6 | Request → approve/reject → order (transactional stock) | P1 | ✅ | `trade.service.js`, `requestMachine.js`, `request_sheet.dart` |
| 7 | Orders timeline + messages | P1 | ✅ | `order.service.js`, `order_detail_screen.dart` |
| 8 | Search with filters and distance | P2 | ✅ | `search.service.js`, `search_screen.dart` |
| 9 | Nashik CFR + MRSAC seed, rights badges, village profile | P2 | ✅ | `seed/run.js`, `rights.js`, `gs_profile_screen.dart` |
| 10 | Back office: Gram Sabha verification | P2 | ✅ | `admin.service.js`, `team_tools_screen.dart` |
| 11 | Deployed API + release APK on demo phone | P2 | 📋 | Ready for deploy & build |
| 12 | Delivery partner flow | P3 | ✅ | `delivery.service.js`, `delivery_jobs_screen.dart` |
| 13 | Barter | P3 | ✅ | `barter.service.js`, `barter_sheet.dart` |
| 14 | Photos, reviews, impact, group selling, fair price, offline, Razorpay, dark QA, Hindi | P4 | 📋 | BACKEND §4.11, FRONTEND §4.8 |


---

## 12. Phase Plan

The time is short, so the phases are measured in **hours**. Each phase has an exit test, and **you do not start a phase while the previous phase's exit test fails.**

| Phase | When (IST) | Backend | Frontend | Exit criteria (all must be true) |
|---|---|---|---|---|
| **P0 Baseline** | Oct 12, evening | B0 | F0 | Repo private; `GET /api/v1/health` 200 against Atlas; `/meta` lists components; app launches on a phone with the VanMitra header, nav and 3 portal homes; CI green |
| **P1 Vertical slice** | Oct 12 night → Oct 13 morning | B1 | F1–F2 | On a real phone against the local API: Gram Sabha creates a listing → buyer finds it → requests → Gram Sabha approves → buyer sees the order; stock decreased; state survives an app restart; the API tests for this flow pass |
| **P2 Demo-ready** | Oct 13, until 17:00 | B2 | F3 | API deployed; the same flow works on **mobile data**; Nashik seed loaded; search + filters; rights badges; bilingual strings on the main screens; release APK installed from clean; `DEMO_RUNBOOK.md` written |
| **P3 Stretch** | Oct 13, 17:00–20:00 | B3 | F3 | Delivery: apply → team approves → job accepted → delivered (or barter offer → accept). **Dropped without regret if P2 is not solid** |
| **Freeze** | Oct 13, 20:00 | — | — | Tag `v0.1.0`; back up the APK and keystore; no more feature changes |
| **P4 After the demo** | Oct 15 → | B4 | F4 | Photos, reviews, impact, group selling, fair price, offline, Razorpay test, dark-mode QA, Hindi, load test |

---

## 13. Architecture Decision Log (system level)

The decisions are summarised here; the backend and frontend files hold their own ADRs.

| ID | Chose | Over | Why |
|---|---|---|---|
| ADR-S1 | Flutter (Dart 3) single app | React Native, two native apps | Same base as the VanMitra team app (future merge); one codebase for 3 portals |
| ADR-S2 | Own REST API between app and DB | Firebase/Firestore direct (as VanMitra uses), Atlas Device Sync | Server-side business rules (stock, approvals, roles) are the core of the product; Atlas Data API and Device Sync were retired; the API keeps the DB secret |
| ADR-S3 | MongoDB Atlas | PostgreSQL (Supabase/Neon), Firestore | Flexible per-resource attributes; built-in 2dsphere geo queries; free tier; the team already chose it |
| ADR-S4 | Express 5 | Fastify, NestJS, Hono | Runs unchanged on Vercel and on a plain server; smallest learning curve for a 1-day build; Express 5 forwards async errors |
| ADR-S5 | Node.js 24 LTS | Node 20 (EOL), Bun, Deno | Supported LTS line in Oct 2026; host support |
| ADR-S6 | Vercel first, Render/Railway fallback | AWS/GCP directly | Deploys from GitHub in minutes; the fallback is the same Express app on an always-on server |
| ADR-S7 | Phone + password + JWT | Firebase Auth phone OTP, Auth0/Clerk | No SMS cost or provider setup before the demo; the data stays in our DB; OTP is a later add-on |
| ADR-S8 | Monorepo `app/` + `server/` | Two repos | The contract and both sides change together |
| ADR-S9 | Unbuilt routes answer 501 + phase | Missing routes or fake success | The app builds against the real contract; status stays honest |
| ADR-S10 | VanMitra design language | A new visual identity | Family resemblance across the team's CFR modules; the owner's instruction |
| ADR-S11 | Seed from real CFR/MRSAC data | Invented sellers | Credibility at a Nashik demo; it exercises search over real Marathi names |

---

## 14. Risk Register

| # | Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|---|
| R1 | Vertical slice not working by Oct 13 noon | Medium | High | Hour-boxed phases; P3/P4 dropped first; daily hand-off in `IMPLEMENTATION_STATUS.md` | All |
| R2 | Venue network fails during the demo | Medium | High | Test on mobile data; hotspot backup; screen recording of the full flow as plan B | Frontend |
| R3 | Vercel cold start / limits during the demo | Medium | Medium | Warm the API with `/health` before going on stage; Render/Railway fallback URL prebuilt into a second APK | Backend |
| R4 | Atlas M0 connection or storage limits | Low (demo) | Medium | Reuse one connection per instance; no photos in P1–P3 | Backend |
| R5 | Wrong rights mapping or village matching shown publicly | Medium | Medium | "Demo data" chip; advisor check (V-S6); show only *पात्र* villages | Data |
| R6 | Repo stays public with confidential plans and data | Medium | High | Make it private before the first push (V-S1) | Owner |
| R7 | Restricted items listed | Low (demo) | High | Restricted check from B1; advisor-validated list before any real user | Backend |
| R8 | Marathi text clipping/overflow | Medium | Low | Noto Sans Devanagari; test the 6 main screens in Marathi on a small phone | Frontend |
| R9 | Fake accounts (no OTP) | High (if public) | Medium | Prototype only; team verification of Gram Sabhas; OTP before the pilot | Product |

---

## 15. Q&A Preparation (demo)

**"Is this real or a mock-up?"**
The answer will be what §11 says on the day. Every ✅ there points to a test. Seeded villages carry a "Demo data" chip. Payments are explicitly not live.

**"Where does the village data come from?"**
From the Nashik CFR claim register (899 community-claim rows across 14 talukas) and the public MRSAC geoportal layers for 680 villages. Seeded sellers come only from approved (*पात्र*) claims.

**"How do you stop protected species being sold?"**
Every listing is checked against a restricted-items list on the server. The starting list needs sign-off by a forest-rights or legal advisor before real users.

**"How does a villager earn?"**
In two ways. Their Gram Sabha's sales are recorded per order. And villagers with a vehicle can apply as delivery partners; after team approval they see paid jobs.

**"Why not just use VanMitra's Firebase?"**
Marketplace rules (stock, approvals, roles, delivery claims) must run on a server we control. The app shares VanMitra's Flutter base and design, so the two can merge later.

**"What about no network in villages?"**
The prototype needs a network. Offline drafts and a sync queue (hive_ce, the same approach as VanMitra) are planned for P4 and are not claimed today.

---

## 16. Open Decisions

| # | Question | Default until decided |
|---|---|---|
| D-1 | Payment settlement: online, cash on delivery, or settled by the team? | `demo_pending`; no money moves |
| D-2 | Delivery pay: fixed per km, or agreed per order? | Fixed demo rate shown as "₹ estimate" |
| D-3 | Login recovery without OTP | "Contact your Gram Sabha / team" screen |
| D-4 | Hindi at launch? | English + Marathi only |
| D-5 | Delivery option in the Gram Sabha portal too? | Villager portal only (per plan) |
| D-6 | Categories live at launch; who adds new ones? | 5 plan categories + "Others"; team adds via back office |
| D-7 | Bulk threshold values | `50` per unit family (kg, litre, piece), configurable |
| D-8 | Can villagers list their own produce? | Yes, behind `ALLOW_VILLAGER_LISTINGS=true` |
| D-9 | Missing 3(1)(c) on MFP listings: warn or block? | Warn (see §7) |
| D-10 | Starting restricted-items list | A short placeholder list marked "unverified" |
| D-11 | Nav active colour | Orange (screenshots) |
| D-12 | Delivery tab placement | Replaces the Requests tab; Requests move into Orders |

---

## 17. Working Rules for Implementation Sessions (including Claude)

1. Read all three documents, then `git status` and the actual tree, **before** changing anything. The folder trees here are targets, not evidence.
2. Work in the phase order of §12. Do not start a phase while the previous exit test fails.
3. Make small, compiling steps: run the formatter, linter, analyzer and tests after each one.
4. Never invent credentials, URLs or results. Put placeholders in `.env.example` and list what a human must configure.
5. Never commit secrets, keystores or `.env`. **Do not push while the repo is public (V-S1).**
6. Mock data is allowed only to unblock UI work, and it must be replaced by the API before a feature is marked ✅.
7. Keep `docs/IMPLEMENTATION_STATUS.md` current: files changed, commands run and their output, the blocker, and the next task. Resume from it in a new session; do not restart.
8. When status changes, update §11 here, §5 in the child document, and `/api/v1/meta` in the same commit.

---

## Appendix A — Source Documents

| Document | Date | Used for |
|---|---|---|
| VanRozgar Implementation Plan (Updated) | 2026-10-07 | Portals, screens, workflows, open questions |
| VanRozgar — Flutter Tech Stack Report | 2026-10-07 | Stack, MongoDB design, search, offline, load, security, release |
| VanMitra-AI Theme & UI Style Guide | — | Colour tokens, typography, component rules, dark mode |
| VanMitra app screenshots (Claims, Gram Sabha, Profile) | — | Layout patterns (§9) |
| CFR Nashik 2026..xlsx | — | Gram Sabha and CFR-claim seed |
| CFR Nashik 2026 MRSAC Resources.docx | Oct 2026 | Village resource profiles |
| v1 SYSTEM/BACKEND/FRONTEND_ARCHITECTURE.md | — | Superseded by v2 |

## Appendix B — Data Measurements (2026-10-12)

| Check | Method | Result |
|---|---|---|
| CFR sheets | `openpyxl` sheet list | 14 taluka sheets (Nashik, Dindori, Peth, IGT, TBK, Surgana, Sinnar, Chandwad, Kalvan, Deola, Malegaon, Baglan, Nandgaon, Yeola) + Summary, Sheet17, MPR |
| Claim rows | rows from row 3 with a cell starting `3(1)` | 899 (Nashik 19, Dindori 86, Peth 142, IGT 56, TBK 119, Surgana 117, Sinnar 18, Chandwad 30, Kalvan 111, Deola 28, Malegaon 56, Baglan 93, Nandgaon 21, Yeola 3) |
| Decisions | cell equal to पात्र / अपात्र / प्रलंबित | 835 / 55 / 8, 1 blank |
| MFP right | rights cell contains `(ग)` | 876 |
| Column layout | header rows | Not uniform: TBK has an extra "committee formed date" column; Peth uses "ग्रामपंचायत" instead of "गांव"; some Surgana rows are shifted. The importer must map by header text, not by position |
| MRSAC coverage | section headings | 680 villages in 14 talukas; per-village rows: General 680, Soil 680, Water resources 680, Water conservation 680, Wells 678, Transport 678, Education & health 664, Forest 636, Wasteland 498, Other assets 481, Conservation reserve 10 |
| Coordinates | grep `latitude, longitude, °N, centroid` | 0 matches (V-S4) |

## Appendix C — FRA Section 3(1) Letter Mapping (to be confirmed, V-S6)

| Marathi | Clause | Right (short) | Badge |
|---|---|---|---|
| (क) | 3(1)(a) | Hold and live in forest land | Habitation |
| (ख) | 3(1)(b) | Nistar / community uses | Nistar |
| (ग) | 3(1)(c) | Ownership, collection, use and disposal of **minor forest produce** | **MFP rights** |
| (घ) | 3(1)(d) | Fish, water bodies, grazing, seasonal resources | Water & grazing |
| (ङ) | 3(1)(e) | Habitat of PVTGs / pre-agricultural communities | Habitat |
| (च) | 3(1)(f) | Disputed lands | — |
| (छ) | 3(1)(g) | Conversion of leases/grants to titles | — |
| (ज) | 3(1)(h) | Settlement of forest villages | — |
| (झ) | 3(1)(i) | Protect, regenerate, conserve, manage **community forest resource** | **CFR management** |
| (ञ) | 3(1)(j) | Rights under state laws | — |
| (ट) | 3(1)(k) | Access to biodiversity, traditional knowledge | Biodiversity |
| (ठ) | 3(1)(l) | Other traditional rights | Traditional |
| (ड) | 3(1)(m) | In-situ rehabilitation | — |

## Appendix D — Glossary

**CFR** Community Forest Resource rights under the Forest Rights Act, 2006 · **Gram Sabha** village assembly holding CFR rights · **MFP** minor forest produce (tendu, mahua, honey, lac, gum, bamboo …) · **MRSAC** Maharashtra Remote Sensing Application Centre · **पात्र / अपात्र / प्रलंबित** eligible / rejected / pending · **Pada** hamlet of a revenue village.

## Appendix E — Document Maintenance Rules

- Put dated update lines in the header.
- Correct a wrong statement in place, with a dated note.
- Update §11 here, §5 of the child document and `/api/v1/meta` in the same commit as the code.
- Every "✅" cites a file and a test.
