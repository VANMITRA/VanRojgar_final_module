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

