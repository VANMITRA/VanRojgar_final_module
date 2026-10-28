# PHASE 8 PROMPT: SELL PAGE (a seller adds and manages listings) for the VanMitra app

You are working in this folder only. Read this whole file before you touch anything, then follow it step by step.

## 0. Who and what

VanMitra (Hindi and Marathi: वनमित्र) is a shop app for forest produce from Community Forest Rights (CFR) villages in Nashik, India. Sellers are Gram Sabhas and
CFR holders. Buyers are wholesalers and businesses. It is a Flutter Android app. We are building a NEW UI as a demo inside `app/lib/ui_v2/`
(run with `flutter run -t lib/ui_v2/main_demo.dart`). All data in the demo is SAMPLE data (made up, shown as "Sample"). Nothing talks to a server yet.
Three languages: English, Hindi, Marathi (never mixed on one screen, never auto-changed). The demo is shown to people soon, so "no crashes, no overflow" matters more than extra features.

Phase 7 (Orders) and Phase 9 (the Profile page) are built in parallel by other engineers, and Phase 6 (cart and checkout) by another one. Your work will be merged with theirs by the main engineer. That is why the file rules in section 1 are strict.
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
   - You OWN and may create or edit: `app/lib/ui_v2/shell/sell/` (new folder, all your pages), `app/lib/ui_v2/models/sell_models.dart` (new),
     `app/lib/ui_v2/data/sell_catalog.dart` (new), `app/lib/ui_v2/providers/sell_providers.dart` (new), `app/lib/ui_v2/l10n/sell_strings.dart` (new),
     `app/lib/ui_v2/widgets/sell/` (new folder), and your own tests `app/test/ui_v2_sell_*.dart`.
   - You MAY make ONE small edit in `app/lib/ui_v2/shell/app_shell.dart`: add the top-level routes `/sell`, `/sell/new` and `/sell/edit/:id` inside a block
     marked `// PHASE 8 ROUTES` (and the import), next to the existing `/cart` route. Nothing else in that file. The entry point into the Sell page is a tile in the
     Profile page, which another engineer (Phase 9) builds: it will simply `context.push('/sell')`. So `/sell` must work when opened directly.
   - You MUST NOT edit any other existing file (for example `providers/catalog_providers.dart`, `models/catalog_models.dart`, `shell/product_page.dart`, `shell/cart_page.dart`, `widgets/product_card.dart`,
     `widgets/quantity_stepper.dart`, `shell/auth_pages.dart`, `l10n/app_strings.dart`, `l10n/shop_extra_strings.dart`, `data/shop_repository.dart`, `data/villages.dart`, `theme/*`, `assets/*`,
     `pubspec.yaml`, and the existing tests). If you need a change in such a file, DO NOT edit it: write the request into `CHANGE_REQUESTS.md` (file, what, why) and work around it inside your own files.
6. New strings: your own file with an extension on `AppStrings` (same style as `l10n/shop_extra_strings.dart`: a private `_t(en, hi, mr)` helper switching on `language`). EVERY new getter or method name must
   start with `sl` (so it can never clash with the other engineers' strings). The Hindi and Marathi texts are machine drafts (say so in a comment). In Hindi and Marathi no English word may be visible
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

## 5. THE FEATURE: Phase 8, SELL PAGE (a seller adds and manages listings)

### 5.1 Who sells and what a listing is
Only a Gram Sabha or a CFR holder sells (`AuthUser.role` is `'gramsabha'` or `'cfrholder'`); a buyer or a guest must never see the forms. Read `docs/BACKEND.md`
section 10 (every listing carries `mrpPerUnitPaise`, `discountPaise`, `discountPercent`, `quantityTotal`, `quantitySold`, `minOrderQuantity`; "The seller sets the MRP and the
selling price" and the rule about the selling price) and, read-only, the listing code under `server/src` in this folder to copy the real validation rules. A listing = a product
from the catalog + a quantity + a unit (the product's own unit) + MRP + selling price + minimum order + how it is handed over (`pickup`, `delivery` or `both`).
Money is an integer in PAISE in code; the seller types RUPEES in the form.

### 5.2 Data layer (all in your own files)
- `data/sell_catalog.dart`: loads EVERY product of `assets/catalog/sample_catalog.json` (all 43, including those without sellers) with `rootBundle`, reusing `ShopProduct.fromJson`
  or a tiny own parser if the model does not fit (look at how `data/shop_repository.dart` loads it; do not edit that file). Expose `sellCatalogProvider` (FutureProvider).
- `models/sell_models.dart`: immutable `MyListing` (id, productCode, quantityTotal, quantitySold, mrpPaise, pricePaise, minOrderQuantity, fulfilment, status 'active'|'paused', createdAt).
- `providers/sell_providers.dart`: `myListingsProvider` = `StateProvider<List<MyListing>>` seeded with 3 SAMPLE listings (labelled "Sample"); pure functions `validateListing(...)`
  (returns a list of field errors), `createListing`, `updateListing`, `pauseListing`, `resumeListing`, `removeListing`, and a `ListingDraft` class kept in a provider so a half-filled
  form survives going back. Unit-test all pure functions (price above MRP, zero quantity, minimum order above quantity, quantity below what is already sold, etc.).
- A single tiny function `myListingsAsShopListings(...)` is NOT needed. Do not touch the shop providers; at merge time the main engineer connects the two.

### 5.3 Screens
- `/sell` (My listings): back arrow, title, a green "Add a listing" button. If role is not a seller: a clear message "Selling is for Gram Sabhas and CFR holders" with
  "Sign in" / "Create account" (guest) or just the message (buyer). For sellers: cards per listing (picture from the catalog, title, price in orange with the crossed-out MRP,
  "N kg left", "N sold", status chip Active/Paused, min order, how it is handed over, "Sample" badge on sample ones) with the actions "Edit", "Pause"/"Resume", "Remove" (asks first).
  Empty state with the "Add a listing" button.
- `/sell/new` and `/sell/edit/:id`: one scrolling form. Step by step in one page: (1) "Choose the product": a search box + a list of the catalog products (picture, title in the
  current language, category label); when editing the product is fixed and shown read-only. (2) "Quantity" (number, unit shown from the product, whole numbers). (3) "MRP per unit"
  and "Your price per unit" in rupees (decimal with up to 2 digits allowed), with a live line "Discount: N%" ONLY when price < MRP, error when price > MRP. (4) "Minimum order"
  (at least 1, at most the quantity). (5) "How can buyers get it?": three choice cards Pickup / Delivery / Both. (6) A live preview card that looks exactly like the shop's product
  card (reuse `widgets/product_card.dart` if its constructor allows it, otherwise a small own copy). (7) A green "Publish listing" button (disabled look is not needed: show errors
  under each field on press). After publishing go back to `/sell` and show the new card at the top. Keep the draft in the provider so going back and returning keeps the input.
- Nothing is sent to a server: a muted "Demo: nothing is sent to a server yet." (reuse `strings.demoNote`).
- No photo upload (there is no real upload yet): the picture is always the catalog picture of the product; say so in one muted line.

## 6. Tests you must write (new files `test/ui_v2_sell_*.dart`, copy the style of `test/ui_v2_product_page_test.dart`)

Use small inline JSON data or inline objects; never read asset files in tests (exception: where a feature explicitly needs the asset file, test the parser on a tiny inline map instead). Helpers pattern
(`_app`, `_tall`, `_open`): set `uiV2LandingSeen.value = true`, `uiV2Router.go(path)`, `pumpWidget(SizedBox())` then `pumpWidget(app)` so provider overrides are not reused; wrap `MediaQuery` in `builder` with
`MediaQuery.of(context).copyWith(textScaler: ...)` (never a fresh `MediaQueryData`). Cover:
1. Pure functions: validation rules, create/update/pause/resume/remove, draft survival.
2. Guest and buyer see the right message and no form; seller sees the list; empty state.
3. Form: product search and choice, errors for each rule (price above MRP, quantity 0, minimum order above quantity), the live discount line only when price < MRP, the three
   hand-over choices, publish adds the card at the top, edit changes it, pause/resume changes the chip, remove asks first.
4. Hindi and Marathi: no English on `/sell`, the form and the dialogs (except unit symbols and brand/place names).
5. No overflow (`expect(tester.takeException(), isNull)`) on `/sell` (empty and with listings), `/sell/new` (also with all errors showing) and the dialogs, at 320x568, 360x800 and 430x932,
   light and dark, English/Hindi/Marathi, `textScaler` 1.5.
After you finish, ALL tests (the 71 existing ones plus yours) must pass and `flutter analyze lib/ui_v2 test` must say "No issues found".

## 7. Order of work

1. Step 0. 2. Strings file + models + providers + pure functions with their unit tests (commit). 3. The screens one by one, each with its tests (commit after each). 4. The one small `app_shell.dart` edit.
5. All tests, analyze, fix. 6. Final commit and the report.

## 8. Deliverables

- Your commits in this folder's local git (`git log` shows them). Do not rewrite or delete the baseline commit (`23df508`).
- `PHASE8_REPORT.md` in this folder: (a) the list of files you created or changed, (b) design decisions you made, (c) things you could NOT do or that need the main engineer (copy the same text into `CHANGE_REQUESTS.md`),
  (d) the exact output summary of `flutter analyze` and `flutter test` that you really ran (never claim what you did not run), (e) a short list of what to check by eye on a real phone (you cannot see a screen).
- Never say "verified" or "tested on a phone". You can only run analyze and the widget tests.
