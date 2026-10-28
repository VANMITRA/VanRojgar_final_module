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
