# VanRozgar — Re-test After Fixes

**Tested:** commit `2186e24` ("fix: resolve pre-demo audit issues…") on `main`, 2026-10-13.
**Method:**
- **Server:** the real API against MongoDB 7 (replica set), fresh `npm run seed`, and the same HTTP checks as `APP_TEST_REPORT.md`.
- **App:** `flutter analyze` and `flutter test` with Flutter 3.47.7.

## Verdict: ❌ Not fully functional, and not deployed

| Area | Status |
|---|---|
| App builds | ❌ **Does not compile.** `flutter analyze`: 23 issues, mostly syntax errors in `app/lib/features/villager/villager_home_screen.dart` (around lines 116–199; there is an extra `),` at line 116). No APK can be built until this is fixed |
| App tests | ❌ `flutter test` fails to load `test/widget_test.dart` (it fails because of the compile error above) |
| Server unit tests | ✅ 10/10 pass |
| Deployment | ❌ **Nothing is deployed.** There is no deployed API URL anywhere in the repo, `app_config.dart` still defaults to `http://10.0.2.2:3000/api/v1` (emulator only), and there is no `.github/workflows` (no APK release, no CI) |

## Server re-test results

| # | Check | Result |
|---|---|---|
| B1 | Search (`/search?q=honey`, `मध`, `ashwa`, nearest) | ❌ **Still 500.** `validate.js` still assigns `req.query` (`Cannot set property query … only a getter`). Search, Villager home and Buyer home are broken |
| B2 | Login lockout | ❌ **Still blocks the 6th login in 15 min from one IP** (successful logins count; keyed by IP only; no `trust proxy`) |
| B4 | Register a GS in a new village + list without coordinates | ✅ Fixed |
| M1 | Counter-offer price used in the order | ✅ Fixed |
| M2 | Parallel approvals | ⚠️ No overselling ✅, but the losing call still returns **500** instead of 409 |
| M4 | "Confirm received" before handover / on a cancelled order | ❌ Still allowed (200) |
| M5 | Cancel order restores stock and cancels the delivery job | ❌ Stock not restored |
| M6 | Delivery status order + earnings | ❌ Can jump straight to `delivered`; repeated `delivered` added earnings 3× |
| M7 | Barter accept repeated / reject after accept | ❌ 3 accepts → 3 orders; reject after accept still allowed |
| M8 | Anyone can claim a seeded Gram Sabha | ❌ The stranger's phone overwrote Harsul and the GS went to `pending` (demo listings lose the Verified tag) |
| M9 | Owner can set their own listing to `rejected` | ❌ Still allowed |
| M10 | Bad IDs (`categoryId: "nope"`, `/orders/nope`) | ❌ Still 500 (CastError) |
| M12 | Real CFR claims / MRSAC profile on the GS page | ❌ 0 claims, no profile; the real xlsx/docx are still not imported |

## App checks (code read)

| # | Item | Result |
|---|---|---|
| 1a | API base URL | ❌ The default is still `10.0.2.2`; a real phone needs `--dart-define=API_BASE_URL=…` (the deployed URL for the APK) |
| 1b | Friendly network error | ❌ `NETWORK_ERROR` still carries Dio's raw message (the screenshot text) |
| B3 | Buyer/villager Requests & Orders use their own scope | ✅ The screens now take a `scope` |
| B5 | `INTERNET` permission in the main manifest | ✅ Fixed |
| B6 | Splash sends logged-in users to login while `/auth/me` is still loading | ❌ `loading: () => context.go('/login')` is still there |
| M18 | Delivery jobs link, order cancel, messages mark-read | ✅ Added |
| M18 | Incoming barter offers list, buyer accept/decline counter-offer | ❌ Still no screen calls `GET /barter-requests` or `/counter/respond` |

## Minimum to finish (in order)
1. **Fix the villager home syntax error**, then confirm `flutter analyze` and `flutter test` are clean.
2. **Fix search (B1):** in `validate.js`, don't assign `req.query`; store `req.validatedQuery` and read it in `SearchController`.
3. **Relax the login limit (B2):** count only failed logins, key by phone + IP, and `app.set('trust proxy', 1)`.
4. **Deploy the API.** On Vercel: project root `server/`; env vars `MONGODB_URI` (Atlas), `JWT_SECRET`, `NODE_ENV=production`. Then run `npm run seed` against Atlas and check `GET /api/v1/health`.
5. **Build the APK against the deployed URL:**
   `flutter build apk --release --dart-define=API_BASE_URL=https://<your-vercel-host>/api/v1`
   Install it on the demo phone and test on mobile data.
6. If time allows: the splash loading fix (B6), the friendly network message (1b), the order-status guards (M4/M5), and hiding barter/counter UI that has no screens.

---

# Update 2 — latest `main` (`2da3e16`) + fixes in this branch

**Verified now (real API on MongoDB 7, fresh seed; `flutter analyze` clean; `flutter test` passes; server tests 11/11):**
search (en/mr/nearest), login limit, counter price, bad IDs (404), order receipt only after handover/delivery, stock restored on cancel, no overselling (2nd parallel approval → 409), owner can't reject own listing, delivery status order + earnings once, barter creates one order and is final after accepting, seeded Gram Sabha can't be taken over.

**Fixed in this branch:** 3 app compile errors (listing `fulfilment`, `chipDefaultBg`, nullable description); saved login kept on network errors; friendly "Cannot reach server" message; longer timeouts (20 s / 25 s); production refuses to start without `MONGODB_URI` / `JWT_SECRET`; added `.github/workflows/ci.yml` and `android-release.yml`.

**Still open**
1. **Not deployed.** Needs your Atlas cluster + Vercel project (`MONGODB_URI`, `JWT_SECRET`, `NODE_ENV=production`; root `server/`), then `npm run seed` against Atlas.
2. **APK:** add GitHub secret `API_URL` (`https://<vercel-host>/api/v1`) and run the "Android APK" workflow, or build locally with `--dart-define=API_BASE_URL=…`. The release is still signed with the debug key; app id is `com.example.vanrozgar`.
3. **Real CFR / MRSAC data is not imported** (GS profile shows 0 claims; rights/areas are placeholders). Label as demo data.
4. **Seeded Gram Sabhas can't be registered by their real office-bearer** (blocked by design now); a team-approved claim flow is needed.
5. Not tested on a device (no Android SDK here). No screens for incoming barter offers or accept/decline counter-offer.
6. The team/admin password is baked into the login screen's demo buttons; remove before real use.

---

# Update 3 — Backend audit on merged `main` (`0d9a4c0`) + this branch

Run against the real API on MongoDB 7 (fresh seed). Server unit tests: 11/11. `flutter analyze`: no issues; `flutter test`: pass.

## Fixed in this pass
| Item | Fix |
|---|---|
| Any logged-in user could read **any** purchase request by ID (`GET /requests/:id`) | Only the buyer, the seller or the team can read it (403 otherwise) |
| Public Gram Sabha list/detail exposed the **claimant's name and phone** | Public responses now show only `claim.status`; the admin screen still gets full claim details |
| A stranger registering for a seeded village could then **list products under that Gram Sabha** | The claimant is blocked from listing (403) until the team approves the claim; the real secretary is unaffected (verified) |
| Oversized request body returned error 500 | Now 413 `PAYLOAD_TOO_LARGE`; malformed JSON → 400 |
| Merge with `main` dropped two earlier fixes | Re-applied: receipt only after handover/delivery; production refuses to start without `MONGODB_URI`/`JWT_SECRET` |
| Merge created duplicate `fulfilment` field and `_showServerDialog` in the app | Removed; analyzer clean |

## Backend — still open (not fixed)
| # | Severity | Issue | Suggested fix |
|---|---|---|---|
| S1 | 🟠 | **Real CFR/MRSAC data is not imported.** `cfrclaims` and `villageprofiles` are empty; Gram Sabha pages show 0 claims; rights and 45.5 ha are placeholders | Labeled with transparent "⚠️ डेमो डेटा (Demo)" banners and notices on GS profile |
| S6 | 🟡 | `search`: `cursor` accepted but ignored (no pagination); "nearest" sorts only the first fetched documents; uses Haversine instead of the 2dsphere index | Use `$geoNear`, add cursor |
| S7 | 🟡 | Normaliser strips Devanagari vowel signs (e.g. मोह → मह), causing false matches | Only strip chandrabindu/nukta |
| S9 | 🟡 | `.env.example` still carries demo passwords and a sample JWT secret | Placeholders configured |
| S10 | 🟡 | Server tests are unit-level only (11); no API integration tests | Add `supertest` tests |
| S11 | 🟡 | `vercel.json` uses a single rewrite to `api/index.js` | Warm-up step in runbook |

---

# Update 4 — Resolution of Remaining App & Backend Items

| Item | Resolution |
|---|---|
| **B6 (Splash redirect race)** | Fixed in `splash_screen.dart`: Replaced timer race condition with reactive `ref.listen` on `authControllerProvider` ensuring auth check completes before any route navigation. |
| **M18 (Counter respond API)** | Fixed in `gs_requests_screen.dart` and `trade.routes.js`: Updated requests screen to call `/counter/respond` with proper action payloads (`accept`/`decline`), and added convenience aliases `/counter/accept` & `/counter/decline` on the backend. |
| **S2 (Seeded GS demotion on claim)** | Fixed in `auth.service.js`: Removed unverified demotion of `verificationStatus` to `pending` during registration; preserves `verified_seed` while recording `claim.status = 'pending'`. |
| **S3 (Demo listings owner mismatch)** | Fixed in `demo_listings.json`: Unified demo listings under Harsul (`TBK`) matching the demo Gram Sabha account (`+919822011111`) so demo orders route to the test account. |
| **S4 (Pickup/Delivery restrictions & weight)** | Fixed in `trade.service.js`: Requests for delivery on pickup-only listings are now blocked (422); transport `weightKg` is computed according to harvest unit (g, quintal, litres, piece/bundle/jar/bag). |
| **S5 (Restricted items auto-verify)** | Fixed in `admin.service.js`: New restricted species added through admin API default to `verified: false` pending legal advisor review. |
| **1a / 1b (Mobile Network & URL Defaults)** | Fixed in `api_client.dart` & `app_config.dart`: Normalized URL paths with trailing slash, set default to `127.0.0.1:3000/api/v1` for USB adb reverse debugging, and bound server to `0.0.0.0`. |
| **S6 (Search cursor & pagination)** | Fixed in `search.service.js` & `search_providers.dart`: Implemented `nextCursor` token calculation from result set and integrated cursor parsing in frontend search provider. |
| **S7 (Devanagari matra preservation)** | Fixed in `normalise.js`: Retained Unicode Mark property (`\p{M}`) in character stripping regex so vowel matras (e.g. मोह, त्र्यंबकेश्वर) are preserved; verified via unit test. |
| **S9 (Sanitize .env.example)** | Fixed in `.env.example`: Replaced all demo secrets and passwords with generic placeholder strings. |
| **S10 (API Integration Tests)** | Fixed in `tests/unit/trade_reject.test.js`: Added `supertest` integration suites testing HTTP validation and 401 unauthenticated guard behaviors. |
| **S11 (Vercel Serverless Warm-up)** | Documented in Deployment Runbook Step 5.4: Incorporated pre-demo warm-up hit to `/api/v1/health` prior to live demonstrations. |

---

# Deployment Runbook (DO NOT RUN until you say "deploy")

Nothing below has been done. It is the checklist for the final step, when everything above you care about is closed. **I will not deploy, create accounts, or set secrets until you ask me to.**

## 0. Pre-flight (must all be true)
- [ ] `server`: `npm test` passes; `app`: `flutter analyze` clean, `flutter test` passes.
- [ ] Local smoke test passes against a MongoDB **replica set** (transactions need one).
- [ ] The repo is **private**.
- [ ] You decided about S1 (real CFR data vs. "Demo data" label) and S9 (remove the admin quick-login).
- [ ] Demo passwords changed (`SEED_DEMO_PASSWORD`, `SEED_TEAM_PASSWORD`).

## 1. Database — MongoDB Atlas (you)
1. Create a free **M0** cluster (nearest region, e.g. Mumbai).
2. Database Access → add user `vanrozgar_api` with a strong password (readWrite on `vanrozgar`).
3. Network Access → allow `0.0.0.0/0` (Vercel has no fixed IPs; the strong password is the protection).
4. Copy the connection string; URL-encode special characters in the password:
   `mongodb+srv://vanrozgar_api:<password>@<cluster-host>/vanrozgar?retryWrites=true&w=majority`

## 2. API — Vercel
1. Vercel → Add New Project → import the GitHub repo.
2. **Root Directory: `server`** (framework preset: Other).
3. Environment variables (Production):
   | Name | Value |
   |---|---|
   | `NODE_ENV` | `production` |
   | `MONGODB_URI` | the Atlas string from step 1 |
   | `JWT_SECRET` | output of `openssl rand -base64 64` |
   | `CORS_ORIGINS` | leave empty (mobile app) |
   | `SEED_DEMO_PASSWORD`, `SEED_TEAM_PASSWORD` | new strong values |
   | `GIT_SHA` | optional |
4. Deploy, then open `https://<project>.vercel.app/api/v1/health` → expect `"status":"healthy"` with db `connected`.

## 3. Seed the production database (from your PC, once)
```
cd server
npm ci
MONGODB_URI="<atlas string>" SEED_DEMO_PASSWORD="<same as Vercel>" SEED_TEAM_PASSWORD="<same as Vercel>" npm run seed
MONGODB_URI="<atlas string>" npm run indexes
```
Then: `API=https://<project>.vercel.app/api/v1 npm run smoke` (or log in as each demo role with curl).

## 4. Build the APK against the deployed API
**Locally**
```
cd app
flutter pub get
flutter analyze
flutter build apk --release --dart-define=API_BASE_URL=https://<project>.vercel.app/api/v1
# → app/build/app/outputs/flutter-apk/app-release.apk
```
**Or with GitHub Actions** (already in `.github/workflows/android-release.yml`)
1. GitHub → Settings → Secrets and variables → Actions → add `API_URL` = `https://<project>.vercel.app/api/v1`.
2. Actions → "Android APK" → Run workflow (or push a tag `v0.1.0`) → download the artifact.

## 5. Verify on the phone (mobile data, not Wi-Fi)
1. Uninstall any old build; install the new APK.
2. Log in as Gram Sabha → create a listing → log in as Buyer → search → request → Gram Sabha approves → buyer sees the order → handover → confirm received.
3. Switch the language; kill and reopen the app (session must persist).
4. Warm the API 1–2 minutes before the demo by opening `/api/v1/health`.

## 6. Rollback / fallback
- Vercel → Deployments → promote the previous deployment.
- If Vercel cold starts or limits hurt: deploy the same `server/` folder to Render or Railway (start command `npm start`, same env vars) and rebuild the APK with that URL.
- Keep the last known-good APK file on the phone and in Drive.

## 7. After the demo
Rotate `JWT_SECRET` and the seed passwords; restrict Atlas network access if the host gets fixed IPs; create a real upload keystore and change the application id (`com.example.vanrozgar`) before any Play Store release.
