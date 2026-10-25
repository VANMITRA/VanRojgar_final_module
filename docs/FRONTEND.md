# Frontend: what exists and what changes

**Updated:** 26 Oct 2026. Two front ends: the Android app and the website.
Older notes: `docs/vanrozgar/FRONTEND_ARCHITECTURE.md`. This file is the short, current version.

## 1. The Android app (`app/`)

- **Stack:** Flutter, Riverpod, GoRouter, Dio. The livelihood feature (`app/lib/features/livelihood/`) keeps its own inner navigator and is mounted inside the main app.
- **Theme:** VanMitra colours and fonts (`core/theme`); Noto Sans Devanagari is bundled so Marathi and Hindi never clip.
- **Languages:** English first, then Marathi and Hindi (ARB files in `app/lib/l10n`). Marathi and Hindi text is a machine draft until a native reader checks it.
- **Sign-in:** phone + 6-digit PIN.
- **Screens by area:** auth, listings, search, trade (requests, orders), barter, delivery, messages, profile, Gram Sabha, villager/farmer, buyer, livelihood (hub, profile, report, idea detail, map, schemes, PDF).
- **Map:** OpenStreetMap tiles via `flutter_map`; your plot, a 2 to 10 km circle, resource pins, marketplace listings, a pin you can move. Needs internet.
- **PDF:** the report as a PDF in English, Marathi or Hindi.
- **Tests:** 153 pass; 4 need a live server and are skipped.

### What changes
| Change | Detail |
|---|---|
| Four roles | Farmer, Buyer, Gram Sabha, CFR holder. Sign-up has the role choice (CFR holder picked by the person for now). |
| Livelihood only for CFR holders | Shown in the CFR holder's navigation and profile ("My livelihood report"). Removed from Gram Sabha. CFR holders also get every Farmer screen. |
| Payment step | At checkout: choose **UPI** or **Cash on delivery**. UPI opens the buyer's UPI app, then asks for the payment reference. A plain note says the seller confirms receipt. |
| Search by item code | The search box accepts an item code from the website and opens that item. |
| Order screens | Show the payment method and its state (awaiting payment, payment reported, payment confirmed, cash received). |

## 2. The website (`website/`)

- **Stack:** React 19, Vite 6, Tailwind 4, Motion (animation). Built by Kaushal. It started in Google AI Studio and uses mock data.
- **Sections today:** hero, how it works, ecosystem, portals compared, resource explorer, barter and fair price, group selling, delivery journey, trust, impact, footer.
- **Not in it yet:** the "live hero dashboard", the app download page, item codes.

### What changes
| Change | Detail |
|---|---|
| Hero landing page | Live project overview: what it is, how it works, what has been achieved. |
| Item codes | Each product shows a copyable item code. |
| Buy button | Opens an App download page: APK link, login steps, the item code. No payment on the site. |
| Real or labelled data | Real marketplace data if the public endpoint works; else mock data labelled **Sample**. |
| Clean up | Remove the AI Studio key use; build must contain no secret. |
| Deploy | Vercel. |

## 3. How the pieces connect

```
Landing page -> website (browse) -> "Buy" -> App download page
   -> app: sign up / log in -> search the item code -> order -> pay (UPI or cash)
CFR holder -> Profile -> My livelihood report -> map, ideas, PDF -> list a product (prefilled)
```

## 4. Frontend tasks, in order

1. Roles and navigation in the app (Soham).
2. Payment step and order states in the app (Ayush).
3. Search by item code in the app (Ayush).
4. Landing page, item codes, download page on the website (Kaushal).
5. Join website to app: the download link and the code flow (Soham).
6. Phone test of every role and every language (Soham).

## 5. Checks

App: `flutter analyze`, `flutter test`. Website: `npm run lint`, `npm run build`. All must pass before a merge to `integration`.
