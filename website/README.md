# 🌿 VanRozgar (वनरोजगार)
### *Trade Resources. Create Livelihoods.*
**A Community Forest Resource Marketplace & Rural Livelihood Module of the [VanMitra](https://github.com/Sinusoidal-Meow/VanRozgar) Ecosystem**

---

![React](https://img.shields.io/badge/React-19.0.0-61DAFB?style=flat-square&logo=react&logoColor=black)
![TypeScript](https://img.shields.io/badge/TypeScript-5.7.0-3178C6?style=flat-square&logo=typescript&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-6.2.0-646CFF?style=flat-square&logo=vite&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-v4.0-38B2AC?style=flat-square&logo=tailwind-css&logoColor=white)
![Motion](https://img.shields.io/badge/Framer_Motion-12.0-FF4154?style=flat-square&logo=framer&logoColor=white)
![License](https://img.shields.io/badge/License-Apache_2.0-green.svg?style=flat-square)

---

## 📌 Executive Summary

**VanRozgar** is an Amazon-style decentralized buyer–seller marketplace and logistics platform designed for forest-dependent tribal communities and village councils (**Gram Sabhas**) operating under **Community Forest Rights (CFR)** (under India's Forest Rights Act, 2006).

While **VanMitra-AI** acts as the parent governance platform securing and mapping tribal land and forest rights, **VanRozgar** transforms those recognized rights into tangible, sustainable rural economic opportunities:

> *"VanMitra protects forest rights; VanRozgar turns them into rural income."*

Different Gram Sabhas possess distinct natural endowments—one village produces wild honey and mahua, another has high-altitude medicinal herbs (jadibuti), while another crafts bamboo products. VanRozgar enables Gram Sabhas, forest-dwelling villagers, and ethical commercial buyers to discover, trade, barter, and transport these resources with end-to-end transparency.

---

## 🌟 Core Value Pillars

```
                     ┌───────────────────────────────────────────────┐
                     │          VanMitra-AI Forest Governance        │
                     │ (Land Rights · Claims · Cadastral Atlas Map)  │
                     └───────────────────────┬───────────────────────┘
                                             │
                                             ▼
                     ┌───────────────────────────────────────────────┐
                     │              VanRozgar Marketplace            │
                     ├───────────────────────┬───────────────────────┤
                     │                       │                       │
     ┌───────────────┴────────┐    ┌─────────┴─────────┐   ┌─────────┴─────────────┐
     │   Community Commerce   │    │  Fair Livelihoods │   │ Employment Generation │
     │  Gram Sabhas monetize  │    │  Fair price guide │   │ Villagers with wheels │
     │  managed forest rights │    │  & barter balance │   │  earn via deliveries  │
     └────────────────────────┘    └───────────────────┘   └───────────────────────┘
```

1. **Community Commerce**: Gram Sabhas collectively list and trade sustainably harvested forest produce directly from their legally demarcated CFR zones.
2. **Sustainable Livelihoods**: Built-in fair price intelligence, transparent barter exchange calculations, and mandatory harvest quota safeguards to prevent forest over-exploitation.
3. **Rural Employment Generation**: Hyperlocal logistics created by on-boarding village vehicle owners (bikes, autos, tempos, pickups) as certified delivery partners.

---

## 🏛️ The Three User Portals

VanRozgar operates with three distinct role-based interfaces sharing a unified marketplace catalog:

| Feature | 🏛️ Gram Sabha Portal | 🏡 Villager / Landowner | 🏢 General Buyer |
|:---|:---|:---|:---|
| **Target User** | Village Forest Council / Executive Committee | Forest-dwelling resident or local landholder | External businesses, Ayurvedic brands, wholesalers |
| **Primary Goal** | Monetize CFR produce & manage village earnings | Acquire local resources & trade produce | Source authentic, certified raw materials |
| **Trading Modes** | **Sell & Barter** | **Buy & Barter** | **Purchase Only** (No Barter) |
| **Listing Creation**| Full creation + Group pool management | Cannot create direct market listings | Cannot create listings |
| **Delivery Role** | Coordinates pickup / handover | **Can enroll as Delivery Partner** (if owns vehicle) | Destination receiver |
| **Order Guardrails**| Reviews requests & issues counter-offers | Can request barter swaps & counter-offers | **Mandatory harvest reason** required for large orders |
| **Verification** | Verified by VanMitra Field Officers | Verified against Gram Sabha village roster | GST / Business identity verification |

---

## 🍃 Resource Categories & Traceability

1. **Medicinal Plants (*Jadibuti*)**:
   - High-potency Ayurvedic raw roots, leaves, and barks (*Ashwagandha, Giloy, Shatavari, Kalmegh*).
   - Rotationally harvested with comb/root preservation tags.
2. **Minor Forest Produce (MFP)**:
   - Multi-flora wild forest honey, sun-dried Mahua flowers, Tendu leaves, natural Lac, Chironji, Gum Karaya.
3. **Tribal Handicrafts**:
   - Handwoven bamboo storage baskets, cane furniture, Sabai grass mats, and dokra tribal crafts.
4. **Water & Community Resources**:
   - Clean stream water rights, inland aquaculture/fish stock, organic wild fertilizers.

### 🛡️ CFR Provenance & Trust Tag
Every listing contains an immutable **Trust & Provenance Tag**:
- **Gram Sabha Name & Compartment ID**: Pinpoints exact CFR forest ridge or compartment.
- **Harvesting Method**: Certified sustainable collection (e.g., wild comb nucleus untouched).
- **Verification Seal**: Verified by VanMitra team field validation.

---

## 🚚 Rural Delivery Partner Network

VanRozgar turns vehicle ownership in remote forested hamlets into a steady livelihood:
- **Registration**: Villagers register their two-wheeler, tempo, auto, or pickup truck with license and capacity details.
- **Verification**: Reviewed by the field team for safety, permit, and coverage area.
- **Job Board (*My Deliveries*)**: Once approved, partners view available nearby delivery runs with transparent upfront payout, weight, distance, pickup Gram Sabha, and buyer drop point.
- **Fairness Rules**: Unverified drivers cannot access delivery manifests; driver ratings are tracked independently of product quality ratings.

---

## ⚖️ Barter & Group Selling Mechanics

- **Interactive Barter Balance Meter**: When two forest communities swap resources (e.g., *Honey for Bamboo Baskets*), VanRozgar evaluates market values of both sides and visually displays fairness so both councils achieve equity.
- **Group / Pooled Selling**: Enables multiple marginal collectors in a village to pool small individual harvests into a single bulk commercial lot, unlocking wholesale bulk pricing while preserving per-collector payout shares.

---

## 💻 Tech Stack & Architecture

- **Core Framework**: [React 19](https://react.dev/) + [TypeScript 5](https://www.typescriptlang.org/)
- **Bundler & Tooling**: [Vite 6](https://vite.dev/)
- **Styling**: [Vanilla Tailwind CSS v4](https://tailwindcss.com/) with custom forest brand design tokens
- **Animations**: [Motion (framer-motion v12)](https://motion.dev/) for smooth layout transitions, interactive dials, and parallax
- **Icons**: [Lucide React](https://lucide.dev/)
- **Internationalization (i18n)**: Native tri-lingual dictionary supporting **English**, **हिन्दी (Hindi)**, and **मराठी (Marathi)** with persistent state
- **Design System Tokens**:
  - `brand-primary`: `#1A4331` (Deep Forest Green)
  - `brand-secondary`: `#2D765C` (Canopy Green)
  - `accent-primary`: `#FF8D20` (Sunrise Orange - Action CTAs)
  - `dark-bg`: `#10261B` (Night Woods)
  - `light-bg`: `#F4F7F5` (Morning Mist)

---

## 📁 Project Directory Structure

```text
vanrozgar_website/
├── public/
│   ├── assets/              # Design references and mock imagery
│   └── brand/               # Brand logos and assets
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── Header.tsx       # Glassmorphism header with language/theme switches
│   │   ├── WindowTabBar.tsx # Sticky tab navigator across ecosystem windows
│   │   ├── ListingDetailModal.tsx # Detailed resource drawer with buy/barter actions
│   │   ├── ResourceIcon.tsx # Dynamic SVG icon representations
│   │   └── preloader/       # Cinematic VanMitra ecosystem intro sequence
│   ├── context/
│   │   └── MarketplaceContext.tsx # Central in-memory state for listings, orders, and roles
│   ├── data/
│   │   └── mockData.ts      # Comprehensive mock listings, Gram Sabhas, and delivery runs
│   ├── demo/
│   │   └── DemoAppModal.tsx # Interactive mobile-frame prototype of all 3 portals
│   ├── i18n/
│   │   └── translations.ts  # English, Hindi, and Marathi translation matrices
│   ├── sections/            # Marketing and showcase viewports
│   │   ├── HeroSection.tsx  # Hero banner with live delivery network animation
│   │   ├── OverviewHubSection.tsx # Strategic hub linking all modules
│   │   ├── EcosystemSection.tsx   # VanMitra-AI parent integration architecture
│   │   ├── ResourceExplorerSection.tsx # Real-time filtered search & sorting
│   │   ├── HowItWorksSection.tsx  # 6-step lifecycle from CFR harvest to payment
│   │   ├── PortalsComparisonSection.tsx # Interactive 3-way portal demonstration
│   │   ├── BarterAndFairPriceSection.tsx # Live barter balance simulator
│   │   ├── GroupSellingSection.tsx # Animated harvest pooling visualization
│   │   ├── DeliveryJourneySection.tsx # Step-by-step driver recruitment flow
│   │   ├── ImpactSection.tsx      # Transparent social & economic metrics
│   │   ├── TrustSustainabilitySection.tsx # CFR governance & compliance rules
│   │   └── OpenDecisionsSection.tsx # Transparent documentation of unresolved product decisions
│   ├── types/               # Strict TypeScript definitions
│   ├── App.tsx              # Application root & window router
│   ├── index.css            # Tailwind directives and typography rules
│   └── main.tsx             # DOM initialization
├── package.json
├── tsconfig.json
└── vite.config.ts
```

---

## 🚀 Getting Started & Local Development

### Prerequisites
- [Node.js](https://nodejs.org/) (version **18.x**, **20.x**, or **22.x** recommended)
- `npm` (version 9+ or 10+)

### 1. Clone the Repository
```bash
git clone https://github.com/Sinusoidal-Meow/VanRozgar.git
cd VanRozgar
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Configure Environment Variables (Optional)
If using AI Studio / Gemini conversational features:
```bash
cp .env.example .env.local
```
Add your API key inside `.env.local`:
```env
GEMINI_API_KEY="your_api_key_here"
```

### 4. Run Development Server
```bash
npm run dev
```
Open your browser and navigate to:
```
http://localhost:3000/
```

### 5. Production Build & Preview
```bash
npm run build
npm run preview
```

---

## 🔍 Open Product Decisions (Roadmap)

In accordance with transparent public governance standards, the following aspects remain intentionally configurable:
1. **Settlement Architecture**: Evaluating UPI Escrow vs. Gram Sabha bank transfer vs. Cash on Delivery (COD) upon physical verification.
2. **Delivery Wage Formulation**: Evaluating fixed base fare + distance model vs. weight-slab negotiated tenders per trip.
3. **Cross-State CFR Transit**: Integration with state forest department Transit Pass (TP) digital waivers for commercial buyers.
4. **Low-Connectivity Offline Sync**: SMS / USSD fallback integration for deep-forest Gram Sabha secretaries with intermittent 2G coverage.

---

## 📄 License & Attribution

This project is licensed under the **Apache-2.0 License**.

Developed as an integral rural livelihood module within the **VanMitra** (वनमित्र) digital forest governance ecosystem.

---
## Integration note
This folder is a copy of Kaushal's website (source: `Sinusoidal-Meow/VanRozgar-Module`, branch `main`), brought into the
VanRozgar monorepo on the `kaushal-website-integration` branch. The AI Studio artefact folder (`.aistudio/`) was left out.
Wiring to the app (buy button -> APK download -> item code) is listed in `docs/tasks.md`.
