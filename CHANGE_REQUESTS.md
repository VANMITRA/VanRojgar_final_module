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

