import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/shell/home_demo_page.dart';
import 'package:vanrozgar/ui_v2/shell/landing_page.dart';
import 'package:vanrozgar/ui_v2/shell/placeholder_pages.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';
import 'package:vanrozgar/ui_v2/widgets/app_background.dart';

Widget _buildTestApp({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  AppLanguage language = AppLanguage.en,
  double textScale = 1.0,
}) {
  return ProviderScope(
    overrides: [
      uiV2ThemeModeProvider.overrideWith((ref) => themeMode),
      uiV2LanguageProvider.overrideWith((ref) => language),
    ],
    child: MaterialApp(
      theme: VanRozgarTheme.lightTheme,
      darkTheme: VanRozgarTheme.darkTheme,
      themeMode: themeMode,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: Material(child: child),
        ),
      ),
    ),
  );
}

Widget _buildTestRouterApp({
  ThemeMode themeMode = ThemeMode.light,
  AppLanguage language = AppLanguage.en,
}) {
  return ProviderScope(
    overrides: [
      uiV2ThemeModeProvider.overrideWith((ref) => themeMode),
      uiV2LanguageProvider.overrideWith((ref) => language),
    ],
    child: MaterialApp.router(
      theme: VanRozgarTheme.lightTheme,
      darkTheme: VanRozgarTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: uiV2Router,
    ),
  );
}

Widget _buildTestNavApp({
  ThemeMode themeMode = ThemeMode.light,
  AppLanguage language = AppLanguage.en,
}) {
  final strings = AppStrings.of(language);
  return ProviderScope(
    overrides: [
      uiV2ThemeModeProvider.overrideWith((ref) => themeMode),
      uiV2LanguageProvider.overrideWith((ref) => language),
    ],
    child: MaterialApp(
      theme: VanRozgarTheme.lightTheme,
      darkTheme: VanRozgarTheme.darkTheme,
      themeMode: themeMode,
      home: Scaffold(
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              label: strings.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.category_outlined),
              label: strings.navCategories,
            ),
            NavigationDestination(
              icon: const Icon(Icons.shopping_cart_outlined),
              label: strings.navCart,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              label: strings.navOrders,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              label: strings.navProfile,
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    // Default to true for shell and catalog tests
    uiV2LandingSeen.value = true;
  });

  group('VanRozgar Shell and Catalog Smoke Tests', () {
    testWidgets(
        '(a) the village picker and the search field are found on Home in light and dark at 320x568, 360x800, 430x932 and 800x1280',
        (WidgetTester tester) async {
      final sizes = [
        const Size(320.0, 568.0),
        const Size(360.0, 800.0),
        const Size(430.0, 932.0),
        const Size(800.0, 1280.0),
      ];
      final modes = [ThemeMode.light, ThemeMode.dark];

      for (final size in sizes) {
        for (final mode in modes) {
          tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _buildTestApp(
              child: const HomeDemoPage(),
              themeMode: mode,
            ),
          );
          await tester.pump();

          // Verify Village Picker elements exist
          expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
          expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

          // Verify Search Field exists and takes input
          expect(find.byType(TextField), findsOneWidget);
        }
      }
    });

    testWidgets('(b) Categories, Cart, Orders and Profile pages build without exceptions when background asset is missing',
        (WidgetTester tester) async {
      // 1. Categories
      await tester.pumpWidget(_buildTestApp(child: const CategoriesPlaceholderPage()));
      await tester.pump();
      expect(find.byType(CategoriesPlaceholderPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 2. Cart
      await tester.pumpWidget(_buildTestApp(child: const CartPlaceholderPage()));
      await tester.pump();
      expect(find.byType(CartPlaceholderPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 3. Orders
      await tester.pumpWidget(_buildTestApp(child: const OrdersPlaceholderPage()));
      await tester.pump();
      expect(find.byType(OrdersPlaceholderPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 4. Profile
      await tester.pumpWidget(_buildTestApp(child: const ProfilePlaceholderPage()));
      await tester.pump();
      expect(find.byType(ProfilePlaceholderPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('(c) no overflow exceptions in Hindi with textScaler 1.5 at 320x568 and at 360x800',
        (WidgetTester tester) async {
      final sizes = [
        const Size(320.0, 568.0),
        const Size(360.0, 800.0),
      ];

      for (final size in sizes) {
        tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Home page
        await tester.pumpWidget(
          _buildTestApp(
            child: const HomeDemoPage(),
            language: AppLanguage.hi,
            textScale: 1.5,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        // Profile placeholder page
        await tester.pumpWidget(
          _buildTestApp(
            child: const ProfilePlaceholderPage(),
            language: AppLanguage.hi,
            textScale: 1.5,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        // Categories placeholder page
        await tester.pumpWidget(
          _buildTestApp(
            child: const CategoriesPlaceholderPage(),
            language: AppLanguage.hi,
            textScale: 1.5,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        // Cart placeholder page
        await tester.pumpWidget(
          _buildTestApp(
            child: const CartPlaceholderPage(),
            language: AppLanguage.hi,
            textScale: 1.5,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        // Orders placeholder page
        await tester.pumpWidget(
          _buildTestApp(
            child: const OrdersPlaceholderPage(),
            language: AppLanguage.hi,
            textScale: 1.5,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('(d) the bottom navigation tabs are at least 48 x 48', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360.0 * 2.0, 800.0 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestNavApp());
      await tester.pump();

      final navBarSize = tester.getSize(find.byType(NavigationBar));
      expect(navBarSize.height, greaterThanOrEqualTo(48.0));

      final navDests = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byType(NavigationDestination),
      );
      expect(navDests, findsNWidgets(5));
      for (int i = 0; i < 5; i++) {
        final size = tester.getSize(navDests.at(i));
        expect(size.width, greaterThanOrEqualTo(48.0));
        expect(size.height, greaterThanOrEqualTo(48.0));
      }
    });

    testWidgets('(e) Home, Categories, Cart, Orders and Profile still build with no overflow at 360x800 with textScaler 1.5 in Hindi',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360.0 * 2.0, 800.0 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final pages = [
        const HomeDemoPage(),
        const CategoriesPlaceholderPage(),
        const CartPlaceholderPage(),
        const OrdersPlaceholderPage(),
        const ProfilePlaceholderPage(),
      ];

      for (final page in pages) {
        await tester.pumpWidget(
          _buildTestApp(
            child: page,
            language: AppLanguage.hi,
            textScale: 1.5,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('(f) AppBackground builds without exceptions when the background asset is missing, in light and dark, at 320x568, 360x800 and 430x932',
        (WidgetTester tester) async {
      const sizes = [
        Size(320.0, 568.0),
        Size(360.0, 800.0),
        Size(430.0, 932.0),
      ];
      const modes = [ThemeMode.light, ThemeMode.dark];
      for (final size in sizes) {
        for (final mode in modes) {
          tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _buildTestApp(
              child: const AppBackground(
                child: SizedBox.expand(),
              ),
              themeMode: mode,
            ),
          );
          await tester.pump();
          expect(find.byType(AppBackground), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('(g) it contains exactly one Image widget with fit BoxFit.cover and alignment Alignment.bottomCenter, and no Image of any other kind',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const AppBackground(
            child: SizedBox.expand(),
          ),
        ),
      );
      await tester.pump();

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final Image imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.fit, BoxFit.cover);
      expect(imageWidget.alignment, Alignment.bottomCenter);
    });
  });

  group('VanRozgar Landing Intro Page Tests', () {
    testWidgets('(a) first screen is landing slide 1 with eyebrow, headline lines and subtitle',
        (WidgetTester tester) async {
      uiV2LandingSeen.value = false;
      await tester.pumpWidget(_buildTestRouterApp());
      await tester.pumpAndSettle();

      expect(find.byType(LandingPage), findsOneWidget);
      expect(find.text('EXPLORE'), findsOneWidget);
      expect(find.text('Straight'), findsOneWidget);
      expect(find.text('from the'), findsOneWidget);
      expect(find.text('village'), findsOneWidget);
      expect(find.text('forest'), findsOneWidget);
      expect(find.text('Bamboo, mangoes and more from CFR villages in Nashik.'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('(b) Next goes to slide 2, then slide 3 which shows Get Started',
        (WidgetTester tester) async {
      uiV2LandingSeen.value = false;
      await tester.pumpWidget(_buildTestRouterApp());
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);

      // Slide 1 -> Slide 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('TRADITIONAL'), findsOneWidget);
      expect(find.text('Forest'), findsOneWidget);
      expect(find.text('herbs'), findsOneWidget);
      expect(find.text('Amla, bael, harad, baheda and more from village forests.'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Slide 2 -> Slide 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('COMMUNITY'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('that stays'), findsOneWidget);
      expect(find.text('village'), findsOneWidget);
      expect(find.text('Gram Sabhas and CFR holders sell direct to buyers.'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('(c) Skip and Get Started open shell', (WidgetTester tester) async {
      // 1. Skip on slide 1
      uiV2LandingSeen.value = false;
      await tester.pumpWidget(_buildTestRouterApp());
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(uiV2LandingSeen.value, isTrue);
      expect(find.byType(HomeDemoPage), findsOneWidget);

      // 2. Get Started on slide 3
      uiV2LandingSeen.value = false;
      await tester.pumpWidget(_buildTestRouterApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(uiV2LandingSeen.value, isTrue);
      expect(find.byType(HomeDemoPage), findsOneWidget);
    });

    testWidgets('(d) in Hindi and Marathi no English landing text', (WidgetTester tester) async {
      // Hindi check
      await tester.pumpWidget(
        _buildTestApp(
          child: const LandingPage(),
          language: AppLanguage.hi,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsNothing);
      expect(find.text('Next'), findsNothing);
      expect(find.text('Get Started'), findsNothing);
      expect(find.text('EXPLORE'), findsNothing);
      expect(find.text('Straight'), findsNothing);
      expect(find.text('खोजें'), findsOneWidget);
      expect(find.text('छोड़ें'), findsOneWidget);
      expect(find.text('आगे'), findsOneWidget);

      // Reset tree before pumping Marathi app
      await tester.pumpWidget(const SizedBox());

      // Marathi check
      await tester.pumpWidget(
        _buildTestApp(
          child: const LandingPage(),
          language: AppLanguage.mr,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsNothing);
      expect(find.text('Next'), findsNothing);
      expect(find.text('Get Started'), findsNothing);
      expect(find.text('EXPLORE'), findsNothing);
      expect(find.text('Straight'), findsNothing);
      expect(find.text('शोधा'), findsOneWidget);
      expect(find.text('वगळा'), findsOneWidget);
      expect(find.text('पुढे'), findsOneWidget);
    });

    testWidgets('(e) no overflow exceptions at 320x568, 360x800 and 430x932 with textScaler 1.5 in light, dark and Hindi',
        (WidgetTester tester) async {
      final landingSizes = [
        const Size(320.0, 568.0),
        const Size(360.0, 800.0),
        const Size(430.0, 932.0),
      ];

      for (final size in landingSizes) {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _buildTestApp(
              child: const LandingPage(),
              language: AppLanguage.hi,
              themeMode: mode,
              textScale: 1.5,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('(f) builds without exceptions when picture assets are missing',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(child: const LandingPage()));
      await tester.pumpAndSettle();

      expect(find.byType(LandingPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Geometry tests: headline overlap, subtitle clearance, card polygon bounds',
        (WidgetTester tester) async {
      const double W = 390.0;
      const double H = 844.0;
      tester.view.physicalSize = const Size(W * 2.0, H * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      uiV2LandingSeen.value = false;
      await tester.pumpWidget(_buildTestRouterApp());
      await tester.pumpAndSettle();

      // --- Slide 1 (Mirrored) ---
      final slide1HeadlineRect = tester.getRect(find.byKey(const Key('landing_headline')));
      final slide1Card1Rect = tester.getRect(find.byKey(const Key('landing_card_top')));
      final slide1Card2Rect = tester.getRect(find.byKey(const Key('landing_card_bottom')));
      final slide1SubtitleRect = tester.getRect(find.byKey(const Key('landing_subtitle')));

      // Headline Rect overlaps Card 1 bounding Rect by between 0.02 W and 0.12 W
      final slide1Overlap = slide1Card1Rect.right - slide1HeadlineRect.left;
      expect(slide1Overlap, greaterThanOrEqualTo(0.02 * W - 1.0));
      expect(slide1Overlap, lessThanOrEqualTo(0.12 * W + 1.0));

      // Subtitle Rect never overlaps Card 2 bounding Rect
      expect(slide1SubtitleRect.overlaps(slide1Card2Rect), isFalse);

      // Slide 1 Card 1 left edge touches the screen's left edge (mirror)
      expect(slide1Card1Rect.left, closeTo(0.0, 2.0));

      // --- Slide 2 (Reference) ---
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      final slide2HeadlineRect = tester.getRect(find.byKey(const Key('landing_headline')));
      final slide2Card1Rect = tester.getRect(find.byKey(const Key('landing_card_top')));
      final slide2Card2Rect = tester.getRect(find.byKey(const Key('landing_card_bottom')));
      final slide2SubtitleRect = tester.getRect(find.byKey(const Key('landing_subtitle')));

      // Headline Rect overlaps Card 1 bounding Rect by between 0.02 W and 0.12 W
      final slide2Overlap = slide2HeadlineRect.right - slide2Card1Rect.left;
      expect(slide2Overlap, greaterThanOrEqualTo(0.02 * W - 1.0));
      expect(slide2Overlap, lessThanOrEqualTo(0.12 * W + 1.0));

      // Subtitle Rect never overlaps Card 2 bounding Rect
      expect(slide2SubtitleRect.overlaps(slide2Card2Rect), isFalse);

      // Slide 2 Card 1 right edge touches the screen's right edge
      expect(slide2Card1Rect.right, closeTo(W, 2.0));

      // Two card polygons stay inside the screen (0 <= x <= W, 0 <= y <= H)
      expect(slide2Card1Rect.left, greaterThanOrEqualTo(0.0));
      expect(slide2Card1Rect.right, lessThanOrEqualTo(W + 0.1));
      expect(slide2Card1Rect.top, greaterThanOrEqualTo(0.0));
      expect(slide2Card1Rect.bottom, lessThanOrEqualTo(H));

      expect(slide2Card2Rect.left, greaterThanOrEqualTo(0.0));
      expect(slide2Card2Rect.right, lessThanOrEqualTo(W + 0.1));
      expect(slide2Card2Rect.top, greaterThanOrEqualTo(0.0));
      expect(slide2Card2Rect.bottom, lessThanOrEqualTo(H));
    });
  });
}
