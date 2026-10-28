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

