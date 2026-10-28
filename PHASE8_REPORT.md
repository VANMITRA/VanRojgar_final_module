# PHASE 8 REPORT: Sell Page (`/sell`, `/sell/new`, `/sell/edit/:id`) for VanMitra

## (a) Files Created or Changed

### Created Files
- `app/lib/ui_v2/l10n/sell_strings.dart` — `SellStrings` extension on `AppStrings` with all `sl*` getters/methods in English, Hindi, and Marathi (machine drafts with zero English words in Hindi and Marathi).
- `app/lib/ui_v2/models/sell_models.dart` — Immutable `MyListing` model (`id`, `productCode`, `quantityTotal`, `quantitySold`, `mrpPaise`, `pricePaise`, `minOrderQuantity`, `fulfilment`, `status`, `createdAt`, `isSample`) and computed stock/discount getters.
- `app/lib/ui_v2/data/sell_catalog.dart` — `parseSellCatalogMap`, `loadSellCatalogAsset`, and `sellCatalogProvider` loading all 43 products from `assets/catalog/sample_catalog.json` (including products without existing sellers).
- `app/lib/ui_v2/providers/sell_providers.dart` — `ListingField`, `ListingFieldError`, `ListingDraft`, rupee/paise parsing and formatting helpers (`parseRupeesToPaise`, `parseWholeNumber`, `formatPaiseForInput`, `liveDiscountPercent`), pure functions (`validateListing`, `validateListingDraft`, `createListing`, `updateListing`, `pauseListing`, `resumeListing`, `removeListing`), `initialSampleMyListings` (3 sample listings marked `isSample: true`), `myListingsProvider`, and `listingDraftProvider`.
- `app/lib/ui_v2/widgets/sell/my_listing_card.dart` — `MyListingCard` displaying a seller's listing on `/sell` with catalog picture, Active/Paused status chip, Sample badge, orange price, crossed-out MRP, stock left/sold, minimum order, hand-over mode, and Edit / Pause-Resume / Remove actions.
- `app/lib/ui_v2/widgets/sell/sell_preview_card.dart` — `SellPreviewCard` reusing `ProductCard` (wrapped in `IgnorePointer`) to show a live shop preview of the listing being created or edited.
- `app/lib/ui_v2/shell/sell/sell_page.dart` — `SellPage` (`/sell`), `SellRoleGateView` (role gate for guests and buyers), empty state view, and the remove confirmation `AlertDialog`.
- `app/lib/ui_v2/shell/sell/sell_form_page.dart` — `SellFormPage` (`/sell/new` and `/sell/edit/:id`) implementing the 7-step scrolling form with draft persistence in `listingDraftProvider`.
- `app/test/ui_v2_sell_unit_test.dart` — 14 unit tests covering `parseSellCatalogMap`, rupee/paise conversion, `liveDiscountPercent`, `validateListing`, `createListing`/`updateListing`/`pauseListing`/`resumeListing`/`removeListing`, `listingDraftProvider`, and checking that all `sl*` Hindi and Marathi strings contain no Latin letters.
- `app/test/ui_v2_sell_page_test.dart` — 8 widget test suites covering `/sell` role gating (guest, buyer, Gram Sabha, CFR holder), empty state, Pause/Resume status toggling, Remove confirmation dialog, Hindi/Marathi text check, and multi-size/multi-theme/multi-language layout checks at `textScaler: 1.5`.
- `app/test/ui_v2_sell_form_test.dart` — 7 widget test suites covering `/sell/new` product search and selection, field error messages, live discount line only when `price < MRP`, draft survival across back navigation, publishing to top of `/sell`, `/sell/edit/:id` fixed product and `quantity >= quantitySold` rule, Hindi/Marathi text check, and multi-size/multi-theme/multi-language layout checks at `textScaler: 1.5` with all validation errors visible.
- `CHANGE_REQUESTS.md` — Integration notes for the main engineer.
- `PHASE8_REPORT.md` — This report.

### Changed Files
- `app/lib/ui_v2/shell/app_shell.dart` — Added `sell/sell_form_page.dart` and `sell/sell_page.dart` imports and the `// PHASE 8 ROUTES` block registering `/sell`, `/sell/new`, and `/sell/edit/:id` next to `/cart`.

---

## (b) Design Decisions Made

1. **Money & Validation Parity with Backend:**
   - All monetary values in `MyListing` and `validateListing` are integer paise (`mrpPaise`, `pricePaise`), while sellers enter rupees (with up to 2 decimal places) in the form, parsed without floating-point rounding drift via `parseRupeesToPaise`.
   - Validation rules in `validateListing` mirror `server/src/validators/listing.schema.js` and `server/src/services/listing.service.js`: a product is required, `quantityTotal > 0` and `quantityTotal >= quantitySold`, `mrpPaise > 0`, `pricePaise > 0`, `pricePaise <= mrpPaise`, `minOrderQuantity >= 1`, `minOrderQuantity <= quantityTotal`, and `fulfilment` in `{'pickup', 'delivery', 'both'}`.
2. **Live Discount vs. Price-Above-MRP Feedback:**
   - `liveDiscountPercent` returns a non-null percentage only when `0 < pricePaise < mrpPaise`. When `pricePaise == mrpPaise`, no discount line is shown. When `pricePaise > mrpPaise`, the discount line is hidden and `slErrPriceAboveMrp` is displayed immediately on the price input as well as on submit.
3. **Draft Persistence Without Clobbering on Edit:**
   - `/sell/new` reads from and writes to `listingDraftProvider` on every field or selection change so navigating back to `/sell` and returning to `/sell/new` preserves half-filled input, and resets `listingDraftProvider` only after a listing is published.
   - `/sell/edit/:id` initializes from the existing `MyListing` and keeps the product read-only (`_FixedProductTile`) without overwriting an in-progress `/sell/new` draft.
4. **Overflow-Safe Responsive Layout:**
   - No fixed heights are used on text containers. Action buttons and primary CTAs use `minimumSize: Size(48, 48)` with `FittedBox(fit: BoxFit.scaleDown)` labels so long Hindi and Marathi strings at `320x568` and `textScaler: 1.5` never clip or overflow.
   - All interactive cards (`_ProductChoiceRow`, `_FulfilmentChoiceCard`) place their `InkWell` directly on a `Material` surface so touch ripples render properly without Material assertions.
   - On `/sell/new`, when the filtered catalog has `<= 6` items (such as in filtered searches or inline test data) it renders as a direct `Column`, and when `> 6` items (the full 43-item catalog) it renders inside a `ConstrainedBox(maxHeight: 240 * s)` so the rest of the single-page form stays immediately reachable below.

---

## (c) Things That Could Not Be Done or Need the Main Engineer (Copied into `CHANGE_REQUESTS.md`)

1. **Profile Page Entry Tile (`app/lib/ui_v2/shell/placeholder_pages.dart` / Phase 9 Profile page)**
   - **What:** Wire the "My listings / Sell produce" tile on the Profile page to call `context.push('/sell')`.
   - **Why:** Section 1.5 specifies that Phase 9 owns the Profile page and will navigate to `/sell` via `context.push('/sell')`. The `/sell`, `/sell/new`, and `/sell/edit/:id` routes are registered and ready in `app/lib/ui_v2/shell/app_shell.dart`.

2. **Connecting `myListingsProvider` to Buyer Shop Providers (`app/lib/ui_v2/providers/catalog_providers.dart` & `app/lib/ui_v2/data/shop_repository.dart`)**
   - **What:** Merge active `MyListing` entries from `myListingsProvider` (`app/lib/ui_v2/providers/sell_providers.dart`) into the buyer-facing catalog (`shopHomeProvider`, `shopProductsProvider`, `productByCodeProvider`) when ready.
   - **Why:** Section 1.5 and Section 5.2 forbid editing `catalog_providers.dart` and `shop_repository.dart` during Phase 8 ("Do not touch the shop providers; at merge time the main engineer connects the two").

3. **Native Speaker Review of Hindi & Marathi Strings (`app/lib/ui_v2/l10n/sell_strings.dart`)**
   - **What:** Review the machine-drafted Hindi (`AppLanguage.hi`) and Marathi (`AppLanguage.mr`) strings in `SellStrings`.
   - **Why:** Per Section 1.6, all `sl*` Hindi and Marathi strings are machine drafts with zero Latin/English characters and should be reviewed by a native speaker.

---

## (d) Exact Output Summary of `flutter analyze` and `flutter test` Really Ran

Commands executed inside `app/`:

1. `flutter analyze lib/ui_v2 test`:
   ```text
   Analyzing 2 items...
   No issues found! (ran in 163.8s)
   ```

2. `flutter test test/ui_v2_smoke_test.dart test/ui_v2_landing_geometry_test.dart test/ui_v2_shop_data_test.dart test/ui_v2_real_catalog_test.dart test/ui_v2_cart_product_auth_test.dart test/ui_v2_category_test.dart test/ui_v2_product_page_test.dart test/ui_v2_sell_unit_test.dart test/ui_v2_sell_page_test.dart test/ui_v2_sell_form_test.dart`:
   ```text
   00:46 +100: All tests passed!
   ```
   (71 existing baseline tests + 14 unit tests in `ui_v2_sell_unit_test.dart` + 8 widget test groups in `ui_v2_sell_page_test.dart` + 7 widget test groups in `ui_v2_sell_form_test.dart` = 100 tests passed).

---

## (e) Short List of What to Check by Eye on a Real Phone

1. **Role Gate on `/sell`:** Open `/sell` as a Guest (check that "Sign in" and "Create account" buttons appear and return to `/sell` after signing in as a Gram Sabha or CFR holder) and as a Buyer (check that only the explanation message appears with no form or listings).
2. **My Listings Cards (`/sell`):** Sign in as a Gram Sabha or CFR holder and inspect the 3 seeded sample cards in both Light and Dark themes across English, Hindi, and Marathi—check picture cropping, `Active` / `Paused` status chip contrast, `Sample` badge, orange price next to strikethrough MRP, and the 3 action buttons (`Edit`, `Pause`/`Resume`, `Remove`).
3. **Add & Edit Form (`/sell/new` and `/sell/edit/:id`):**
   - Scroll through the 43 catalog products in Step 1 and filter using the search box in English, Hindi, and Marathi.
   - Type MRP and Selling Price values to check the green `Discount: N%` line when `price < MRP` and the inline error when `price > MRP`.
   - Inspect the `SellPreviewCard` in Step 6 as fields are edited, then press `Publish listing` and confirm the new card appears at the top of `/sell`.
4. **Large Font & Small Screen Check:** Enable system font scaling (1.5x) on a narrow handset and scroll through `/sell`, `/sell/new` (after tapping `Publish listing` on an empty form so all error messages are visible), and the `Remove listing?` confirmation dialog to visually confirm spacing and readability above the gesture navigation bar.
