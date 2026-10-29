# UI Round 2 Implementation Report

## 1. Overview & Objectives

In UI Round 2, the four placeholder Profile pages ("Opens in the full app": Delivery partner, Messages, Barter, Livelihood report) were completely replaced with real, standalone screens built on VanMitra's Material 3 design system and token palette (`VanRozgarColorTokens`).

All screens strictly adhere to:
- M3 typography, forest-produce themed page backgrounds, card borders, and chip styles.
- Strict touch target sizing (minimum 48×48 dp interactive hit areas).
- Multi-viewport responsiveness (320×568, 360×800, 430×932) and font accessibility scaling (`textScale: 1.5`) without RenderFlex overflows.
- Language purity in English, Hindi, and Marathi with zero English leaks on non-English screens.
- Zero invented claims (no claims of "verified", "organic", fake delivery times, or fake phone helplines).
- Collective Gram Sabha authority preservation: clear community forest guidance and wildlife safety badges that never suggest harm to wildlife.

---

## 2. Files Created or Changed

### Task 1: Delivery Partner Module
- `app/lib/ui_v2/widgets/community/community_widgets.dart`: Shared UI kit containing `CommunityPage`, `CommunityCard`, `CommunityHeading`, `CommunityChip`, `CommunityPrimaryButton`, `CommunitySecondaryButton`, `CommunityMessageCard`, `CommunityGuestCard`, `showCommunityConfirm`, and layout helpers.
- `app/lib/ui_v2/l10n/community_strings.dart`: Localized strings for Delivery, Messages, and Barter across English, Hindi, and Marathi.
- `app/lib/ui_v2/widgets/delivery/delivery_job_card.dart`: Responsive job card widget with village routes, pay amount, weight, and status chips.
- `app/lib/ui_v2/shell/delivery/delivery_page.dart`: Hub screen (`/delivery`) presenting guest sign-in cards, non-CFR buyer explanations, CFR holder application prompts, pending review statuses, and the 3-tab job hub (`Available`, `My jobs`, `Completed`) for approved partners.
- `app/lib/ui_v2/shell/delivery/delivery_job_page.dart`: Job detail screen (`/delivery/jobs/:id`) with route information, pickup/drop-off contacts, pay breakdown, and state transitions (Accept, Mark Picked Up, Mark Delivered) with confirmation dialogs.
- `app/lib/ui_v2/shell/delivery/delivery_apply_page.dart`: Application form screen (`/delivery/apply`) with block multi-selection (Deola, Dindori, Trimbakeshwar), vehicle type choice (motorcycle, auto rickshaw, pickup truck, bicycle), validation errors, and submission confirmation.
- `app/test/ui_v2_delivery_test.dart`: Complete test suite covering role access, application flow, job status transitions, language purity, and 18-combination overflow matrix tests.
- `app/test/community_test_helpers.dart`: Shared test harness with fake repositories, mock users, and screen rendering helpers.

### Task 2: Messages Module
- `app/lib/ui_v2/shell/messages/messages_page.dart`: Notifications and conversations list screen (`/messages`) with guest gate, empty inbox states, category chips (Order, Barter, System), unread visual indicators, item detail sheet, and "Mark all as read" action.
- `app/lib/ui_v2/shell/profile/profile_page.dart`: Added real-time unread messages count pill badge (`profile_messages_badge`) to the `profile_more_messages` row in the Profile menu.
- `app/test/ui_v2_messages_test.dart`: Complete test suite covering guest gate, filtering, read status updates, language purity, and 18-combination overflow matrix tests.

### Task 3: Barter Module
- `app/lib/ui_v2/widgets/barter/barter_card.dart`: Barter offer item card showing offering vs requested products, parties, status badges, and cash adjustment notice if applicable.
- `app/lib/ui_v2/shell/barter/barter_page.dart`: Barter list screen (`/barter`) with 3 tabs (`Incoming`, `Sent`, `Closed`), guest sign-in prompt, empty states, and FAB to create a new offer.
- `app/lib/ui_v2/shell/barter/barter_detail_page.dart`: Detail screen (`/barter/:id`) displaying offer comparison, negotiation history versions, accept/reject confirmations, and an inline counter-offer bottom sheet.
- `app/lib/ui_v2/shell/barter/barter_new_page.dart`: Creation screen (`/barter/new`) with offering product selector, listing exchange picker, quantity inputs, optional message, and validation.
- `app/test/ui_v2_barter_test.dart`: Complete test suite covering incoming/sent/closed tabs, counter-offer sheet, accept/reject dialogs, validation, language purity, and 18-combination overflow matrix tests.

### Task 4: Livelihood Module
- `app/lib/ui_v2/l10n/livelihood_ui_strings.dart`: Comprehensive translations for intake steps, report headlines, government schemes, resources, map, and wildlife policy.
- `app/lib/ui_v2/widgets/livelihood/livelihood_widgets.dart`: Specialized domain components including `TrustLabelCard`, `WildlifeRiskBadge`, `GramSabhaNoticeCard`, `IdeaCardWidget`, `SchemeCardWidget`, and `ResourceCardWidget`.
- `app/lib/ui_v2/shell/livelihood/livelihood_home_page.dart`: Entry hub (`/livelihood`) with role filtering (CFR holders only; guest and buyer friendly cards), intake status card, report action buttons, delete confirmation dialog, and navigation links to schemes, resources, map, and policy.
- `app/lib/ui_v2/shell/livelihood/livelihood_details_page.dart`: 5-step intake wizard (`/livelihood/details`) for Land area & unit, Animals counters, Assets toggles, Past work selections, and Location source selection with progress bar.
- `app/lib/ui_v2/shell/livelihood/livelihood_report_page.dart`: Report screen (`/livelihood/report`) featuring header trust card, analysis headlines & strengths, ranked idea cards, PDF export button via `exportReportPdf`, Gram Sabha community forest notice, and official schemes link.
- `app/lib/ui_v2/shell/livelihood/livelihood_idea_page.dart`: Detailed idea view (`/livelihood/idea/:code`) with reasoning, seasonal fit, equipment needed, wildlife safety reminders, and matching government schemes.
- `app/lib/ui_v2/shell/livelihood/livelihood_schemes_page.dart`: Official government schemes directory (`/livelihood/schemes`) listing programs with eligibility rules and official external portal links.
- `app/lib/ui_v2/shell/livelihood/livelihood_resources_page.dart`: Nearby facilities directory (`/livelihood/resources`) showing water bodies, processing units, and markets with distances and ground-check trust labels.
- `app/lib/ui_v2/shell/livelihood/livelihood_map_page.dart`: Interactive map screen (`/livelihood/map`) rendered with `flutter_map`, showing village centre, water points, and markets with detail bottom sheet.
- `app/lib/ui_v2/shell/livelihood/livelihood_policy_page.dart`: Guidance screen (`/livelihood/policy`) explaining the Forest Rights Act (FRA 2006), wildlife protection regulations, and Gram Sabha resolution procedures.
- `app/lib/ui_v2/shell/profile/profile_page.dart`: Added "My livelihood report" card under the "My activity" section for CFR holders.
- `app/test/ui_v2_livelihood_test.dart`: Complete test suite covering role access, intake form progression, report analysis, scheme links, language purity, forbidden words check, and 18-combination overflow matrix tests.

### Task 5: Routing Cleanup & Legacy Removal
- `app/lib/ui_v2/shell/profile/profile_page.dart`: Routed `profile_more_delivery` to `/delivery`, `profile_more_messages` to `/messages`, `profile_more_barter` to `/barter`, and `profile_more_livelihood` to `/livelihood`.
- `app/lib/ui_v2/shell/app_shell.dart`: Removed `/more/:key` route and cleaned up imports; registered all 14 new feature routes.
- `app/lib/ui_v2/shell/profile/more_feature_page.dart`: Deleted legacy placeholder screen.
- `app/lib/ui_v2/l10n/profile_strings.dart`: Removed `pfOpensInFullApp`, `pfUnknownMoreTitle`, `pfUnknownMoreBody`, and entry point description getters.
- `app/lib/ui_v2/providers/profile_providers.dart`: Removed legacy `knownMoreFeatureKeys` and `isKnownMoreFeatureKey`.
- `app/lib/ui_v2/widgets/profile/profile_subpage_scaffold.dart`: Updated documentation comments.
- `app/test/ui_v2_profile_test.dart`: Updated navigation tests to verify real screen navigation instead of the legacy route.
- `app/test/ui_v2_profile_unit_test.dart`: Cleaned up unit test assertions for removed strings.

---

## 3. Design Decisions

1. **Responsive Flex vs Wrap**:
   - In badges (`WildlifeRiskBadge`), filter chips, and metric summaries, `Wrap` or flexible child text was used rather than unconstrained `Row` widgets to guarantee zero RenderFlex overflow across narrow 320 px devices at `textScale: 1.5`.
   - In form dropdowns (`DropdownButtonFormField`), `isExpanded: true` and truncated text overflow prevent horizontal expansion conflicts with adjacent numeric fields.

2. **Access Control & Role Awareness**:
   - Guest visitors are never blocked with harsh error dialogs. Instead, consistent friendly `CommunityGuestCard` components provide clear Sign In and Create Account options.
   - Non-CFR buyers attempting to access CFR-specific features (such as delivery partner onboarding or livelihood intake) see informative cards explaining that these features belong to tribal CFR holders under FRA provisions.

3. **Safe Livelihood & Wildlife Messaging**:
   - All wildlife badges clearly indicate low or moderate precautions and link to the legal framework (`/livelihood/policy`). They never suggest trapping, chasing, or harming wildlife.
   - Prominent `GramSabhaNoticeCard` banners emphasize that community forest produce must be gathered and managed only in accordance with Gram Sabha resolutions.

4. **PDF Export Integration**:
   - Built an accessible `_PdfActionButton` wrapper around the core `exportReportPdf` routine to ensure proper loading indicators, error snackbars, and flexible multiline button labels across all font scales.

---

## 4. Things That Could NOT Be Done (Needs Main Engineer)

As recorded in `CHANGE_REQUESTS.md`:

1. **`app/lib/features/livelihood/pdf/report_pdf.dart` (`PdfExportButton`)**:
   - `PdfExportButton` in the core livelihood feature uses `OutlinedButton.icon` with non-wrapping text that overflows on narrow viewports with large accessibility text scale. In `ui_v2`, `_PdfActionButton` was implemented with responsive styling around `exportReportPdf`. Upstream `PdfExportButton` should be modernized in the core feature.
2. **Backend REST APIs for Community Features (`/delivery`, `/barter`, `/messages`)**:
   - Live backend services for delivery partner job assignment, barter WebSocket transactions, and messaging push notifications are mocked via in-memory Riverpod state providers for UI V2. The backend engineer needs to connect real server endpoints when available.
3. **Seeded Sample Data in Static JSON**:
   - `app/assets/catalog/sample_catalog.json` and `sampleSeedOrders` contain sample seller names that will be replaced when live backend catalog databases are linked.

---

## 5. Exact Output Summary of Commands Run

### `flutter analyze --no-pub`
```
Analyzing app...
No issues found! (ran in 40.3s)
```

### Full Repository Test Suite (`flutter test --no-pub`)
```
01:35 +463 ~4: All tests passed!
```
- Total test files: 21
- Total tests passed: 463
- Total tests failed: 0
- Total tests skipped: 4 (pre-existing upstream tests in `test/livelihood/data_test.dart`)

### Round 2 Specific Test Suites
- `ui_v2_delivery_test.dart`: 17 tests passed (0 failures)
- `ui_v2_messages_test.dart`: 27 tests passed (0 failures)
- `ui_v2_barter_test.dart`: 28 tests passed (0 failures)
- `ui_v2_livelihood_test.dart`: 30 tests passed (0 failures)
- `ui_v2_profile_test.dart` & `ui_v2_profile_unit_test.dart`: 21 tests passed (0 failures)
- **Total Round 2 Tests**: 123 tests passed (0 failures)

---

## 6. What to Check by Eye on a Real Phone

When running the application on a physical device, visually inspect the following:

1. **Profile Navigation & Badges**:
   - Navigate to the **Profile** tab.
   - When signed in, observe the green circular badge showing the count of unread messages on the "Messages" row.
   - For CFR holder accounts, observe the "My livelihood report" card appearing under "My activity" with the appropriate state (Create report vs View/Update report).
   - Tap Delivery partner, Messages, Barter, and Livelihood rows: verify that each navigates smoothly to its dedicated full-screen page with a working back arrow returning to Profile.

2. **Delivery Partner Flows**:
   - Under `/delivery`, switch between "Available", "My jobs", and "Completed" tabs.
   - Tap "Apply to become a partner": inspect checkbox toggle touch targets, vehicle chips, and validation feedback when no blocks are selected.
   - Open an individual job (`/delivery/jobs/:id`): tap "Accept job" and "Mark delivered", and observe the confirmation dialog layout.

3. **Messages & Notifications**:
   - Under `/messages`, filter notifications using the chip selector ("All", "Orders", "Barter", "System").
   - Tap an unread notification to open the bottom sheet modal and verify the unread indicator clears.
   - Tap "Mark all as read" in the top bar.

4. **Barter Exchanges**:
   - Under `/barter`, switch between "Incoming", "Sent", and "Closed" tabs.
   - Tap the floating action button to open "Make a barter offer" (`/barter/new`) and verify the product selectors and numeric quantity stepper.
   - Open an incoming barter offer (`/barter/:id`): review the version history cards and open the "Counter offer" bottom sheet.

5. **Livelihood Module**:
   - Under `/livelihood`, observe the local storage sync indicator and tap "Update my details" to step through the 5-step form (Land, Animals, Assets, Past work, Location).
   - Under `/livelihood/report`, verify the trust source card, ranked idea cards with wildlife badges, and the "Save report as PDF" button.
   - Open `/livelihood/map`: check pinch-to-zoom on the OSM map and marker tap sheets.
   - Open `/livelihood/schemes` and `/livelihood/policy`: verify clean card spacing and legible typography.

6. **Accessibility & Dark Mode**:
   - Change system language to **हिन्दी** and **मराठी**: verify that all headers, chips, dialogs, and button labels render in natural Devanagari script with zero stray English text.
   - Enable **Dark theme**: verify contrast of card backgrounds, text tokens, chip fills, and borders.
   - Increase system font size to 150%: confirm that labels wrap cleanly without any yellow/black RenderFlex overflow stripes.
