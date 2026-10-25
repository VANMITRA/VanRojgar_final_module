# MASTER PROMPT — VanRozgar Website (a VanMitra Ecosystem Module)

## 1. ROLE AND DELIVERABLE

Act as a senior product designer, creative frontend engineer, motion designer and UX architect.

Build a complete, polished, highly interactive **website + working frontend demo** for **VanRozgar**, the community-resource marketplace and livelihood module of the **VanMitra** ecosystem (VanMitra-AI is the parent platform for forest-rights governance).

- Output a **runnable React + TypeScript + Vite + Tailwind CSS app** using **Motion (framer-motion)** for animation and **lucide-react** for icons. No backend: use typed mock data and local state only.
- It must look like a premium product shown at a national hackathon or government innovation showcase. It must NOT look like a generic e-commerce template, a SaaS admin template, or an old government portal.
- Implement the real thing, not a wireframe. Every button must do something meaningful (navigate, open a panel, change state). No dead CTAs.
- Do not rely on external image URLs. Create all visuals with inline SVG / CSS / canvas (forest silhouettes, topographic contour lines, resource icons, map paths).

---

## 2. WHAT VANROZGAR IS (source of truth — do not contradict)

VanRozgar is a marketplace built on the Amazon-style buyer–seller model for trading natural resources (jadibuti/medicinal plants, honey, handicrafts, etc.). Resources are produced by forest-dependent **Gram Sabhas** (village forest councils) under **Community Forest Rights (CFR)**. Different Gram Sabhas are rich in different resources (one has medicinal plants, another has water resources), so VanRozgar lets Gram Sabhas, landowners and outside buyers find, exchange and buy them in one place. It also creates **paid delivery work for villagers who own a vehicle**.

Three ideas the site must communicate within seconds:
1. **Community commerce** – Gram Sabhas bring locally managed resources to one shared marketplace.
2. **Sustainable livelihoods** – transparent trading with trust/provenance and fair-price guidance.
3. **Employment generation** – villagers with vehicles earn through delivery.

Positioning line (refine wording if you wish): *"Trade resources. Create livelihoods."* Within the ecosystem: *VanMitra-AI protects forest rights; VanRozgar turns them into rural income.*

### Resource categories (examples, not a fixed list — "Others" lets new ones be added)
Medicinal plants (jadibuti, herbs, roots, bark, Ayurvedic raw material) · Forest produce (honey, mahua flowers, tendu leaves, lac, gum, tamarind, wild fruits, seeds) · Handicraft materials & products (bamboo, cane, grass, baskets, mats, tribal crafts) · Water & land resources (water resources, fish, other community-managed resources) · Others.

### Exactly THREE login portals (delivery is NOT a fourth portal)
| Portal | Who | Bottom tabs | Key abilities |
|---|---|---|---|
| **Gram Sabha** | Village forest council managing a CFR area (the seller) | Home, My Listings, Requests, Orders, Profile | Add/edit listings (photo, quantity+unit, price with "Suggested fair price", mode Sell/Barter/Both, barter wants, source details, pickup/delivery), Approve / Reject / Counter requests, track orders, "Confirm handover", group selling, earnings |
| **Landowner / Villager** | Lives in / owns land in a CFR village | Home, Search, My Requests, Orders, Profile (+ "More" menu) | Search & compare, Request to buy, Offer barter, track orders, Confirm received + rate, **"Earn with delivery"** card in More menu and on Home |
| **General Buyer** | Person/business with no CFR land (e.g. an Ayurvedic brand) | Home, Search, My Requests, Orders, Profile | Purchase only (**no barter**), reason required for large orders, bulk & group listings shown first, can order from a combined group listing in one request, **no delivery option**, large requests reviewed by Gram Sabha |

All three share the same marketplace data; only the home screen, menu and actions change.

### Pre-login flow (build as an interactive "Try the app" demo)
1. Promo splash (logo, name, motto, "Get Started"; nothing else; auto-advances after a few seconds)
2. Login / Register (phone or email + password or SMS one-time code; "Forgot password")
3. Choose portal (3 cards with help text: *Gram Sabha* "We manage a CFR village and want to sell or exchange resources"; *Landowner / Villager* "I live in or own land in a CFR village and want to buy resources"; *General Buyer* "I am a person or business outside CFR villages and want to buy")
4. Register form that changes by portal (Gram Sabha: name, village, district, contact person, phone, CFR recognition detail, password · Villager: name, village, Gram Sabha belonged to, phone, password · Buyer: name, optional business name, city, phone, email, password). Show note: *Gram Sabha accounts are verified by the VanRozgar team before listings go live.*
5. Language choice (English / Hindi / Marathi) — asked once, changeable in Settings.

### Core mechanics to demonstrate
- **Search**: by name/category; every card shows resource name + photo, Gram Sabha + trust tag, **distance**, price/unit, star rating, mode badge (Buy / Barter / Both). Sort: nearest, lowest price, best rated. Filters: category, price range, quantity available. Empty state: "nothing matches" + nearby categories.
- **Trust & provenance tag**: Gram Sabha name + village, "Verified" mark (after team check), source forest area + how collected, sustainable-collection confirmation ticked at listing creation.
- **Request flow** (every step notifies the user): Sent → Pending → Approved / Rejected / Counter-offer (buyer accepts or declines the counter) → Order created (stock held) → Delivery (partner found, or buyer collects) → Delivered & confirmed → Closed (rating requested, recorded in impact numbers).
- **Reason for large orders**: required; explain why (a large order can exhaust a village's seasonal stock; protects sustainable harvesting; helps the team spot unusual orders).
- **Barter** (Gram Sabhas & villagers only): A offers X wants Y with quantities → B sees suggested fair value of both sides → B approves / rejects / counters → one order → delivery. Build a small **balance meter** showing whether the swap is fair.
- **Fair price suggestion**: range from past sales; if little data, show "Not enough data yet". Guide only; seller always sets own price.
- **Group selling**: several small producers pool the same resource into one listing with total quantity and one price; each producer paid for their own share; each sees their share in their Orders tab. Build an animated visual of stock pooling.
- **Ratings**: only after "Confirm received"; 1–5 stars + optional short review per order; delivery partner rated separately; averages appear on search cards and Gram Sabha profile.
- **Delivery partner option** (Villager portal only): card text *"Have a vehicle? Earn money by delivering resources. Become a delivery partner."* → explainer + Start → registration (name, phone, village, vehicle type e.g. pickup truck / tempo / bike, vehicle number, carrying weight, driving-licence detail, areas covered) → **"Under review"** → team approves or rejects (reason if rejected) → a **"My Deliveries"** tab appears in the same app. My Deliveries: Available jobs (pickup village, drop village, goods, weight, distance, pay), Job detail (both contacts, pickup/drop, "Accept job" — job then disappears for others), Active delivery (Picked up → On the way → Delivered), Earnings, My rating, "I am available" switch. Fairness rules: unapproved users never see job details; poorly rated partners can be paused after team review; partners can leave anytime without losing their main account.
- **Impact dashboard** (for team/presentations/funders): total earnings paid to villagers, delivery jobs created, families benefited.
- **Team back-office** (verify Gram Sabhas, review delivery registrations) is team-only and **not a user login portal**. Show it only as an informational illustration, never as a login option.

### Open decisions — do NOT silently decide these
Payment handling (online / cash on delivery / settled by team), delivery pay model (fixed by distance vs agreed per order), whether delivery also appears in the Gram Sabha portal, launch languages (EN/HI/MR assumed), offline/low-network sync, who adds new categories later.
→ Where the demo must show something for these, use a neutral placeholder such as "Payment method: to be confirmed" and "Delivery pay: shown per job (model to be confirmed)". Add a clearly labelled **"Open product decisions"** section on the site listing them. Never invent a payment gateway, fee percentage, commission, or pay formula.

---

## 3. BRAND & DESIGN SYSTEM (from the VanMitra-AI Theme & UI Style Guide)

Use these tokens as CSS variables / Tailwind theme. Do not introduce another brand palette. You may use transparent tints for glows, gradients and overlays.

| Token | Hex | Use |
|---|---|---|
| brand.primary | #1A4331 | Header, nav, branded surfaces (core forest green) |
| brand.primaryDark | #0C1B14 | Deep dark surfaces |
| brand.secondary | #2D765C | Secondary green, icons |
| accent.primary | #FF8D20 | Primary buttons, active states, progress |
| accent.dark | #D96B00 | Pressed / strong orange (use sparingly) |
| light.background | #F4F7F5 | Light page background (soft, not pure white) |
| light.surface | #FFFFFF | Light cards |
| dark.background | #10261B | Dark page background |
| dark.surface | #173425 | Dark cards/tiles |
| dark.border | #2B5A46 | Dark borders/separators |
| text.primary | #13202B | Light-mode text |
| text.muted | #66737C | Light-mode secondary |
| text.onDark | #F4F7F5 | Dark-mode text |
| text.mutedDark | #AAB8B2 | Dark-mode secondary |
| status.success | #5FAE3B | Delivered / verified / synced |
| status.warning | #F0B323 | Pending / under review |
| status.error | #D7262E | Rejected / critical |
| status.info | #2F5FB3 | Informational |

**Rules from the guide:** green anchors identity; orange = action only (CTAs, active/selected, progress); status colours carry real status only, never decoration; no pure-black text on dark green; **dark mode is a full theme** (surfaces, text, nav, inputs, chips, dialogs all switch — no stuck white cards); selected nav item is green in light mode and orange in dark mode; cards separated by spacing more than heavy borders; soft shadows in light mode, low-contrast borders/subtle elevation in dark mode; medium-to-large corner radii; green/orange focus rings on inputs.

**Typography:** one family — Manrope (or Inter) plus **Noto Sans Devanagari** for Hindi/Marathi. Fluid sizing (`clamp`). Hero 64–96px desktop; section headings 40–64px; card titles 16–22px; body 15–18px; metadata 12–14px; big numerals bold 700. Give Devanagari extra line height and never clip glyphs. One semantic type scale shared by all languages.

**Visual mood:** premium, nature-inspired, editorial, spacious, trustworthy, human-centred, technologically advanced. Motifs: layered forest silhouettes, organic landscape curves, faint topographic contour lines, floating resource cards, animated paths linking villages to buyers, subtle firefly particles, warm orange points for economic activity. Avoid excessive glassmorphism, random gradients and decoration without purpose.

---

## 4. SITE STRUCTURE

Single-page marketing site with smooth anchor navigation, plus a full-screen **Demo App** route (hash routing, e.g. `#/demo`). Sections in order:

1. **Header** – VanMitra mark (build a simple original leaf/path wordmark; no external logo), nav (Ecosystem, How it works, Portals, Marketplace, Delivery, Impact), theme toggle, EN/हिं/मरा language switch, primary CTA "Try the demo" (orange). Transparent over hero → blurred solid on scroll; animated active-link indicator; accessible mobile menu.
2. **Hero** – headline with staggered reveal (e.g. "Where forest resources become rural livelihoods."), one-line supporting copy, CTAs ("Try the demo" → `#/demo`, "See how it works" → scroll). Right/background: parallax forest layers, topographic lines, firefly particles, and an animated **village-to-buyer network map** with orange pulses travelling between nodes, plus 2–3 floating listing cards (e.g. Honey, Ashwagandha, Bamboo). Three concept chips: Community Commerce · Sustainable Livelihoods · Employment Generation.
3. **Ecosystem** – VanMitra-AI (forest-rights governance: Dashboard, Claims, Gram Sabha, Atlas Map, Profile/Settings — only features named in the style guide) connected by an animated path to VanRozgar (marketplace). Make clear VanRozgar is a module of VanMitra, not a separate company. Do not invent VanMitra-AI features beyond those five areas.
4. **Resource explorer** – category chips + live search over ~12 mock listings with sort/filter exactly as described above, trust-tag popover, mode badges, distance, rating. Clicking a card opens a listing detail drawer with "Request to buy" / "Offer barter" (barter only if listing allows).
5. **How it works** – scroll-pinned, animated stepper of the order flow: *Gram Sabha lists → Buyer searches by distance & price → Request or barter offer → Gram Sabha approves → Approved driver assigned → Delivery completed (rating & earnings logged) → Impact dashboard updates.*
6. **Three portals** – tabbed interactive showcase (Gram Sabha / Villager / General Buyer) rendered inside a phone frame **and** a desktop panel; show each portal's real tabs and a comparison table of differences (barter, delivery option, bulk-first home, reason for large orders).
7. **Barter & fair price** – interactive balance meter (sliders for quantities; "Not enough data yet" state; fair value is guidance only).
8. **Group selling** – animated pooling of producers into one listing with per-producer share and payout split.
9. **Delivery partner journey** – horizontal timeline: Have a vehicle? → Explainer → Registration → Under review → Approved → My Deliveries (jobs, accept, status buttons, earnings, rating, availability). Include the fairness rules. Frame as employment generation.
10. **Impact** – animated counters (earnings paid, jobs created, families benefited) clearly labelled **"Sample demo data"**; small chart of monthly growth (also sample). Never present fabricated numbers as real results.
11. **Trust & sustainability** – provenance tag explained, Gram Sabha verification, large-order reason rule.
12. **Open product decisions** – the unresolved items from §2, presented honestly.
13. **Footer** – ecosystem links, language, theme, "Team back-office is internal; not a user portal".

---

## 5. THE DEMO APP (`#/demo`)

A working, mobile-first interactive prototype (centred phone frame on desktop, full-screen on mobile) implementing:
- Splash → Login/Register → Choose portal → portal-specific register form (with validation) → language choice → portal home.
- **Gram Sabha**: dashboard cards (active listings, new requests, orders in progress, total earnings), Add/Edit listing form with fair-price hint, listing status (Active / Paused / Sold out), Requests with Approve/Reject/Counter, Orders with "Confirm handover", group-listing join, Profile.
- **Villager**: Home (search bar, category buttons, "Near you" row, open request/order status, "Earn with delivery" card), Search, listing detail, request/barter form, My Requests (Pending / Approved / Rejected / Counter-offer received), Orders with status steps + "Confirm received" + star rating, More menu → delivery registration flow → simulated team approval (a demo button "Simulate team approval") → "My Deliveries" tab appears.
- **General Buyer**: same without barter or delivery; bulk/group listings first; reason box required for large quantities (define a clearly named constant for "large", e.g. ≥ 25 units, and mark it as a demo default).
- One shared in-memory store so actions in one portal appear in another (e.g. a buyer's request shows up in the Gram Sabha's Requests; approving creates an order; a delivery job appears for approved partners). Provide a "Switch portal" control for demo convenience.
- Notification toasts at each request-flow step.

---

## 6. MOTION GUIDELINES

Purposeful only: staggered text reveals, scroll-linked parallax on forest layers, path-draw animations for routes, number count-ups, layout transitions between list and detail, spring-based drawers, pulse on live status, hover lift on cards. Respect `prefers-reduced-motion` (disable parallax/particles). Keep animation GPU-friendly (transform/opacity), lazy-run off-screen animations, and keep the particle canvas light.

## 7. LANGUAGE (EN / हिन्दी / मराठी)

Implement a simple i18n dictionary with real translations for navigation, hero, portal names, buttons, status labels, and the demo's main screens. Hindi and Marathi must be natural, not literal. Language switch updates instantly without reload. Persist theme and language in `localStorage` (guard with try/catch).

## 8. QUALITY BAR

- Fully responsive (360px phone → 1440px+ desktop); no horizontal overflow.
- WCAG AA contrast in both themes; visible focus states; semantic HTML; keyboard-operable menus, drawers and tabs; alt text / aria-labels on icons and SVGs.
- Theme toggle switches Light ↔ Dark instantly with no stuck-light components (cards, nav, inputs, chips, dialogs, drawers, toasts).
- Clean folder structure (`components/`, `sections/`, `demo/`, `data/`, `i18n/`, `styles/`), typed models matching the data in the plan (Users, Gram Sabhas, Listings, Requests, Orders, Delivery partners, Deliveries, Ratings, Earnings).
- No console errors. No lorem ipsum. No fake testimonials, partner logos, press mentions or unsourced statistics.

## 9. WORKING METHOD

1. First, in a few lines, state your creative concept (visual metaphor, hero idea, motion language) and your assumptions.
2. Then build the full app in one pass, starting with design tokens and theme/i18n infrastructure, then shared components, then the marketing sections, then the demo app.
3. Finish with a short summary: what was built, what is mocked, and which open decisions from §2 remain undecided.

If any instruction conflicts: **product behaviour follows §2; visual identity follows §3; web layout, motion and presentation are your design judgement.**
