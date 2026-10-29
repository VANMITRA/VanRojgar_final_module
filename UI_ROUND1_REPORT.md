# UI Round 1 Report

## 1. Git Commits

- `0e61889` — `Task 1: Remove user-visible Sample and Demo text across EN, HI, and MR`
- `ee3d17d` — `Task 2: Pull headline words onto picture cards on Landing Slides 1 and 3`
- `6b247a2` — `Task 3: Fix Top Deals dark-mode contrast and add folder-tab shape`
- `ee91a5b` — `Task 4: Redesign Sign-in and Create-account pages with role cards, PIN toggle, and searchable village sheet`

---

## 2. Files Touched and Summary

### Localization (`app/lib/ui_v2/l10n/`)
- `app/lib/ui_v2/l10n/app_strings.dart` — Replaced user-facing `"Sample"` / `"Sample village"` / `"SAMPLE DEALS"` / `"Sample prices"` strings in English, Hindi, and Marathi with clean Nashik / CFR village copy and cleared `sampleBadge`.
- `app/lib/ui_v2/l10n/shop_extra_strings.dart` — Cleared `demoNote` across English, Hindi, and Marathi.
- `app/lib/ui_v2/l10n/checkout_strings.dart` — Updated `coSellerName` so seller names in Hindi and Marathi no longer prefix `sampleBadge`.
- `app/lib/ui_v2/l10n/orders_strings.dart` — Updated `odLocalizePartyName` and `odLocalizeNote` so `"Sample"` / `"नमूना"` / `"नमुना"` is stripped instead of rendered on order cards and detail pages.
- `app/lib/ui_v2/l10n/sell_strings.dart` — Removed `"(photo upload is not in this demo)"` from `slCatalogPhotoNote` in all three languages.
- `app/lib/ui_v2/l10n/profile_strings.dart` — Cleared `pfDemoVersion` (`"Demo version"`) and removed `"demo"` / `"sample"` wording from About, Credits, and More fallback copy across all three languages.

### Shell Pages (`app/lib/ui_v2/shell/`)
- `app/lib/ui_v2/shell/landing_page.dart` — Added per-slide, per-line horizontal pull fractions and highlighted-word font scaling (`1.14x` on Slide 1) in `_LandingSlideView` so pulled headline lines on Slides 1 and 3 overlap the picture card with outlined letters by at most `0.08 * W` while keeping Slide 2 unchanged.
- `app/lib/ui_v2/shell/auth_pages.dart` — Removed `demoNote` and redesigned `SignInPage` and `SignUpPage` with a round `BrandLogo` header, language chips, Google button first, icon-prefixed inputs, `+91 ` phone prefix, numeric keyboard for phone and PIN, show/hide PIN toggle buttons, 3 large role cards with icons and one-line descriptions from existing strings, a searchable village bottom sheet, and a sticky bottom submit bar on Create Account.
- `app/lib/ui_v2/shell/product_page.dart` — Removed the `sampleBadge` pill from the product image header while keeping the `Illustration` pill.
- `app/lib/ui_v2/shell/cart_page.dart` — Removed `· Sample village` from seller group headers and removed `sampleBadge` pills from cart item rows.
- `app/lib/ui_v2/shell/checkout/checkout_page.dart` — Removed the `demoNote` footer text widget.
- `app/lib/ui_v2/shell/checkout/checkout_done_page.dart` — Removed the `sampleBadge` status chip and `demoNote` footer text widget.
- `app/lib/ui_v2/shell/orders/order_detail_page.dart` — Removed the `sampleBadge` pill and `demoNote` text widget and added `Key('order_detail_timeline_card')` on the timeline card.
- `app/lib/ui_v2/shell/sell/sell_page.dart` — Removed the `demoNote` text widgets from the guest, buyer, and seller views.
- `app/lib/ui_v2/shell/sell/sell_form_page.dart` — Removed the `demoNote` text widget and used `strings.sellerGramSabha` as the preview fallback instead of `strings.sampleBadge`.
- `app/lib/ui_v2/shell/profile/profile_page.dart` — Removed the `"Demo version"` footer label so only `BrandLogo` and `VanMitra` (`strings.appNameNative`) appear.

### Widgets (`app/lib/ui_v2/widgets/`)
- `app/lib/ui_v2/widgets/home_top_deals_section.dart` — Fixed the dark-mode white-on-cream contrast bug using `tokens.primaryGreen`/`tokens.onPrimaryGreen` (selected strip) and `tokens.chipBg`/`tokens.chipText` (unselected tab) for `>= 4.5:1` contrast across all 4 combinations, and added `_FolderTabBorderPainter` for the rounded folder-tab shape that smoothly joins the panel below when selected.
- `app/lib/ui_v2/widgets/product_card.dart` — Removed the `sampleBadge` overlay pill and semantic label suffix while keeping the `Illustration` pill.
- `app/lib/ui_v2/widgets/checkout/change_seller_sheet.dart` — Removed `· Sample village` from seller option subtitles.
- `app/lib/ui_v2/widgets/orders/order_card.dart` — Removed the `sampleBadge` pill from order cards.
- `app/lib/ui_v2/widgets/sell/my_listing_card.dart` — Removed the `sampleBadge` pill from seller listing cards.

### Tests (`app/test/`) and Root Docs
- `app/test/ui_v2_no_sample_demo_test.dart` — Added widget tests asserting no visible text contains `"Sample"` or `"Demo"` (or Hindi/Marathi equivalents) across Home, Product, Cart, Checkout, Orders, Sell, and Profile in EN, HI, and MR.
- `app/test/ui_v2_landing_geometry_test.dart` — Added widget geometry tests for Slides 1 and 3 checking that pulled headline lines overlap the picture card, do not exceed `0.08 * W` overlap, stay inside screen bounds `[0, W]`, and keep subtitle/note clear of pictures across `320×568`, `360×800`, and `430×932` in EN, HI, MR, light and dark modes, at `textScaler: 1.5`.
- `app/test/ui_v2_top_deals_test.dart` — Added widget tests checking WCAG contrast `>= 4.5:1` across all 4 combinations (`selected/unselected × light/dark`), folder-tab connection with the panel below, and no overflow across 3 screen sizes, 3 languages, and `textScaler: 1.5`.
- `app/test/ui_v2_cart_product_auth_test.dart` — Updated existing expectations for Task 1 and added Task 4 tests for the show/hide PIN toggle, 3 role cards, and searchable village bottom sheet.
- `app/test/ui_v2_category_test.dart` — Updated empty-seller expectation from `"No sample sellers yet"` to `"No sellers yet"`.
- `app/test/ui_v2_checkout_unit_test.dart` — Updated `coSellerName` unit test expectations to match removal of the `"Sample"` prefix in HI/MR.
- `app/test/ui_v2_orders_test.dart` — Updated order card/detail tests after removing `sampleBadge` and `demoNote`.
- `app/test/ui_v2_sell_page_test.dart` — Updated `/sell` tests after removing `sampleBadge` and `demoNote`.
- `app/test/ui_v2_smoke_test.dart` — Updated Home smoke test expectations to assert `"Sample"` is absent and `"No sellers yet"` is shown for empty categories.
- `CHANGE_REQUESTS.md` — Recorded follow-up items in files outside the round-1 edit scope (`app/assets/catalog/sample_catalog.json` and `app/lib/ui_v2/providers/orders_providers.dart`).
- `UI_ROUND1_REPORT.md` — This report.

---

## 3. Output of `flutter analyze` and `flutter test`

### `flutter analyze --no-pub`
```text
Analyzing app...
No issues found! (ran in 86.2s)
```

### `flutter test --no-pub`
```text
01:25 +341 ~4: All tests passed!
```
- **341 tests passed**, **0 failed** (4 skipped legacy tests unchanged).

---

## 4. Items Recorded in `CHANGE_REQUESTS.md`

1. **`app/assets/catalog/sample_catalog.json`**:
   - Contains `"sampleBadge": "Sample"` and `"village": {"en": "Sample village", "hi": "नमूना गाँव", "mr": "नमुना गाव"}` in the JSON asset. The UI layer in `lib/ui_v2/` ignores these fields, and cleaning the JSON asset directly is recorded for a follow-up data pass.
2. **`app/lib/ui_v2/providers/orders_providers.dart`**:
   - Seeded order objects in `sampleSeedOrders` contain `"Sample "` in English `sellerName`, `buyerName`, and `note` strings. The UI localization helpers (`coSellerName`, `odLocalizePartyName`, `odLocalizeNote`) strip `"Sample "` before display, and removing the prefix directly in `orders_providers.dart` is recorded for a follow-up provider pass.

---

## 5. What Still Needs a Human Eye on a Real Device

Widget tests check layout geometry, bounding-box overlap math, contrast ratios, and overflow rules, but a human eye on a physical screen should still inspect:
1. **Landing Slides 1 and 3 headline-on-photo legibility**: How the `0.014 * d` page-colored outline halo around the pulled words (`"from the"` / `"forest"` on Slide 1, `"that stays"` / `"village"` on Slide 3, and their Hindi/Marathi counterparts) looks over the actual bamboo, mango, and basket photographs in both light and dark modes.
2. **Top Deals folder-tab curve and border join**: How the concave bottom fillets (`_FolderTabBorderPainter`) and open-bottom overlap of the active tab blend visually into the `top_deals_panel` card border across different device pixel ratios.
3. **Sign-in and Create-account visual balance and keyboard ergonomics**: How the round logo header, the 3 role cards, the searchable village bottom sheet when the soft keyboard opens, and the sticky bottom submit bar feel during one-handed use.

