# VanRojgar final module

One Android app for forest-dwelling communities (CFR title holders) in Nashik district, built for the IEEE
Tech4Tomorrow hackathon: a **livelihood report with a map** (what your forest land can earn, what is around it) joined
with a **forest-produce marketplace** (who buys it). Separate from VanMitra.

**Working plan (who does what):** [docs/plan.md](docs/plan.md)

**Read first:** [docs/final_plan.md](docs/final_plan.md) (decisions, build order) and [docs/QUESTIONS.md](docs/QUESTIONS.md) (what is still open).

## Layout

| Folder | What | Stack |
|---|---|---|
| `app/` | the Android app | Flutter, Riverpod, GoRouter. The marketplace is Ayush's; the livelihood feature is `lib/features/livelihood/` |
| `server/` | accounts, marketplace, trade, delivery, barter | Node.js 24, Express 5, MongoDB (Mongoose) |
| `livelihood_server/` | the livelihood report (rules, ideas, schemes, nearby resources) | Python, FastAPI, MongoDB (read-only on `users`) |
| `docs/` | plan, questions, Ayush's original architecture notes (`docs/vanrozgar/`) | |

## How the two servers fit together

* **One sign-in.** The Node server registers people (phone + 6-digit PIN) and signs a token. The Python server accepts
  that same token (same `JWT_SECRET`) and looks the person up in the same MongoDB (`users`, read-only).
* **One app, two addresses:** `API_BASE_URL` (Node) and `LIVELIHOOD_API_BASE_URL` (Python).
* Ask AI is removed everywhere.

## Run it (development)

```bash
# 1. Node server (in-memory database, nothing to install besides Node 24)
cd server && npm ci && npm run dev:local     # http://127.0.0.1:3000/api/v1

# 2. Python server (set the same secret and database as the Node server)
cd livelihood_server && python -m venv venv && venv/Scripts/pip install -r requirements-dev.txt
venv/Scripts/uvicorn app.main:app --port 8000

# 3. The app
cd app && flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=LIVELIHOOD_API_BASE_URL=http://10.0.2.2:8000/api/v1
```

## Checks

`server`: `npm test` · `livelihood_server`: `ruff check`, `mypy app scripts`, `pytest -q` · `app`: `flutter analyze`, `flutter test`.

**Not committed on purpose:** the raw Nashik spreadsheet and resource document (they contain personal data), secrets,
build output.
