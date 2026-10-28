# PHASE 7 PROMPT: ORDERS (requests, approvals, payment steps) for the VanMitra app

You are working in this folder only. Read this whole file before you touch anything, then follow it step by step.

## 0. Who and what

VanMitra (Hindi and Marathi: वनमित्र) is a shop app for forest produce from Community Forest Rights (CFR) villages in Nashik, India. Sellers are Gram Sabhas and
CFR holders. Buyers are wholesalers and businesses. It is a Flutter Android app. We are building a NEW UI as a demo inside `app/lib/ui_v2/`
(run with `flutter run -t lib/ui_v2/main_demo.dart`). All data in the demo is SAMPLE data (made up, shown as "Sample"). Nothing talks to a server yet.
Three languages: English, Hindi, Marathi (never mixed on one screen, never auto-changed). The demo is shown to people soon, so "no crashes, no overflow" matters more than extra features.

Phase 8 (the Sell page) and Phase 9 (the Profile page) are built in parallel by other engineers, and Phase 6 (cart and checkout) by another one. Your work will be merged with theirs by the main engineer. That is why the file rules in section 1 are strict.
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
   - You OWN and may create or edit: `app/lib/ui_v2/shell/orders/` (new folder, all your pages), `app/lib/ui_v2/models/order_models.dart` (new),
     `app/lib/ui_v2/providers/orders_providers.dart` (new), `app/lib/ui_v2/l10n/orders_strings.dart` (new),
     `app/lib/ui_v2/widgets/orders/` (new folder), and your own tests `app/test/ui_v2_orders_*.dart`.
   - You MAY make ONE small edit in `app/lib/ui_v2/shell/app_shell.dart`: (a) change the builder of the existing `/orders` route from
     `OrdersPlaceholderPage()` to your `OrdersPage()` (and add the import); (b) add the top-level route `/orders/:id` (order detail) in a block marked
     `// PHASE 7 ROUTES`, next to the existing `/cart` route. Nothing else in that file. Do NOT edit `shell/placeholder_pages.dart` (the other engineers
     need it; it will be cleaned at merge time).
   - You MUST NOT edit any other existing file (for example `providers/catalog_providers.dart`, `models/catalog_models.dart`, `shell/product_page.dart`, `shell/cart_page.dart`, `widgets/product_card.dart`,
     `widgets/quantity_stepper.dart`, `shell/auth_pages.dart`, `l10n/app_strings.dart`, `l10n/shop_extra_strings.dart`, `data/shop_repository.dart`, `data/villages.dart`, `theme/*`, `assets/*`,
     `pubspec.yaml`, and the existing tests). If you need a change in such a file, DO NOT edit it: write the request into `CHANGE_REQUESTS.md` (file, what, why) and work around it inside your own files.
6. New strings: your own file with an extension on `AppStrings` (same style as `l10n/shop_extra_strings.dart`: a private `_t(en, hi, mr)` helper switching on `language`). EVERY new getter or method name must
   start with `od` (so it can never clash with the other engineers' strings). The Hindi and Marathi texts are machine drafts (say so in a comment). In Hindi and Marathi no English word may be visible
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

## 5. THE FEATURE: Phase 7, ORDERS (requests, approvals, payment steps)

### 5.1 What an order is
The shop server turns a checkout into ONE REQUEST PER SELLER LISTING (see `docs/BACKEND.md` section 10 and section 3 "Payments"; you may READ the
server code under `server/src` in this folder to copy the real status names, never run it). Each seller approves, rejects or counters (another quantity
or price) on their own, and is paid on their own. Payment is `upi` (paid by the buyer AFTER the seller approves: the buyer reports the payment with a
reference, the seller confirms) or `cod` (cash on receipt). Delivery preference is `pickup` or `delivery` (with a drop village).
Mirror the real status flow as closely as the docs and server code show it (pending -> approved / rejected / countered -> payment steps -> completed,
and cancelled by the buyer while pending). Show each status as a chip with plain words in all 3 languages ("Waiting for the seller", "Approved",
"Seller sent another offer", "Rejected", "Payment reported", "Payment confirmed", "Completed", "Cancelled" - adjust to the real names you find).

### 5.2 Your own data layer (Phase 6 is not in your folder, so do NOT depend on it)
Another engineer builds the checkout and creates its own request list. You must NOT use or recreate his provider. Instead create, in YOUR files:
- `models/order_models.dart`: an immutable `OrderView` (id, sellerId, sellerName, sellerType, buyerName, buyerPhone, lines (productCode, title en/hi/mr, unit en/hi/mr,
  quantity, unitPricePaise), totalPaise (computed from lines), deliveryPref, paymentMethod, dropVillageId?, note, status, a list of status events with DateTime,
  counter offer (new quantity and/or unit price, optional), paymentReference?). Money = integer paise.
- `providers/orders_providers.dart`: `ordersProvider` = `StateProvider<List<OrderView>>` seeded with 6 to 8 SAMPLE orders in different statuses (all labelled
  "Sample", sample buyer and seller names like "Sample Buyer", "Sample Gram Sabha 1"; use real product codes/titles from `assets/catalog/sample_catalog.json`);
  plus pure functions for every state change (approve, reject with reason, counter, accept counter, decline counter, cancel, report payment, confirm payment,
  mark completed) that return a new `OrderView` or throw/return an error when the move is not allowed in the current status. Unit-test every one of them.
- A single clearly named function `addOrders(WidgetRef/Ref, List<OrderView>)` so that, at merge time, the checkout can append real requests. Keep it tiny.
- The demo identity: a signed-in `buyer` (see `authUserProvider`) sees the orders whose `buyerPhone` equals their phone PLUS all sample orders marked as the "demo buyer";
  a signed-in `gramsabha` or `cfrholder` is treated as seller `seller-1` and sees the incoming requests of `seller-1`. Put this rule in ONE documented function.

### 5.3 The Orders tab (`shell/orders/orders_page.dart`, route `/orders`, inside the existing shell)
- Guest: a friendly card "Sign in to see your orders" with two buttons "Sign in" / "Create account" (`context.push('/signin')`, `/signup`). Nothing else.
- Buyer: two segments "Active" and "Past" (a simple segmented control, not a TabBar that scrolls). Cards: seller, product summary ("Mango x 5 kg + 2 more"),
  total in orange, status chip, "Sample" badge, date. Empty states in words. Tap opens `/orders/:id`.
- Seller (Gram Sabha / CFR holder): segments "New requests", "In progress", "Done". Same cards but with the buyer name. Tap opens `/orders/:id`.

### 5.4 Order detail (`shell/orders/order_detail_page.dart`, route `/orders/:id`, full screen, own back arrow)
- Header: status chip, id, date. Seller (buyer view) or buyer (seller view). Lines with picture (`Image.asset` with an `errorBuilder`), quantity, unit price, line total.
  Total. Delivery or pickup (+ village name from `data/villages.dart`), payment method in words, the note.
- A vertical status timeline built from the events.
- Actions, shown only when allowed (use the pure functions): Buyer: "Cancel request" (asks to confirm) while pending; when the seller countered "Accept offer" / "Decline offer";
  for UPI after approval "I have paid" opens a sheet asking for a payment reference (free text, 6 to 30 characters; never show a UPI ID, QR code or amount-to-pay link).
  Seller: "Approve", "Reject" (sheet with a reason, required), "Send another offer" (sheet: quantity within the stock and at least the minimum order, price in rupees at most
  the MRP; use the same rules as the Sell page: price must not be above MRP), "Confirm payment received" after a reported UPI payment, "Mark completed".
- Every confirmation is a bottom sheet or dialog on a `Material` surface; after an action the page shows the new status at once (state in `ordersProvider`).
- A small muted "Demo: nothing is sent to a server yet." line (reuse `strings.demoNote`).

## 6. Tests you must write (new files `test/ui_v2_orders_*.dart`, copy the style of `test/ui_v2_product_page_test.dart`)

Use small inline JSON data or inline objects; never read asset files in tests (exception: where a feature explicitly needs the asset file, test the parser on a tiny inline map instead). Helpers pattern
(`_app`, `_tall`, `_open`): set `uiV2LandingSeen.value = true`, `uiV2Router.go(path)`, `pumpWidget(SizedBox())` then `pumpWidget(app)` so provider overrides are not reused; wrap `MediaQuery` in `builder` with
`MediaQuery.of(context).copyWith(textScaler: ...)` (never a fresh `MediaQueryData`). Cover:
1. The pure state-change functions: allowed moves, refused moves, counter rules, totals.
2. Guest sees the sign-in card; buyer sees their orders in Active/Past; seller sees New/In progress/Done; empty states.
3. Detail page: the right actions appear for each status and role; cancel asks first; accept/decline offer; "I have paid" needs a reference of 6 to 30 characters.
4. Seller actions: approve, reject needs a reason, counter validates quantity/price, confirm payment, complete. Status chip and timeline update.
5. Hindi and Marathi: no English on the Orders tab, the detail page and the sheets (except "UPI").
6. No overflow (`expect(tester.takeException(), isNull)`) on `/orders` (3 roles) and `/orders/:id` (3 statuses) and the sheets, at 320x568, 360x800 and 430x932,
   light and dark, English/Hindi/Marathi, `textScaler` 1.5.
After you finish, ALL tests (the 71 existing ones plus yours) must pass and `flutter analyze lib/ui_v2 test` must say "No issues found".

## 7. Order of work

1. Step 0. 2. Strings file + models + providers + pure functions with their unit tests (commit). 3. The screens one by one, each with its tests (commit after each). 4. The one small `app_shell.dart` edit.
5. All tests, analyze, fix. 6. Final commit and the report.

## 8. Deliverables

- Your commits in this folder's local git (`git log` shows them). Do not rewrite or delete the baseline commit (`23df508`).
- `PHASE7_REPORT.md` in this folder: (a) the list of files you created or changed, (b) design decisions you made, (c) things you could NOT do or that need the main engineer (copy the same text into `CHANGE_REQUESTS.md`),
  (d) the exact output summary of `flutter analyze` and `flutter test` that you really ran (never claim what you did not run), (e) a short list of what to check by eye on a real phone (you cannot see a screen).
- Never say "verified" or "tested on a phone". You can only run analyze and the widget tests.
