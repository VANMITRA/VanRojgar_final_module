# VanRozgar (वनरोजगार)

> **"Trade resources. Create livelihoods." / "संसाधनांचा व्यापार. रोजगाराची निर्मिती."**

VanRozgar is a community forest resource marketplace and livelihood module within the VanMitra-AI family of CFR (Community Forest Rights) applications. It serves Gram Sabhas with CFR titles, villagers living in forest communities, and external buyers seeking sustainably harvested Minor Forest Produce (MFP) and rural products.

---

## 🏛️ Architecture & Documentation

- [SYSTEM_ARCHITECTURE.md](SYSTEM_ARCHITECTURE.md) — Product requirements, roles, permissions, state machines, and master plan.
- [BACKEND_ARCHITECTURE.md](BACKEND_ARCHITECTURE.md) — Source of truth for API, database models, validators, and seed pipeline.
- [FRONTEND_ARCHITECTURE.md](FRONTEND_ARCHITECTURE.md) — Source of truth for the Flutter client, VanMitra design system, and screens.
- [docs/API_CONTRACT.md](docs/API_CONTRACT.md) — Endpoint specifications, request/response formats, and status codes.
- [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md) — Build record, verification, and component progress.
- [docs/DEMO_RUNBOOK.md](docs/DEMO_RUNBOOK.md) — Demo walkthrough steps and seeded accounts.

---

## 📂 Repository Layout

```
VanRozgar/
├── app/                  # Flutter (Dart 3) Mobile Client (Android)
├── server/               # Express 5 + Node.js 24 + Mongoose REST API
├── docs/                 # API Contract, Implementation Status, Runbook
├── SYSTEM_ARCHITECTURE.md
├── BACKEND_ARCHITECTURE.md
├── FRONTEND_ARCHITECTURE.md
└── README.md
```

---

## 🚀 Getting Started

### 1. Server (Backend)

```bash
cd server
cp .env.example .env
npm install
npm run seed     # Seeds categories, demo accounts, and Nashik CFR villages
npm run dev      # Starts local API at http://localhost:3000/api/v1
```

Health check:
```bash
curl http://localhost:3000/api/v1/health
```

### 2. Mobile App (Flutter)

```bash
cd app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```
*(On physical Android devices, replace `10.0.2.2` with your machine's LAN IP).*

---

## 👥 Portals & Key Roles

1. **Gram Sabha Portal**: For CFR village office bearers to manage resource listings, inspect purchase requests, negotiate counters, and track orders.
2. **Villager / Landowner Portal**: For forest community residents to procure resources, engage in barter, and optionally register as Delivery Partners to earn livelihood from transport.
3. **General Buyer Portal**: For external purchasers, cooperatives, and Ayurvedic enterprises to source authenticated MFP in bulk with sustainability provenance.
4. **Back Office (Team)**: Protected administration area for verifying Gram Sabhas, reviewing delivery partners, and overseeing restricted items.
