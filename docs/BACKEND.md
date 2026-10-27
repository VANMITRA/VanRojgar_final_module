# Backend: what exists and what changes

**Updated:** 26 Oct 2026. Two servers, one database, one login.
This file is the short, current version of the backend notes.

## 1. The two servers

| | Marketplace server | Livelihood server |
|---|---|---|
| Folder | `server/` | `livelihood_server/` |
| Language | Node 24, Express 5, Mongoose | Python, FastAPI, Pydantic v2 |
| Owner | Ayush (roles and payments: Soham/Ayush) | Soham |
| Job | Accounts, sign-in, listings, requests, orders, barter, delivery, messages, search | Land profile, report, ideas, map data, schemes, weather, nearby resources |
| Database | MongoDB (`users`, listings, orders and so on) | Same MongoDB, own `lv_*` collections; reads `users` read-only |
| Tests | 34 (Node) | 213 (Python) |

**One sign-in:** the Node server issues a token (HS256) with `sub` (user id), `role`, `exp`. The Python server checks the same token with the same secret (`JWT_SECRET` / `VANMITRA_JWT_SECRET`) and looks the user up in the same `users` collection.

## 2. Roles (changing now)

| Role | Stored as | Marketplace | Livelihood |
|---|---|---|---|
| Farmer | `villager` (shown as "Farmer") | yes | no |
| Buyer | `buyer` | yes | no |
| Gram Sabha | `gramsabha` | yes | no (removed) |
| CFR holder | `cfr` (new) | yes, same as Farmer | **yes** |

Work: add `cfr` to the user model and sign-up check, token, Python role map (`gramsabha -> gram_sabha`, `cfr -> cfr_holder`), and make the report routes accept only `cfr`. Self-picked at sign-up for now; Gram Sabha approval is a later step. Tests for every role.

## 3. Payments (new)

- Order gets `paymentMethod`: `upi` or `cod`. No card, no gateway.
- **UPI:** the app builds a `upi://pay?...` link (team UPI ID from server settings, amount, order id) and opens the buyer's own UPI app. The server cannot see the money. States: `awaiting_payment` -> `payment_reported` (buyer gives the reference) -> `payment_confirmed` (the seller confirms).
- **Cash on delivery:** order goes into delivery; the delivery partner marks `cash_received`; the seller sees it.
- The team UPI ID lives only in server settings, never in git.

## 4. Item codes (new)

Each listing gets a short **item code** shown on the website and in the app, and the search endpoint finds a listing by it. Product codes (`honey`, `bamboo`, ...) already exist (`server/src/core/productCode.js`); the item code is a new, per-listing code. Format to be agreed in the item-code task.

## 5. The livelihood report

Pure rule functions in `livelihood_server/app/livelihood/domain/` (no database, no HTTP): units, resource labels, four legal checks, idea ranking, wildlife badge, analysis. Rules that never break: no harm to wildlife; community forest is "use only through the Gram Sabha"; labels only, no numbers; missing facts show "not available"; every result carries source and date; ideas are a draft. Radius default 5 km, capped at 10 km. Weather is Open-Meteo (typical values; falls back to a labelled sample). Schemes are 10 real government schemes with official links only.

## 6. Data

- Only the 14 villages of the Raah Foundation report (seed in `server/src/seed/data/raah/`). No synthetic villages or demo listings.
- Raw Nashik files (spreadsheet, MRSAC document) are never committed; only cleaned data without phone, bank or name columns.
- Village positions are approximate (taluka town centres) and say so.
- Real resource pins: tool written (`build_osm_resources.py`), never run. A person runs it and loads the result.

## 7. Deploy

Render (both servers, `render.yaml`) + MongoDB Atlas. Steps in `docs/DEPLOY.md`. Not deployed yet. Secrets are entered by a person in Render and GitHub, not in chat or git. A person runs any database write.

## 8. Backend tasks, in order

1. CFR role in both servers (Soham).
2. Order `paymentMethod`, UPI states, cash on delivery (Ayush).
3. Item code on listings and in search (Ayush; format agreed by all).
4. Deploy both servers, same secret, test one sign-in on the live URLs (Ayush deploys, Soham tests).
5. Run the OSM resource builder, load the result (person runs it).
6. Keep both servers awake before the demo.

## 9. Checks

Node: `npm test`. Python: `ruff check`, `ruff format --check`, `mypy app scripts`, `pytest -q`. All must pass before a merge to `integration`.
