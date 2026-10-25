# Bug list

Updated 26 Oct 2026. Owner column says who fixes what. A task is done only after it was run and the result read.

## Fixed

| # | Bug | Where | Fix |
|---|---|---|---|
| 1 | Profile badge would show `CFRHOLDER` / `VILLAGER` | `app/lib/shared/widgets/profile_hero.dart` | Uses `roleLabelFor` (CFR HOLDER, FARMER) |
| 2 | Website "Buy" demanded a quantity check and a bulk-order reason (a `required` box blocked submit at 25 units or more) before it showed the item code | `website/src/components/ListingDetailModal.tsx` | Buy goes straight to the app page; the bulk reason is asked only for barter, which stays a demo |
| 3 | CI ran neither the Python tests nor the website | `.github/workflows/ci.yml` | Added `livelihood_server` (ruff + pytest, Python 3.12) and `website` (lint, test, build) jobs |
| 4 | Website showed made-up hero numbers (12+ Gram Sabhas, 18.4L earnings, 1,420 deliveries) with no label | `website/src/sections/HeroSection.tsx` | Replaced with Raah Foundation report figures |

## Open

| # | Bug / risk | Owner | Note |
|---|---|---|---|
| 5 | Existing farmer and Gram Sabha accounts lose the Livelihood tab (intended) but old CFR users must sign up again or be changed to `cfrholder` | Soham | A person changes the role in the database; no script written (database changes are given as a command for a person to run) |
| 6 | Listings made before item codes have none, so they cannot be found by code | Soham | Run `npm run indexes`, then `node scripts/backfill_item_codes.js --apply` |
| 7 | `CORS_ORIGINS` on the Node server must include the website's address once deployed, or live listings will not load (the site then silently shows Sample) | Soham | Set in the Render dashboard |
| 8 | Website Impact tab (Palghar, Gadchiroli, Amravati) is sample data, labelled with a demo warning but not real | Kaushal | Replace or remove before the judges |
| 9 | Website barter and "demo app" still simulate orders in the browser | Kaushal | Labelled prototype; payment is not on the site |
| 10 | Hindi and Marathi strings (new and old) are machine drafts | Soham | Native reader needed |
| 11 | APK link defaults to the GitHub releases page; no release exists yet | Ayush | Set `VITE_APK_URL` after the first release |
| 12 | Payments (UPI, cash on delivery) not built; the download page promises them | Ayush | Tasks A1 to A5 |
| 13 | Nothing tested on a real phone or on the deployed servers | Soham | Tasks S6, S7 |
