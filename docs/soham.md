# Soham's file: what exists, what Ayush built, what I still have to do

**Written:** 25 Oct 2026 · **Real deadline:** 30 Oct · **Plan:** code freeze 28 Oct, submit 29 Oct
**Repo:** `VANMITRA/VanRojgar_final_module` (this branch: `kaushal-website-integration`)
Plain English on purpose. Details of each part are in `WHAT_WE_BUILT.md`, `plan.md` and `DEPLOY.md`.

---

## 1. The big picture

We are shipping **one product** made of three pieces:

1. **The website** (Kaushal). A landing page that explains the project, plus a marketplace that people can look at. It lives in `website/`. It is a React site with mock data.
2. **The Android app** (Ayush's marketplace + my livelihood report, merged). It lives in `app/`.
3. **Two servers**: `server/` (accounts and marketplace, Node) and `livelihood_server/` (the report, Python). They share one database and one login secret, so a person signs in once.

The flow we want a judge to follow:

**Live landing page -> Kaushal's website -> press "Buy" -> download the app (APK) and log in -> find the item by its code -> pay by UPI or cash on delivery.**

---

## 2. What Ayush built (the marketplace and the shared app)

- **Accounts:** sign up and sign in with a phone number and a 6-digit PIN. Roles today: Gram Sabha, villager, buyer.
- **Listings:** a Gram Sabha adds forest products (honey, bamboo, herbs, seeds and so on). Each listing has a **product code**.
- **Trade:** a buyer sends a request, the Gram Sabha accepts, counters or rejects (with a reason). Accepted requests become orders. Barter is also supported.
- **Delivery:** people can apply as delivery partners for the three blocks; orders move through delivery steps.
- **Search:** by text, category, price and distance.
- **Messages, village pages, protected-species scanner** (it stops banned products being listed).
- **Data:** only the **14 villages of the Raah Foundation report** (Deola, Dindori, Trimbakeshwar). Their real figures are in the app. No made-up listings.
- **Three languages:** English, Marathi, Hindi.
- **Deploy and APK:** a Render setup file, a deploy guide, and a GitHub Action that builds a signed APK.
- **Tests:** Node 34, Python 213, app 153 (all passing when last run). Not yet run on a real phone with live servers.
- **After my merge, Ayush also did parts of my side** (see section 3).

## 3. What my backend (livelihood) does, including the parts Ayush finished

- A person gives facts about their land (size, water, animals, tools, past work, location).
- The **report** shows: ranked work ideas with reasons, what is nearby, typical rain and temperature, and government schemes (links to the official sites only).
- **Rules that never break:** never suggest anything that harms wildlife; community forest land is "use only through the Gram Sabha"; no numeric scores (labels only); missing facts say "not available"; ideas are a draft, not expert-reviewed.
- **Map** (OpenStreetMap): your plot, a 2 to 10 km circle, resource pins, marketplace listings layer, pin you can move.
- **PDF export** in English, Marathi and Hindi.
- **Marketplace link:** from an idea you can start a listing; from a listing you can open the report.
- **One login:** my Python server accepts the Node server's login token and reads the user from the same database.
- **Ask AI is removed** completely (decided earlier).

## 4. New decisions (25 Oct) that change the plan

| Topic | Decision |
|---|---|
| **Logins** | Four roles: **Farmer** (basic, today's "villager"), **Gram Sabha**, **Buyer**, and **CFR holder** (new). Buyer stays. |
| **CFR holder** | Has everything a farmer has, **plus** the Livelihood tab/report. They pick this role themselves at sign-up for now (simple for the demo). Gram Sabha approval can come later. |
| **Livelihood access** | Only CFR holders see it. Farmers and the Gram Sabha **lose** the Livelihood tab. Buyers never had it. |
| **Payments** | **UPI** (free: the app opens the buyer's own UPI app with our team UPI ID and the amount filled in) and **cash on delivery**. No cards. No payment gateway. |
| **UPI limit** | Without a gateway the app cannot see the money arrive. The buyer pays, enters or confirms the payment reference, and the seller confirms receipt. We say this openly. |
| **Cash on delivery** | Not built anywhere yet. It needs a payment-method field on orders and a "cash received" step for delivery. |
| **Buy on the website** | The website cannot take payment. "Buy" sends the person to the APK download with login steps. Each item shows a **custom item code** the person copies and pastes into the app's search. |
| **Where code lives** | Kaushal's site in `website/`. App and servers as before. |
| **Credentials** | Team UPI ID to be given by the team. Never put it or any password in git. |

## 5. What I still have to do

**A. Roles and access (blocks everything else)**
1. Add the **CFR holder** role in the Node server (role list, sign-up choice, token) and in the Python server's role map.
2. Rename "villager" to **Farmer** in the screens (keep the stored value so old accounts work, or migrate).
3. Move the Livelihood tab so only CFR holders get it; remove it from Gram Sabha. CFR holders get all farmer screens too.
4. Tests for each role: who sees what, who can call the report.

**B. Item code search**
5. Make the item code (website) match the app's product codes and search. Search by code in the app.

**C. Payments (UPI and cash)** — Ayush does the build, I check it. See `tasks.md`.

**D. Integration and bug hunt (my main job)**
6. Check all merged code builds from a clean clone (server, livelihood server, app, website).
7. One sign-in test on the **deployed** servers with a fresh user (never run yet).
8. Run the **real-phone test over mobile data**: sign-up in each role, three languages, report, map, PDF, order, UPI, cash on delivery, website to app.
9. Fix everything found; then freeze.
10. Keep both Render servers awake before the demo (open the two health URLs).

**E. Still open from the earlier list (data and trust)**
11. Real resource pins from OpenStreetMap (tool is written, never run): I run it and Ayush loads it.
12. A named person checks each scheme row; a native reader checks Marathi and Hindi.
13. Credits screen, privacy page (I draft, Ayush reads), screenshots and short video for Round 2.
14. People facts for Round 2: NGO and letter, community representative, photos, permission, team (see `QUESTIONS.md`).

## 6. Rules I follow
- No made-up data; anything sample is labelled **Sample/Demo**.
- Raw Nashik files (they hold phone and bank numbers) never go in git.
- I do not write to any database myself. I give the command; a person runs it.
- Nothing is called done until it was run and the output was read.
