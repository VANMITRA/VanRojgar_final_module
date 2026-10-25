# VanRozgar Implementation Status & Pilot Audit Log

**Product:** VanRozgar (वनरोजगार)  
**Pilot District:** Nashik CFR Villages (14 Talukas, Maharashtra)  
**Status Date:** October 2026  
**Audited & Verified:** Pre-Demo Pilot Release  

---

## 🏗️ Architecture Baseline & Deliverables

| Component | Architecture Document | Status | Implemented Files |
|---|---|---|---|
| **System Rules & Master Plan** | `SYSTEM_ARCHITECTURE.md` | ✅ Complete | Root configs, models, contract, runbook |
| **Backend REST API** | `BACKEND_ARCHITECTURE.md` | ✅ Complete & Hardened | `server/` (Express 5, Mongoose, Zod, Auth, Trade, Seed) |
| **Frontend Mobile App** | `FRONTEND_ARCHITECTURE.md` | ✅ Complete & Hardened | `app/` (Flutter Dart 3, Riverpod, GoRouter, VanMitra Theme) |

---

## 🧩 Backend Implementation Highlights (`server/`)

- **Security & Infrastructure**:
  - Express 5 with Helmet, CORS, pino-http structured JSON logger, and unique `X-Request-ID` tracking.
  - Fail-fast environment variable validation with Zod (`core/config.js`). Relaxed dev rate limits (`120/15m`).
  - **Login Lockout Protection (B2)**: Rate limiting keys on phone + IP (`req.ip:phone`) rather than shared IP; successful logins immediately reset rate limit counters; stale dev locks are cleared on startup.
  - Cached Mongoose database connection supporting local dev, Docker, and Vercel serverless deployment (`core/db.js` & `api/index.js`).
  - Centralized `UPPER_SNAKE` error envelope with automatic request ID echoing (`middleware/errorHandler.js`).
- **Core Business Flows**:
  - **Auth**: E.164 phone normalisation (`+91`), bcrypt hashing, HS256 JWT, 3 distinct portals (`gramsabha`, `villager`, `buyer`) and back-office `team`. Seeded records labeled with `Demo Data` chip.
  - **Listings & Restricted Protection**: Protected species scanner matching against Wildlife Protection Act rules; checks for FRA Section 3(1)(c) MFP rights on the Gram Sabha.
  - **Trade & Order Transactions**:
    - Pure finite state machine (`requestMachine.js`).
    - Guarded decrement with stock protection against overselling (`$gte: quantityAvailable`).
    - Bulk order check: orders of 50 units or more strictly require a sustainability purpose.
    - Agreed counter-offer price is strictly respected upon order generation.
    - Listing GPS coordinates are rounded to 2 decimal places before an order is placed to protect tribal harvest locations.
  - **Search & Geo**: Regex special characters are safely escaped; Unicode Devanagari vowel marks (`\p{M}`) are preserved during normalization; cursor pagination supported; distance calculation in km via Haversine formula and 2dsphere indexing.
  - **Delivery & Barter**: Atomic claiming of available delivery jobs (`findOneAndUpdate`), delivery partner status lifecycle tracking (`assigned` → `in_transit` → `delivered`), mutual versioned barter terms.
  - **Pilot Seeder**: Idempotent upsert seeder for 10 Nashik pilot villages, 50 demo listings (managed/cultivated produce only) and 13 demo accounts, every one labelled Demo. Each listing carries a `productCode` (honey, bamboo, herb, preserve, seed, leaf-plate, fibre, dried-fruit). Real CFR claim data is **not** imported yet.

---

## 📱 Frontend Implementation Highlights (`app/`)

- **VanMitra-AI Visual Identity**:
  - Light & dark design tokens matching the style guide (`#1A4331` forest green, `#FF8D20` action orange, `#2D765C` verified green).
  - Floating 5-tab bottom navigation with active orange highlight, derived dynamically from GoRouter location.
  - Illustrated village and hills hero banner.
  - Bilingual typography (`Noto Sans` & `Noto Sans Devanagari`).
  - VanMitra statistic cards, leaf-framed empty states, status count chips.
- **Portals & Navigation**:
  - 3 Portal Shells with `StatefulShellRoute` via GoRouter:
    - **Gram Sabha**: Dashboard, My Listings, Listing Pause/Activate, Incoming Requests, Orders, Profile.
    - **Villager**: Home, Direct Delivery Jobs & Application Status, Search, Requests, Orders, Profile.
    - **Buyer**: Home, Bulk Produce, Search, Requests, Orders, Profile.
  - Bottom-sheet purchase request modal with dynamic bulk-reason prompt.
  - Delivery partner livelihood application & atomic job claim with driver status buttons (`Picked Up`, `Delivered`).
  - Messages automatically marked as read upon viewing (`POST /messages/read`), with synchronized unread count badge.
  - Network client with 20s timeout, automatic GET retry, and 401 token invalidation.
  - Android configuration includes `INTERNET` permission, cleartext network traffic support, and Windows cross-drive Kotlin fix.

---

## 🚀 Tasks T3–T6 Implementation & Audit Status (October 2026)

### T3 — Reject with Reason (Server & Gram Sabha UI)
- **Status:** ✅ Complete & Verified
- **Server Updates**:
  - `server/src/validators/trade.schema.js`: Added `.superRefine` on `updateRequestStatusSchema` requiring `note` (5–300 chars trimmed) when `action === 'reject'`.
  - `server/src/models/Request.js`: Added top-level `decisionNote: { type: String, trim: true }`.
  - `server/src/services/trade.service.js`: Stores `request.decisionNote = note` on rejection while keeping message dispatch to the applicant.
- **App Updates**:
  - `app/lib/shared/models/trade_request.dart`: Added `decisionNote` field parsed from JSON.
  - `app/lib/shared/widgets/request_card.dart`: Shows red-tinted `कारण • Reason: <decisionNote>` callout when status is `rejected`. Added "ऑर्डर पहा • View Order" button for approved requests.
  - `app/lib/shared/widgets/reject_reason_sheet.dart`: Rejection modal bottom sheet with real-time character counter (min 5, max 300), validation, and localized error handling.
  - Integrated into `gs_home_screen.dart` and `gs_requests_screen.dart`.

### T4 — Applicant Dashboard & Order Linking
- **Status:** ✅ Complete & Verified
- **Components & Screens**:
  - `app/lib/shared/widgets/status_count_chips.dart`: Added support for `counteredCount`.
  - `app/lib/shared/widgets/my_requests_summary.dart`: Dashboard widget with status summary chips, 3 recent items with color-coded status pills (amber/green/red/blue), empty state, and "View all" routing. Placed directly below search pill in `villager_home_screen.dart` and `buyer_home_screen.dart`.
  - `app/lib/features/gramsabha/gs_requests_screen.dart`: Configured 4-tab filtering (`लंबित • Pending`, `मंजूर • Approved`, `नाकारले • Rejected`, `वाटाघाटी • Counter`). Added counter offer Accept/Decline action buttons calling PATCH status API. Matches approved requests to buying orders with direct navigation to order details.
  - Added `WidgetsBindingObserver` lifecycle listener to auto-refresh requests and orders when resuming from background.

### T5 — VanMitra UI/UX Parity (U1–U7)
- **Status:** ✅ Complete & Verified
- **U1 (Bottom Inset)**: Applied 120dp bottom padding across all primary scroll views to eliminate overlap with the floating bottom nav and FAB.
- **U2 (Breadcrumb)**: 36dp surface container breadcrumb in `app/lib/shared/widgets/breadcrumb.dart` deployed across Gram Sabha, Villager, Buyer, Orders, Requests, and Profile screens.
- **U3 (Notice Strip)**: Full-width light-blue notice strip with persistent dismissal per notice ID via `SharedPreferences` and dynamic `/meta` backend integration.
- **U4 (Footer Strip)**: 28dp dark green docked strip (`app/lib/shared/widgets/footer_strip.dart`) pinned globally in `PortalShell` above the bottom nav bar.
- **U5 (Hero Banner)**: 3-layer `CustomPainter` hills with rising sun (`app/lib/shared/widgets/hero_banner.dart` & `landscape_banner.dart`).
- **U6 (Stat Cards & Preference Row)**: Interactive `StatCard`s with chevrons and touch routing to listings, requests, and orders. Added `PreferenceCard` settings row on Gram Sabha home.
- **U7 (Sync Diagnostics Card)**: Profile screen diagnostics card showing online connection status and sync timestamp (avoiding inaccurate offline claims).
- **Brand Subtitle**: `PortalShell` dynamically displays `VanRozgar | वनरोजगार` with `<village>_<taluka>_<district>` subtitle for all authenticated portals.

### T6 — Code Cleanup, Config Sanitization & API Testing
- **Status:** ✅ Complete & Verified
- **Flutter Analyzer**: Clean compilation on `SM A566E` device. Cleaned `login_screen.dart` quick logins (`+919822011001` Gram Sabha, `+919822022222` Villager, `+919822033333` Buyer) gated under `AppConfig.devTools`.
- **Environment**: Sanitized `server/.env.example` with placeholder credentials.
- **API Tests**: Automated test suite verifying reject validation (422 when note < 5 chars, 200 with note persistence), status filtering, and pilot village registration constraints.


---

## ✅ Verified on 25 Oct 2026 (what was actually run)

| Check | Result |
|---|---|
| `cd server && npm test` | **33 / 33 pass**, including the database-backed API test (seed, paging through all 50 listings, nearest order, login, map layer) |
| `GET /api/v1/listings/map` (new) | Returns active listings that have a position; coordinates rounded to 2 decimals; optional `?product=<code>` filter. Covered by an integration test |
| `productCode` on listings (new) | Set on all 50 seeded listings, inferred from the title when a new listing does not give one, validated on create and update |
| App: files outside `features/livelihood` | `flutter analyze` has **no errors or warnings**; the new link helper has 3 passing tests |
| App id | Changed to `in.vanrozgar.app` (namespace, `applicationId`, `MainActivity` package). **Not built**: see the blocker below |
| Demo account buttons | Off by default in release builds (`DEV_TOOLS` defaults to `!kReleaseMode`); no admin credential in the app |

### ❌ Known blockers and gaps (not fixed)

| # | Item |
|---|---|
| 1 | **The app does not compile from a clean clone.** `app/lib/features/livelihood/data/` (the API client, repositories, cache and location service the livelihood screens import) was never committed. `flutter analyze` reports 240 issues, all in `features/livelihood` and its tests, and `test/widget_test.dart` cannot load. Owner: Soham. No APK can be built until the folder is pushed |
| 2 | **Nothing is deployed.** The Render blueprint, Atlas and the secrets are ready to be entered by the owner; no production URL exists |
| 3 | **Release signing is untested.** The workflow and Gradle guard are written; the keystore and GitHub secrets do not exist yet |
| 4 | **Real CFR / MRSAC data is not imported.** The raw files are not on this machine |
| 5 | **Listing to report link**: the button and the route (`/gs|v/livelihood?village=&taluka=&product=`) exist, but the livelihood screen does not read those parameters yet (Soham, S9) |
| 6 | **No test on a real phone** has been done |
| 7 | The earlier "✅ Complete" ticks above for the app were recorded before the livelihood merge and were not re-run |

---

## ✅ 25 Oct 2026, evening: real CFR data and removal of invented data (what was run)

| Change | Verified by |
|---|---|
| Real data loaded: 771 villages, 950 claims (832 approved, 61 rejected, 8 pending, 49 with no decision recorded), 680 MRSAC profiles, rights parsed to FRA clauses | `cfr_data` unit tests and a database-backed test (load, detail endpoint, load twice gives the same counts) |
| Privacy: claimant, committee members, phones, bank name/account/IFSC and homestay owners are not in the repo. One area cell that was really an account number was blanked | A test scans the cleaned files for long numbers and bank fields |
| **Bug fixed:** registering for an existing village created a second, fake Gram Sabha (45.5 ha invented) and attached the user to it | Integration test: no duplicate, claim filed on the real record |
| **Invented data removed from the app:** requests and orders were silently replaced by fake ones (including wild honey and mahua) when a list was empty or the server failed; the profile screen invented 124 ha / 28 wells / 45.5 ha; the register screen had a short made-up village list with old codes (`TBK`, `IGT`) | The fake data file is deleted; lists now show what the server returned or an error with retry |
| Register and delivery areas use the 14 real talukas; villages come from the server | `flutter analyze` clean outside `features/livelihood` |
| Search-screen loop fixed (the buyer home called search 25 times in 9 seconds) | 2 unit tests |
| Server tests | **41 / 41 pass** |

Still open: the app cannot be built until `app/lib/features/livelihood/data/` is pushed; nothing is deployed; no real-phone test; village map points; the livelihood module items assigned to Soham.

---

## ✅ 25 Oct 2026, night: the app compiles, and the livelihood module is built (what was run)

| Check | Result |
|---|---|
| `flutter analyze` | **No issues** (it was 240 issues: `features/livelihood/data/` had never been committed; rebuilt from the tests) |
| `flutter test` | **150 pass**, 4 skipped (they need a live server) |
| `npm test` (Node server) | **41 / 41 pass**, including a database-backed test |
| Python livelihood server: `pytest`, `ruff`, `mypy` | **209 pass**, lint and types clean |

Built: map (tap to move the plot, 2 to 10 km circle, resource pins, listings layer, OSM credit); PDF in English, Marathi and Hindi (checked by looking at the pictures; the `pdf` package cannot shape Devanagari so Flutter draws the text); Hindi for every string; idea to marketplace and listing to idea links; live weather from Open-Meteo with a labelled fallback; 10 real government scheme rows (links only, unchecked by a person); approximate village centres so every register village gets a report; an OpenStreetMap resource builder.

**Not done:** nothing is deployed; no test on a real phone; real resource pins and village positions (the map and Overpass services were unreachable from the build machine); a native reader for Marathi and Hindi; a person to check each scheme row; the privacy page. See `docs/plan.md` section 8.
