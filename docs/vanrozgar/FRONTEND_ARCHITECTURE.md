# VanRozgar App — Frontend Architecture, UI Plan & Build Record

**Product:** VanRozgar (वनरोजगार) · **Client:** Flutter (Dart 3), Android first · **Demo:** 2026-10-14, Nashik
**Parent document:** [`SYSTEM_ARCHITECTURE.md`](SYSTEM_ARCHITECTURE.md) is the product source of truth. **This** document is the source of truth for the Flutter app: structure, screens, the VanMitra-derived design system, state, networking and release. The API contract belongs to [`BACKEND_ARCHITECTURE.md`](BACKEND_ARCHITECTURE.md) §3.1 and §4. When the documents disagree, fix all of them in the same commit.
**Design reference:** the VanMitra-AI Theme & UI Style Guide and the VanMitra screenshots (Claims, Gram Sabha Records, Profile & Settings).
**Document date:** 2026-10-12 (v2.0)
**Frontend phase:** **F0 — Shell: 📋 NOT STARTED.**

> ⚠️ **Same honesty rule as the system document:** a "✅" must point to a file and a test or a recorded on-device check. A screen that renders mock data is ⚠️, never ✅. Everything below is a **plan**.

---

## 0. Where the frontend actually stands right now (2026-10-12)

**Built:** nothing. There is no `app/` folder and the branch has no commits.

**Design inputs in hand:**
- **Style Guide tokens:** colours, type scale, component rules and the dark-mode contract.
- **Three VanMitra screenshots.** Together they show the pattern VanRozgar must follow:
  - green header with a bilingual title, a location subtitle, a sync dot and an `EN ▾` pill;
  - a notice ticker;
  - breadcrumb;
  - illustrated hills-and-village banner;
  - search pill + kebab;
  - status count chips;
  - leaf-framed empty state;
  - orange pill CTA/FAB;
  - underlined orange tabs with Marathi in brackets;
  - green profile hero with an orange avatar;
  - an offline-queue diagnostics card;
  - dark-green legal/helpline strip;
  - a floating white 5-item bottom nav with an orange active item.

**First target (F0):** `app/` runs on a real Android phone and shows the VanMitra shell (header, notice strip, banner, bottom nav) for all three portals from a portal switcher. Router and theme are in place, `GET /api/v1/health` reaches the API, and `flutter analyze` is clean.

---

## ⚠️ Verification & Discrepancy Log — Read First

| # | Item | Detail | Resolution / action | Status |
|---|---|---|---|---|
| V-F1 | Nav active colour | The Style Guide says green in light mode; the screenshots show orange | Orange in both modes (System D-11). One token, `navSelected`, so it is a one-line change | ✅ Decided |
| V-F2 | Exact hex values | The Style Guide says its hex values are "approximated from the visuals" | Use the guide's tokens; if the VanMitra repo's `ThemeData` becomes available, reconcile with it and log the change here | ⏳ Open |
| V-F3 | VanMitra font unknown | The screenshots look like a geometric sans | **Noto Sans + Noto Sans Devanagari**, bundled as assets (offline, full Marathi coverage). Swap if VanMitra's font file is provided | ✅ Decided |
| V-F4 | Banner illustrations | The VanMitra artwork files are not in hand | Request the asset files from the VanMitra team; until then use a simple SVG hills/trees/hut banner in the same palette (`assets/illustrations/`) | ⏳ Open |
| V-F5 | Offline package | The report picks Hive; the original is unmaintained | `hive_ce` in F4 only | ✅ Decided |
| V-F6 | Delivery tab vs 5-item nav | Plan adds "My Deliveries" | Approved partners: Home · Search · Orders · Deliveries · Profile; requests live in a segmented control inside Orders (System D-12) | ✅ Decided |
| V-F7 | Map tile source | `flutter_map` needs a tile provider; the public OSM tiles have a usage policy unsuited to production apps | The demo shows no map (distance appears as text). Pick a tile provider with a free tier and attribution before P4 | ⏳ Open — P4 |
| V-F8 | Package versions | Must be current on pub.dev on build day | Resolve at `flutter pub add` time; record them in Appendix B. Don't copy versions from any document | ✅ Rule |

---

## 1. Frontend Identity & Scope

| Field | Value |
|---|---|
| SDK | Flutter 3.x stable, Dart 3 (versions recorded in Appendix B at F0) |
| Platforms | Android (min SDK 23 or Flutter's current minimum, whichever is higher). iOS/web not in scope |
| State + DI | `flutter_riverpod` (`Notifier`/`AsyncNotifier`; no code generation before the demo) |
| Routing | `go_router` with a `StatefulShellRoute` per portal (5-tab shell) + redirects |
| HTTP | `dio` with interceptors: request ID, auth, error mapping, GET-only retry |
| Token storage | `flutter_secure_storage` |
| Preferences | `shared_preferences` (language, theme mode, last portal) |
| Models | Hand-written immutable classes with `fromJson`/`toJson` (no `freezed` before the demo) |
| Localisation | `flutter_localizations` + `intl` with ARB files (`app_en.arb`, `app_mr.arb`) |
| Fonts | Noto Sans, Noto Sans Devanagari (bundled assets) |
| Icons | Material Symbols (rounded) to match the VanMitra icon style |
| Images (F4) | `image_picker`, `flutter_image_compress`, `cached_network_image` |
| Location (F3) | `geolocator` (permission + one-shot position; falls back to the saved village) |
| Maps (F4) | `flutter_map` + `latlong2` |
| Offline (F4) | `hive_ce` + `connectivity_plus` |
| Charts (F4) | `fl_chart` (impact dashboard) |
| Payments (F4) | `razorpay_flutter` (test mode) |
| Tests | `flutter_test`, `mocktail`, `integration_test` |
| Lints | `flutter_lints` (+ a few stricter rules in `analysis_options.yaml`) |

**The frontend owns:** presentation, navigation, the VanMitra look, localised text, first-pass validation, token storage, connectivity messaging, image compression (F4) and offline cache/queue (F4).
**The frontend does not own:** any authorisation decision, stock/price/state logic, or the source of truth for any record. It never talks to MongoDB and never holds a secret.

---

## 2. Architecture

### 2.1 Layer view

```
 ┌───────────────────────── presentation (widgets, screens) ─────────────────────────┐
 │ VanMitra shell: VrHeader · NoticeStrip · Breadcrumb · HeroBanner · body · FooterStrip │
 │ · VrBottomNav (5 tabs, per portal)                                                │
 └───────────────▲─────────────────────────────────────────────┬─────────────────────┘
        watch state│                                           │ call intent (submit, approve…)
 ┌───────────────┴─────────── providers (Riverpod) ────────────▼─────────────────────┐
 │ authController · sessionProvider · listingsProvider(filter) · listingDetail(id)     │
 │ requestsProvider(scope) · ordersProvider(scope) · searchController · metaProvider   │
 │ unreadCountProvider · languageController · themeModeController                      │
 └───────────────▲─────────────────────────────────────────────┬─────────────────────┘
                 │ typed models / AppException                  │
 ┌───────────────┴──────────── repositories (one per feature) ──▼─────────────────────┐
 │ AuthRepository · ListingRepository · TradeRepository · SearchRepository · …          │
 └───────────────▲─────────────────────────────────────────────┬─────────────────────┘
                 │                                              │
 ┌───────────────┴──────── data sources ───────────────────────▼─────────────────────┐
 │ ApiClient (Dio: base URL, timeouts, RequestId, Auth, ErrorMapper, GET retry)        │
 │ TokenStore (secure storage) · Prefs (shared_preferences) · LocalCache (hive_ce, F4)│
 └─────────────────────────────────────────────────────────────────────────────────────┘
```

**Dependency rule:** `screens → providers → repositories → data sources`. Widgets never import Dio. Repositories return typed models or throw `AppException`. One repository is the source of truth per feature.

### 2.2 Module map (feature → folder → phase)

| Feature | Folder `lib/features/…` | Phase | Main screens |
|---|---|---|---|
| Shell & design system | `core/theme`, `shared/widgets` | F0 | header, nav, banner, chips, empty/error states |
| Onboarding & auth | `auth/` | F1 | splash/promo, language, login, choose portal, register ×3 |
| Gram Sabha portal | `gramsabha/` | F1–F2 | home dashboard, my listings, add/edit listing |
| Listings (shared) | `listings/` | F1 | listing card, detail, trust tag |
| Requests & orders | `trade/` | F2 | request form, my requests, incoming requests, order timeline |
| Search | `search/` | F3 | search bar, results, filters sheet, sort |
| Villager & buyer homes | `villager/`, `buyer/` | F2 | home with search + categories + near you + open items |
| Gram Sabha profile | `gramsabhas/` | F3 | CFR rights badges, village resources card |
| Messages | `messages/` | F2 | updates list, unread badge |
| Profile & settings | `profile/` | F2 | hero, language, theme, logout, team tools (hidden) |
| Delivery | `delivery/` | F3 (stretch) | earn card, explainer, apply, status, jobs, job detail, active, earnings |
| Barter | `barter/` | F3 (stretch) | offer form, offers list, respond |
| Photos, reviews, impact, offline | `media/`, `reviews/`, `impact/`, `sync/` | F4 | — |

---

## 3. Conventions

### 3.1 App ↔ API conventions

| Topic | Rule |
|---|---|
| Base URL | `--dart-define=API_BASE_URL=…` at build time. Dev: emulator `http://10.0.2.2:3000`, device `http://<PC-LAN-IP>:3000`; demo: the deployed HTTPS URL. **Never ship a laptop IP** |
| Envelope | `ApiClient` unwraps `{success, data, meta}`; an error envelope becomes `AppException(code, message, fields, phase, requestId)` |
| Error → UI | `UNAUTHENTICATED` → clear the token, go to login · `FORBIDDEN` → "You don't have access to this" · `VALIDATION_ERROR` → inline field errors · `INSUFFICIENT_STOCK`, `BULK_REASON_REQUIRED`, `RESTRICTED_ITEM`, `INVALID_TRANSITION` → specific localised messages · `NOT_IMPLEMENTED` → "Coming in a later version (phase X)" card · network/timeout → offline banner + retry |
| Retries | Only GET is retried (2 times, exponential backoff with jitter). Mutations are **never** blindly retried; the ones the API marks idempotent send an `Idempotency-Key` (UUID per user action) so a manual retry is safe |
| Money | The API sends paise integers; `formatInr()` shows `₹1,250 / kg` in the active locale |
| Time | Parse ISO UTC; show IST with `intl` ("12 Oct, 4:30 PM" / "१२ ऑक्टो, ४:३० PM") |
| Pagination | `nextCursor`; infinite lists load the next page 3 items before the end |
| Language | Send `Accept-Language: mr|en`; error text comes from ARB by `code`, not from the server message |
| IDs | Strings; never parse ObjectIds |

### 3.2 Code conventions
- `flutter analyze` must be clean, and `dart format` is applied.
- Every user-visible string goes in ARB files. **No hard-coded text in widgets** (a test greps `lib/features/**` for quoted literals inside `Text(`).
- No `Colors.white`, `Colors.black` or raw hex in feature code. Use `Theme.of(context).colorScheme` or `context.vr` (the `VrTokens` ThemeExtension). A test greps for `Color(0x` outside `core/theme`.
- Every data screen renders the five states via `AsyncValueView`: **loading** (skeleton) · **empty** (VanMitra empty state) · **error** (message + Retry) · **offline** (banner) · **data**.
- Submit buttons disable themselves and show a spinner while a mutation runs (no double taps).
- Success messages appear only after server confirmation.
- Destructive actions (pause listing, reject request, cancel order) ask for confirmation in a bottom sheet.

### 3.3 Git & review
The same as Backend §3.3. A UI change ships with a screenshot (English and Marathi) in the PR description.

---

## 4. Module Designs

Each module uses the same layout: **Responsibilities · Files · Screens · Providers · Tests · Done when.**

### 4.1 Shell & design system (F0)
- **Responsibilities:**
  - `VrTheme.light()`/`VrTheme.dark()` built from the tokens in §5.1.
  - `VrTokens` ThemeExtension.
  - Shared widgets (§5.3).
  - `PortalShell`: a `StatefulShellRoute` with 5 branches, the floating bottom nav, the header and the footer strip.
  - Dev-only portal switcher (`--dart-define=DEV_TOOLS=true`).
  - `/meta` fetch for notices.
- **Files:** `core/theme/{tokens.dart, vr_theme.dart, typography.dart}`, `shared/widgets/*`, `core/routing/app_router.dart`, `core/network/api_client.dart`, `core/config/app_config.dart`.
- **Tests:**
  - Golden tests of the header, nav, empty state and status chips in light mode (dark mode at F4).
  - The theme has no hard-coded colours.
  - The router shows the correct 5 tabs per portal.
- **Done when:** the shell runs on a phone and visually matches the VanMitra screenshots, checked side by side (photo recorded in Appendix B).

### 4.2 Onboarding & auth (F1)
- **Screens:**
  1. **Promo/splash:** logo, "VanRozgar", the motto, a "Get Started" pill; auto-advances after ~2.5 s; no menus.
  2. **Language (first launch):** two large cards, "English" / "मराठी", with a check mark; changeable later in Profile.
  3. **Login:** phone (+91 prefix) + password with a visibility toggle; "Forgot password?" opens the help screen (System D-3); "New here? Sign up".
  4. **Choose portal** (registration only): exactly 3 cards with the plan's help text. **No delivery card, no admin card.**
  5. **Register form**, which changes by portal:
     - Gram Sabha: GS name, village (search picker over seeded villages; "not listed" allows free text), taluka, district (prefilled "Nashik"), contact person, phone, CFR detail, password.
     - Villager: name, village picker, Gram Sabha picker, phone, password.
     - Buyer: name, business (optional), city, phone, email (optional), password.
  6. **Pending verification banner:** Gram Sabha accounts see "Verification pending — listings show without the Verified tag".
- **Providers:** `authController` (AsyncNotifier), `sessionProvider` (`User?`), `languageController`.
- **Startup:**
  1. Read the token.
  2. If there is one, `GET /auth/me`: OK → that portal's home; `401` → clear the token, go to login; network error → retry screen. **Never** assume the user is logged in from a stale token.
  3. Then apply the language and go.
- **Tests:** form validation per role; a login error shows the localised message; startup redirect matrix (no token / valid / 401 / offline).
- **Done when:** all 3 demo roles log in on a phone and land on their homes.

### 4.3 Gram Sabha portal (F1–F2)
**Tabs:** Home · Listings · Requests · Orders · Profile.

- **Home (dashboard):**
  - Header subtitle shows the GS village/taluka.
  - Hero banner.
  - 4 summary cards (VanMitra statistic cards): Active listings · New requests · Orders in progress · Total earnings (`₹ — (demo)` until B4).
  - Orange "Add new resource" button.
  - "Latest requests" list (3 items + "See all").
  - A verification banner if pending.
- **Listings:**
  - Breadcrumb `Home › My Listings`.
  - Search pill + kebab (filter: Active/Paused/Sold out).
  - Count chips: `n Active` (green) · `n Paused` (amber) · `n Sold out` (grey).
  - Listing cards: photo/placeholder, title, `50 kg left`, `₹120/kg`, mode badge, status pill.
  - Tapping a card opens edit/pause.
  - Orange FAB "+ Add Listing".
  - Empty state: "No listings yet." + "Start selling your village's forest produce." + CTA.
- **Add/edit listing** (one scrolling form in sections, the VanMitra card style):
  - **What:** category chips + "Others: type new", resource name (mr/en), description.
  - **How much:** quantity + unit dropdown, price per unit (₹) with "Suggested fair price: Not enough data yet" (B4).
  - **Mode:** segmented Sell / Barter / Both; if barter, "What do you want in return?".
  - **Source & trust:** forest area/compartment, collection note, ☐ "We confirm this was collected sustainably" (required).
  - **Handover:** pickup / delivery / both.
  - **Photos:** "Add photos (coming soon)" placeholder card until F4.
  - Server errors map inline (`RESTRICTED_ITEM` shows the reason card).
- **Requests:**
  - Tabs `Pending (प्रलंबित)` / `Done (पूर्ण)`.
  - Each request card: requester + role pill, item, qty, delivery preference, **reason** (highlighted for bulk), time.
  - Actions: **Approve** (orange), **Counter** (outlined), **Reject** (text, red, asks for a reason).
  - After approval, a snackbar "Order created" and a link to the order.
- **Orders:**
  - Tabs `Active` / `Past`.
  - Order detail: a vertical status stepper (Approved → Partner assigned → On the way → Delivered → Closed), the buyer's contact (shown after approval), and a **"Confirm handover"** button.
- **Profile:** hero (GS name, role pill "GRAM SABHA", verification state, location), "CFR rights" badges, account preference cards (Language, Theme, Help, Privacy), Logout.

### 4.4 Listings (shared, F1)
- **`ListingCard`** (search and feeds):
  - Thumbnail.
  - Title (mr/en per locale).
  - GS name + **trust tag** (`Verified` green check · `Verification pending` amber · `Demo data` grey chip).
  - Distance ("4.2 km" / "distance unknown").
  - Price/unit.
  - Rating stars (hidden until B4).
  - Mode badge (`Buy` / `Barter` / `Buy + Barter`).
  - "Rights not on record" chip if flagged.
- **Listing detail:**
  - Photo pager/placeholder, title, price, quantity, description.
  - **Trust & source** card: GS, village, verified state, forest area, collection note, sustainability tick.
  - GS card linking to the GS profile.
  - Reviews section ("No reviews yet").
  - Sticky bottom bar: **Request to buy** (orange) + **Offer barter** (outlined), shown only if the mode allows it **and** the role is not buyer.
- **Tests:** card states (each trust tag, each mode badge, missing distance); detail hides barter for buyers.

### 4.5 Requests & orders (F2 — the vertical slice)
- **Request form** (bottom sheet from the listing detail):
  - Quantity stepper/field with the unit, and "Max available: 50 kg".
  - Pickup / Delivery choice; drop village (prefilled from the profile).
  - **Reason**, which appears and becomes required once the quantity crosses the threshold from `/meta` (the server checks again).
  - Submit sends an `Idempotency-Key` and disables the button.
- **My Requests** (villager/buyer): tabs `Pending / Approved / Rejected / Counter-offers`; counter cards offer **Accept counter** and **Decline**.
- **Orders** (all roles): an `ordersProvider(scope)` list, then the status-stepper detail (same widget as §4.3); **Confirm received** for the buyer, then a "Rate this order" placeholder (B4).
- **Refresh rules:**
  - After any mutation, invalidate `requestsProvider`, `ordersProvider`, `listingDetail(id)` and `unreadCountProvider`.
  - Pull-to-refresh everywhere.
  - Refresh on app resume.
- **Tests:** the bulk reason appears at the threshold; double tap sends one request; approval updates both lists (mocked repository); the stepper renders each status.
- **Done when:** P1's exit test passes on two phones (System §12).

### 4.6 Villager & buyer homes, search (F2–F3)
- **Villager home:**
  - Header + notice strip + banner.
  - **Search pill** (the main action).
  - Category quick buttons (icons from `/categories`).
  - "Near you" horizontal row.
  - "Your open requests/orders" card.
  - The **"Have a vehicle? Earn by delivering"** card (F3).
- **Buyer home:** the same, but "Bulk & group listings" comes first (listings sorted by `quantityAvailable`; group listings in B4); no delivery card.
- **Search:**
  - A debounced (350 ms) query fills the grouped results: *Listings* · *Gram Sabhas* · *Resources*, each with "See all".
  - The filter bottom sheet: category, price range slider, min quantity, taluka, mode, verified only, in season, distance radius.
  - Sort chips: Nearest · Lowest price · Best rated.
  - The empty state suggests categories.
  - Location permission is asked only on first search with "Nearest" (with a reason sheet); if declined, the saved village is used.
- **Gram Sabha public profile:** hero, **CFR rights badges** (System Appendix C), "Approved CFR area: 24 ha", **Village resources** card from MRSAC (forest ha, water bodies, wells, conservation works) with the source note "MRSAC geoportal, Oct 2026", and their active listings.
- **Tests:** debounce; filter → query parameters; grouped rendering; permission-denied fallback.

### 4.7 Delivery & barter (F3, stretch)
- **Delivery** (villager only):
  - Earn card → explainer (work, earnings estimate, requirements) → **Start**.
  - Application form (vehicle type chips: bike/tempo/pickup, vehicle number, capacity kg, licence number, service talukas multi-select).
  - Status screen: `Under review` amber · `Approved` green · `Rejected` red + reason.
  - When approved, the nav changes to **Home · Search · Orders · Deliveries · Profile** (V-F6).
  - **Deliveries** tab: availability switch "I am available"; Available jobs list (pickup → drop villages, goods, weight, distance, ₹ estimate); job detail (contacts after accept); **Accept job**; active job with large buttons `Picked up` → `On the way` → `Delivered`; earnings card; rating (B4).
  - "Leave delivery program" in Profile.
- **Barter:** "Offer barter" sheet (what I offer: pick my listing or free text + qty; what I want: qty of this listing; note); offers list with tabs `Incoming` / `Sent`; respond with Accept / Counter / Reject; shows "Both sides must accept the same terms".
- **Tests:** an unapproved partner never sees the jobs tab (UX); a 403 from the API is handled; accept-race 409 shows "Job already taken".

### 4.8 Later modules (F4)
- **Photos:** pick (camera/gallery), compress to ≤ 1280 px long edge, JPEG/WebP ≈ 75 quality, target ≤ 300 KB, plus a 320 px thumbnail; upload one at a time with progress and retry; at most 4 per listing.
- **Reviews:** a star sheet after "Confirm received"; a separate rating for the delivery partner.
- **Impact dashboard** (team/presentation): `fl_chart` totals (earnings to villagers, jobs created, families benefited).
- **Offline (hive_ce):**
  - Cache recent searches, own listings and settings.
  - A draft queue for listing creates/edits that syncs on reconnect.
  - VanMitra's **"Offline queue · Synced / n pending"** diagnostics card with an orange **Sync now** button.
  - "Saved on this phone; will upload when online."
  - The server's newest version wins; conflicts are shown.
- **Dark mode QA:** the Style Guide §8 checklist.
- **Hindi:** `app_hi.arb`.
- **Razorpay test checkout.**

---

## 5. UI / UX Design System (VanMitra-derived)

### 5.1 Tokens (`core/theme/tokens.dart`)

| Token | Light | Dark | Use |
|---|---|---|---|
| `brandPrimary` | `#1A4331` | `#1A4331` | Header, footer strip, profile hero, branded surfaces |
| `brandSecondary` | `#2D765C` | `#2D765C` | Secondary green icons/surfaces, verified tag |
| `actionPrimary` | `#FF8D20` | `#FF8D20` | Primary buttons, FAB, active tab underline, **nav selected** |
| `actionPressed` | `#D96B00` | `#D96B00` | Pressed orange |
| `background` | `#F4F7F5` | `#10261B` | Page |
| `surface` | `#FFFFFF` | `#173425` | Cards, nav bar, inputs |
| `outline` | `#E3E9E5` | `#2B5A46` | Card borders/dividers |
| `textPrimary` | `#13202B` | `#F4F7F5` | Headings, body |
| `textMuted` | `#66737C` | `#AAB8B2` | Metadata, unselected nav |
| `onBrand` | `#F4F7F5` | `#F4F7F5` | Text on the green header/hero |
| `success` | `#5FAE3B` | `#5FAE3B` | Approved, delivered, synced |
| `warning` | `#F0B323` | `#F0B323` | Pending, under review |
| `error` | `#D7262E` | `#D7262E` | Rejected, errors |
| `info` | `#2F5FB3` | `#2F5FB3` | Notice strip icon/tint |
| `chipSuccessBg` / `chipWarningBg` / `chipErrorBg` | 10% tints of the status colours | 20% tints on the dark surface | Status count chips |

**Shape and spacing:**

| Token | Value | Use |
|---|---|---|
| `radius.sm` | 8 | Chips |
| `radius.md` | 14 | Inputs, small cards |
| `radius.lg` | 20 | Cards |
| `radius.xl` | 28 | Bottom nav, hero, pill buttons |
| Spacing scale | 4 · 8 · 12 · 16 · 20 · 24 · 32 | — |
| Page padding | 16 | Horizontal |
| Light shadow | `0 4 16 rgba(19,32,43,0.08)` | Elevation in light mode |
| Dark elevation | outline border, no glow | Elevation in dark mode |

### 5.2 Typography (Noto Sans / Noto Sans Devanagari, one semantic scale for both languages)

| Style | Size / weight | Use |
|---|---|---|
| `titleApp` | 20 / 700 | Header title "VanRozgar \| वनरोजगार" |
| `headline` | 18 / 700 | Section heads ("Account Preferences & Documents" style) |
| `cardTitle` | 16 / 600 | Card titles |
| `value` | 30 / 700 | Dashboard numbers |
| `body` | 14 / 400 | Descriptions |
| `caption` | 12 / 500 | Metadata, chips, nav labels |
| `button` | 15 / 600 | Buttons |

Marathi line height is 1.4 (English 1.3); never fix text heights; test clipping on a 360 dp-wide phone.

### 5.3 Components (each in `shared/widgets/`, each with a golden test)

| Widget | Anatomy (from the VanMitra screenshots) |
|---|---|
| `VrHeader` | Green bar: back arrow (if not root) · bold title "VanRozgar \| वनरोजगार" or the screen title with Marathi first ("विनंत्या \| Requests", like "ग्रामसभा \| Gram Sabha Records") · subtitle `village_taluka_district` in muted on-brand text · **connection dot** (green online / amber syncing / red offline) in a rounded pill · **language pill** `EN ▾` / `मरा ▾` |
| `NoticeStrip` | Light blue tint, megaphone icon, one-line marquee "Important Notice: …", pager `2/4`, ✕ dismiss (per-notice, remembered) |
| `Breadcrumb` | `Home › My Listings`; the last item bold |
| `HeroBanner` | Illustrated hills, trees, hut and sun in pale greens; fades into the background; ~120 dp |
| `SearchPill` | Rounded `surface` pill, search icon, hint "Search listings…", trailing round kebab button |
| `StatusCountChips` | Row: `✓ n Approved` green tint · `◷ n Pending` amber tint · `⊗ n Rejected` red tint · `n Total` plain |
| `UnderlineTabs` | Bilingual labels "Pending (प्रलंबित)"; active = bold text + orange underline bar |
| `EmptyState` | A soft circle with an outlined icon, leaf sprigs either side, bold title, muted helper line, orange pill CTA |
| `VrFab` | Orange extended pill "+ Add Listing", bottom-right above the nav |
| `ListingCard`, `RequestCard`, `OrderCard` | White `radius.lg` card, leading icon tile or thumbnail, title, metadata, trailing status pill or chevron |
| `StatCard` | Icon tile + big value + label (dashboard) |
| `ProfileHero` | Green card with a leaf watermark, orange circle avatar with the initial, "Hello, {name}", role pill (uppercase, translucent), location pin line, verification pill |
| `PreferenceCard` | Tinted icon tile (orange/blue), title, subtitle, chevron |
| `SyncDiagnosticsCard` (F4) | Title "Offline queue", green "Synced" pill, explanatory text, full-width orange "Sync now" |
| `StatusStepper` | Vertical steps with dots (done green / current orange / future grey) + timestamps |
| `TrustTag`, `ModeBadge`, `RightsBadge`, `DemoDataChip` | Small rounded chips with an icon + text (never colour alone) |
| `FooterStrip` | Dark green: "Helpline: 1800-XXX-XXXX · Forest Rights Act 2006 · Privacy Policy" (the real helpline number is TBD) |
| `VrBottomNav` | Floating white `radius.xl` bar with a shadow, 16 dp margin, 5 items, outlined icons + caption labels; selected = orange icon + label |

### 5.4 Bottom navigation per portal

| Portal | Tabs (icon) |
|---|---|
| Gram Sabha | Home (grid) · Listings (inventory) · Requests (inbox) · Orders (local_shipping) · Profile (person) |
| Villager | Home · Search (search) · Requests · Orders · Profile |
| Villager (approved partner) | Home · Search · Orders (with a Requests segment) · Deliveries (two_wheeler) · Profile |
| Buyer | Home · Search · Requests · Orders · Profile |

### 5.5 Accessibility & field use
- Tap targets ≥ 48 dp. Body text is never below 14. Contrast meets WCAG AA (check the orange-on-white button text in bold 15 pt).
- Status is always conveyed by icon + text + colour.
- Large, distinct primary actions; one orange primary action per screen.
- Works with system font scaling up to 130 % without overflow on the 6 main screens.
- `Semantics` labels on icon-only buttons and on images.

---

## 6. Designed vs. Built (frontend)

Status keys: 📋 Planned · 🔨 In progress · ✅ Built & tested · ⚠️ Built with a known limitation or on mock data.

| # | Component | Phase | Status | Evidence |
|---|---|---|---|---|
| 1 | `app/` project, lints, CI job | F0 | ✅ | `app/pubspec.yaml`, `analysis_options.yaml` |
| 2 | Tokens, light/dark `ThemeData`, fonts | F0 | ✅ | `core/theme/tokens.dart`, `vr_theme.dart` |
| 3 | Shell widgets (header, notice, banner, nav, footer, empty state) | F0 | ✅ | `shared/widgets/*` |
| 4 | Router with 3 portal shells + redirects | F0 | ✅ | `core/routing/app_router.dart` |
| 5 | `ApiClient` + `/health` + `/meta` | F0 | ✅ | `core/network/api_client.dart` |
| 6 | Splash, language, login, choose portal, register ×3 | F1 | ✅ | `features/auth/*` |
| 7 | GS home, my listings, add/edit listing | F1 | ✅ | `features/gramsabha/*` |
| 8 | Listing card + detail | F1 | ✅ | `shared/widgets/listing_card.dart`, `listing_detail_screen.dart` |
| 9 | Request form, my/incoming requests, approve/counter/reject | F2 | ✅ | `features/trade/request_sheet.dart`, `gs_requests_screen.dart` |
| 10 | Orders + stepper + handover/received | F2 | ✅ | `order_detail_screen.dart`, `status_stepper.dart` |
| 11 | Villager/buyer homes, messages badge, profile | F2 | ✅ | `villager_home_screen.dart`, `buyer_home_screen.dart`, `profile_screen.dart` |
| 12 | Search + filters + sort + location | F3 | ✅ | `features/search/search_screen.dart` |
| 13 | GS public profile with CFR rights + MRSAC card | F3 | ✅ | `features/gramsabhas/gs_profile_screen.dart` |
| 14 | Marathi strings for all F1–F3 screens | F3 | ✅ | `l10n/app_mr.arb`, `l10n/app_en.arb` |
| 15 | Release APK against the deployed API | F3 | 📋 | Ready for `flutter build apk` |
| 16 | Delivery flow | F3 (stretch) | ✅ | `features/delivery/*` |
| 17 | Barter | F3 (stretch) | ✅ | `features/barter/*` |
| 18 | Photos, reviews, impact, offline, dark QA, Hindi, Razorpay | F4 | 📋 | §4.8 |

---

## 7. Routing (`go_router`)

```
/splash
/language
/login
/register                    → /register/portal → /register/:portal(gramsabha|villager|buyer)
/help/forgot-password
/gs        (StatefulShellRoute: home | listings | requests | orders | profile)
   /gs/listings/new · /gs/listings/:id/edit · /gs/requests/:id · /gs/orders/:id
/v         (StatefulShellRoute: home | search | requests | orders | profile [| deliveries])
/b         (StatefulShellRoute: home | search | requests | orders | profile)
/listings/:id                (shared detail; opened above the shell)
/gramsabhas/:id              (public GS profile)
/requests/new/:listingId     (sheet route)
/orders/:id
/messages
/delivery/intro · /delivery/apply · /delivery/status · /deliveries/jobs/:id
/barter/new/:listingId · /barter/:id
/settings/language · /settings/theme
/team                        (hidden; only for role=team; verification queues)
```

**Redirects:**
- No session → `/login` (except splash/language/register/help).
- Logged in → `/gs`, `/v` or `/b` by role.
- A wrong-portal path → own home.
- `/deliveries` only when `partnerStatus == approved`.

Deep links always refetch and handle 403/404 with a friendly screen.

---

## 8. Data, State & Networking

**Models** (`shared/models/`): `User`, `GramSabha`, `CfrSummary`, `VillageProfile`, `Category`, `Resource`, `Listing`, `TrustInfo`, `PurchaseRequest`, `CounterOffer`, `Order`, `OrderStep`, `Message`, `Meta`, `Notice`, `DeliveryPartner`, `DeliveryJob`, `BarterOffer`, `Paged<T>`, `AppException`. Each one parses **JSON fixtures copied from the backend API tests** (in `test/fixtures/`), so contract drift fails a test.

**Providers** (selection):

| Provider | Type | Invalidated by |
|---|---|---|
| `sessionProvider` | `AsyncNotifier<User?>` | login, logout, profile patch, 401 |
| `metaProvider` | `FutureProvider<Meta>` (cached 10 min) | app resume |
| `categoriesProvider` | `FutureProvider` | language change |
| `listingsProvider(ListingFilter)` | `AsyncNotifier<Paged<Listing>>` | listing create/edit, approval |
| `myListingsProvider` | — | the same |
| `listingDetailProvider(id)` | `FutureProvider.family` | approval, edit |
| `searchController` | `Notifier<SearchState>` | query/filter change |
| `requestsProvider(scope, status)` | `AsyncNotifier` | any request mutation |
| `ordersProvider(scope)` / `orderDetailProvider(id)` | — | order mutations |
| `unreadCountProvider` | `StreamProvider` (poll 60 s while visible) | message read |
| `languageController`, `themeModeController` | `Notifier` | settings |

**`ApiClient` interceptors, in order:**
1. `RequestIdInterceptor` (UUID per request).
2. `AuthInterceptor` (Bearer from `TokenStore`; on 401, clear the session and redirect).
3. `ErrorMapper` (envelope → `AppException`; Dio errors → `NetworkException`/`TimeoutException`).
4. `GetRetryInterceptor` (GET only, 2 retries).

Timeouts: connect 10 s, receive 20 s (village networks).

---

## 9. Localisation

- Use ARB keys by feature (`listing_form_quantity_label`), with English and Marathi kept complete together. A test fails if `app_mr.arb` is missing keys from `app_en.arb`.
- Bilingual labels follow VanMitra where it helps comprehension (tabs: "Pending (प्रलंबित)"), with the active language first.
- Data names come from the API in both languages (`title.mr`, `title.en`); show the active one, with the other as a subtitle on detail screens.
- Numbers: Indian grouping (`1,25,000`); Marathi digits only if the team decides (default Latin digits; `intl` supports both).
- Before F3's exit, check the 6 main screens in Marathi on a 360 dp phone: login, GS home, add listing, search results, request form, order detail.

---

## 10. Security & Privacy (client side)

- The token lives only in `flutter_secure_storage`, and is deleted on logout or a 401. Passwords are never stored anywhere.
- No secrets in Dart, assets or `--dart-define` (only the public API URL).
- Role-based UI is UX only. Every action handles a 403 gracefully.
- Precise seller location/phone is shown only when the API returns it (after approval).
- Logging: `debugPrint` is stripped in release; never log tokens, phone numbers or request bodies.
- Location permission is requested only when needed, with an explanation; "Nearest" still works from the saved village.
- Release builds use R8/minify; the keystore and `key.properties` are git-ignored (§12).

---

## 11. Testing Strategy & CI

| Layer | Tooling | Runs where | Count |
|---|---|---|---|
| Unit (models from fixtures, formatters, threshold logic, error mapping) | `flutter_test` | every push | 0 (from F0) |
| Provider (state transitions with mocked repositories) | `flutter_test` + `mocktail` + `ProviderContainer` | every push | 0 (from F1) |
| Widget/golden (shell widgets, cards, forms, 5 data states) | `flutter_test` goldens | every push | 0 (from F0) |
| Integration (login → create listing → request → approve against a local API) | `integration_test` on emulator/device | before the demo | 0 (from F2) |
| Manual device checklist (§12) | Demo phone, mobile data | before freeze | — |

**CI job `app-checks`:** set up Flutter stable (cached) → `flutter pub get` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`.

---

## 12. Build, Release & Demo Device

**Local release build (P2):**
```bash
cd app
flutter pub get
flutter analyze
flutter build apk --release --dart-define=API_BASE_URL=https://<deployed-api-host>
# → app/build/app/outputs/flutter-apk/app-release.apk
```

**Signing:**
1. Create the upload keystore with `keytool`; store `key.properties` outside git.
2. Back up the keystore and passwords in two private places. If they are lost, the app cannot be updated with the same key.
3. Before P4, CI decodes `KEYSTORE_BASE64` and reads `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` and `API_URL` from GitHub Actions secrets. `android-release.yml` builds on tag `v*` and attaches the APK to a GitHub Release (in the **private** repo).

**Demo-phone checklist (before freeze):**
1. Uninstall any old build, then install the release APK from clean.
2. Log in as each demo role.
3. Run the full slice on **mobile data**.
4. Switch the language to Marathi and repeat the main screens.
5. Kill and reopen the app; the state persists.
6. Install the fallback-API APK as "VanRozgar (B)".
7. Copy a screen recording of the full flow to the phone (offline plan B).
8. Set the battery saver off and the brightness high; disable notifications.

---

## 13. Frontend Architecture Decision Log

| ID | Chose | Over | Why |
|---|---|---|---|
| ADR-F1 | Riverpod | Bloc, Provider, GetX | Async state with less boilerplate than Bloc; testable without widgets; the report's choice |
| ADR-F2 | go_router `StatefulShellRoute` | Navigator 1, auto_route | Per-portal 5-tab shells that keep each tab's stack; redirects for auth/role |
| ADR-F3 | Dio | `http` | Interceptors (auth, request ID, error mapping, retry), timeouts, multipart for photos |
| ADR-F4 | Hand-written models | freezed/json_serializable | No build_runner time before the demo; fixtures guard correctness; adopt codegen after the demo |
| ADR-F5 | ThemeExtension tokens from the VanMitra guide | Ad-hoc colours | Family look; one-switch dark mode; the guide's own implementation contract |
| ADR-F6 | Bundled Noto fonts | `google_fonts` runtime fetch, system font | Works offline; guaranteed Devanagari rendering |
| ADR-F7 | hive_ce for offline (F4) | Original Hive, Isar, sqflite/drift | Same model as VanMitra's Hive queue; maintained fork; drift is a candidate if relational queries are needed later |
| ADR-F8 | No map in the demo; distance as text | `flutter_map` from day one | The tile provider is undecided (V-F7); the text distance answers the plan's need |
| ADR-F9 | Polling `/messages/unread-count` | FCM push | Push is not required for the MVP; no Firebase project needed |
| ADR-F10 | Idempotency keys on mutations | Blind retries | Village networks drop responses; prevents duplicate requests/orders |

---

## 14. Frontend Risk Register

| # | Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|---|
| RF1 | UI polish eats the time for the slice | High | High | F0 shell is time-boxed to ~2 h; feature screens reuse shell widgets; polish only after the P1 exit | Frontend |
| RF2 | Marathi overflow on small phones | Medium | Medium | Flexible layouts; the §9 check; font scale test | Frontend |
| RF3 | Wrong base URL in the demo APK | Medium | High | `--dart-define` in the build script; `/meta` shows the host on the Profile → About screen | Frontend |
| RF4 | Gradle/AGP build issues on release day | Medium | High | Build a release APK in F0 already, not first on Oct 13 | Frontend |
| RF5 | Mock data left in a "done" screen | Medium | Medium | The ⚠️ rule; `DemoDataChip`; a review checklist item | All |

---

## 15. Frontend Q&A Preparation

**"Why does it look like VanMitra?"**
It is a module of the same family. The design tokens, the header, the cards and the navigation come from the VanMitra style guide, so users of one app recognise the other, and the two can merge later on the same Flutter base.

**"Does it work in Marathi?"**
Yes. Every screen's text comes from translation files, and the Marathi file is checked for completeness by a test. Village names come from the CFR register in Marathi.

**"Does it work offline?"**
Not in this prototype; it shows a clear offline banner. An offline drafts and sync queue, like VanMitra's Hive queue, is planned (F4).

**"What if someone taps Submit twice?"**
The button locks while sending, and each request carries an idempotency key, so the server records it once.

---

## 16. Immediate Next Actions (frontend)

1. `flutter create app --org <org.id> --platforms android`, then add the §1 packages and `analysis_options.yaml`. **Build a release APK once now** (RF4).
2. Tokens + themes + fonts; the shell widgets in §5.3, with golden tests.
3. Router with the 3 portal shells and a dev portal switcher; `ApiClient` → `/health`, `/meta`.
4. Request the VanMitra illustration assets and font (V-F3, V-F4).
5. Start F1 (auth screens) as soon as B1's `/auth` routes stop returning 501.

---

## Appendix A — Frontend File Tree (target)

```
app/
├── pubspec.yaml · analysis_options.yaml · l10n.yaml
├── assets/
│   ├── fonts/                 NotoSans-*.ttf, NotoSansDevanagari-*.ttf
│   ├── illustrations/         hero_hills.svg, empty_leaves.svg, logo.svg
│   └── icons/                 category icons
├── lib/
│   ├── main.dart · app.dart
│   ├── l10n/                  app_en.arb, app_mr.arb (app_hi.arb in F4)
│   ├── core/
│   │   ├── config/app_config.dart       API_BASE_URL, DEV_TOOLS
│   │   ├── network/                     api_client.dart, interceptors/, app_exception.dart
│   │   ├── routing/app_router.dart      routes, shells, redirects
│   │   ├── security/token_store.dart
│   │   ├── storage/prefs.dart           (local_cache.dart in F4)
│   │   ├── theme/                       tokens.dart, vr_theme.dart, typography.dart
│   │   └── utils/                       format_inr.dart, dates.dart, idempotency.dart
│   ├── shared/
│   │   ├── models/                      see §8
│   │   └── widgets/                     see §5.3 + async_value_view.dart
│   └── features/
│       ├── auth/ gramsabha/ villager/ buyer/ listings/ trade/ search/
│       ├── gramsabhas/ messages/ profile/ team/
│       └── delivery/ barter/            (F3)  media/ reviews/ impact/ sync/ (F4)
│           each: data/ (repository, dto) · application/ (providers) · presentation/ (screens, widgets)
├── test/                       unit/, providers/, widgets/, goldens/, fixtures/
└── integration_test/           slice_test.dart
```

## Appendix B — Verification Record

*Empty until F0 runs. Record each check as: the command, the date and the output. This includes:*
- *`flutter --version`;*
- *the resolved package versions (`pubspec.lock`);*
- *`flutter analyze`/`flutter test` results;*
- *the first release-APK build;*
- *a side-by-side photo of the shell vs the VanMitra screenshots;*
- *the demo-phone checklist results.*

## Appendix C — Document Maintenance Rules

The same as System Appendix E:
- Put dated update lines in the header.
- Correct a wrong statement in place, with a dated note.
- Update §6 here and System §11 in the same commit as the code.
- Every "✅" cites a file and a test or recorded device check.
