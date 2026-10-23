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
