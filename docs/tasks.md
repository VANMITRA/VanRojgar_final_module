# Tasks: website + app integration

**Written:** 25 Oct 2026 · **Code freeze:** 28 Oct evening · **Submit:** 29 Oct (30 Oct is the spare day)
**Goal:** when a judge uses it, nothing breaks. Landing page, website, app, payment and the livelihood report must work together.

| Person | Owns |
|---|---|
| **Kaushal** | The website (`website/`) and the hero landing page |
| **Ayush** | Payments (UPI, cash on delivery) and the marketplace side |
| **Soham** | Roles, the livelihood report, joining everything, and finding bugs |

## The flow to deliver

1. Hero landing page (live): what the project is, how it works, what has been achieved.
2. Kaushal's website: browse products. Each product shows a **custom item code** with a copy button.
3. "Buy" opens a page: **download the APK** + login steps + "copy your item code".
4. In the app: sign up or log in, search by the item code, open the item.
5. Place the order. Pay by **UPI** (free, no gateway) or **cash on delivery**.

## Roles (all in the app)

| Role | Gets |
|---|---|
| Farmer | Marketplace screens. No Livelihood. |
| Buyer | Marketplace screens (buy side). No Livelihood. |
| Gram Sabha | Listings, requests, orders, delivery. No Livelihood. |
| CFR holder | Everything a farmer has + the **Livelihood** report. They choose this at sign-up for now. |

---

## Kaushal: website

| # | Task | Done when |
|---|---|---|
| K1 | Build the **hero landing page**: hero, how it works, what has been achieved, what is in the app (reuse existing sections in `src/sections`) | Opens and reads well on phone and laptop |
| K2 | Each product on the site shows a **custom item code** (format agreed in S3 below) with a "Copy" button | Copied code finds the same item in the app |
| K3 | "Buy" opens an **App download page**: APK download link, 4 login steps, the item code, a note that payment happens in the app | No payment is taken on the site |
| K4 | Remove the AI Studio leftovers: the `GEMINI_API_KEY` use and `@google/genai` if unused; make sure no key is baked into the build | `npm run build` passes and the bundle has no key |
| K5 | Replace mock listings with real data from the marketplace server if the public listing endpoint (`/api/v1/listings/map` or search) is reachable; otherwise keep mock data labelled **Sample** | Labelled correctly either way |
| K6 | Languages: English first, then Marathi and Hindi if the site already has them | Switching language never breaks the layout |
| K7 | Deploy the site (Vercel) and send the link to the team | Public link works on mobile data |
| K8 | Check: `npm run lint`, `npm run build`, `npm test` if present | All pass |

## Ayush: payments and marketplace

| # | Task | Done when |
|---|---|---|
| A1 | Add a **payment method** to orders: `upi` or `cod` (no card). Server field, validation, tests | Order shows the method |
| A2 | **UPI (free):** open the buyer's UPI app with a `upi://pay?pa=<team UPI ID>&pn=<name>&am=<amount>&tn=<order id>&cu=INR` link (Android intent). Buyer comes back and enters or confirms the payment reference | Pay flow works with GPay/PhonePe on a real phone |
| A3 | Order states for UPI: `awaiting payment` -> `payment reported` -> `payment confirmed` (the seller confirms the money arrived). Say plainly in the UI that confirmation is by the seller | No state claims "verified" without a person confirming |
| A4 | **Cash on delivery:** order goes straight to the delivery steps; the delivery partner marks "cash received"; the seller sees it | COD order completes end to end |
| A5 | UPI ID comes from config or a server setting. **Never committed to git** | Not in the repo |
| A6 | Search the marketplace **by item code** (and show the same code on each listing) | Code from the website opens the item |
| A7 | Tests for A1 to A6 on the server and in the app; `flutter analyze`, `flutter test`, `npm test` stay green | All three pass |
| A8 | Keep the signed APK pipeline working; produce the APK the website links to | A signed APK installs and logs in |

## Soham: roles, livelihood, integration, bug hunt

| # | Task | Done when |
|---|---|---|
| S1 | Add the **CFR holder** role: Node (role list, sign-up, token), Python (role map), app (sign-up choice) | A CFR account can sign up and sign in |
| S2 | Rename villager to **Farmer** on screen; Livelihood only for CFR holders; remove it from Gram Sabha; CFR holders also get all farmer screens | Each role sees only what the table above says |
| S3 | **Item code format** agreed with Kaushal and Ayush (one short code per listing, shown on site and in app). Product codes already exist (`honey`, `bamboo`, ...); a listing code is the new part | Written down here, then used by K2 and A6 |
| S4 | Tests for roles: access rules in Node, Python and the app | Pass |
| S5 | Merge Kaushal's branch and Ayush's work into `main` in small steps; everything must build from a clean clone | `main` always builds |
| S6 | Check one sign-in on the **deployed** servers with a new user | Same token works on both |
| S7 | Real-phone test sheet over mobile data (all roles, three languages, report, map, PDF, order, UPI, COD, website to app) | Signed off, fixes made |
| S8 | Hunt bugs after each merge; keep a bug list in `docs/BUGS.md` with who fixes what | List empty or accepted before submit |
| S9 | Real resource pins (OpenStreetMap tool), scheme-row checks, Marathi and Hindi reader | Done or marked not done on the Credits screen |
| S10 | Credits screen, privacy page, screenshots, short video, Round 2 answers | Package ready 28 Oct |
| S11 | Before the judges: open both Render health URLs and the site one minute early | |

## Dates

| Date | Kaushal | Ayush | Soham |
|---|---|---|---|
| Sun 25 Oct | Start K1; read this file | Start A1, A2 | S1, S3 (agree the item code) |
| Mon 26 Oct | K1, K2 | A2, A3, A4 | S1, S2, S4 |
| Tue 27 Oct | K3, K4, K5 | A5, A6, A7 | S5, S6 |
| Wed 28 Oct | K6, K7, K8; **freeze** | A8; **freeze** | S7, S8, S10; **freeze** |
| Thu 29 Oct | Fixes only | Fixes only | S11, **submit** |
| Fri 30 Oct | Spare | Spare | Spare |

## Rules for everyone
- Each person works on their own folder and branch; the integration happens through pull requests into `main`.
- No secret, UPI ID, keystore or `.env` in git. No raw data files in git.
- Anything made up is labelled **Sample** in the screen.
- A task is "Done" only after it was run and the result was seen.
- After the freeze on 28 Oct, only bug fixes. No new features.

## Open facts we still need from the team
- The **team UPI ID** (used only in server config).
- The **APK download link** (Release page or storage).
- Item code format approval (S3).
- NGO and letter, community representative, photos, permission, team list (see `QUESTIONS.md`).
