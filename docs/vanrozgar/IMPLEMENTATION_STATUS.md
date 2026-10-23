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
  - **Pilot Seeder**: Idempotent upsert seeder for 16 Nashik pilot CFR villages *(clearly labeled as pilot demo accounts & records)*, 5 categories, demo accounts, and demo produce.

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

