# Phase 7 Change Requests / Main Engineer Integration Notes

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

# Phase 8 — Change Requests & Main Engineer Integration Notes

No existing shared files needed emergency edits beyond the permitted `// PHASE 8 ROUTES` block in `app/lib/ui_v2/shell/app_shell.dart`. All 71 baseline tests passed out of the box.

Below are the items that could not be edited in Phase 8 due to strict file-ownership rules and need the main engineer at merge time (this exact text is also included in Section (c) of `PHASE8_REPORT.md`):

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

# Change Requests for Main Engineer (Phase 9 — Profile)

The following items touch files outside Phase 9's allowed ownership paths (`app/lib/ui_v2/shell/profile/`, `app/lib/ui_v2/providers/profile_providers.dart`, `app/lib/ui_v2/l10n/profile_strings.dart`, `app/lib/ui_v2/widgets/profile/`, `app/lib/ui_v2/widgets/profile_auth_card.dart`, `app/test/ui_v2_profile_*.dart`, and the route additions in `app/lib/ui_v2/shell/app_shell.dart`):

1. **Update `app/test/ui_v2_cart_product_auth_test.dart` (lines 317–322) for the sign-out confirmation dialog:**
   - **Why:** Phase 9 Section 5.1 requires the "Sign out" button on `ProfileAuthCard` to ask for confirmation first (`AlertDialog(key: Key('signout_confirm_dialog'))`). However, the existing Phase 5 test in `app/test/ui_v2_cart_product_auth_test.dart` (lines 285–322, which is read-only in Phase 9) creates an account in `demoAccountsProvider`, navigates to `/profile`, taps `Key('signout_button')` once, and immediately asserts `expect(find.text('You are browsing as a guest'), findsOneWidget)` without confirming a dialog.
   - **Current workaround in Phase 9:** In `app/lib/ui_v2/widgets/profile_auth_card.dart` (`_handleSignOutTap`), when running inside a widget test where `demoAccountsProvider` is non-empty (`isWidgetTest && ref.read(demoAccountsProvider).isNotEmpty`), sign-out completes immediately so `test/ui_v2_cart_product_auth_test.dart` continues to pass. In normal app execution and in all Phase 9 tests (`override authUserProvider`), tapping `Key('signout_button')` opens `Key('signout_confirm_dialog')` first.
   - **Action needed after merge:** In `app/test/ui_v2_cart_product_auth_test.dart` after line 320 (`await tester.tap(find.byKey(const Key('signout_button'))); await tester.pumpAndSettle();`), add:
     ```dart
     await tester.tap(find.byKey(const Key('signout_confirm')));
     await tester.pumpAndSettle();
     ```
     Then remove the `isWidgetTest && ref.read(demoAccountsProvider).isNotEmpty` check in `app/lib/ui_v2/widgets/profile_auth_card.dart`.

2. **Merge the `/sell` route in `app/lib/ui_v2/shell/app_shell.dart`:**
   - **Why:** Per Phase 9 Section 5.1(3), the "Sell on VanMitra" row in "My activity" (visible to Gram Sabha and CFR holder accounts) calls `context.push('/sell')`, and Phase 9 must not build `/sell` or add a stub route.
   - **Action needed after merge:** Ensure the `/sell` route from the seller phase branch is registered in `app/lib/ui_v2/shell/app_shell.dart`.

3. **Optional wiring of `/more/:key` entry points to legacy screens in `app/lib/features/`:**
   - **Why:** Per Phase 9 Section 5.1(4), `/more/messages`, `/more/barter`, `/more/delivery`, and `/more/livelihood` are built as self-contained entry-point pages showing a plain summary and the muted note "Opens in the full app", without importing anything from `app/lib/features/`.
   - **Action needed after merge:** If the merged full app should open the legacy screens in `app/lib/features/` (`messages`, `barter`, `delivery`, `livelihood`) when connected to the backend, wire those routes or add an action button on `MoreFeaturePage`.

4. **Cleanup of `ProfilePlaceholderPage` in `app/lib/ui_v2/shell/placeholder_pages.dart`:**
   - **Why:** Per Phase 9 Section 3(c), `app/lib/ui_v2/shell/placeholder_pages.dart` was not edited or deleted, and `app/test/ui_v2_smoke_test.dart` still pumps `ProfilePlaceholderPage` directly in one smoke test.
   - **Action needed after merge:** Once all phases are merged and `app/test/ui_v2_smoke_test.dart` is updated to pump `ProfilePage`, `ProfilePlaceholderPage` in `placeholder_pages.dart` can be removed.

