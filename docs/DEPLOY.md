# Deploying the Node server (Render + MongoDB Atlas)

Only the account steps need you. Never paste a secret into chat or commit it.

## 1. Database (about 5 minutes)
1. Sign up at mongodb.com/atlas and create a free **M0** cluster (region Mumbai if offered).
2. Database Access: add a user with a long random password.
3. Network Access: add `0.0.0.0/0` for now (Render's free tier has no fixed address). Tighten it after the demo.
4. Connect, Drivers: copy the `mongodb+srv://...` string and put the database name in it: `.../vanrozgar?retryWrites=true&w=majority`.

## 2. API on Render
1. render.com, New, Blueprint, pick this repo and branch. It reads `render.yaml`.
2. Set the three secrets when asked:
   - `MONGODB_URI`: the string from step 1
   - `JWT_SECRET`: at least 32 random characters. **The Python livelihood server must use the same value.**
   - `CORS_ORIGINS`: the website's address, or leave empty
   - `UPI_ID` (optional): the team's UPI ID, like `name@bank`. Buyers pay this ID by UPI. **Leave it empty to switch UPI off** (cash on delivery still works). Never put it in git or in chat.
3. When it is live, open `https://<name>.onrender.com/api/v1/health`. The free tier sleeps when idle, so open this URL a minute before any demo.

## 3. Seed the demo data (once, from any computer)
```bash
cd server && npm ci
MONGODB_URI='<atlas string>' NODE_ENV=production SEED_DEMO_PASSWORD='<6-digit PIN>' npm run seed
```
The back-office account is not created in production unless `SEED_TEAM_PASSWORD` is set.

## 4. Build the app against the live server
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://<name>.onrender.com/api/v1 --dart-define=DEMO_PIN=<same 6-digit PIN>
flutter build web --release --dart-define=API_BASE_URL=https://<name>.onrender.com/api/v1
```
In GitHub, Settings, Secrets, Actions, set `API_URL` to the same address and run the "Android APK" workflow.

## 5. Signed APK in GitHub Actions (application id `in.vanrozgar.app`)
You hold the keystore. It is never committed (`*.jks` and `key.properties` are git-ignored).

1. Create the keystore once, on your PC, and keep a backup somewhere private. If it is lost the app can never be updated under the same id:
   ```bash
   keytool -genkeypair -v -keystore vanrozgar-upload.jks -alias vanrozgar -keyalg RSA -keysize 2048 -validity 10000
   base64 -w0 vanrozgar-upload.jks      # on Windows PowerShell: [Convert]::ToBase64String([IO.File]::ReadAllBytes("vanrozgar-upload.jks"))
   ```
2. GitHub, Settings, Secrets and variables, Actions, add these **secrets**:

   | Secret | Value |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | the base64 text from step 1 |
   | `ANDROID_KEYSTORE_PASSWORD` | the keystore password |
   | `ANDROID_KEY_ALIAS` | `vanrozgar` (or the alias you chose) |
   | `ANDROID_KEY_PASSWORD` | the key password |
   | `API_URL` | `https://<node-service>.onrender.com/api/v1` |
   | `LIVELIHOOD_API_URL` | `https://<python-service>.onrender.com/api/v1` |
   | `DEMO_PIN` | the 6-digit `SEED_DEMO_PASSWORD`, only if you want demo buttons |

   Optional **variable** `DEV_TOOLS` = `true` to show the labelled demo-account buttons in the APK. Leave it unset for a build without them.
3. Actions, "Android APK", Run workflow (or push a tag such as `v0.1.0`). The job stops with a clear message if a secret is missing, and Gradle refuses to sign a release with the debug key (`REQUIRE_RELEASE_KEY=1`).
4. Download `vanrozgar-apk`, install on a phone, sign in over mobile data.

Local builds without `android/key.properties` still fall back to the debug key; that APK is for your own testing only.

## 6. The dataset: 14 villages (Raah Foundation report)
The only village data in the app is the **14 Community Forest Resource villages of the Raah Foundation report** (letter of 1 October 2026): Dongargaon, Kanchane, Kumbharde, Varshi (Deola); Bhatode, Kochargaon (Dindori); Ambai, Chakore, Devgaon, Met Chandrachi, Pahine, Take Harsh, Talwade, Waghera (Trimbakeshwar). `npm run seed` loads them as Gram Sabhas with the report's figures (CFR area, saplings, forest ponds, water storage, boulder structures, labour days, meetings, wildlife sessions and, for 12 villages, the plantation species). It also removes every other village from the database. Registration, the delivery areas and the livelihood server accept only these 14. There are **no demo listings**: the marketplace starts empty and holds only what Gram Sabhas list. The demo logins stay (one demo Gram Sabha per village, `+919822011001` to `+919822011014`, a demo villager in Devgaon, a demo buyer), PIN from `SEED_DEMO_PASSWORD`.

- The data file is `server/src/seed/data/raah/raah_villages.json`, typed from the report; a test checks that every column adds up to the report's printed totals (2,019 ha, 217,708 saplings, 11 ponds, 794 boulder structures, 12,710 labour days, 19 meetings, 4 sessions). The report gives no map position, so each village sits at its block town's centre, labelled approximate.
- **Check against the paper before you submit:** in the Varshi and Waghera species lists the rows do not add up to the total the report prints (6,261 against 6,161, and 23,257 against 26,866). The numbers are as read from the scan; the app does not show list totals.
- To preview a load without writing: `cd server && npm run import:raah`. To write only the villages: `npm run import:raah -- --apply`. Both are safe to repeat.
- **Production seeding needs `JWT_SECRET` too** (the server refuses to start in production without it). In PowerShell:
  `$env:NODE_ENV="production"; $env:MONGODB_URI="<Atlas string>"; $env:JWT_SECRET="<same as Render>"; $env:SEED_DEMO_PASSWORD="123456"; npm run seed; npm run indexes`
- Village positions are approximate (block town), so listings show a rough distance until real coordinates are added.

## 7. The livelihood server (Python) on Render
`render.yaml` now has a second service, `vanrozgar-livelihood`. It reads the same MongoDB (`users`, read-only) and accepts the same sign-in token, so the two secrets below must match the Node service exactly.

1. Render, New, Blueprint (or open the existing blueprint and sync). Enter the two secrets when asked:
   - `VANMITRA_MONGODB_URI`: the **same** Atlas string as `MONGODB_URI`
   - `VANMITRA_JWT_SECRET`: the **same** value as `JWT_SECRET`
2. Open `https://<livelihood-service>.onrender.com/api/v1/health`. It should say `ok`.
3. Load the livelihood data into Atlas once, from your PC (this writes to the database, so you run it):
   ```powershell
   cd livelihood_server
   py -3.12 -m venv venv; venv\Scripts\pip install -r requirements-core.txt
   $env:VANMITRA_MONGODB_URI="<Atlas string>"; $env:VANMITRA_MONGODB_DB="vanrozgar"; $env:VANMITRA_JWT_SECRET="<same as Render>"
   venv\Scripts\python scripts\setup_livelihood_indexes.py          # indexes
   venv\Scripts\python scripts\seed_livelihood.py                   # dry run: shows what it would write
   venv\Scripts\python scripts\seed_livelihood.py --apply           # ideas (draft) and the scheme register
   ```
   Do **not** load `sample_resources.geojson`: it is a labelled sample for a place outside the 14 villages. Without resource data a report says there are no mapped resources nearby, which is honest. Real resources: `scripts/build_osm_resources.py` (section 8).
4. Put its address in the GitHub secret `LIVELIHOOD_API_URL` (`https://<livelihood-service>.onrender.com/api/v1`), then build the APK.
5. A person from any of the 14 villages gets a report. With no surveyed centre for the village, the server uses the **block town** as the centre and says so in the report's source; they get a report about their own land by saving their plot location (GPS, pin or typed).

## 8. Real resources from OpenStreetMap (optional, run from your PC)
`livelihood_server/scripts/build_osm_resources.py` asks the public Overpass service for wells, water bodies, rivers, dams and protected areas in Nashik district and writes a GeoJSON file in the format the loader checks. Everything is labelled `confidence: low`, `check_status: to_verify` and credited to OpenStreetMap contributors (ODbL). The public service is often busy: the script retries slowly. Check the file with `load_livelihood_resources.py <file>` (validate only) before adding `--apply`.
