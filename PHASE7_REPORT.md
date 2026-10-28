# Phase 7 Report — ORDERS (Requests, Approvals, Payment Steps)

## (a) Files Created or Changed

### Created Files
- `app/lib/ui_v2/models/order_models.dart`
  - Defines `OrderStatus` (`pending`, `approved`, `rejected`, `countered`, `cancelled`, `paymentReported`, `paymentConfirmed`, `completed`), `OrderLine`, `OrderCounterOffer`, `OrderStatusEvent`, and `OrderView`.
- `app/lib/ui_v2/l10n/orders_strings.dart`
  - Defines `OrdersStrings` extension on `AppStrings` with `od*`-prefixed getters and helper methods in English, Hindi, and Marathi.
- `app/lib/ui_v2/providers/orders_providers.dart`
  - Defines `ordersProvider` (seeded with 8 sample orders `ord-1001`..`ord-1008` covering all statuses and both UPI and COD flows), `addOrders(WidgetRef ref, List<OrderView> newOrders)`, `ordersForUser`, `visibleOrdersProvider`, `orderByIdProvider`, and pure state-transition functions (`approveOrder`, `rejectOrder`, `counterOrder`, `acceptCounter`, `declineCounter`, `cancelOrder`, `reportPayment`, `confirmPayment`, `markCompleted`).
- `app/lib/ui_v2/widgets/orders/order_status_chip.dart`
  - Renders localized status chips using theme tokens (`primaryGreen`, `accentSaffron`, `error`, `mutedText`) for light and dark modes.
- `app/lib/ui_v2/widgets/orders/order_card.dart`
  - Renders order summary cards on `/orders` with status chip, sample badge, order number, localized date, counterparty name, product summary, formatted total, and fulfilment/payment subtitle.
- `app/lib/ui_v2/widgets/orders/order_action_sheets.dart`
  - Renders `Material`-backed confirmation and input bottom sheets:
    - `showCancelOrderSheet` (buyer cancel confirmation while `pending`)
    - `showPaymentReferenceSheet` (buyer UPI payment reference input, 6 to 30 characters; no UPI ID, QR code, or payment link)
    - `showRejectOrderSheet` (seller rejection reason input, required)
    - `showCounterOfferSheet` (seller counter-offer sheet validating quantity within `[minOrderQuantity..availableStock]` and rupee price `<= MRP`)
- `app/lib/ui_v2/shell/orders/orders_page.dart`
  - Replaces `OrdersPlaceholderPage` at `/orders`:
    - Guest view: sign-in prompt card with Sign in (`/signin`) and Create account (`/signup`) buttons.
    - Buyer view (`role == 'buyer'`): segmented tabs `Active` and `Past` with empty states.
    - Seller view (`role == 'gramsabha' || role == 'cfrholder'`): segmented tabs `New requests`, `In progress`, and `Done` with empty states.
- `app/lib/ui_v2/shell/orders/order_detail_page.dart`
  - Full-screen order detail view at `/orders/:id` (outside the bottom-navigation shell) with header card, counter-offer banner (when `countered`), line items with `Image.asset` + `errorBuilder`, total in rupees, delivery/pickup (+ village name from `data/villages.dart`), payment method in words, buyer/seller/rejection/payment notes, role-and-status-gated action buttons, vertical status timeline, and muted demo notice.
- `app/test/ui_v2_orders_logic_test.dart`
  - 12 unit tests covering line/order totals, localized product summaries, all allowed and refused state transitions, counter-offer validation rules (`minOrder`, `stock`, `MRP`), `ordersForUser`, and `addOrders`.
- `app/test/ui_v2_orders_test.dart`
  - 12 widget test groups/cases covering `/orders` (guest, buyer, seller, empty states), `/orders/:id` buyer and seller flows and confirmation sheets, Hindi and Marathi zero-English-except-`UPI` checks, and multi-size (`320x568`, `360x800`, `430x932`) light/dark/3-language/`textScaler: 1.5` overflow checks.
- `CHANGE_REQUESTS.md` and `PHASE7_REPORT.md`

### Modified Existing Files
- `app/lib/ui_v2/shell/app_shell.dart`
  - Added imports for `orders/order_detail_page.dart` and `orders/orders_page.dart`.
  - Added top-level route `/orders/:id` under `// PHASE 7 ROUTES` next to `/cart`.
  - Changed the `/orders` branch builder from `OrdersPlaceholderPage()` to `OrdersPage()`.

---

## (b) Design Decisions Made

1. **Unified Request + Order Lifecycle Matching Backend Models**:
   - Combined the backend `Request` states (`pending`, `approved`, `rejected`, `countered`, `cancelled` from `server/src/models/Request.js` and `server/src/services/requestMachine.js`) and `Order` payment/completion states (`paymentReported`, `paymentConfirmed`, `completed` from `server/src/models/Order.js` and `server/src/services/payment.service.js`) into a single `OrderStatus` enum on `OrderView`.
   - For UPI orders (`paymentMethod == 'upi'`), the happy path is `pending -> approved -> paymentReported -> paymentConfirmed -> completed`.
   - For Cash on Delivery (`paymentMethod == 'cod'`), `reportPayment` and `confirmPayment` are refused; `markCompleted` is allowed directly after `approved` (`pending -> approved -> completed`).
2. **Pure State-Change Functions + Guard Predicates**:
   - Every transition in `orders_providers.dart` is a pure function `(OrderView, ...) -> OrderView?` paired with `can*` boolean helpers (`canApproveOrder`, `canRejectOrder`, `canCounterOrder`, `canAcceptOrDeclineCounter`, `canCancelOrder`, `canReportPayment`, `canConfirmPayment`, `canMarkCompleted`). Both the UI buttons on `OrderDetailPage` and the unit tests call the exact same pure functions.
3. **Demo Identity & Seeded Orders**:
   - `ordersProvider` is seeded with 8 sample orders (`ord-1001`..`ord-1008`, all marked `isSample: true` and `isDemoBuyer: true`) spanning `pending`, `countered`, `approved` (UPI and COD), `paymentReported`, `paymentConfirmed`, `completed`, `rejected`, and `cancelled`, across sellers `seller-1` (Gram Sabha) and `seller-2` (CFR Holder).
   - Because `SignInPage` creates a fresh `AuthUser` without a fixed ID, `ordersForUser` matches demo buyers via `isDemoBuyer`, matches demo sellers by `sellerId` (`seller-1` for `gramsabha`, `seller-2` for `cfrholder`, or matching `user.id`), and returns an empty list for guests (`user == null`).
4. **Zero-English Localization in Hindi and Marathi (Except `"UPI"`)**:
   - All strings in `OrdersStrings` (`orders_strings.dart`) are prefixed with `od` to avoid collisions with other phases.
   - Sample counterparty names (`Sample Gram Sabha 1`, `Sample Buyer`, etc.), sample timeline notes, order IDs (`ord-1001` rendered as `#1001`), and dates (`odFormatDate`) are localized in Hindi and Marathi so that no English words appear on `/orders`, `/orders/:id`, or any bottom sheet when the language is Hindi or Marathi (except `"UPI"`).
5. **Small-Screen (`320x568`) and `textScaler: 1.5` Layout Resilience**:
   - Used `Wrap` and responsive column/row switching when `textScaler > 1.25` or width `< 340` in segmented controls, cards, line rows, and modal sheet buttons so that all views and sheets render with zero overflow at `320x568`, `360x800`, and `430x932` with `textScaler: 1.5`.

---

## (c) Things That Could Not Be Done or Need the Main Engineer

*(The exact same text below is also saved in `CHANGE_REQUESTS.md`.)*

1. **Phase 6 (Checkout) to Phase 7 (Orders) handoff**:
   - Because `app/lib/ui_v2/shell/cart_page.dart` and the `/checkout` route belong to Phase 6 (and are off-limits to Phase 7), Phase 7 exposes `addOrders(WidgetRef ref, List<OrderView> newOrders)` in `app/lib/ui_v2/providers/orders_providers.dart`.
   - When merging Phase 6 and Phase 7, the main engineer should call `addOrders(ref, newOrders)` from the Phase 6 checkout submission handler (creating one `OrderView` per seller group with `isDemoBuyer: true`) before navigating to `/orders` or `/orders/:id`.

2. **Optional cleanup of `OrdersPlaceholderPage` in `app/lib/ui_v2/shell/placeholder_pages.dart`**:
   - `app/lib/ui_v2/shell/app_shell.dart` now routes `/orders` to `OrdersPage` from `app/lib/ui_v2/shell/orders/orders_page.dart`.
   - `app/lib/ui_v2/shell/placeholder_pages.dart` is not owned by Phase 7 and was left untouched; the main engineer can remove `OrdersPlaceholderPage` once all phases are merged if desired.

3. **Future live backend wiring**:
   - In accordance with Phase 7 rules, all order and request actions (`approveOrder`, `rejectOrder`, `counterOrder`, `acceptCounter`, `declineCounter`, `cancelOrder`, `reportPayment`, `confirmPayment`, `markCompleted`) operate purely in memory via `ordersProvider`, and no UPI IDs, QR codes, or payment links are shown.
   - Wiring these providers to `/api/v1/trade/requests`, `/api/v1/orders`, and `/api/v1/payments` is left to the main engineer when backend connectivity is enabled.

---

## (d) Exact Output Summary of `flutter analyze` and `flutter test` Actually Run

### 1. `flutter analyze lib/ui_v2 test` (run in `app/`)
```text
Analyzing 2 items...
No issues found! (ran in 8.8s)
```

### 2. Full UI v2 Test Suite (71 baseline tests + 24 Phase 7 tests = 95 tests, run in `app/`)
Command run:
```powershell
flutter test test/ui_v2_smoke_test.dart test/ui_v2_landing_geometry_test.dart test/ui_v2_shop_data_test.dart test/ui_v2_real_catalog_test.dart test/ui_v2_cart_product_auth_test.dart test/ui_v2_category_test.dart test/ui_v2_product_page_test.dart test/ui_v2_orders_logic_test.dart test/ui_v2_orders_test.dart
```
Output summary:
```text
00:00 +0: loading C:/Soham/college work/VanRojgar_phase7/app/test/ui_v2_smoke_test.dart
...
00:23 +93: C:/Soham/college work/VanRojgar_phase7/app/test/ui_v2_orders_test.dart: No overflow across sizes, themes, languages, roles, statuses, and sheets at textScaler 1.5 /orders (3 roles), /orders/:id (3 statuses), and sheets at 320x568, 360x800, 430x932
00:27 +94: C:/Soham/college work/VanRojgar_phase7/app/test/ui_v2_orders_test.dart: No overflow across sizes, themes, languages, roles, statuses, and sheets at textScaler 1.5 /orders (3 roles), /orders/:id (3 statuses), and sheets at 320x568, 360x800, 430x932
00:28 +95: All tests passed!
```

### 3. Phase 7 Isolated Test Suite (`test/ui_v2_orders_logic_test.dart` + `test/ui_v2_orders_test.dart`, run in `app/`)
```text
00:00 +0: loading C:/Soham/college work/VanRojgar_phase7/app/test/ui_v2_orders_logic_test.dart
...
00:27 +24: All tests passed!
```

---

## (e) Short Checklist of What to Check by Eye on a Real Phone

1. **Orders Tab (`/orders`) across Roles**:
   - As a **guest**, open the Orders tab and check that the sign-in prompt card is centered, legible, and its **Sign in** and **Create account** buttons open `/signin` and `/signup`.
   - Sign in as a **buyer** and check the `Active` and `Past` segmented pill switch, badge counts, card spacing, status chip contrast in both light and dark modes, and product summary truncation.
   - Sign in as a **Gram Sabha** or **CFR Holder** seller (via Create account -> Gram Sabha / CFR Holder) and check the 3-way segmented control (`New requests`, `In progress`, `Done`) so that labels do not clip on narrow screens or in Hindi/Marathi.
2. **Order Detail Page (`/orders/:id`)**:
   - Tap each sample order card and inspect the full-screen detail layout: back arrow navigation, status chip + sample badge wrapping, product thumbnail fallback when an asset is missing, line calculation (`₹price × qty unit`), delivery village name, payment method in words, and vertical timeline connector alignment.
3. **Interactive Bottom Sheets & Keyboard Behavior**:
   - As a buyer on `#1001` (`pending`), tap **Cancel request** and check the confirmation bottom sheet padding above the system navigation bar.
   - As a buyer on `#1002` (`countered`), check the saffron counter-offer comparison banner and tap **Accept offer** (confirming the line quantity, unit price, total, status chip, and timeline update immediately).
   - As a buyer on `#1003` (`approved`, UPI), tap **I have paid**, check that the soft keyboard pushes the sheet up cleanly (`viewInsets.bottom`), and confirm that entering fewer than 6 characters shows an inline validation message.
   - As a seller on `#1001` (`pending`), test **Send another offer** (checking the allowed quantity range and MRP ceiling hint) and **Reject** (confirming a reason is required).
4. **Language Switching (`EN` / `हिं` / `मरा`)**:
   - Switch between English, Hindi, and Marathi in the top bar and visually inspect `/orders`, `/orders/:id`, and each bottom sheet to confirm natural Devanagari line height and that no stray English text appears (other than `"UPI"`).

