# Change Requests (Outside `ui_v2` UI Scope)

The following files outside the owned UI paths (`app/lib/ui_v2/shell/**`, `widgets/**`, `l10n/**`, `theme/**`, `app/test/**`) contain `"Sample"` or `"Demo"` in seeded data or asset files that are passed through to the UI in English when real backend data is not yet connected:

1. **`app/assets/catalog/sample_catalog.json`** (lines 3–4 and listing `sellerName` entries across lines 20–1450):
   - **Reason**: Contains `"village": {"en": "Sample village", "hi": "नमूना गाँव", "mr": "नमुना गाव"}` and listing `sellerName` values such as `"Sample Gram Sabha 1"` and `"Sample CFR holder 2"` in the static JSON asset catalog; replace with real Gram Sabha / CFR holder names when wiring the production catalog.
2. **`app/lib/ui_v2/providers/orders_providers.dart`** (lines 308–639, `sampleSeedOrders`):
   - **Reason**: Seeded in-memory `OrderView` items have `sellerName: 'Sample Gram Sabha 1'`, `sellerName: 'Sample CFR holder 3'`, `buyerName: 'Sample Buyer'`, and `note: 'Sample ...'`, which appear in English order views until replaced with real seller/buyer names or live backend orders.

3. **pp/lib/features/livelihood/pdf/report_pdf.dart** (PdfExportButton):
   - **Reason**: PdfExportButton in the core livelihood feature uses OutlinedButton.icon with non-wrapping text that overflows on narrow viewports with large accessibility text scale. In ui_v2, _PdfActionButton was implemented with responsive styling around exportReportPdf. Upstream PdfExportButton should be modernized in the core feature.
4. **Backend REST APIs for Community Features (/delivery, /barter, /messages)**:
   - **Reason**: Live backend services for delivery partner matching, barter negotiation websockets, and messaging push notifications are mocked via in-memory Riverpod providers for UI V2. The backend engineer needs to wire up the actual server endpoints when the server infrastructure is ready.
