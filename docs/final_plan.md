# Final plan: Tech4Tomorrow (IEEE) app

**Status:** plan only, nothing built yet · **Written:** 23 Oct 2026 · **Final submission deadline:** **30 Oct 2026**
(the organisers' mail says no extension; the 25th/26th we discussed earlier is replaced by this date)
**Time left:** 7 days. **My proposed freeze:** 28 Oct evening (code), 29 Oct (video, photos, forms), **submit on 29 Oct** so a
broken link or upload does not cost us the entry.

Repo for the new app: `VanRojgar_final_module` (new, private for now, separate from VanMitra).

> How to read this file. **Section 1** is what is still undecided or missing. **Section 2** is what you decided.
> **Section 3** is what I found in the data and in Ayush's repo. **Section 4** is the build order, step by step.
> **Section 5** maps the organisers' Round 2 forms to the app. **Section 6** is the day-by-day schedule. **Section 7**
> lists risks.

---

## 1. Still open or missing (please close these first)

### 1.1 Decisions only you can make

| # | Open item | My recommendation | Needed by |
|---|---|---|---|
| O1 | **App name** (and logo, tagline). Repo is named `VanRojgar_final_module` for now | Pick by 25 Oct: it goes on the splash, the APK, the video and the forms | 25 Oct |
| O2 | **Where does the app run?** (server hosting) | Node server on **Vercel**, Python server on **Render** (Docker), database on a new **MongoDB Atlas** free cluster (details in 4.2). You create the three free accounts and give me access, or tell me the steps and I write each click | 24 Oct |
| O3 | **Which accounts and owner:** the new repo is under your GitHub name; who else is added (Ayush, Kaushal, the teammate doing the slides)? | Add Ayush and the slides teammate now | 24 Oct |
| O4 | **Privacy page text** (put on hold by you) | I draft a one-page plain text on 28 Oct; you read it | 28 Oct |
| O5 | **Numbers I proposed** (fit bands, "near" distances): you will check against local Nashik data first | Until then they stay defaults and are shown as such | 27 Oct |
| O6 | **Taluka and village boundaries** are not in hand | I will try the MRSAC public map services (the same source as the Resources document); see 4.4. If they refuse or are incomplete, fall back to open data (O7) | 24 Oct (my check) |
| O7 | **Which open datasets may I use?** You asked me to tell you first. List and licences are in 4.4 | You approve the list below, or strike items | 24 Oct |

### 1.2 Things I need from you for the Round 2 forms (Section 5)

| # | Needed | Why |
|---|---|---|
| F1 | **NGO**: name, address, registration number, contact person, and the **Letter of Support** (or say if no NGO) | Mandatory for teams working with an NGO |
| F2 | **Community representative** (name, village, role, phone) | The mail says it is **mandatory** in this round |
| F3 | **The exact deployment location**: which village or villages in Nashik district | The form asks for the exact place and why it was chosen |
| F4 | **Photos and videos of the Nashik visit** (the site and the problem), with date and place | Required evidence |
| F5 | **Permission status:** Yes / No / Under discussion, and from whom (name and office of the Nashik authority) | A question on the form |
| F6 | **Numbers for the form**: how many people benefit directly and indirectly (the claim data helps, see 3.1); cost per beneficiary; yearly running cost | I draft; you confirm every figure because the form says answers must be supported by the project |
| F7 | **Team details**: all members, roles and any missing fields | Mandatory |
| F8 | **Who does what for the slides** (another teammate): I supply screenshots, the architecture picture and facts | The slides are not mine to build |

---

## 2. Decisions taken

### 2.1 Product

| Topic | Decision |
|---|---|
| Product | **One Android app** that joins the **livelihood report with a map** (ours) and the **forest-produce marketplace** (Ayush). It is **separate from VanMitra** |
| Users | People who live on and claim **community forest land (CFR)**, and the Gram Sabhas that hold the title. Not a general-farmer app. Buyers come through Ayush's marketplace |
| Headline | Know what your forest land can earn, on a map; then sell it |
| Platform | **Android only**. No web version. Judges use Android |
| Languages | **English, Marathi and Hindi.** English is the first language shown; the user can then switch (setting kept) |
| Sign-in | **Phone number + 6-digit PIN.** A new user registers with a phone number and creates a PIN. Roles: the user types (Gram Sabha, villager, buyer, as in Ayush's app) |
| Personal data | Keep what we keep today (name, village, land size, animals, plot location). No caste, income or ID numbers. Add more only when needed |
| Report | Search radius **adjustable from 2 km to 10 km**, default 5 km; the server cap is 10 km |
| PDF | The report can be **exported as a PDF**, in the language the user is using, with Marathi and Hindi text shown correctly |
| Map | **Online only** for now. User's **location by permission** (GPS) **and a pin picker**. Basemap: whichever looks best and has terms that allow our use (4.5) |
| Ask AI | **Removed completely**: button, screens, server routes, settings, scripts, tests, docs, dependency. Nothing replaces it for now (you will tell me later) |
| Kept from today | Report, ideas in full, "why not others", Schemes, wildlife policy page, "Delete my answers" |
| Schemes | A **real registry** (4.6) |
| Forest rules | **Kept**: the four legal checks, the wildlife badge, "community forest land: only through the Gram Sabha", labels not scores, Sample labels on any made-up data |
| Idea library | No expert review (too technical). It stays a **clearly labelled draft**; we never say "reviewed by..." |
| Livestock | **Facts only** (is fodder and water within the radius, how far) |
| Crop history | The user types it |
| Weather and prices | **Use them if free and genuinely available** (monsoon rain, weather, market prices). Data is "in the works" |
| Data | **Real Nashik data from you** (the `data` folder). If it is not good enough, open data as in 4.4 |
| Demo data | Mock data is fine where real data is missing, always labelled Sample |
| Reuse | We **may reuse** VanMitra and Module 4 code. Credit the team in the app's Credits screen and the README |
| Database | A **new** MongoDB database, nothing shared with VanMitra |
| Tech | Same stack as today: Flutter, Riverpod, FastAPI (Python), MongoDB; plus Ayush's Node.js server (see 4.1) |
| UI | **First recreate the VanMitra look** (green header, saffron, floating bottom bar, hero card). You may send a better UI later |
| Testing | Proper testing, including on a real phone |
| Slides | Another teammate builds them |

### 2.2 Technical check of my earlier defaults (you asked me to check before using them)

| Item | Default I proposed | Technical check | Verdict |
|---|---|---|---|
| D1 Two servers (Python and Node) | Keep both, one Flutter app calls both | Port of Module 4 to Node would be 1.5 to 2 days of work (about 2,000 lines plus tests) and costs a risk of subtle errors in the rules; running both is more to deploy but each already works and is tested. Both can share one **JWT secret** so one sign-in works for both | **Keep both** for this deadline. Revisit after 30 Oct |
| D2 Which Flutter shell | Use Ayush's (GoRouter) shell, move our screens in | Our screens navigate with `Navigator.pushNamed`; GoRouter is not built for that. Solution: mount our feature inside **its own nested Navigator** under one GoRouter route, so our code is unchanged | **Yes**, with the nested Navigator |
| D3 Headline | "See what your land can earn, then sell it" | Fits both parts | Yes |
| D4 Link between them | An idea can open a marketplace listing | Needs one shared field (the idea's product code) and one screen change | Yes, in step 7 |
| D5 Personal data in the spreadsheet | Use only a cleaned copy | Needed: committee phone numbers and bank details are in the sheet | **Yes. Raw files never go into the repo** |
| D7 Village coordinates | Geocode with open data, mark approximate | Better: take **village boundary centres from MRSAC** (the source of the Resources document); OSM place search only for the leftovers. Nominatim's rules forbid bulk lookup, so I use an OSM extract, not their live service | Yes, order changed |
| D8 What to show publicly | Village, taluka, right type, area, decision; no names | Correct. Claimants' names are not needed | Yes |
| D9 Name | One new name | See O1 | Open |
| D10 Owners | Ayush: marketplace; you: report and map | Needed to avoid conflicts in one repo | Yes, plus one folder per owner |
| D11 Demo script | Keep Ayush's five acts, add a sixth | Fine | Yes |
| D12 Run his app and server | In-memory database only | Safe: nothing is written to a real database | Yes |

---

## 3. What I found

### 3.1 The Nashik data (`data/`)

| File | What it has | Use | Care |
|---|---|---|---|
| `CFR Nashik 2026..xlsx` | 14 taluka sheets + Summary, Sheet17, MPR; about **1,000 claim rows**: village, taluka, right type, forest compartment / gat number, area claimed and approved, decision, whether the CFR committee exists | Real claim facts for the map and for the form's beneficiary estimate | Holds **committee members' phone numbers and bank account / IFSC numbers**. **Never committed or published.** I build a cleaned file without those columns |
| `CFR_Nashik_2026_MRSAC_Resources.docx` | Village resource facts for **680 villages** (area, forest compartments, soil, water, wells, roads, schools); 853 of 950 rows matched by name | The real resources for the report | **No coordinates.** 92 village names unmatched |
| Implementation Plan, Flutter Tech Stack Report, `VanRozgar.pdf` | Ayush's original plan (Amazon-style marketplace, Vercel + MongoDB Atlas, APK by GitHub Actions) | Context | Internal |
| Round 2 questionnaire (`vnd...rendition=1.docx`) | The organisers' questions | Section 5 | |
| `02_SOHAM_OOPS_ASSIGNMENT_5.docx` | A college assignment, unrelated | **Not used, not committed** | |

### 3.2 Ayush's repo (`ayushmore007/VanRozgar-Module`, private)

Node.js 24 + Express 5 + Mongoose + Zod; Flutter with Riverpod, GoRouter and Dio. Marketplace for forest produce:
three portals (Gram Sabha, villager, buyer) plus a back office; listings, purchase requests with counter-offers and
reject-with-reason, orders and timeline, barter, delivery-partner jobs, messages, distance search; a protected-species
scanner against the Wildlife Protection Act; a seeder for 16 Nashik villages; tests and a demo runbook. It already
carries the VanMitra look. It has **no map package** and **no coordinates** for most villages.

---

## 4. Build order, step by step

Each step ends with something I can test. I do not start a step before the one above it passes.

### Step 0: Repo and ground rules (today)
- Create `VanRojgar_final_module` (private). First commit: this plan and the questions file.
- Add `.gitignore` that blocks the `data/` folder, `.env`, keys, `*.xlsx`, and the raw MRSAC document.
- Add `README`, `CREDITS.md` (VanMitra team, Ayush, data sources).

### Step 1: Bring both codebases in and make them run (24 Oct)
- Copy Ayush's `server/` and `app/` (his shell is the base). Copy our `backend/app/livelihood` and
  `frontend/lib/features/livelihood`.
- Keep VanMitra-only code out: claims screens, the demo server, Gram Sabha records, `host/`.
- **Remove Ask AI** everywhere (list in `QUESTIONS.md` B-8). Re-run both test suites.
- Exit check: his server tests, our server tests and the Flutter analyzer all pass; the app opens and signs in.

### Step 2: One sign-in for both servers
- Ayush's Node server owns accounts: phone + 6-digit PIN (his login is phone + password; PIN is the same code with a
  6-digit rule and a lockout after failed tries, which he already has).
- Both servers share one JWT secret (set in each host's settings, never in the repo). The Python server reads the
  user id and role from the token; our `deps.py` already has a single place for this.
- Exit check: register once, call both servers with the same token.

### Step 3: Our feature inside his shell
- One GoRouter route (`/livelihood`) opens our feature in a nested Navigator (our screens unchanged).
- Add the **Livelihood** and **Map** tabs to his bottom bar; keep five tabs by moving the least used one into Profile.
- Recreate the VanMitra look on our screens through his design tokens (same colours, fonts, hero card).
- Exit check: from his app a user opens the report and goes back without a crash.

### Step 4: Real Nashik data (24 to 26 Oct)
1. **Boundaries and coordinates.** First try the MRSAC public map services (taluka and village boundaries, village
   centres). They are the source of the Resources document, so the village names match. If unavailable: open data.
2. **Clean the spreadsheet** (drop phone, bank, IFSC and person-name columns) into `nashik_cfr_claims.json`.
3. **Parse the Resources document** into one record per village: area, forest compartments (reserved / protected),
   soil, water bodies, wells, structures, roads, schools, with the figures exactly as printed and the source line.
4. **Load** into a new database through scripts that run **dry first**; you run the `--apply` (I cannot write to a
   database).
5. **Match** the village list used by the marketplace seeder to the same records.
- Exit check: pick any of the 680 villages; the report lists real resources for it and says where each came from.

### Step 5: The map (25 to 27 Oct)
- Package: `flutter_map` (already used in VanMitra), with `latlong2`.
- Layers: taluka / district lines, the user's plot (GPS **and** pin picker), the radius circle (**2 to 10 km slider**),
  resource pins from the real data, forest compartments if the geometry is available, protected areas, marketplace
  listings as a toggle.
- Online only. Every layer has a source line on a Credits screen.
- Exit check: on a real phone, the pin moves, the slider redraws the circle, the report updates.

### Step 6: Three languages (parallel, ending 27 Oct)
- English first on a fresh install; a language choice on first run and in Profile; saved on the phone.
- Hindi strings are written (we only had English fallbacks); Marathi is read by you.
- Check Devanagari is never clipped on a small screen.

### Step 7: Link the two parts
- A livelihood idea that is about produce (honey, mahua, bamboo, ...) shows **List this on the marketplace**.
- A marketplace listing shows **See what land near here can produce** (opens the report at that village).

### Step 8: Real schemes registry
- Fields: scheme, who runs it, who can apply, papers, official link, last checked date, who checked it.
- I collect from official sources only (Maharashtra and central scheme portals), keep the link, never promise money,
  and put `last checked` and the checker's name on every row. You or a teammate confirms each row.

### Step 9: PDF export
- On the phone with the `pdf` package and a bundled **Noto Sans Devanagari** font, so Marathi and Hindi are correct.
- Content: the report as shown, source and date on each part, the Sample label where it applies, the suggestion-only note.

### Step 10: Weather, rain and prices (only if free and reliable)
- Weather and rain: a free service with no key (checked for terms before use); prices from the public mandi feed if it
  answers reliably. Any key stays on the server.

### Step 11: Deployment (26 to 27 Oct)
- **Database:** new MongoDB Atlas free cluster. Allow the servers' addresses, then **remove any "allow all"** rule.
- **Node server:** Vercel (his `api/index.js` already targets it). **Python server:** Render (Docker, free tier). Free
  tiers sleep when idle; I add a keep-warm ping and a health page for the demo.
- **APK:** built by GitHub Actions on a tag and attached to a release; a signed release build, not debug.
- **Checks:** `check_deploy` style script for each server; one real phone, one real SIM data connection.
- Exit check: a fresh install, registered over mobile data, reaches both servers.

### Step 12: Testing (27 to 28 Oct)
- Both servers' test suites, the Flutter analyzer and tests, plus a written manual test sheet on a real phone: sign-up,
  three languages, report, map, marketplace, PDF.

### Step 13: Round 2 package (28 to 29 Oct)
- README with screenshots; short video; photographs of the working app; architecture picture and facts for the
  slides; the questionnaire answers drafted (Section 5) for you to confirm.

---

## 5. Round 2 forms: what the app and we must answer

The questionnaire has six groups. I draft every answer from the project's own facts. **Every number must be one you
confirm.**

| Group | Questions | What we can answer from the project | What we still need |
|---|---|---|---|
| Problem and need | problem, magnitude, frequency, existing solution and limits, measurable improvement, model, **TRL**, extra work before deployment, infrastructure, operator, maintenance | Forest communities with CFR titles do not know what their land can earn or who buys it; the claim data shows how many titles exist (about 900 community claims in 14 talukas); existing solution = no tool, middlemen; improvement = measurable by time to a first listing and by listings per village | Magnitude sources; operator and maintainer (F1, F2); TRL (I will propose after Step 12, honestly) |
| Deployment location | exact place, type, why, problem there, visited, evidence | Nashik district villages with CFR titles; type = village; you visited | Exact village (F3), photos and videos (F4) |
| Beneficiaries | direct, indirect, numbers, primary group, how estimated | Gram Sabha members and families in the pilot villages; buyers; delivery partners | Counts and the estimation method (F6) |
| Cost and sustainability | cost per beneficiary, deployment cost, yearly cost, funding, savings or revenue | Free-tier hosting; costs are small and I list them line by line | Your figures; a revenue idea (e.g. small commission on trade) is a team decision |
| Impact | social, environmental, economic, after one year, permission | Wildlife and forest protection built in; sustainable harvest rule for bulk orders | Permission status (F5) |
| Evidence | photographs and video of the site and the model | I produce screenshots and a screen recording of the working app | Site photos (F4) |

Also required: **NGO details and letter** (F1), **community representative** (F2), **complete team information** (F7).

---

## 6. Day-by-day (23 to 30 Oct)

| Day | Date | Work | Done when |
|---|---|---|---|
| 1 | Fri 23 Oct | This plan; repo; answers to Section 1; probe the MRSAC map services; start Step 1 | Repo exists, plan agreed |
| 2 | Sat 24 Oct | Steps 1 to 3 (merge, remove Ask AI, one sign-in, shell). Accounts for hosting | App runs, one login, both servers answer |
| 3 | Sun 25 Oct | Step 4 (real data in) and start Step 5 (map) | Real villages in the report |
| 4 | Mon 26 Oct | Step 5, Step 6 (languages), Step 8 (schemes), start Step 11 (deploy) | Map and three languages work on a phone |
| 5 | Tue 27 Oct | Steps 7, 9, 10, finish 11 | Deployed; PDF; marketplace link |
| 6 | Wed 28 Oct | Step 12 (testing), fixes; **code freeze in the evening** | Test sheet passed on a real phone |
| 7 | Thu 29 Oct | Step 13: video, photos, README, form answers; **submit** | Submitted |
| Spare | Fri 30 Oct | Only for a failed upload | Deadline day |

**If time runs short, cut in this order:** prices, weather, boundary polygons (keep points and the radius), the
marketplace link, Hindi polish. **Never cut:** sign-in, the report on real data, the map, deployment, the video.

---

## 7. Risks

| Risk | Effect | Handling |
|---|---|---|
| MRSAC services refuse or have no polygons | No village coordinates | Fall back to open data; mark every point approximate; fewer villages is acceptable |
| Free tier servers sleep | First request takes tens of seconds in the demo | Keep-warm ping; open the app once before the demo; video as backup |
| Two servers, two deployments | More to break | One shared secret, two health checks, one deploy script each |
| Personal data in the spreadsheet | Leak if committed | Ignored by git from the first commit; cleaned file only; I check the repo before every push |
| Real Marathi/Hindi never read by a native speaker | Wrong words | You read Marathi; Hindi limited to labels we can check |
| Idea list is a draft | A judge asks who reviewed it | Say so plainly; no claim of review |
| Time | Seven days for a large scope | The cut list in Section 6 |
| I cannot test on your phone from here | Bugs a phone shows | A phone test on Day 6 is mandatory; you send screenshots |
| Reusing VanMitra code | Credit and consent | Credits screen and README; you said we may reuse |
