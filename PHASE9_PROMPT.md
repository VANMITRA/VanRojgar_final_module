# PHASE 9 PROMPT: PROFILE (account, settings, About, Credits, Privacy, the older features) for the VanMitra app

You are working in this folder only. Read this whole file before you touch anything, then follow it step by step.

## 0. Who and what

VanMitra (Hindi and Marathi: वनमित्र) is a shop app for forest produce from Community Forest Rights (CFR) villages in Nashik, India. Sellers are Gram Sabhas and
CFR holders. Buyers are wholesalers and businesses. It is a Flutter Android app. We are building a NEW UI as a demo inside `app/lib/ui_v2/`
(run with `flutter run -t lib/ui_v2/main_demo.dart`). All data in the demo is SAMPLE data (made up, shown as "Sample"). Nothing talks to a server yet.
Three languages: English, Hindi, Marathi (never mixed on one screen, never auto-changed). The demo is shown to people soon, so "no crashes, no overflow" matters more than extra features.

Phase 7 (Orders) and Phase 8 (the Sell page) are built in parallel by other engineers, and Phase 6 (cart and checkout) by another one. Your work will be merged with theirs by the main engineer. That is why the file rules in section 1 are strict.
The app name is VanMitra / वनमित्र. Never write the old name (VanRozgar, वनरोजगार) in anything a user can see, in your strings, comments or tests. CODE names that contain `VanRozgar`
(`VanRozgarTokens`, `VanRozgarColorTokens`, `VanRozgarTheme`, the package `vanrozgar`, files `van_rozgar_*.dart`) stay as they are: do not rename them.

## 1. Rules (read carefully)

1. Work ONLY inside this folder. Do not read, open, list or change anything outside it. This folder has NO git remote: never add one, never push. You MAY use `git add` and `git commit`
   here to save your work (small commits, clear messages). Never `git add -A` at the folder root; add your own paths.
2. Do not use the network. Do not look for, open, print or create `.env`, keys, tokens, passwords, keystores or any secret.
3. Commands you may run (inside `app/`): `flutter pub get`, `flutter analyze`, `flutter test`. Do NOT run `flutter build`, do NOT touch anything under `app/android`, `app/ios`, `app/web`, and do NOT edit
   `app/pubspec.yaml` (no new packages, no new asset folders; the assets you need already exist). Allowed packages: only those already in pubspec.
4. Anything made up is labelled "Sample". Never invent claims: no ratings, no "verified", "organic", "free", "fast", "guaranteed", no delivery times, no delivery fees, no helplines, no discounts that are
   not in the data. Never print real-looking UPI IDs, phone numbers of real people or links.
5. FILE OWNERSHIP (very important, to avoid merge conflicts):
   - You OWN and may create or edit: `app/lib/ui_v2/shell/profile/` (new folder, all your pages), `app/lib/ui_v2/providers/profile_providers.dart` (new),
     `app/lib/ui_v2/l10n/profile_strings.dart` (new), `app/lib/ui_v2/widgets/profile/` (new folder), your own tests `app/test/ui_v2_profile_*.dart`, and the existing
     `app/lib/ui_v2/widgets/profile_auth_card.dart` (you may change it, because only the Profile uses it).
   - You MAY make ONE small edit in `app/lib/ui_v2/shell/app_shell.dart`: (a) change the builder of the existing `/profile` route from `ProfilePlaceholderPage()` to your
     `ProfilePage()` (and add the import); (b) add the top-level routes `/about`, `/credits`, `/privacy` and `/more/:key` inside a block marked `// PHASE 9 ROUTES`, next to the existing
     `/cart` route. Nothing else in that file. Do NOT edit `shell/placeholder_pages.dart` (others need it; it will be cleaned at merge time).
   - You MUST NOT edit any other existing file (for example `providers/catalog_providers.dart`, `models/catalog_models.dart`, `shell/product_page.dart`, `shell/cart_page.dart`, `widgets/product_card.dart`,
     `widgets/quantity_stepper.dart`, `shell/auth_pages.dart`, `l10n/app_strings.dart`, `l10n/shop_extra_strings.dart`, `data/shop_repository.dart`, `data/villages.dart`, `theme/*`, `assets/*`,
     `pubspec.yaml`, and the existing tests). If you need a change in such a file, DO NOT edit it: write the request into `CHANGE_REQUESTS.md` (file, what, why) and work around it inside your own files.
6. New strings: your own file with an extension on `AppStrings` (same style as `l10n/shop_extra_strings.dart`: a private `_t(en, hi, mr)` helper switching on `language`). EVERY new getter or method name must
   start with `pf` (so it can never clash with the other engineers' strings). The Hindi and Marathi texts are machine drafts (say so in a comment). In Hindi and Marathi no English word may be visible
   (the word "UPI" and brand/place names are allowed). Reuse existing getters wherever they exist (read `l10n/app_strings.dart` and `l10n/shop_extra_strings.dart` first).
7. No debug prints, no commented-out code, no unused files. `flutter analyze` must report "No issues found".

## 2. Step 0: get your bearings (do this first)

1. `cd app`, run `flutter pub get`, `flutter analyze lib/ui_v2 test`, and the ui_v2 tests:
   `flutter test test/ui_v2_smoke_test.dart test/ui_v2_landing_geometry_test.dart test/ui_v2_shop_data_test.dart test/ui_v2_real_catalog_test.dart test/ui_v2_cart_product_auth_test.dart test/ui_v2_category_test.dart test/ui_v2_product_page_test.dart`
   All 71 tests must pass before you change anything. If they do not, STOP and write that in `CHANGE_REQUESTS.md`.
2. Read fully before designing: `lib/ui_v2/main_demo.dart`, `shell/app_shell.dart`, `shell/placeholder_pages.dart`, `shell/cart_page.dart`, `shell/product_page.dart`, `shell/auth_pages.dart`,
   `providers/catalog_providers.dart`, `models/catalog_models.dart`, `widgets/product_card.dart`, `widgets/quantity_stepper.dart`, `widgets/profile_auth_card.dart`, `widgets/app_background.dart`,
   `widgets/brand_logo.dart`, `theme/van_rozgar_tokens.dart`, `theme/van_rozgar_theme.dart`, `l10n/app_strings.dart`, `l10n/shop_extra_strings.dart`, `data/villages.dart`, `data/shop_repository.dart`,
   `assets/catalog/sample_catalog.json` (the first 2 products), and the tests `test/ui_v2_cart_product_auth_test.dart` and `test/ui_v2_product_page_test.dart` (they show the test style to copy).
3. Read `docs/BACKEND.md` (all of it, it is short).

## 3. What already exists (do not rebuild it)

- Shell: bottom navigation with 4 tabs (Home, Categories, Orders, Profile). There is NO cart tab. A floating "View cart" pill hovers above the bottom bar when the cart is not empty and opens `/cart`.
  Routes (go_router, `shell/app_shell.dart`): top-level `/landing`, `/cart`, `/checkout` (a temporary stub), `/product/:code`, `/signin`, `/signup`; shell tabs `/`, `/categories` (+ `/categories/:slug`), `/orders`
  and `/profile` (both still placeholders from `shell/placeholder_pages.dart`).
- Cart state in memory (`providers/catalog_providers.dart`): `cartQuantitiesProvider` (productCode -> quantity), `cartSellerChoiceProvider` (productCode -> listing id), `cartLinesProvider`, `lastAddedImageProvider`.
- Models (`models/catalog_models.dart`): `ShopProduct` (productCode, categorySlug, imageAsset, title en/hi/mr, unit en/hi/mr, notForEating, isIllustration, `listings`, `cheapestListing`,
  `localizedTitle(lang)`, `localizedUnit(lang)`) and `ShopListing` (id, sellerId, sellerName, sellerType 'gramsabha' | 'cfrholder', fulfilment 'pickup' | 'delivery' | 'both', pricePerUnitPaise, mrpPerUnitPaise,
  quantityTotal, quantitySold, quantityAvailable, minOrderQuantity, discountPaise, discountPercent, isSample). Money is always an integer in PAISE. `formatRupees(int paise)` formats it ("₹99", "₹1,20,000").
- Sample data: `assets/catalog/sample_catalog.json` (43 products, 29 with sellers, 6 sample sellers `seller-1` .. `seller-6`).
- Sign-in (demo, in memory): `authUserProvider` (`AuthUser` name, role 'buyer' | 'gramsabha' | 'cfrholder', phone, villageId; null = guest), `demoAccountsProvider`; pages `/signin` and `/signup`.
  `/signin?redirect=/some/path` returns there after success.
- `uiV2LanguageProvider` (default English) and `uiV2ThemeModeProvider` (default system).
- Village list: `data/villages.dart` -> `pilotVillages` (14 villages, `label(lang)`).
- Widgets to reuse: `QuantityStepper`, `AppBackground` (full-screen painted background), `BrandLogo`, `VanRozgarTokens.picturePanel`, the colours via
  `Theme.of(context).extension<VanRozgarColorTokens>()` (page, card, heading, bodyText, mutedText, primaryGreen, onPrimaryGreen, orange, chipBg, chipText, borders, outlinedControl).
  Orange is ONLY for prices and tiny highlights, never a button fill. Buttons are `tokens.primaryGreen` with `tokens.onPrimaryGreen` text.

## 4. Design rules for every screen you build (these decide whether it passes review)

- Look: match the existing screens (same cards: `tokens.card`, radius 16 * s, 1 dp `tokens.borders` border, no shadows on cards; same fonts and weights as `cart_page.dart` and `product_page.dart`).
  Scale factor `s = (MediaQuery.sizeOf(context).width / 360).clamp(0.85, 1.25)`.
- NO fixed heights for text content. Rows and cards take their height from their content (`IntrinsicHeight`, `Flexible`, `Expanded`, `maxLines` + `TextOverflow.ellipsis`, `FittedBox(fit: BoxFit.scaleDown)` for numbers
  and buttons). Everything must work with large system fonts (textScaler 1.5) and long Hindi / Marathi words.
- Anything that shows a touch ripple (ListTile, SwitchListTile, ChoiceChip, InkWell on a coloured Container) must sit on a `Material` (a plain `Container` with a `BoxDecoration` colour hides the ripple and Flutter asserts).
  Modal sheets: use `Material` as the sheet surface.
- Tap targets at least 48 x 48 dp. Give every interactive element a `Key` (tests need them) and `Semantics` labels where an icon has no text.
- Safe areas: use `SafeArea`; keep bottom bars above the gesture/navigation bar. Nothing important under the status bar or camera hole.
- No spinners. While data loads show an empty transparent area. Only simple animations (sheet slide, 200 ms fades).
- Both themes (light and dark) and all 3 languages must look right. Use the tokens, never hard-coded colours except white on pictures.
- Phones from 320 x 568 up to tablets 800 x 1280 must work, portrait only.

## 5. THE FEATURE: Phase 9, PROFILE (account, settings, About, Credits, Privacy, the older features)

### 5.1 The Profile tab (`shell/profile/profile_page.dart`, route `/profile`, inside the existing shell)
Top to bottom, one scrolling page:
1. Account card. Guest: the existing sign-in card (read `widgets/profile_auth_card.dart` and `shell/auth_pages.dart`: "Continue with Google" is first and says it is coming soon, then phone and PIN
   sign in, then "Create account"). Signed in: avatar circle with the initial, name, role in words (Buyer / Gram Sabha / CFR holder), phone, village name (from `data/villages.dart`), and a "Sign out" button
   that asks first.
2. "Settings": Language (three choices English / हिन्दी / मराठी, writes `uiV2LanguageProvider`; English is the default; the language never changes on its own), Appearance (System / Light / Dark,
   writes `uiV2ThemeModeProvider`). Use segmented controls or choice cards on a `Material`.
3. "My activity" (only when signed in): "My orders" (`context.go('/orders')`), and for a Gram Sabha or CFR holder "Sell on VanMitra" (`context.push('/sell')`; that page is built by another engineer
   and will exist after the merge: do not build it and do not add a stub route; in tests do not tap it).
4. "More": rows with an icon, a title and a chevron, 48 dp or taller, each opening a page:
   - "About VanMitra" `/about`, "Credits" `/credits`, "Privacy" `/privacy`.
   - The OLDER features of the app stay reachable from the new navigation. Look in `app/lib/features/` (about, barter, delivery, gramsabha, gramsabhas, livelihood, messages, profile, trade,
     villager) and `app/lib/l10n` and `docs/` to see what the old app offered. For each of these four entries create ONE simple page under `/more/:key` (keys: `messages`, `barter`, `delivery`,
     `livelihood`): the title, one or two honest plain sentences about what that part of the app does (take them from the old screens / docs; invent nothing), and a muted line
     "Opens in the full app" - these are entry points only; do NOT rebuild those features and do NOT import anything from `lib/features`. `livelihood` (the livelihood report) is shown ONLY to a CFR holder
     (the server's rule, `docs/BACKEND.md` section 2); `delivery` to everyone; `messages` and `barter` only when signed in.
5. Footer: "VanMitra" with the round logo (`widgets/brand_logo.dart`), the app version text "Demo version" (not a number you invent).

### 5.2 About, Credits, Privacy
- `/about`: what VanMitra is, in 4 to 6 short plain sentences, taken from `README.md`, `docs/` and `WHAT_WE_BUILT.md` in this folder (CFR villages of Nashik, forest produce, buyers meet Gram Sabhas and CFR
  holders directly, three languages). No invented numbers, no "verified/organic/fast/guaranteed".
- `/credits`: a readable version of `CREDITS.md` (pictures table etc.): what the pictures are and where they came from, grouped, each row a card. Read the file; keep the facts exactly; do not add claims.
- `/privacy`: a readable version of `docs/PRIVACY.md`: short sections with headings. Keep the facts exactly; do not add claims.
These three texts are long, so put the English text and the Hindi/Marathi machine drafts in `l10n/profile_strings.dart` (Hindi/Marathi are drafts: say so in a comment) and show a muted line in Hindi and Marathi
modes that the translation is a draft (in that language). Each page has a back arrow, the full-screen background (`AppBackground`) and works with large fonts.

### 5.3 State
`providers/profile_providers.dart` only if you need it (for example the sign-out confirmation). Sign out = `authUserProvider` to null (nothing else is stored). Language and theme providers already exist.

## 6. Tests you must write (new files `test/ui_v2_profile_*.dart`, copy the style of `test/ui_v2_product_page_test.dart`)

Use small inline JSON data or inline objects; never read asset files in tests (exception: where a feature explicitly needs the asset file, test the parser on a tiny inline map instead). Helpers pattern
(`_app`, `_tall`, `_open`): set `uiV2LandingSeen.value = true`, `uiV2Router.go(path)`, `pumpWidget(SizedBox())` then `pumpWidget(app)` so provider overrides are not reused; wrap `MediaQuery` in `builder` with
`MediaQuery.of(context).copyWith(textScaler: ...)` (never a fresh `MediaQueryData`). Cover:
1. Guest: the sign-in card with Google first; signed in (override `authUserProvider`): name, role words, phone, village; sign out asks first, then returns to the guest card.
2. Language: choosing हिन्दी and मराठी switches the whole Profile page; English stays the default; appearance choice writes the theme provider.
3. Rows by role: Buyer, Gram Sabha, CFR holder, guest (which rows show, which do not: Sell only for sellers, livelihood only for a CFR holder, messages/barter only when signed in).
4. `/about`, `/credits`, `/privacy`, `/more/<key>` open and have a back arrow; text comes from the strings file; unknown `/more/xyz` shows a friendly empty page, not an error.
5. Hindi and Marathi: no English on the Profile page and the new pages (except "UPI", "Google", brand and place names, and the word "Sample").
6. No overflow (`expect(tester.takeException(), isNull)`) on `/profile` (4 identities), `/about`, `/credits`, `/privacy`, `/more/messages`, at 320x568, 360x800 and 430x932, light and dark,
   English/Hindi/Marathi, `textScaler` 1.5.
After you finish, ALL tests (the 71 existing ones plus yours) must pass and `flutter analyze lib/ui_v2 test` must say "No issues found".

## 7. Order of work

1. Step 0. 2. Strings file + models + providers + pure functions with their unit tests (commit). 3. The screens one by one, each with its tests (commit after each). 4. The one small `app_shell.dart` edit.
5. All tests, analyze, fix. 6. Final commit and the report.

## 8. Deliverables

- Your commits in this folder's local git (`git log` shows them). Do not rewrite or delete the baseline commit (`23df508`).
- `PHASE9_REPORT.md` in this folder: (a) the list of files you created or changed, (b) design decisions you made, (c) things you could NOT do or that need the main engineer (copy the same text into `CHANGE_REQUESTS.md`),
  (d) the exact output summary of `flutter analyze` and `flutter test` that you really ran (never claim what you did not run), (e) a short list of what to check by eye on a real phone (you cannot see a screen).
- Never say "verified" or "tested on a phone". You can only run analyze and the widget tests.
