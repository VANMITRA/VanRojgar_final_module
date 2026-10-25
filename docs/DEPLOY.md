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

## 6. Real village data (CFR register + MRSAC)
`npm run seed` now also loads the real villages: 771 villages and 950 claims from the district CFR register, and 680 MRSAC village profiles, as **unclaimed Gram Sabhas** (the first person to register for a village files a claim that the team approves). The 10 demo villages and their demo listings stay, labelled Demo.

- The raw spreadsheet and Word document are **never committed** (git ignores them). Only the cleaned files in `server/src/seed/data/cfr/` are in the repo: they hold village, taluka, right type, area, decision and the committee flag, and no names, phone numbers or bank details. A test fails if a long number or a bank field ever appears there.
- To rebuild them from new raw files: `pip install openpyxl python-docx`, then `python -I -X utf8 server/scripts/cfr/clean_cfr_data.py "<xlsx>" "<docx>" server/src/seed/data/cfr`.
- To preview a load without writing: `cd server && npm run import:cfr`. To write only the CFR part: `npm run import:cfr -- --apply`. Both are safe to repeat.
- **Production seeding needs `JWT_SECRET` too** (the server refuses to start in production without it). In PowerShell:
  `$env:NODE_ENV="production"; $env:MONGODB_URI="<Atlas string>"; $env:JWT_SECRET="<same as Render>"; $env:SEED_DEMO_PASSWORD="123456"; npm run seed; npm run indexes`
- Village positions are not in these files, so real villages have no map point and listings from them show "distance unknown" until coordinates are added.
