import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/sell_catalog.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/sell_models.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/sell_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/shell/sell/sell_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

/// Widget tests for `/sell` (My listings): role gate for guest and buyer, seller listings list,
/// empty state, pause/resume status chip, remove confirmation dialog, Hindi/Marathi language check,
/// and no-overflow checks across sizes, themes, languages, and textScaler 1.5.
/// Only small inline data is used (no asset files are read).

const Map<String, dynamic> _data = {
  'products': [
    {
      'productCode': 'fruit_mango',
      'categorySlug': 'fruit',
      'image': 'assets/catalog/fruit_mango.jpg',
      'pictureNote': 'ready',
      'notForEating': false,
      'title': {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
      'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
      'listings': [
        {
          'id': 'm1',
          'sellerType': 'gramsabha',
          'pricePerUnitPaise': 9900,
          'mrpPerUnitPaise': 12000,
          'quantityTotal': 300,
          'quantitySold': 75,
          'minOrderQuantity': 5,
          'daysAgo': 3,
        },
      ],
    },
    {
      'productCode': 'bamboo',
      'categorySlug': 'handicrafts-bamboo',
      'image': 'assets/catalog/bamboo.jpg',
      'pictureNote': 'ready',
      'notForEating': false,
      'title': {'en': 'Bamboo', 'hi': 'बाँस', 'mr': 'बांबू'},
      'unit': {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
      'listings': [
        {
          'id': 'b1',
          'sellerType': 'cfrholder',
          'pricePerUnitPaise': 11200,
          'mrpPerUnitPaise': 14000,
          'quantityTotal': 100,
          'quantitySold': 20,
          'minOrderQuantity': 2,
          'daysAgo': 5,
        },
      ],
    },
    {
      'productCode': 'fruit_awla',
      'categorySlug': 'fruit',
      'image': 'assets/catalog/fruit_awla.jpg',
      'pictureNote': 'ready',
      'notForEating': false,
      'title': {'en': 'Amla', 'hi': 'आँवला', 'mr': 'आवळा'},
      'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
      'listings': <Map<String, dynamic>>[],
    },
  ],
};

const AuthUser _gramSabhaSeller = AuthUser(
  name: 'Dongargaon Gram Sabha',
  role: 'gramsabha',
  phone: '+919876543210',
  villageId: 'dongargaon',
);

const AuthUser _cfrSeller = AuthUser(
  name: 'Ramesh Pawar',
  role: 'cfrholder',
  phone: '+919876543211',
  villageId: 'ambai',
);

const AuthUser _buyerUser = AuthUser(
  name: 'Nashik Traders',
  role: 'buyer',
  phone: '+919876543212',
);

Widget _app({
  AppLanguage language = AppLanguage.en,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  AuthUser? user = _gramSabhaSeller,
  List<MyListing>? listings,
}) {
  final inlineProducts = parseSellCatalogMap(_data);
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => language),
      uiV2ThemeModeProvider.overrideWith((ref) => mode),
      shopRepositoryProvider.overrideWithValue(SampleShopRepository.fromMap(_data)),
      sellCatalogProvider.overrideWith((ref) async => inlineProducts),
      authUserProvider.overrideWith((ref) => user),
      if (listings != null) myListingsProvider.overrideWith((ref) => listings),
    ],
    child: MaterialApp.router(
      theme: VanRozgarTheme.lightTheme,
      darkTheme: VanRozgarTheme.darkTheme,
      themeMode: mode,
      routerConfig: uiV2Router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
    ),
  );
}

void _tall(WidgetTester tester, {double w = 360, double h = 1800}) {
  tester.view.physicalSize = Size(w * 2.0, h * 2.0);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _open(WidgetTester tester, Widget app, String path) async {
  uiV2LandingSeen.value = true;
  uiV2Router.go(path);
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  group('/sell role gate (guest, buyer, seller)', () {
    testWidgets('guest sees "Selling is for Gram Sabhas and CFR holders" with Sign in and Create account, and no form/listings',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(user: null), '/sell');

      expect(find.byType(SellPage), findsOneWidget);
      expect(find.text('Selling is for Gram Sabhas and CFR holders'), findsOneWidget);
      expect(find.byKey(const Key('sell_guest_signin')), findsOneWidget);
      expect(find.byKey(const Key('sell_guest_signup')), findsOneWidget);
      expect(find.byKey(const Key('sell_add_listing_button')), findsNothing);
    });

    testWidgets('buyer sees "Selling is for Gram Sabhas and CFR holders" without Sign in / Create account and no listings',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _buyerUser), '/sell');

      expect(find.text('Selling is for Gram Sabhas and CFR holders'), findsOneWidget);
      expect(find.byKey(const Key('sell_guest_signin')), findsNothing);
      expect(find.byKey(const Key('sell_guest_signup')), findsNothing);
      expect(find.byKey(const Key('sell_add_listing_button')), findsNothing);
    });

    testWidgets('Gram Sabha and CFR holder sellers see the list and the green "Add a listing" button', (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _gramSabhaSeller), '/sell');
      expect(find.byKey(const Key('sell_add_listing_button')), findsOneWidget);
      expect(find.text('Mango'), findsOneWidget);
      expect(find.text('Bamboo'), findsOneWidget);
      expect(find.text('Amla'), findsOneWidget);
      expect(find.text('Sample'), findsWidgets);

      await _open(tester, _app(user: _cfrSeller), '/sell');
      expect(find.byKey(const Key('sell_add_listing_button')), findsOneWidget);
      expect(find.text('Mango'), findsOneWidget);
    });

    testWidgets('empty state shows message and the "Add a listing" button', (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _gramSabhaSeller, listings: const <MyListing>[]), '/sell');

      expect(find.byKey(const Key('sell_empty_state')), findsOneWidget);
      expect(find.byKey(const Key('sell_add_listing_button')), findsOneWidget);
      expect(find.text('Add a listing'), findsOneWidget);
    });
  });

  group('/sell listing actions: Pause/Resume and Remove confirmation dialog', () {
    testWidgets('Pause and Resume toggle the status chip between Active and Paused', (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _gramSabhaSeller), '/sell');

      // First sample listing ('sample-my-1') starts Active
      expect(
         find.descendant(
          of: find.byKey(const Key('listing_status_sample-my-1')),
          matching: find.text('Active'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('toggle_listing_sample-my-1')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('listing_status_sample-my-1')),
          matching: find.text('Paused'),
        ),
        findsOneWidget,
      );

      // Resume it back to Active
      await tester.tap(find.byKey(const Key('toggle_listing_sample-my-1')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('listing_status_sample-my-1')),
          matching: find.text('Active'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Remove asks first; Cancel keeps the card, Remove deletes it', (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _gramSabhaSeller), '/sell');

      expect(find.byKey(const Key('my_listing_card_sample-my-1')), findsOneWidget);

      await tester.tap(find.byKey(const Key('remove_listing_sample-my-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('remove_listing_dialog')), findsOneWidget);
      expect(find.text('Remove listing?'), findsOneWidget);
      expect(find.text('Remove Mango from your listings?'), findsOneWidget);

      // Cancel keeps it
      await tester.tap(find.byKey(const Key('remove_dialog_cancel')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('remove_listing_dialog')), findsNothing);
      expect(find.byKey(const Key('my_listing_card_sample-my-1')), findsOneWidget);

      // Confirm removes it
      await tester.tap(find.byKey(const Key('remove_listing_sample-my-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('remove_dialog_confirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('my_listing_card_sample-my-1')), findsNothing);
    });
  });

  group('/sell Hindi and Marathi have no English text', () {
    final latinRe = RegExp(r'[A-Za-z]');

    void expectNoEnglishInVisibleText(WidgetTester tester, AppLanguage lang) {
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final w in textWidgets) {
        final data = w.data ?? '';
        if (data.isEmpty) continue;
        expect(
          latinRe.hasMatch(data),
          isFalse,
          reason: 'Found English letters on /sell in $lang: "$data"',
        );
      }
    }

    testWidgets('no English on /sell (list, empty, guest, and remove dialog) in Hindi and Marathi', (tester) async {
      _tall(tester);
      for (final lang in [AppLanguage.hi, AppLanguage.mr]) {
        // Seller with listings + remove dialog
        await _open(tester, _app(language: lang, user: _gramSabhaSeller), '/sell');
        expectNoEnglishInVisibleText(tester, lang);

        await tester.tap(find.byKey(const Key('remove_listing_sample-my-1')));
        await tester.pumpAndSettle();
        expectNoEnglishInVisibleText(tester, lang);
        await tester.tap(find.byKey(const Key('remove_dialog_cancel')));
        await tester.pumpAndSettle();

        // Empty state
        await _open(tester, _app(language: lang, user: _gramSabhaSeller, listings: const []), '/sell');
        expectNoEnglishInVisibleText(tester, lang);

        // Guest gate
        await _open(tester, _app(language: lang, user: null), '/sell');
        expectNoEnglishInVisibleText(tester, lang);
      }
    });
  });

  group('No overflow on /sell and remove dialog', () {
    testWidgets('/sell (with listings, empty, and remove dialog) at 320x568, 360x800, 430x932, light & dark, en/hi/mr, textScaler 1.5',
        (tester) async {
      const sizes = [Size(320, 568), Size(360, 800), Size(430, 932)];
      for (final size in sizes) {
        for (final lang in AppLanguage.values) {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            _tall(tester, w: size.width, h: size.height);

            // With listings + dialog
            await _open(
              tester,
              _app(language: lang, mode: mode, textScale: 1.5, user: _gramSabhaSeller),
              '/sell',
            );
            expect(tester.takeException(), isNull, reason: '/sell list $size $lang $mode');

            await tester.tap(find.byKey(const Key('remove_listing_sample-my-1')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '/sell dialog $size $lang $mode');
            await tester.tap(find.byKey(const Key('remove_dialog_cancel')));
            await tester.pumpAndSettle();

            // Empty state
            await _open(
              tester,
              _app(language: lang, mode: mode, textScale: 1.5, user: _gramSabhaSeller, listings: const []),
              '/sell',
            );
            expect(tester.takeException(), isNull, reason: '/sell empty $size $lang $mode');
          }
        }
      }
    });
  });
}

