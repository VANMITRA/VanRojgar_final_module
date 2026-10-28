# UI ROUND 1 PROMPT: final-app clean-up and four screen fixes for the VanMitra app

You are working in this folder only. Read this whole file before you touch anything, then follow it step by step.

## 0. Who and what

VanMitra (Hindi and Marathi: वनमित्र) is a shop app for forest produce from Community Forest Rights (CFR) villages in Nashik, India. Sellers are Gram Sabhas and CFR holders.
Buyers are wholesalers and businesses. It is a Flutter Android app. The NEW UI lives in `app/lib/ui_v2/` (run with `flutter run -t lib/ui_v2/main_demo.dart`).
Three languages: English, Hindi, Marathi (never mixed on one screen, never auto-changed).

IMPORTANT CHANGE OF DIRECTION: this app is being SUBMITTED as a FINAL app. The words "Sample", "Demo", "demo" and anything that says "this is test data" must disappear from everything a user can see.
The app also stands ALONE: it has nothing to do with the old VanRozgar app that sits in `app/lib/features/` and `app/lib/main.dart`. Do not open, edit or import those.

The main engineer (Claude) works IN PARALLEL on the backend and on the data layer in a different copy of this project. The two copies will be merged. That is why the file rules in section 1 are strict.
The app name is VanMitra / वनमित्र. Never write the old name (VanRozgar, वनरोजगार) in anything a user can see. CODE names containing `VanRozgar` (`VanRozgarTokens`, `VanRozgarColorTokens`, `VanRozgarTheme`,
the package `vanrozgar`, files `van_rozgar_*.dart`) stay as they are: do not rename them.

## 1. Rules (read carefully)

1. Work ONLY inside this folder. Do not read, open, list or change anything outside it. This folder has NO git remote: never add one, never push. You MAY use `git add` and `git commit` here
   (small commits, clear messages). Never `git add -A` at the folder root; add your own paths.
2. Do not use the network. Do not look for, open, print or create `.env`, keys, tokens, passwords, keystores or any secret.
3. Commands you may run (inside `app/`): `flutter pub get`, `flutter analyze`, `flutter test`. Do NOT run `flutter build`, do NOT touch `app/android`, `app/ios`, `app/web`, and do NOT edit `app/pubspec.yaml`
   (no new packages, no new asset folders).
4. Never invent claims: no ratings, no "verified", "organic", "free", "fast", "guaranteed", no delivery times or fees, no helplines, no discounts that are not in the data.
5. FILE OWNERSHIP (very important, to avoid merge conflicts):
   - You OWN and may edit: everything under `app/lib/ui_v2/shell/`, `app/lib/ui_v2/widgets/`, `app/lib/ui_v2/l10n/`, `app/lib/ui_v2/theme/`, and every test under `app/test/` that tests those screens.
   - You MUST NOT edit: `app/lib/ui_v2/providers/`, `app/lib/ui_v2/data/`, `app/lib/ui_v2/models/`, `app/assets/` (including `sample_catalog.json`), `app/pubspec.yaml`, `server/`, `livelihood_server/`, `docs/`.
     Those belong to the main engineer, who is replacing the made-up data with real server data. If you need a change there, write it into `CHANGE_REQUESTS.md` (file, what, why) and work around it in your own files.
     Typical case: a model has a flag `isSample`; you simply stop SHOWING anything for it in the UI, you do not edit the model.
6. Strings: keep the existing style (`l10n/*.dart`, private `_t(en, hi, mr)`). Hindi and Marathi are machine drafts. In Hindi and Marathi no English word may be visible (the word "UPI", "Google" and brand/place names are allowed).
7. No debug prints, no commented-out code, no unused files. `flutter analyze` must report "No issues found".

## 2. Step 0: get your bearings (do this first)

1. `cd app`, run `flutter pub get`, `flutter analyze`, then `flutter test`. All tests must pass before you change anything. If they do not, STOP and write that in `CHANGE_REQUESTS.md`.
2. Read fully before designing: `lib/ui_v2/main_demo.dart`, `shell/app_shell.dart`, `shell/landing_page.dart`, `shell/landing_geometry.dart`, `widgets/home_top_deals_section.dart`, `widgets/category_tab_row.dart`,
   `shell/auth_pages.dart`, `widgets/profile_auth_card.dart`, `theme/van_rozgar_tokens.dart`, `theme/van_rozgar_theme.dart`, `l10n/app_strings.dart`, and the tests of those screens
   (`test/ui_v2_landing_geometry_test.dart`, `test/ui_v2_smoke_test.dart`, `test/ui_v2_cart_product_auth_test.dart`).
3. Look at the reference pictures in `ui_reference/` (`3.jpeg`, `5.jpeg`, `6.jpeg`, `14.jpeg`): they show the style the owner wants (rounded tab shapes, text running over pictures).

## 3. Design rules for every screen you touch (these decide whether it passes review)

- Match the existing screens: cards `tokens.card`, radius 16 * s, 1 dp `tokens.borders`, scale `s = (MediaQuery.sizeOf(context).width / 360).clamp(0.85, 1.25)`.
- NO fixed heights for text content (use `IntrinsicHeight`, `Flexible`, `Expanded`, `maxLines` + ellipsis, `FittedBox(fit: BoxFit.scaleDown)`). Everything must work with textScaler 1.5 and long Hindi/Marathi words.
- Anything with a touch ripple must sit on a `Material`. Tap targets at least 48 x 48 dp. Every interactive element gets a `Key`.
- Both themes (light and dark) and all 3 languages must look right. Use tokens, never hard-coded colours except white on pictures. Phones 320 x 568 up to 800 x 1280, portrait.
- No spinners. Orange only for prices and tiny highlights, never a button fill.

## 4. THE WORK (do the tasks in this order, commit after each)

### Task 1: No "Sample" / "Demo" anywhere a user can see
- Search `lib/ui_v2/shell`, `widgets`, `l10n` for every visible use of: `Sample`, `sample`, `Demo`, `demo`, `नमूना`, `नमुना`, `डेमो`, "Illustration" is allowed to stay (it is an honest picture note), "Sample village", "Demo version", `demoNote`
  ("Demo: nothing is sent to a server yet"), the `sampleBadge` pills on product cards, product page, cart lines, order cards, sell cards, success page, and the seller-name localizer that turns "Sample Gram Sabha 1" into Hindi/Marathi.
- Remove the badge/line completely (do not leave an empty gap). Where a line carried real information (for example the village text), keep only the real part; if there is no real value, drop the line.
- The Profile footer says "Demo version": show only the logo and the name "VanMitra".
- Do NOT touch data that comes from providers or models (seller names such as "Sample Gram Sabha 1" come from the data; the main engineer replaces that data). Just never print the word yourself.
- Update every test that expected those words. Add one test that opens Home, a Product page, the Cart, Checkout, Orders, Sell and Profile in English, Hindi and Marathi and asserts no visible text contains "Sample", "Demo" (case-insensitive) in the UI chrome (tests use their own inline data, so data text is not an issue).

### Task 2: Landing slides (text running over the pictures)
Look at slide 2 (pictures on the right, text on the left): the headline word "herbs" runs onto the picture; its outlined letters stay readable. The owner loves this and wants it on the other slides too.
- Slide 1 (pictures LEFT, text RIGHT, headline "Straight / from the / village / forest"): move "from the" a little toward the picture so it runs onto it (outlined, same rule as slide 2) and make "forest" (the highlighted word) a little bigger, at most 15 percent.
- Slide 3 (pictures LEFT, text RIGHT, headline "Work / that stays / in the / village"): let the headline run onto the picture the same way (choose the one or two lines that look best), so "village" is the highlighted word that sits partly on the image.
- Same for Hindi and Marathi (their headline lines differ: choose the matching lines). Overlap per line at most 0.08 * W; the text must never leave the screen; subtitle and note must not touch the pictures. Keep slide 2 as it is.
- Implement it as a small per-slide, per-line "pull toward the picture" value in the slide view, not as hard-coded pixel positions. Update `test/ui_v2_landing_geometry_test.dart` only if a rule changed; add tests that the pulled lines overlap the picture rect and stay inside the screen at 320 x 568, 360 x 800, 430 x 932, all 3 languages, light and dark, textScaler 1.5.

### Task 3: Top Deals tab strip on Home (dark mode bug)
The strip of tabs at the top of the Top Deals section: when a tab is selected in DARK mode its top part (the small "Starting at ₹39" / "Up to 24% off" text) turns white on a white background, so the text cannot be read.
- Fix it for both themes with tokens: a selected tab keeps readable contrast (dark text on the light selected tab, or light text on a dark one). Check every state: selected, not selected, light, dark, long Hindi/Marathi text.
- Give the tabs the shape the owner wants (see `ui_reference/` pictures with tab shapes): the tab is not a plain rectangle; its top corners are rounded and the selected tab joins the panel below it smoothly. Keep the existing behaviour (tap changes the section, horizontal scroll).
- Tests: the label colour has at least 4.5:1 contrast against its tab background in all four combinations (compute it in the test from the widget tree or the tokens); no overflow at 3 sizes, 3 languages, textScaler 1.5.

### Task 4: Better sign-in and create-account pages
Keep the behaviour, the keys (`google_button`, `signin_phone`, `signin_pin`, `signin_submit`, `go_signup`, `signup_name`, `signup_phone`, `signup_pin`, `signup_village`, `signup_submit`, `role_*`, `go_signin`) and the `?redirect=` handling.
Make the pages clearly better looking and easier to use:
- A proper header (round logo, a short friendly line, the language chips), generous spacing, one clear primary green button, "Continue with Google" first as it is now.
- Fields with icons, clear labels, inline error text, a show/hide switch for the PIN, number keyboard for phone and PIN, the "+91" prefix shown for the phone field.
- Create account: the three role choices become three large cards with an icon and a one-line description each (taken from existing strings; do not invent claims), the village picker becomes a searchable bottom sheet, the form is one scrolling page with a sticky bottom button.
- Keep all existing tests passing; add tests for the new show/hide PIN, the searchable village sheet and the role cards. No overflow at 3 sizes, 3 languages, light and dark, textScaler 1.5.

## 5. Deliverables

- Your commits in this folder's local git (`git log`). Do not rewrite or delete the baseline commit (`c203d99`).
- `UI_ROUND1_REPORT.md`: (a) files created or changed, (b) design decisions, (c) things you could NOT do or that need the main engineer (also copy into `CHANGE_REQUESTS.md`: for example every place where the data layer still produces a made-up word),
  (d) the exact output summary of `flutter analyze` and `flutter test` that you really ran, (e) a short list of what to check by eye on a real phone.
- Never say "verified" or "tested on a phone". You can only run analyze and the widget tests.
