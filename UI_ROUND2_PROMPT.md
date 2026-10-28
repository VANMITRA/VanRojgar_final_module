# UI ROUND 2 PROMPT: delivery partner, messages, barter and the livelihood report for the VanMitra app

You are working in this folder only. Read this whole file before you touch anything, then follow it step by step. Round 1 (UI_ROUND1_PROMPT.md) is finished and merged; the rules below are the same, with the changes written here.

## 0. Who and what

VanMitra (Hindi and Marathi: वनमित्र) is a shop app for forest produce from Community Forest Rights (CFR) villages in Nashik, India. Sellers are Gram Sabhas and CFR holders; buyers are wholesalers and businesses.
Flutter Android app; the UI lives in `app/lib/ui_v2/` (run with `flutter run -t lib/ui_v2/main_demo.dart`). Three languages: English, Hindi, Marathi (never mixed on one screen).
This is a FINAL app that is being submitted: no "Sample", no "Demo", no "Opens in the full app", no placeholder pages, no made-up data. It stands ALONE: it is not part of the old VanRozgar app.

Today the Profile has four entries (Messages, Barter, Delivery partner, Livelihood report) that open small info pages saying "Opens in the full app". Your job is to build the REAL screens for all four, in the same look as the rest of the app.
The main engineer (Claude) works in parallel on the servers and on the code that fetches real data. He has already written the data contracts you build on (section 3). Do not wait for him: you build against those contracts, and your tests use inline test data.

## 1. Rules (read carefully)

1. Work ONLY inside this folder. Never read, open or change anything outside it. No git remote: never add one, never push. You MAY `git add` and `git commit` here (small commits). Never `git add -A` at the folder root.
2. No network. Do not look for, open, print or create `.env`, keys, tokens, passwords, keystores or any secret.
3. Commands you may run (inside `app/`): `flutter pub get`, `flutter analyze`, `flutter test`. NOT `flutter build`; do not touch `app/android`, `app/ios`, `app/web`; do NOT edit `app/pubspec.yaml` (all packages you need, `flutter_map`, `latlong2`, `geolocator`, `pdf`, `printing`, `url_launcher`, are already there).
4. Never invent claims: no ratings, "verified", "organic", "free", "fast", "guaranteed", no delivery times, no helplines, no earnings promises, no prices that are not in the data.
5. FILE OWNERSHIP:
   - You OWN: `app/lib/ui_v2/shell/` (new folders `delivery/`, `messages/`, `barter/`, `livelihood/` and the existing profile pages), `app/lib/ui_v2/widgets/` (new sub-folders for your screens), `app/lib/ui_v2/l10n/` (new files only: `community_strings.dart` and `livelihood_ui_strings.dart`), `app/lib/ui_v2/theme/`, all tests under `app/test/`.
   - In `app/lib/ui_v2/shell/app_shell.dart` you MAY add routes in a block marked `// ROUND 2 ROUTES` and remove the old `/more/:key` route; nothing else there.
   - You MUST NOT edit: `app/lib/ui_v2/providers/`, `models/`, `data/`, `api/`, `app/assets/`, `app/pubspec.yaml`, `server/`, `livelihood_server/`, `docs/`, and nothing under `app/lib/features/` (you may READ and IMPORT the non-screen parts of `app/lib/features/livelihood/`, see section 3.4; you must NOT import any of its screens or widgets and not its routes).
   - If you need a change in a file you must not edit, write it into `CHANGE_REQUESTS.md` (file, what, why) and work around it.
   - UI-only state (selected tab, form fields) lives in the widget's own `State` or in a provider declared inside your own screen file.
6. Strings: new files with an `extension ... on AppStrings` and a private `_t(en, hi, mr)` helper, same style as `l10n/shop_extra_strings.dart`. Prefixes so nothing clashes: `dl` (delivery), `ms` (messages), `bt` (barter), `lh` (livelihood). Hindi and Marathi are machine drafts (say so in a comment). In Hindi and Marathi no English word may be visible ("UPI", "Google", brand and place names are allowed). Reuse existing getters where they exist.
7. No debug prints, no commented-out code, no unused files. `flutter analyze` must report "No issues found".

## 2. Step 0

1. `cd app`; `flutter pub get`; `flutter analyze`; `flutter test`. All tests must pass before you change anything (about 362). If not, STOP and say so in `CHANGE_REQUESTS.md`.
2. Read: `docs/API_CONTRACT_UI.md` (what the servers offer: sections 7 to 10 are yours), `lib/ui_v2/models/community_models.dart` and `lib/ui_v2/providers/community_providers.dart` (your data contracts), `shell/app_shell.dart`, `shell/profile/*` (especially `more_feature_page.dart` and `profile_page.dart`), `shell/orders/*` and `widgets/orders/*` (the closest existing look: lists of cards, status chips, detail pages, action sheets), `theme/*`, `l10n/shop_extra_strings.dart`, `l10n/orders_strings.dart`.
3. Read the OLD screens only to learn what each feature does (not to copy their look): `lib/features/delivery/*`, `lib/features/messages/messages_screen.dart`, `lib/features/barter/*`, `lib/features/livelihood/screens/*` and `widgets/*`, `docs/`.

## 3. The data you build on (already written, do not change)

### 3.1 Delivery partner
`DeliveryRepository` (in `providers/community_providers.dart`) and the providers `deliveryProfileProvider` (null = never applied), `deliveryOpenJobsProvider`, `deliveryMyJobsProvider`. Models: `DeliveryPartnerProfile` (approvalStatus pending|approved|rejected|paused, vehicleType, vehicleNumber, capacityKg, serviceTalukas, available, earningsPaise, jobsCompleted, reviewNote), `DeliveryApplication`, `DeliveryJob` (pickup/drop village and taluka, goodsSummary, weightKg, distanceKm, feePaise, collectCashPaise, cashCollected, status, timeline), `DeliveryStep`.
Actions go through `ref.read(deliveryRepositoryProvider)`: `apply`, `setAvailable`, `acceptJob`, `updateJobStatus(jobId, 'picked_up'|'on_the_way'|'delivered', note:)`. After an action call `ref.invalidate(...)` on the providers it changes. Errors: catch everything, show a plain message in the user's language, never a stack trace.
Only a CFR holder (`AuthUser.role == 'cfrholder'`) may apply; a Gram Sabha or buyer sees a short explanation. A guest sees sign in / create account.

### 3.2 Messages
`MessagesRepository`, `messagesProvider`, `unreadMessagesProvider`; model `AppMessage` (type, title, body, orderId, requestId, barterId, readAt, createdAt; `localizedTitle(lang)`, `localizedBody(lang)`; the server text exists in Marathi and English only, Hindi shows the English text, add one muted line in Hindi mode saying so, in Hindi). These are notices, not a chat: no composer.

### 3.3 Barter
`BarterRepository`, `incomingBarterProvider`, `outgoingBarterProvider`; models `BarterOffer`, `BarterVersion`, `NewBarterOffer`. Actions: `create(NewBarterOffer)`, `respond(id, 'accept'|'reject'|'counter', counterOfferedTitle:, counterOfferedQuantity:, counterWantedQuantity:, note:)`.

### 3.4 Livelihood report (CFR holders only)
The old, working code is in `app/lib/features/livelihood/`. You may import (and only these) `models/`, `data/`, `providers/`, `pdf/`, `product_links.dart` and the strings files (read them for the Hindi/Marathi text; copy what you need into your own `lh` strings file). Do NOT import its `screens/`, `widgets/`, `livelihood_routes.dart`, `livelihood_embed.dart`. Do not use `hostFrameBuilderProvider`/`host_hooks` (that was for the old app shell).
Providers you will use: `profileProvider`, `intakeProvider`, `reportProvider`, `schemesProvider`, `ideaDetailProvider`, `marketPointsProvider`, `resourceFilterProvider`, `livelihoodRepositoryProvider` (read them to see the exact shapes). In your tests override these with inline test data (never the network, never asset files). The report server is separate and is wired by the main engineer; you must never call the demo/sample report. If the report cannot be loaded, show a clear message and a retry button.

## 4. Design rules (these decide whether it passes review)

- Same look as the existing screens: cards `tokens.card`, radius 16 * s, 1 dp `tokens.borders`, scale `s = (MediaQuery.sizeOf(context).width / 360).clamp(0.85, 1.25)`, green buttons (`tokens.primaryGreen`/`onPrimaryGreen`), orange only for money and tiny highlights, `AppBackground` as page background, a back arrow on full-screen pages.
- NO fixed heights for text content (`IntrinsicHeight`, `Flexible`, `Expanded`, `maxLines` + ellipsis, `FittedBox`). Must work with textScaler 1.5 and long Hindi/Marathi words.
- Anything with a ripple sits on a `Material`; tap targets at least 48 x 48; every interactive element has a `Key`; icon-only buttons have `Semantics` labels. Bottom bars above the gesture bar (`SafeArea`).
- No spinners: while loading show an empty transparent area; use plain "nothing here yet" empty states with one clear next step. Both themes, three languages, phones 320 x 568 up to 800 x 1280, portrait.
- Money is integer PAISE in the models; format with `formatRupees` (from `models/catalog_models.dart`).

## 5. THE WORK (in this order, commit after each task)

### Task 1: Delivery partner (`/delivery`, `/delivery/apply`, `/delivery/jobs/:id`)
- `/delivery` by state: guest -> sign in / create account card; signed in but not a CFR holder -> a short explanation (delivery partners are CFR holders), nothing else; CFR holder who has not applied -> intro text (what a delivery partner does, from the old screens/docs, invent nothing) and a green "Apply" button; applied -> a status card by `approvalStatus` (pending: "Waiting for approval", rejected: show `reviewNote`, paused: explain) and, when approved, the hub: availability switch (`setAvailable`), earnings (orange, `formatRupees`) and jobs completed, and two segments "Open jobs" / "My jobs".
- Job card: pickup village to drop village, goods summary, weight and distance, the fee (orange), and when `collectCashPaise > 0` a clear line "Collect cash: ₹X". Open jobs have an "Accept job" button (asks first). My jobs show the status chip and the next step button: "Picked up" -> "On the way" -> "Delivered" (only the next valid one), asking before each.
- `/delivery/jobs/:id`: full job: both places, goods, the cash line, a vertical timeline from `timeline`, the same action button.
- `/delivery/apply`: one scrolling form with a sticky submit: vehicle type as four large cards (bike, tempo, pickup, tractor) with icons, vehicle number, capacity in kg (whole number > 0), licence number (min 4 characters), service talukas as multi-select chips built from the talukas in `data/villages.dart` (`pilotVillages`; at least one). Inline errors; on success go back to `/delivery` and show "Waiting for approval".

### Task 2: Messages (`/messages`)
List newest first, grouped by day label if you like; unread ones have a dot and bold title; tapping marks it read (`markRead`) and opens its target when it has one (`orderId` or `requestId` -> `/orders/<id>`, `barterId` -> `/barter`). A "Mark all read" action. Empty state. An unread count badge on the Profile "Messages" row (from `unreadMessagesProvider`).

### Task 3: Barter (`/barter`, `/barter/new`, `/barter/:id`)
- `/barter`: two segments "Offers to me" (`incomingBarterProvider`) and "My offers" (`outgoingBarterProvider`); cards: what is offered, what is wanted, status chip (pending, accepted, rejected, countered), other party, date. Empty states.
- `/barter/:id`: both sides of the deal, the version history (`versions`), and for an incoming pending/countered offer the actions "Accept", "Reject" (asks first), "Counter" (a sheet with offered title, offered quantity, wanted quantity, optional note; numbers must be > 0). For an outgoing countered offer: "Accept" / "Reject".
- `/barter/new` (opened as `/barter/new?listing=<id>&title=<text>&unit=<unit>`): the form to make an offer for that listing: offered item name (min 2 characters), offered quantity and unit, wanted quantity, note. Submit calls `create`. (A button that opens this form from a product will be added later by the main engineer; you only build the page and handle a missing `listing` parameter with a friendly message.)

### Task 4: Livelihood report (`/livelihood`, `/livelihood/details`, `/livelihood/report`, `/livelihood/idea/:code`, `/livelihood/schemes`, `/livelihood/resources`, `/livelihood/map`, `/livelihood/policy`)
Rebuild the 8 old screens in the new look with go_router routes, keeping their logic and their rules, which must never break: no harm to wildlife is ever suggested; community forest is "use only through the Gram Sabha"; labels only, no invented numbers; missing facts show "not available"; every result shows its source and date; ideas are drafts; the 10 government schemes show official links only. Read `docs/BACKEND.md` section 5 and the old screens for the exact behaviour.
- `/livelihood` (home): for a CFR holder: a hero card, a green "Create my livelihood report" button when there is no report (it opens `/livelihood/details`), or "View my report" plus "Update my details" when there is one; entries for schemes, resources, map and policy. A non-CFR user or guest gets the short explanation / sign-in card.
- `/livelihood/details`: the intake (location, resources, answers) with the same steps as the old `add_details_screen`, as a clean multi-step form with a progress indicator, per-step validation and a final "Create report" button; show the progress without a spinner.
- `/livelihood/report`: the report with its parts (analysis, ideas, legal checks, wildlife badge, trust/source labels), a share/PDF action using the existing `pdf` code, and links to idea detail pages.
- The other screens (idea detail, schemes, resources, map, policy) restyled the same way. The map uses the existing `flutter_map` setup; do not add a tile provider that needs a key.
- Profile (`shell/profile/profile_page.dart`): for a CFR holder add a section "My livelihood report" at the top of "My activity" with the same two buttons as the home screen (create / view), and keep a row to `/livelihood`.

### Task 5: Replace the "Opens in the full app" pages
- The Profile rows Messages, Barter, Delivery partner and Livelihood open the new routes (Messages and Barter only when signed in; Livelihood only for a CFR holder; Delivery for everyone, with the states of Task 1).
- Delete `more_feature_page.dart`, the `/more/:key` route and every string that said "Opens in the full app" or described these features as entry points; update the tests that used them.
- Keep About, Credits and Privacy as they are.

## 6. Tests (new files `test/ui_v2_delivery_*.dart`, `ui_v2_messages_*.dart`, `ui_v2_barter_*.dart`, `ui_v2_livelihood_*.dart`)
Use small inline data and provider overrides (copy the helper style of `test/ui_v2_product_page_test.dart`: `_app`, `_tall`, `_open`; `MediaQuery.of(context).copyWith(textScaler: ...)`). Cover for each feature: every state of the screens (guest, wrong role, empty, with data), each action and its confirmation, validation errors, Hindi and Marathi with no English text, and no overflow (`expect(tester.takeException(), isNull)`) at 320x568, 360x800, 430x932, light and dark, English/Hindi/Marathi, textScaler 1.5. Add a test that no screen of this round shows the words "Sample", "Demo" or "Opens in the full app". After you finish ALL tests must pass and `flutter analyze` must say "No issues found".

## 7. Deliverables
- Your commits in this folder's local git. Do not rewrite or delete the baseline commit.
- `UI_ROUND2_REPORT.md`: (a) files created or changed, (b) design decisions, (c) things you could NOT do or that need the main engineer (also in `CHANGE_REQUESTS.md`), (d) the exact output summary of `flutter analyze` and `flutter test` that you really ran, (e) what to check by eye on a real phone.
- Never say "verified" or "tested on a phone". You can only run analyze and the widget tests.
