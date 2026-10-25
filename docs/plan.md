# Working plan: VanRozgar | वनरोजगार (Tech4Tomorrow)

**Written:** 25 Oct 2026 · **Final deadline:** 30 Oct 2026 · **Code freeze:** 28 Oct evening · **Submit:** 29 Oct (30 Oct is spare)
This file replaces the "what to do next" parts of [final_plan.md](final_plan.md) (that file still says "nothing built yet"; it is
now the record of decisions). Open questions and the reasons behind them stay in [QUESTIONS.md](QUESTIONS.md).

## Update, 25 Oct night: one person, one dataset
Ayush is the only developer now, so the Ayush/Soham split below is history: everything is in one repo and one branch (`main`).
**The dataset is the 14 villages of the Raah Foundation report and nothing else** (the old 771-village CFR register, the
680 MRSAC profiles, the 10 demo villages and all demo listings are removed; the sections below that mention them are out of date).
One Mitra stays a bottom tab for Gram Sabha and villager accounts. See [DEPLOY.md](DEPLOY.md) section 6.

## 0. Decisions confirmed on 25 Oct

| Topic | Decision |
|---|---|
| App name | **VanRozgar \| वनरोजगार** (kept) |
| Hosting | **Render for both servers**, database on **MongoDB Atlas**. Atlas and Render accounts already exist (owner enters all secrets; nobody pastes a secret into chat or git) |
| Android | App id **`in.vanrozgar.app`**, a proper release keystore (held by Ayush, never in git), signed in GitHub Actions |
| Must-have features | Map (`flutter_map`), real schemes registry, PDF export, idea ⇄ marketplace link |
| Weather / rain / prices | Only if a free, reliable source exists; otherwise cut. First thing cut |
| Demo data | **Keep the synthetic villages, listings and demo accounts for now**, all labelled Demo. Real CFR villages replace them when the CFR file arrives |
| Raw Nashik files (CFR xlsx, MRSAC docx) | Not on this PC. **Soham holds them.** They contain phone numbers and bank details: never committed; only a cleaned copy |
| Round 2 form items | Split: each owner drafts the technical answers for their module; people facts (NGO, community representative, photos, permission, team) stay with the people who have them |
| Branches | Ayush: `ayush/vanrozgar-backend` · Soham: `soham/vanmitra-livelihood` (created from `main` after Ayush's branch is merged) |
| Commits | Each person's commits carry only their own name |

## 1. Who owns what

| | **Ayush: VanRozgar (marketplace)** | **Soham: VanMitra module (livelihood) + integration** |
|---|---|---|
| Server | `server/` (Node 24, Express 5, MongoDB): accounts, listings, trade, delivery, barter, seeder | `livelihood_server/` (Python, FastAPI): rules, ideas, schemes, nearby resources, report, PDF data |
| App | everything under `app/lib` **except** `features/livelihood` (auth, gramsabha, villager, buyer, listings, search, trade, delivery, barter, messages, profile, shared widgets, theme) | `app/lib/features/livelihood/` (report, ideas, map, schemes, PDF, strings) |
| Data | Gram Sabha profiles from the CFR claims (once Soham hands over the cleaned file); marketplace seed | Raw CFR xlsx + MRSAC docx cleaning, village resource records, coordinates and boundaries |
| Deploy | Node service on Render, Atlas seeding, signed APK pipeline | Python service on Render, keep-warm pings |
| Integration | Provides the agreed marketplace endpoints and routes below | **Owns integration end to end** (section 4) |

**Rule:** do not edit the other person's folder. If you need a change there, put it in section 3 (the shared contract) and ask.

## 2. Tasks

Status words: **Todo**, **Blocked** (needs something named), **Done**. Nothing below is claimed done until it was run and checked.

### 2A. Ayush: VanRozgar

| # | Task | When | Done when | Needs |
|---|---|---|---|---|
| A1 | **Today, by 7 pm:** keep the synthetic seed as it is. Check if the CFR file is available; if it is, clean it (drop phone, bank, IFSC, person names) and prepare the Gram Sabha profile import as a **dry run** (`--apply` is run by Ayush, I do not write to a database) | 25 Oct 19:00 | Seed still passes; either a cleaned file + dry-run report exists, or the blocker is written down | CFR xlsx (not on this PC; Soham holds it) |
| A2 | Import real CFR claims into Gram Sabha profiles and remove the "Demo placeholder" banners **only for villages that now have real data**; everything else stays labelled Demo | 26 Oct | GS page shows real claim count/area for a real village | Soham's cleaned file (S2) |
| A3 | Deploy the Node server: Atlas string, `render.yaml` blueprint, secrets entered by Ayush, `/api/v1/health` healthy, production seed, `npm run indexes` | 26 Oct | Health shows `db: connected` over mobile data | A secret list from [DEPLOY.md](DEPLOY.md); same `JWT_SECRET` handed to Soham |
| A4 | App id `in.vanrozgar.app`, release keystore, `android-release.yml` signs with secrets, build against both live URLs | 26 to 27 Oct | Signed APK installs on a phone and signs in | A3, S1 |
| A5 | Remove the admin quick-login and any baked-in team password; demo buttons only behind `AppConfig.devTools` and the configurable PIN | 26 Oct | No credential in the release build | |
| A6 | Marketplace side of the idea link: a **product code** on listings/categories, a "See what land near here can produce" button on a listing that opens `/livelihood/...` with a village | 27 Oct | Button opens the report for the listing's village | Section 3 contract, S9 |
| A7 | Marketplace listings as a map layer: an endpoint returning listing points (coordinates rounded to 2 decimals, as the server already does for orders) | 27 Oct | Soham's map can toggle listings | Section 3 contract, S4 |
| A8 | Incoming barter offers: check whether a screen lists `GET /barter-requests`; if not, hide the barter entry points rather than ship dead buttons | 26 Oct | No dead UI | |
| A9 | Checks green: `npm test`, `flutter analyze`, `flutter test`; add `supertest` tests for new endpoints (A6, A7) | every push | All three pass locally | |
| A10 | Update `IMPLEMENTATION_STATUS.md` honestly (✅ only for what was tested) and add the screenshots needed for the README | 28 Oct | | |
| A11 | Round 2: draft the technical answers for the marketplace side (problem, users, beneficiaries method, cost lines for Atlas/Render, impact); mark every number "to confirm" | 28 to 29 Oct | Draft in `docs/round2/ayush.md` | Facts only the team has (F1 to F7) |

### 2B. Soham: VanMitra livelihood module

| # | Task | When | Done when | Needs |
|---|---|---|---|---|
| S1 | Deploy the Python server on Render (Docker or Python service, health route, `JWT_SECRET` **identical** to the Node service, `MONGODB_URI` read-only on `users`) | 26 Oct | Same token works on both servers over mobile data | A3 secrets |
| S2 | Clean the raw CFR xlsx into `nashik_cfr_claims.json` (no phone, bank, IFSC or person names) and parse the MRSAC docx into one record per village (figures exactly as printed, source line kept). **Hand the cleaned CFR file to Ayush for A1/A2** | 25 to 26 Oct | Cleaned files exist outside git history of the raw data; dry-run loader report | Raw files |
| S3 | Village coordinates and boundaries: try MRSAC map services first, then open data; every point marked approximate with its source | 26 Oct | Villages from S2 have a point and source | |
| S4 | Map: `flutter_map` + `latlong2`, GPS and a pin picker, radius circle with a 2 to 10 km slider, resource pins, protected areas, marketplace listings toggle (A7), basemap with correct attribution on the Credits screen | 26 to 27 Oct | On a phone the pin moves, the circle redraws, the report updates | S3, A7 |
| S5 | Real schemes registry: scheme, who runs it, who can apply, papers, official link, **last checked date and checker name** on every row; official sources only | 26 to 27 Oct | Registry screen with confirmed rows | A teammate to confirm each row |
| S6 | PDF export with the bundled Noto Sans Devanagari font, source/date on each part, Sample label where it applies | 27 Oct | PDF opens with correct Marathi and Hindi | |
| S7 | Weather, rain and prices: only free, reliable sources, key (if any) kept on the server. **Cut if not clearly free** | 27 Oct | Or marked cut | |
| S8 | Languages: write the Hindi strings, Marathi read by a native speaker, check Devanagari is never clipped on small screens | 26 to 27 Oct | | A Marathi reader |
| S9 | Livelihood side of the idea link: idea has a product code; "List this on the marketplace" opens the Gram Sabha add-listing screen prefilled | 27 Oct | Idea to listing works | A6 route, section 3 |
| S10 | Python checks green: `ruff check`, `mypy app scripts`, `pytest -q` | every push | | |
| S11 | Round 2: draft the answers about the report, data and map; mark every number "to confirm" | 28 to 29 Oct | `docs/round2/soham.md` | |

### 2C. Integration (Soham owns all of it)

| # | Task | When | Done when |
|---|---|---|---|
| I1 | Merge both branches into `main` in small steps; resolve conflicts; no direct pushes to `main` after the freeze without a second person present | from 25 Oct | `main` always builds |
| I2 | One sign-in: register once, same token on both servers (shared `JWT_SECRET` set in each Render service) | 26 Oct | Checked with a fresh user on the deployed servers |
| I3 | App build config: `API_BASE_URL` and `LIVELIHOOD_API_BASE_URL` both pointing at Render, set as GitHub secrets, one workflow builds the APK | 27 Oct | One APK talks to both |
| I4 | Cross-module links (A6 + S9 + A7 + S4) wired and tested end to end | 27 Oct | Both directions work on a phone |
| I5 | Keep-warm: health pings for both Render services; open both URLs a minute before any demo | 27 Oct | |
| I6 | Credits screen and README: VanMitra team, Ayush, data sources, basemap attribution, "Demo data" labels | 27 to 28 Oct | |
| I7 | Privacy page (one page, plain text) drafted for Ayush to read | 28 Oct | |
| I8 | Manual test sheet on a **real phone over mobile data**: sign-up, three languages, report, map, marketplace, PDF, link both ways | 28 Oct | Sheet signed off; fixes only after this |
| I9 | Round 2 package: README with screenshots, short video, photographs of the working app, architecture picture, the combined answers from A11 + S11 | 28 to 29 Oct | Submitted |

## 3. Shared contract (change only by telling the other person)

| Item | Agreed shape |
|---|---|
| Sign-in | Node server owns accounts (phone + 6-digit PIN); the Python server verifies the same JWT with the same `JWT_SECRET` and reads `users` read-only |
| Product code | One of `honey`, `bamboo`, `herb`, `preserve`, `seed`, `leaf-plate`, `fibre`, `dried-fruit` (list in `server/src/core/productCode.js`). **Built on the marketplace side:** every listing has one. Soham maps each produce idea to a code (for example `beekeeping_box` to `honey`) |
| Link: idea to listing | App route to the Gram Sabha add-listing screen with `?product=<code>&village=<id>` |
| Link: listing to report | **Built (marketplace side):** the button on a listing opens `/gs/livelihood` or `/v/livelihood` with `?village=&taluka=&product=`. Soham's `LivelihoodShell` must read those parameters. Buyers have no livelihood tab, so they get no button |
| Listing map layer | **Built:** `GET /api/v1/listings/map[?product=<code>]` returns `{points: [{id, title{mr,en}, village, taluka, category, productCode, pricePerUnitPaise, unit, lat, lng}]}`; coordinates rounded to 2 decimals; public, no sign-in. Soham renders it |
| Village identity | One village id used by both servers; matched by name+taluka against the cleaned CFR/MRSAC records |
| Environment | `API_BASE_URL`, `LIVELIHOOD_API_BASE_URL`, `JWT_SECRET`, `MONGODB_URI` per service; secrets only in Render/GitHub settings |

## 4. Schedule

| Date | Ayush | Soham |
|---|---|---|
| **Sun 25 Oct** | Plan merged; A1 (7 pm target); branches created | S2 start; hand over the raw/cleaned CFR file |
| Mon 26 Oct | A2, A3, A5, A8 | S1, S2, S3, S4 start, S5 start, S8 |
| Tue 27 Oct | A4, A6, A7 | S4, S5, S6, S7, S9, I2 to I5 |
| Wed 28 Oct | A9, A10, A11; **freeze in the evening** | I6, I7, I8; S10, S11 |
| Thu 29 Oct | Screenshots, review of form answers | I9, **submit** |
| Fri 30 Oct | Spare: failed upload only | |

**If time runs short, cut in this order:** prices, weather, boundary polygons (keep points and the radius), the idea ⇄ marketplace link, Hindi polish.
**Never cut:** sign-in, the report on real or labelled data, the map, deployment, the video.

## 5. Still needed from people (not code)

| # | Item | Who |
|---|---|---|
| F1 | NGO name, registration number, contact, and the Letter of Support (or say there is no NGO) | Team |
| F2 | Community representative (name, village, role, phone) | Team |
| F3 | Exact deployment village or villages | Ayush |
| F4 | Photos and videos of the Nashik visit, with date and place | Ayush |
| F5 | Permission status and from whom | Ayush |
| F6 | Beneficiary counts, cost per beneficiary, yearly running cost (every number confirmed by a person) | Ayush + Soham |
| F7 | All team members, roles and any missing fields | Team |
| F8 | Who builds the slides | Team |
| F9 | The CFR xlsx / MRSAC docx location, and a native Marathi reader | Soham |

## 6. Working rules

1. Each person commits and pushes only their own folder and their own branch; commits carry only that person's name.
2. Raw data, secrets, keystores and `.env` are never committed. Check `git status` before every push.
3. Anything made up is labelled **Demo** in the UI; nothing claims official review or real data it does not have.
4. No database write (seed, import, index) is run by Claude; Ayush or Soham runs it after reading the dry run.
5. A task is only "Done" after it was run and the output was read.

## 7. Progress log

**25 Oct (Ayush), checked by running it:**

| Task | State |
|---|---|
| A1, A2 | **Blocked**: the CFR file is not on this PC. Synthetic seed (10 villages, 50 listings, 13 accounts) is kept and labelled |
| A3 | **Needs Ayush**: the Render blueprint and guide are ready; entering the Atlas string and secrets is the owner's step |
| A4 | **Partly done**: app id `in.vanrozgar.app`, signing workflow and Gradle guard written ([DEPLOY.md](DEPLOY.md) section 5). **Not built or tested**; needs the keystore, the GitHub secrets, and blocker B1 below |
| A5 | Done: demo buttons are off in release builds by default; no admin credential in the app. (The server seeder still has a development-only back-office password and skips it in production unless one is set) |
| A6 | Marketplace half done (button, route, product code, tests). Soham's half open (S9) |
| A7 | Done: endpoint and tests |
| A8 | Done: the barter offers screen exists and is reachable, so nothing was hidden |
| A9 | Server 33/33 pass. App: my files are analyzer-clean; the rest is blocked by B1 |
| A10 | Done: `IMPLEMENTATION_STATUS.md` rewritten with what was run and the open gaps |
| A11 | Draft written: `docs/round2/ayush.md` (every figure marked to confirm) |

**Blockers found**

| # | Blocker | Owner |
|---|---|---|
| B1 | `app/lib/features/livelihood/data/` (API client, repositories, cache, location service) was never committed, so the app does not compile from a clean clone and no APK can be built. `flutter analyze`: 240 issues, all in `features/livelihood` and its tests | Soham: push that folder first |
| B2 | Raw CFR/MRSAC files are not on Ayush's PC | Soham |

## 8. Soham's part and the integration, done by Ayush on 25 Oct (Soham: review and take over)

Done on request while Soham's branch was empty, from `main`. **If Soham already has his own copy of any of these files, his version and this one will conflict: compare them, keep one, and drop the other.**

| # | Task | State |
|---|---|---|
| B1 | The missing `features/livelihood/data/` layer | **Rebuilt** (API adapter, cache, repositories, location) from the tests. App now compiles: `flutter analyze` clean, **150 app tests pass** (4 need a live server and are skipped) |
| S1 | Python server on Render | Blueprint and steps written (`render.yaml`, `DEPLOY.md` 7). **Not deployed** |
| S2 | Real data | CFR claims and MRSAC village profiles cleaned and loaded by the seeder (see Ayush's A1/A2). Resource coordinates: **not available** from the MRSAC files |
| S3 | Coordinates and boundaries | **Not done**: the MRSAC geoportal and a second Overpass server were unreachable from the build machine. Approximate taluka-town centres are used and labelled |
| S4 | Map | **Done**: OSM tiles, plot, 2 to 10 km circle, resource pins, tap-to-move pin, listings layer, visible credit. Pins are from the labelled sample until real resources are loaded |
| S5 | Schemes registry | 10 real government rows with official links, **unchecked by a person**; NGO rows still samples. A named person must check each row |
| S6 | PDF | **Done**, English, Marathi and Hindi, drawn with Flutter's own text engine because the `pdf` package cannot shape Devanagari. Verified by looking at the output |
| S7 | Weather and prices | Weather **done** (Open-Meteo, opt-in, falls back to the sample). Prices **cut** |
| S8 | Languages | Hindi written for all 325 strings (machine draft). Marathi and Hindi **still need a native reader** |
| S9 | Idea and marketplace link | **Done** both ways with product codes, tested |
| S10 | Python checks | 209 tests, `ruff` and `mypy` clean |
| S11 | Round 2 | Draft in `docs/round2/soham.md` |
| I1 | Merge to main | Done for everything above |
| I2 | One sign-in | Designed in the code and read: the Python server accepts the Node token and reads the user from the same database. **Not tested on deployed servers** |
| I3 | APK build | Workflow ready; needs the secrets and a deployed API |
| I4 | Cross-module links | Built and tested with fakes. **Not tested end to end on a phone** |
| I5 | Keep-warm | **Not done**: open both health URLs a minute before a demo |
| I6 | Credits | `CREDITS.md` updated |
| I7 | Privacy page | **Not written** |
| I8 | Phone test | **Not done** |
| I9 | Round 2 package | Drafts only |

Still needs people: deploy and secrets (A3, S1, E in DEPLOY.md), the keystore, a native Marathi and Hindi reader, a named checker for every scheme row, the real resource data (run `build_osm_resources.py`), form facts F1 to F8, the phone test.
