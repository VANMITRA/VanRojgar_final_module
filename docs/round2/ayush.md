# Round 2 draft: marketplace side (Ayush)

**Status:** draft for the team to confirm. Anything marked **[confirm]** needs a person's figure or fact; nothing here is a measured result. The answers about the report, data and map are Soham's (`docs/round2/soham.md`).

## 1. Problem and need

- **Problem.** Forest-dwelling communities that hold Community Forest Resource (CFR) titles have rights over minor forest produce, but no direct way to list it, find a buyer or agree a price. Sales go through middlemen. **[confirm: one sentence from the Nashik visit that shows this]**
- **Existing solution and its limit.** Generic marketplaces do not know about Gram Sabhas, forest rights or protected species, and do not work in Marathi first. **[confirm: name the alternatives the team actually looked at]**
- **What the app does.** Three portals (Gram Sabha, villager, buyer) and a back office. A Gram Sabha lists produce; a buyer requests it; the Gram Sabha approves, rejects with a reason, or counter-offers; an approved request becomes an order with a timeline; delivery jobs and barter are supported. Protected or wildlife species cannot be listed (checked against a restricted list). Bulk orders of 50 units or more need a stated sustainability purpose.
- **How improvement can be measured.** Time from sign-up to a first listing; listings per village; share of requests answered within a set time; share of orders completed. **[confirm which two the team commits to]**
- **Technology readiness level.** To be proposed honestly after the phone test (plan task I8). It is not claimed in this draft.

## 2. Deployment location

- Nashik district, Maharashtra. Pilot villages in the demo data: Matori, Jalalpur, Mahadevpur, Chandshi, Govardhan, Mughsare, Dari, Yashwantnagar, Mahiravani, Vasali. **These are demo labels; the real deployment village is [confirm: F3].**
- Why this place and who was met on the visit: **[confirm: F3, F4, F5]**. Photos and videos with date and place: **[F4, from the team]**.

## 3. Beneficiaries

- **Direct:** Gram Sabha members and families in the pilot villages who can sell; buyers; delivery partners from the villages. **[confirm: counts]**
- **Indirect:** families of the sellers and the wider village. **[confirm]**
- **How the numbers will be estimated:** from the CFR claim records for the chosen villages (families and area) once Soham's cleaned data is loaded. No number is stated until it comes from that file. **[confirm]**

## 4. Cost and sustainability (marketplace)

| Line | Today | Source |
|---|---|---|
| Database (MongoDB Atlas) | Free M0 tier | Atlas pricing page **[confirm still free on the day]** |
| API hosting (Render, Node) | Free web service; sleeps when idle, so the first request is slow | Render pricing **[confirm]** |
| Mobile app | Android APK, no store fee while shared directly | |
| Maintenance | A named maintainer after the hackathon **[confirm: F1, F2]** | |
| Revenue idea | A small commission on completed orders is a possibility; **not decided** | Team decision |

Cost per beneficiary and yearly running cost: **[confirm: F6]**. Free tiers are limits, not guarantees, and the plan says so.

## 5. Impact

- **Social:** a Gram Sabha controls what it lists and at what price; a rejection must carry a written reason the applicant can read.
- **Environmental:** restricted-species check at listing time; sustainability declaration on every listing; wild-hive honey and reserve produce are not part of the demo catalogue.
- **Economic:** a direct path from village to buyer. No income uplift is claimed because none has been measured.
- **After one year, permission status:** **[confirm: F5, name and office]**.

## 6. Evidence the app can show today

- Server: 33 automated tests pass (run on 25 Oct), including a database-backed API test.
- Screens and a short screen recording: to be produced after the phone test (plan I8, I9).
- Honest limits to state out loud: the data in the demo is synthetic and labelled; nothing is deployed yet; real CFR data is not imported; there has been no test on a phone.
