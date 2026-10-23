# Tech for Tomorrow app: questions and the shortcuts we took

> **Update 23 Oct:** the answers to Parts A and B and the decisions that followed are now collected in [final_plan.md](final_plan.md). This file stays as the record of the questions.


> One file, two parts. **Part A** lists every shortcut we took to finish quickly (the "decisions to save time"),
> with what we would do now that there is time. **Part B** is every question I have before building.
> Each item has a **recommended answer** so you can reply "ok" or change it. Write your answer in the
> **Your answer** column (or reply in chat by number, e.g. "A3 yes, B7 Nashik only").
>
> Nothing is built until you answer. Today is 22 October; the submission is on the 25th or 26th, so about
> three to four working days. Part C proposes a cut line.

**Housekeeping already done:** I compared every Markdown file in the repo with every other one. The most any
two files share is 6 %, so **no file meets your "more than 90 % the same" rule and none was deleted.**
Candidates you may want gone are listed in B-12.

---

## Part A. Shortcuts we took, and what we do now that there is time

| # | What we did to save time | What it means today | Recommended now | Your answer |
|---|---|---|---|---|
| A1 | **Resource data is made up.** 12 places around Trimbak (19.7805, 73.2210), labelled Sample. No real Nashik survey data | The "5 km around your land" list is not real | Replace with real Nashik data: water bodies, wells, markets, forest areas, roads (see B-4). Keep the Sample set only as a fallback labelled as such | DECIDED: you will provide the real Nashik dataset; Sample set kept only as a labelled fallback |
| A2 | **No map in the livelihood report.** It is a list; location is GPS or typed coordinates | A judge sees no map of the plot or its surroundings | Build a map: your plot, the 5 km circle, resources as pins, Nashik district / taluka / village boundaries (B-4, B-5) | DECIDED: add the map properly (no map in the report today) |
| A3 | **Idea library is a draft**: 16 ideas, not reviewed by an agriculture expert, forest-law expert or animal-welfare reviewer | Suggestions may not suit Nashik crops and conditions | Rewrite the library for Nashik with a named agriculture reviewer (B-3, B-9) | DECIDED: no expert review (too technical). Library stays a labelled draft; I will not claim "reviewed by" |
| A4 | **Schemes are 8 Sample rows**, three of them link to the national scheme portal | Not a real register; no one signed it | Build a real register: scheme, who runs it, who can apply, papers, official link, "last checked" date and who checked it | DECIDED: build a real, proper schemes registry |
| A5 | **Marathi and Hindi are machine drafts**; Hindi falls back to English for newer strings; Konkani not covered | A native speaker has not read any Marathi screen | Marathi + English fully; Hindi only if a reviewer exists (B-9) | DECIDED: English, Marathi and Hindi. English is the first language shown; the user can then switch |
| A6 | **Weather is a Sample file**, not live data | "Hot months, rain" are not real for the user's place | Use a free live or historical source for Nashik (B-4) | DECIDED: use free weather / monsoon rain data if a free dataset is really available (in the works) |
| A7 | **The report cannot be recomputed on a phone with no server.** The offline demo shows one prepared report for one sample farmer; editing details does not change it | Fine for a pitch of a demo build, wrong for a real app | Decide the architecture: hosted server (needs internet), or port the rules to the phone (about 3 to 5 days). Recommended: hosted server + the last report cached on the phone (B-6) | DECIDED: absolute deployment; what to deploy on is still open |
| A8 | **No real login of our own.** We reused VanMitra's login, roles and village list (Gram Sabha, SDO, admin) | The new app would inherit someone else's roles and database | Its own simple sign-in and its own database (B-7) | DECIDED: the app gets its own proper sign-in |
| A9 | **Nothing is deployed.** There is no server on the internet for this app | A judge cannot open it from a link | Deploy a lean server (B-6) | DECIDED: same as A7 (deploy) |
| A10 | **Radius 5 km, fit bands, "near" distances are my proposals** (e.g. protected area "near" = 2 km, flood "near" = 300 m, "hot" month = 40 degrees) | Numbers nobody has checked | Ask an agriculture officer or the Nashik authorities to confirm or change them (B-9) | OPEN: check local Nashik data first, then answer |
| A11 | **Livestock analysis is facts only** ("fodder and water within 5 km: yes/no"). No feed or yield calculation | Looks thin next to a real advisory app | Add real calculations only if an agriculture expert supplies the numbers (B-9) | DECIDED: facts only |
| A12 | **Crop history is typed by the user** (no 7/12 extract) | Extra typing; cannot be checked | Keep typed; add the Maharashtra land-record link if a permitted source exists (B-4) | DECIDED: farmer types it in (no 7/12 extraction) |
| A13 | **Forest and FRA rules drive the app** (four legal checks, "community forest: only through the Gram Sabha") | Right for forest dwellers, odd for a general farmer in Nashik | Decide who the user is (B-1) and keep or drop the forest checks accordingly | DECIDED: keep the forest/CFR checks. Users are people living on and claiming community forest land (CFR), not necessarily farmers |
| A14 | **Satellite map pictures come from the internet and are never saved** (Esri imagery) | No map without a connection; licence limits copying | Choose a basemap whose terms allow what we need (B-5) | DECIDED: map online only for now |
| A15 | **Privacy review is not done** (consent wording, retention) | Fine for a hackathon, not for real farmers | A short, honest privacy page; real legal review later (B-10) | not answered yet |
| A16 | **Tests cover the logic, not a real phone.** I could not run the apps on your phone from here | Bugs a phone would show may exist | Reserve a testing block on a real phone before submitting (C) | DECIDED: proper testing, including on a real phone |
| A17 | **Ask AI** (answers questions about the report; built, off by default) | You have decided to remove it | **Remove it completely**, see B-8 | DECIDED: remove Ask AI completely |

---

## Part B. Questions

### B-1. Product and users

| # | Question | Recommended | Your answer |
|---|---|---|---|
| B1.1 | **What is the app called?** (It is not VanMitra.) Logo, colours and tagline? | Pick a name today; I use it everywhere (package id, titles, README). Reuse VanMitra's green and saffron unless you prefer new colours | |
| B1.2 | **Who is the user?** (a) tribal forest-dwelling families (as in VanMitra), (b) every farmer or rural household in Nashik district, (c) both | (b) with an optional forest layer. Nashik's main income is not only forest produce, and "any business" was your wording | ANSWERED via A13: people who live on and claim community forest land (CFR) |
| B1.3 | **Is it still livelihood suggestions as the core?** Or is the core now the map and the data, with livelihood ideas as one feature? | Core = "what can I earn from my land and what is around it", on a map | |
| B1.4 | **Other users beyond the farmer?** Officials (agriculture office, Gram Panchayat, forest dept) who see an overview, or farmer only? | Farmer only for submission; an officer overview screen only if time remains | |
| B1.5 | **The hackathon theme / track and judging criteria.** Please paste the exact wording | I align the demo to the stated criteria | |
| B1.6 | **What did the Nashik authorities say, exactly?** Names, offices, what they liked, what they asked for, any data or letter they promised | I put this in the pitch and plan features around it | |
| B1.7 | **Do we have a letter or photos from the Nashik visit** we may show? | Yes, one slide | |

### B-2. Submission

| # | Question | Recommended | Your answer |
|---|---|---|---|
| B2.1 | **Exact deadline** (date, time, time zone) and **what must be submitted**: app file, repo link, live link, demo video, slides, report? | I plan for all of them: APK, public repo, short video, README, 5-slide deck | |
| B2.2 | **Live demo or recorded?** If live, is internet available on the stage? | Record a backup video either way | |
| B2.3 | **Must the code be original / open source?** Are we allowed to reuse VanMitra and Module 4 code? | Ask the organisers; see B-11 | |
| B2.4 | **Who presents and in which language?** | English with Marathi labels in the app | |
| B2.5 | **Phones:** which Android phones and Android versions will judges or you use? iPhone needed? | Android only | |

### B-3. Scope and features

| # | Question | Recommended | Your answer |
|---|---|---|---|
| B3.1 | **Must-have features for submission** (I propose a cut line in Part C). Mark each: must / nice / drop | See Part C | |
| B3.2 | **Which parts of today's app stay?** Report, idea detail, "why not others", Schemes, wildlife policy page, Delete my answers | Keep all except Ask AI | |
| B3.3 | **Which Ayush features come in?** (needs his repo, B-11) | Decide after I scan it | |
| B3.4 | **The replacement for Ask AI** (you will discuss with the team): should I leave an empty slot or hide it until you decide? | Hide it; no placeholder in the submitted app | |
| B3.5 | **Should the app work in Marathi first?** All text, including idea names and schemes | Marathi + English toggle on every screen | |
| B3.6 | **PDF or share of the report?** (an earlier idea was a PDF plan) | Skip for submission | |

### B-4. Data (the biggest risk)

| # | Question | Recommended | Your answer |
|---|---|---|---|
| B4.1 | **Is there a dataset for Nashik district?** What do you have already: files from the visit, the authorities' data, anything from MRSAC, Forest Dept, Agriculture Dept, Irrigation Dept? Please put the files in a folder and tell me | Use whatever you have first, then open data | |
| B4.2 | **If none: may I use open data?** Candidates: OpenStreetMap (roads, water, markets), DataMeet / Survey-of-India style district and taluka boundaries, Bhuvan, India WRIS (water), Agmarknet (mandi prices), Open-Meteo or IMD (weather). I must check each licence and show credits | Yes, with attribution on a Credits screen | |
| B4.3 | **Boundary level:** district, 15 talukas, or every village? Village boundaries for Maharashtra are not freely published in one set; do you have a source? | District + taluka now; village centres as points | |
| B4.4 | **Which resource types matter for Nashik?** e.g. water (Godavari, dams, wells, ponds), markets (APMC), cold storage, processing units, forest areas, protected areas, roads. Add or remove | Water, markets, forest/protected areas, roads | |
| B4.5 | **Live data allowed?** Weather and mandi prices need internet and a free API; any key must live on the server, not in the app | Yes for weather; prices only if a free feed is reliable | |
| B4.6 | **Mock data for the demo:** how many sample farmers, in which talukas? | 3 farmers in 3 talukas, labelled Sample | |

### B-5. Map

| # | Question | Recommended | Your answer |
|---|---|---|---|
| B5.1 | **What must the map show?** (boundary lines, the user's plot, 5 km circle, resource pins, protected areas, a heat layer?) | Boundaries + plot + circle + pins + protected areas | |
| B5.2 | **Basemap source.** Satellite (Esri) has usage limits; OpenStreetMap tiles forbid heavy use; self-hosted vector tiles for Nashik need work | OpenStreetMap-based tiles through a provider that allows our use, plus our own boundary layers drawn on top | |
| B5.3 | **Does the map have to work without internet?** | Boundaries and pins offline; basemap needs internet | |
| B5.4 | **Pin picker** to choose the plot on the map instead of typing coordinates? | Yes | |

### B-6. Architecture and hosting

| # | Question | Recommended | Your answer |
|---|---|---|---|
| B6.1 | **Hosted server or everything on the phone?** | Hosted server (Railway or similar) + cached last report on the phone | |
| B6.2 | **Who pays for hosting and the database,** and which account? A free tier may sleep; do you have a Railway / Render / Atlas account for this app? | Free tiers for the hackathon; you create the accounts, I give exact steps | |
| B6.3 | **New database, separate from VanMitra's?** | Yes, a new MongoDB database (or a new Atlas project) so nothing touches VanMitra | |
| B6.4 | **Same tech (Flutter + FastAPI + MongoDB) or a different one?** | Same: it is built and tested | |
| B6.5 | **Do you want a web version for judges** (open a link, no install)? | Only if time remains after the Android app | |

### B-7. Accounts and privacy

| # | Question | Recommended | Your answer |
|---|---|---|---|
| B7.1 | **Sign-in:** phone + 6-digit PIN as now, or open (no sign-in) for the demo, or phone OTP? | Phone + PIN; a "try as guest" button for judges | |
| B7.2 | **Roles:** just "farmer", or also an "officer" login? | Farmer only | |
| B7.3 | **What personal data do we keep?** Name, village, land size, animals, location of the plot. No caste, income or ID numbers (as in our rules). OK? | Yes | |
| B7.4 | **Privacy text** for the app: who writes it? | I draft; you edit; no legal review | |

### B-8. Removing Ask AI (please confirm the scope)

I will remove: the "Ask AI" button (header, floating button, hub card), the Ask screen and its history, the
suggested questions, the AI consent card, the server routes `/ask`, the AI module and its settings
(`anthropic` package, key setting, daily limit), the evaluation script and question set, the schemes
"ask" counts, the tests and the documents about it.

| # | Question | Recommended | Your answer |
|---|---|---|---|
| B8.1 | **Remove the plain (non-AI) question box as well?** It shares the same screen and answers from the report with no model | Yes, remove all of it | |
| B8.2 | **Keep** idea detail, Schemes and the wildlife policy page? | Yes | |
| B8.3 | Say **"no AI recommendations"** anywhere in the app or pitch? | Yes, one line: "suggestions come from published rules and data, not from a chatbot" | |

### B-9. Content and expert review

| # | Question | Recommended | Your answer |
|---|---|---|---|
| B9.1 | **Who can review the idea library for Nashik?** An agriculture officer, a KVK (Krishi Vigyan Kendra) contact, a professor? Even a 20-minute review helps | Ask the Nashik authorities you met | |
| B9.2 | **Who reads the Marathi?** | A teammate who is a native speaker | |
| B9.3 | **May we show the idea list as "reviewed by ..."?** Only if someone actually reviewed it | Yes, only if true | |
| B9.4 | **Should the numbers (radius, bands) be shown as adjustable settings?** | No; keep fixed, document them | |

### B-10. Legal and safety rules we carried from VanMitra

| # | Question | Recommended | Your answer |
|---|---|---|---|
| B10.1 | **Keep these rules?** No numeric scores shown (labels only); every result shows its source and date; demo data labelled Sample; suggestions never promise money or approval; nothing suggested that harms wildlife | Yes, they are what make the app trustworthy | |
| B10.2 | **Keep the forest-law checks** if the user is a general farmer (B1.2)? | Keep as a "forest nearby" warning only | |

### B-11. Integration, repos and credit

| # | Question | Recommended | Your answer |
|---|---|---|---|
| B11.1 | **Ayush's repo** | **Scanned on 22 Oct**; findings are in `INTEGRATION.md` and the questions it raised are in Part D | answered |
| B11.2 | **New repo:** name, owner (your account or an organisation), **public or private**? Hackathons often need public | New public repo `<name>` under your account | |
| B11.3 | **Permission to reuse VanMitra code** (Kaushal's and the team's work: login, screens, hero look, the claim screens we ported)? Do we copy it, or leave it out and build only Module 4 plus Ayush's part? | Reuse only Module 4 code and the demo shell; do **not** copy the claims screens. Credit the team | |
| B11.4 | **Licence for the new repo** (MIT, Apache-2.0, none) | MIT | |
| B11.5 | **Do you want the old VanMitra work kept in this repo** (`host/`, `docs/DEMO_APKS.md` and so on), or moved out? It does not belong in the new app | Leave this repo as is; start the new repo clean and copy only what is needed | |

### B-12. Documents: what to delete

No file is a 90 % copy of another. These are candidates **you** may want removed; tell me which:

| File | What it is | Recommended |
|---|---|---|
| `docs/DEPLOY_DEMO.md` | steps to put the VanMitra server online for a demo | delete from the new app (keep here) |
| `docs/DEMO_APKS.md` | the offline VanMitra demo APK | delete from the new app |
| `docs/MODULE4_LIVELIHOOD.md` | the note for the VanMitra host | delete from the new app |
| `docs/DATA_PLAN.md` | where data comes from and how it is loaded | **keep**, rewrite for Nashik |
| `docs/IDEA_LIBRARY.md` | the 16 draft ideas | **keep**, rewrite for Nashik |
| `docs/to_do.md`, `to_do_deferred_items.md` | status and deferred work | replace with one new plan |
| `docs/PROJECT_PLAN.md`, `BACKEND_PLAN.md`, `FRONTEND_PLAN.md`, `MVP_SPRINT.md` | the plan for Module 4 | keep until the new plan exists, then merge |
| `previous/*` | older plan documents of VanMitra | delete from the new app |
| `host/*` | files that exist only inside the VanMitra host app | not part of the new app |

---

## Part D. Questions after scanning Ayush's repo

What I found, in one paragraph: Ayush built a **forest-produce marketplace** (trade, barter, delivery jobs, three
portals) with a **Node.js server and a Flutter app**. It is not the map and not the livelihood report. It also holds
the **real Nashik data**: a spreadsheet of about 1,000 community-claim rows over 14 talukas and a document with
resource facts for 680 villages from the MRSAC geoportal. Neither has coordinates. Details are in
`docs/INTEGRATION.md`.

| # | Question | Recommended | Your answer |
|---|---|---|---|
| D1 | **Two server stacks (our Python, his Node).** For one app we should pick **one**. Which? (a) keep both servers behind one address, (b) rewrite Module 4's rules in Node, (c) rewrite his server in Python, (d) one Flutter app that talks to both servers | (d) for the submission: it needs no rewrite and both parts already work; revisit after. A rewrite in 3 days is a risk | |
| D2 | **Flutter structure.** His app uses GoRouter, ours named routes with Riverpod. Copy his screens into our shell, or ours into his? | Use **his** shell (GoRouter, portals, theme already built, tests) and move our report screens into it, because his app is the larger one | |
| D3 | **Is the marketplace the main story or the livelihood report?** The pitch needs one headline | "Know what your land can earn (report + map), then sell it (marketplace)" | |
| D4 | **How do the two meet?** e.g. a livelihood idea "sell mahua / honey" shows a button "List this on the marketplace" | Yes, one link in each direction | |
| D5 | **The spreadsheet contains phone numbers and bank account numbers** of committee members. The repo (his notes) says internal only; the hackathon repo may be public. May I use it only to build a clean dataset (village, taluka, rights, area, decision) and **leave the personal columns out of every file we publish**? | Yes. The raw files stay private; a cleaned copy is committed | |
| D6 | **Is Ayush's repo private on purpose, and does he agree to merge it into a public repo?** | Ask him; keep the merged repo private until the submission if the rules allow | |
| D7 | **Village coordinates:** neither Nashik file has them. May I geocode the villages myself (from open data such as OpenStreetMap and census/LGD places), mark each point's source, and show a "approximate" label? About 700 villages is more than a hand job | Yes, with a source and an "approximate" flag for every point; unmatched villages are listed | |
| D8 | **Which Nashik claims data do we show to the public?** Claim area and decision are official records, but the villages are small | Show village, taluka, right type and approved area only; no names of people | |
| D9 | **Name.** His product is also called VanRozgar and has the same repo name as our module. What is the combined app called? | One new name (B1.1) | |
| D10 | **Who owns what after the merge?** Ayush for the marketplace, you for the report and map? | Yes; one owner per folder, to avoid conflicts | |
| D11 | **Does his demo (14 Oct) have an agreed demo script I should preserve** (his `DEMO_RUNBOOK.md` has five acts)? | Keep his five acts and add a sixth: the report and map | |
| D12 | **Can I run his server and app here to test them?** It needs Node and a MongoDB (he uses an in-memory one for local runs, which writes nothing to a real database) | Yes, in-memory only | |

---

## Part C. Proposed cut line (so the 3 to 4 days are enough)

| Day | Work | Output |
|---|---|---|
| Day 1 (22 Oct) | Answers to this file; scan Ayush's repo; create the new repo and project skeleton; remove Ask AI; decide data | New repo builds and runs |
| Day 2 | Nashik boundaries and real resource data in; the map screen; pin picker; report on the new data | Map + report on real Nashik data |
| Day 3 | Ayush's part merged; Marathi review; real schemes register; deploy the server; install on a real phone | One APK that works against the live server |
| Day 4 (24 Oct) | Phone testing and fixes only; README, screenshots, 3-minute video, slides; submit on the 25th | Submission ready, a day early |

**Must:** map with Nashik boundaries, report with real data, schemes, Marathi + English, deployed server, APK, README + video.
**Nice:** Ayush's part (depends on his repo), mandi prices, officer view, web version.
**Cut first if late:** Hindi, officer view, web version, live weather.
