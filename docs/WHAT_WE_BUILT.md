# What we have built so far (in simple English)

**App name:** VanMitra | वनमित्र
**Updated:** 25 October 2026
**What it is:** One Android app for forest communities in Nashik district. It helps people find ways to earn from their forest land, and it lets them sell forest products to buyers.

This file lists everything that exists today. It also says what is **not** done, so nobody is surprised.

---

## 1. The big idea

The app joins two things into one:

1. **One Mitra** (the livelihood part). A person enters facts about their land. The app shows a report: what is around the land, and what work ideas may suit it.
2. **The marketplace** (the trade part). Gram Sabhas list forest products. Buyers ask to buy them.

Both parts use **one login**. You sign in once and both parts know who you are.

---

## 2. The data: only 14 villages

The app uses **only the 14 villages in the Raah Foundation report** (dated 1 October 2026). No other village is in the app.

| Block | Villages |
|---|---|
| Deola | Dongargaon, Kanchane, Kumbharde, Varshi |
| Dindori | Bhatode, Kochargaon |
| Trimbakeshwar | Ambai, Chakore, Devgaon, Met Chandrachi, Pahine, Take Harsh, Talwade, Waghera |

For each village the app holds the numbers from the report:
- forest area (hectares)
- saplings planted
- forest ponds and how much water they hold
- loose boulder structures (small stone walls that hold water and soil)
- labour days given to local people
- community meetings and wildlife awareness sessions
- the tree species planted (for 12 of the 14 villages; the report has no list for the other 2)

The numbers add up to the totals printed in the report: 2,019 hectares, 217,708 saplings, 11 ponds, 794 boulder structures, 12,710 labour days, 19 meetings, 4 sessions. A test checks this.

**The app does not invent anything.** If a fact is missing, it says "not available".

---

## 3. What a person can do in the app

### Sign up and sign in
- Choose a role: **Gram Sabha**, **Villager**, or **Buyer**.
- Gram Sabha and Villager pick their block and village from a list of the 14. No other village is accepted.
- Demo logins exist for testing (clearly marked as demo): one Gram Sabha per village, one villager (in Devgaon) and one buyer.

### One Mitra (a tab for Gram Sabha and Villager)
- **Add your details:** land size, type of land, water, animals, tools, past work, money level, and where the land is (GPS, a pin on the map, typed numbers, or the village centre).
- **Your report** shows:
  - ideas that may suit your land, ranked, with the reason for each
  - what is nearby on a map (wells, water, and similar)
  - typical rain and temperature for each month (from past years, not a forecast)
  - government schemes you can read about (links go to the official websites)
- **Map:** your plot, a search circle (2 to 10 km), resource pins, and listings from the marketplace.
- **PDF:** save the report as a PDF in English, Marathi or Hindi.
- **Languages:** English, Marathi and Hindi.

### The marketplace
- **Gram Sabha:** add and manage product listings, answer buyer requests, handle orders, and manage delivery.
- **Villager:** search the marketplace, see requests and orders.
- **Buyer:** search products, send requests, follow orders.
- **Village page:** shows the Gram Sabha's report figures and species list.
- **Search:** by text, category, price, distance and more.
- **Delivery:** people can apply to be delivery partners for the 3 blocks.

### Paying for an order (added 26 October)
- When a buyer sends a request, they choose **UPI** or **cash on delivery**. UPI is offered only when the team has set its UPI ID on the server.
- **UPI:** after the Gram Sabha approves, the buyer taps "Open UPI app" (the amount and the team UPI ID are filled in), pays in their own app, then types the payment reference. The **seller** then confirms the money arrived. The app cannot see a bank, so until the seller confirms, it says "reported, not yet confirmed".
- **Cash on delivery:** the delivery partner marks the cash received once the goods are on the way (for a pickup, the seller does). The seller sees it on the order.
- The delivery partner screen has an Open tab and a Mine tab and now matches the server's steps.

### Links between the two parts
- From an **idea** in the report, a person can start a **listing** with the product already filled in.
- From a **listing**, a person can open a report about what their land can produce.

---

## 4. How it is built

| Part | Folder | Made with |
|---|---|---|
| The Android app | `app/` | Flutter |
| Accounts, marketplace, trade, delivery | `server/` | Node.js, Express, MongoDB |
| One Mitra report | `livelihood_server/` | Python, FastAPI, MongoDB |
| Plans and guides | `docs/` | Markdown files |

- Both servers use the **same database** (MongoDB) and the **same secret key**, so one login works on both.
- Both are set up to run on **Render**, with the database on **MongoDB Atlas**. The file `render.yaml` describes both servers.
- A **GitHub Action** builds the signed Android APK.

---

## 5. Free outside data we use (and credit)

- **Map:** OpenStreetMap (the credit is shown on screen).
- **Weather:** Open-Meteo, typical rain and temperature from the last 5 years. If it fails, the app shows a clearly labelled sample instead.
- **Schemes:** 10 real government schemes. Each links only to its official website. No money amounts are shown.

All credits are in `CREDITS.md`.

---

## 6. Honesty rules we follow

- Sample or draft data is always **labelled**.
- No guessing: a missing fact is shown as "not available".
- The app never says a person is **eligible** for a scheme. It only points to the official page.
- The idea list is a **draft** and has **not** been reviewed by an expert. The app says so.
- No wild honey or banned forest products are offered.
- Personal data (phone numbers, bank details) is never stored in the repo. The raw Nashik spreadsheet and Word file are never committed.

---

## 7. How well it is tested

| Part | Result |
|---|---|
| App | Code check clean. 153 tests pass (4 more need a live server and are skipped) |
| Node server | 34 tests pass, including one that starts a real database, seeds it and registers users |
| Python server | 213 tests pass. Code style and type checks are clean |

A debug APK builds successfully.

---

## 8. What is NOT done yet

These need a person, an account, or a real phone:

1. **Not deployed.** You must create the Atlas and Render setup and enter the secrets. Steps are in `docs/DEPLOY.md`.
2. **Not tested on a real phone** with the live servers.
3. **The signing key** (keystore) and the GitHub secrets are not created yet.
4. **No map positions for the villages.** The report has none, so each village sits at its block town's centre, and the app says "approximate".
5. **No real resource pins** (wells, water bodies). The tool to fetch them from OpenStreetMap is written but was never run, because the public service was busy.
6. **Two species lists need checking against the paper.** In Varshi and Waghera, the rows do not add up to the total the report prints.
7. **Marathi village names and Marathi/Hindi text** are machine drafts. A native reader must check them.
8. **Scheme rows** have not been checked by a named person. The app says so.
9. **Idea list** is a draft and has not been reviewed by an expert.
10. **UPI has not been tried on a real phone** with GPay or PhonePe, and the team UPI ID is not set yet.
11. **Not built:** market prices (no free reliable source), a privacy page, and a keep-awake ping for Render's free tier.

---

## 9. Where to find things

| I want to… | Open |
|---|---|
| Deploy the app | `docs/DEPLOY.md` |
| See the data credits | `CREDITS.md` |
| See the village data | `server/src/seed/data/raah/raah_villages.json` |
