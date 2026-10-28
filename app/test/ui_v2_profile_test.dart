import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/l10n/profile_strings.dart';
import 'package:vanrozgar/ui_v2/l10n/shop_extra_strings.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/shell/orders/orders_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

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
          'sellerId': 's1',
          'sellerName': 'Sample Seller One',
          'fulfilment': 'pickup',
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
  ],
};

const AuthUser _buyerUser = AuthUser(
  name: 'Kavita Deshmukh',
  role: 'buyer',
  phone: '9876543210',
  villageId: 'dongargaon',
);

const AuthUser _gramSabhaUser = AuthUser(
  name: 'Ramesh Madavi',
  role: 'gramsabha',
  phone: '9823012345',
  villageId: 'bhatode',
);

const AuthUser _cfrHolderUser = AuthUser(
  name: 'Sunita Gavit',
  role: 'cfrholder',
  phone: '9422098765',
  villageId: 'ambai',
);

Widget _app({
  AppLanguage language = AppLanguage.en,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  AuthUser? user,
}) {
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => language),
      uiV2ThemeModeProvider.overrideWith((ref) => mode),
      shopRepositoryProvider.overrideWithValue(
        SampleShopRepository.fromMap(_data),
      ),
      authUserProvider.overrideWith((ref) => user),
    ],
    child: Consumer(
      builder: (context, ref, _) {
        final watchedMode = ref.watch(uiV2ThemeModeProvider);
        return MaterialApp.router(
          theme: VanRozgarTheme.lightTheme,
          darkTheme: VanRozgarTheme.darkTheme,
          themeMode: watchedMode,
          routerConfig: uiV2Router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          ),
        );
      },
    ),
  );
}

void _tall(WidgetTester tester, {double w = 360, double h = 1800}) {
  tester.view.physicalSize = Size(w * 2.0, h * 2.0);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _open(
  WidgetTester tester,
  Widget app,
  String path,
) async {
  uiV2LandingSeen.value = true;
  uiV2Router.go(path);
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  group('1. Guest and signed-in account card', () {
    testWidgets(
      'Guest card shows Google first, then Sign in, then Create account; Google shows coming soon snackbar',
      (tester) async {
        _tall(tester);
        await _open(tester, _app(), '/profile');

        final googleFinder = find.byKey(const Key('profile_google'));
        final signInFinder = find.byKey(const Key('profile_signin'));
        final signUpFinder = find.byKey(const Key('profile_signup'));

        expect(googleFinder, findsOneWidget);
        expect(signInFinder, findsOneWidget);
        expect(signUpFinder, findsOneWidget);

        // Verify top-to-bottom visual order: Google -> Sign in -> Create account.
        final googleY = tester.getTopLeft(googleFinder).dy;
        final signInY = tester.getTopLeft(signInFinder).dy;
        final signUpY = tester.getTopLeft(signUpFinder).dy;
        expect(googleY, lessThan(signInY));
        expect(signInY, lessThan(signUpY));

        // Tapping Continue with Google shows coming soon snackbar.
        await tester.tap(googleFinder);
        await tester.pump();
        expect(find.text(AppStrings.en.googleSoon), findsOneWidget);
      },
    );

    testWidgets(
      'Guest Sign in and Create account buttons open /signin and /signup',
      (tester) async {
        _tall(tester);
        await _open(tester, _app(), '/profile');

        await tester.tap(find.byKey(const Key('profile_signin')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('signin_submit')), findsOneWidget);

        uiV2Router.go('/profile');
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('profile_signup')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('signup_submit')), findsOneWidget);
      },
    );

    testWidgets(
      'Signed-in card shows avatar initial, name, role words, phone, village, and Sign out asks first',
      (tester) async {
        _tall(tester);
        await _open(tester, _app(user: _gramSabhaUser), '/profile');

        expect(find.byKey(const Key('profile_avatar')), findsOneWidget);
        expect(find.byKey(const Key('profile_avatar_initial')), findsOneWidget);
        expect(find.text('R'), findsWidgets);
        expect(find.text('Ramesh Madavi'), findsOneWidget);
        expect(find.text('Gram Sabha'), findsOneWidget);
        expect(find.text('9823012345'), findsOneWidget);
        expect(find.textContaining('Bhatode'), findsOneWidget);

        final signOutBtn = find.byKey(const Key('signout_button'));
        expect(signOutBtn, findsOneWidget);

        // Tap Sign out -> confirmation dialog appears first.
        await tester.tap(signOutBtn);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('signout_confirm_dialog')), findsOneWidget);

        // Cancel -> remains signed in.
        await tester.tap(find.byKey(const Key('signout_cancel')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('signout_confirm_dialog')), findsNothing);
        expect(find.text('Ramesh Madavi'), findsOneWidget);

        // Tap Sign out again and confirm -> clears user and returns to guest card.
        await tester.tap(signOutBtn);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('signout_confirm')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('profile_google')), findsOneWidget);
      },
    );
  });

  group('2. Settings (Language & Appearance)', () {
    testWidgets(
      'English is default; tapping हिन्दी and मराठी switches the whole Profile page',
      (tester) async {
        _tall(tester);
        await _open(tester, _app(), '/profile');

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Appearance'), findsOneWidget);

        // Tap हिन्दी
        await tester.tap(find.byKey(const Key('profile_lang_hi')));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.hi.pfSettingsSectionTitle), findsOneWidget);
        expect(find.text(AppStrings.hi.languageLabel), findsOneWidget);
        expect(find.text(AppStrings.hi.pfAboutTitle), findsOneWidget);

        // Tap मराठी
        await tester.tap(find.byKey(const Key('profile_lang_mr')));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.mr.pfSettingsSectionTitle), findsOneWidget);
        expect(find.text(AppStrings.mr.languageLabel), findsOneWidget);
        expect(find.text(AppStrings.mr.pfAboutTitle), findsOneWidget);

        // Tap English
        await tester.tap(find.byKey(const Key('profile_lang_en')));
        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsOneWidget);
      },
    );

    testWidgets(
      'Appearance selector writes uiV2ThemeModeProvider (System, Light, Dark)',
      (tester) async {
        _tall(tester);
        await _open(tester, _app(), '/profile');

        final element = tester.element(
          find.byKey(const Key('profile_scroll_view')),
        );
        final container = ProviderScope.containerOf(element);

        await tester.tap(find.byKey(const Key('profile_theme_dark')));
        await tester.pumpAndSettle();
        expect(container.read(uiV2ThemeModeProvider), ThemeMode.dark);

        await tester.tap(find.byKey(const Key('profile_theme_light')));
        await tester.pumpAndSettle();
        expect(container.read(uiV2ThemeModeProvider), ThemeMode.light);

        await tester.tap(find.byKey(const Key('profile_theme_system')));
        await tester.pumpAndSettle();
        expect(container.read(uiV2ThemeModeProvider), ThemeMode.system);
      },
    );
  });

  group('3. Rows by role (Guest, Buyer, Gram Sabha, CFR holder)', () {
    testWidgets('Guest sees no My activity section and only guest More rows', (
      tester,
    ) async {
      _tall(tester);
      await _open(tester, _app(user: null), '/profile');

      expect(find.byKey(const Key('profile_activity_orders')), findsNothing);
      expect(find.byKey(const Key('profile_activity_sell')), findsNothing);

      expect(find.byKey(const Key('profile_more_delivery')), findsOneWidget);
      expect(find.byKey(const Key('profile_more_about')), findsOneWidget);
      expect(find.byKey(const Key('profile_more_credits')), findsOneWidget);
      expect(find.byKey(const Key('profile_more_privacy')), findsOneWidget);

      expect(find.byKey(const Key('profile_more_messages')), findsNothing);
      expect(find.byKey(const Key('profile_more_barter')), findsNothing);
      expect(find.byKey(const Key('profile_more_livelihood')), findsNothing);
    });

    testWidgets(
      'Buyer sees My orders (not Sell on VanMitra), messages & barter (not livelihood)',
      (tester) async {
        _tall(tester);
        await _open(tester, _app(user: _buyerUser), '/profile');

        expect(
          find.byKey(const Key('profile_activity_orders')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('profile_activity_sell')), findsNothing);

        expect(find.byKey(const Key('profile_more_messages')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_barter')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_delivery')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_livelihood')), findsNothing);
        expect(find.byKey(const Key('profile_more_about')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_credits')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_privacy')), findsOneWidget);

        // Tapping My orders navigates to /orders
        await tester.tap(find.byKey(const Key('profile_activity_orders')));
        await tester.pumpAndSettle();
        expect(find.byType(OrdersPage), findsOneWidget);
      },
    );

    testWidgets(
      'Gram Sabha sees My orders and Sell on VanMitra, messages & barter, but not livelihood',
      (tester) async {
        _tall(tester);
        await _open(tester, _app(user: _gramSabhaUser), '/profile');

        expect(
          find.byKey(const Key('profile_activity_orders')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('profile_activity_sell')), findsOneWidget);

        expect(find.byKey(const Key('profile_more_messages')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_barter')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_delivery')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_livelihood')), findsNothing);
      },
    );

    testWidgets(
      'CFR holder sees My orders, Sell on VanMitra, messages, barter, delivery, and livelihood',
      (tester) async {
        _tall(tester);
        await _open(tester, _app(user: _cfrHolderUser), '/profile');

        expect(
          find.byKey(const Key('profile_activity_orders')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('profile_activity_sell')), findsOneWidget);

        expect(find.byKey(const Key('profile_more_messages')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_barter')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_delivery')), findsOneWidget);
        expect(
          find.byKey(const Key('profile_more_livelihood')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('profile_more_about')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_credits')), findsOneWidget);
        expect(find.byKey(const Key('profile_more_privacy')), findsOneWidget);
      },
    );
  });

  group('4. About, Credits, Privacy, and /more/:key navigation & back arrow', () {
    testWidgets(
      'All More rows open their subpage with content from profile_strings and return via back arrow',
      (tester) async {
        _tall(tester);
        await _open(tester, _app(user: _cfrHolderUser), '/profile');

        final rowToExpectedText = <String, String>{
          'profile_more_about': AppStrings.en.pfAboutSentences.first,
          'profile_more_credits':
              AppStrings.en.pfCreditGroups.first.items.first.what,
          'profile_more_privacy': AppStrings.en.pfPrivacySections.first.body,
          'profile_more_messages':
              AppStrings.en.pfMorePageSentences('messages').first,
          'profile_more_barter':
              AppStrings.en.pfMorePageSentences('barter').first,
          'profile_more_delivery':
              AppStrings.en.pfMorePageSentences('delivery').first,
          'profile_more_livelihood':
              AppStrings.en.pfMorePageSentences('livelihood').first,
        };

        for (final entry in rowToExpectedText.entries) {
          final rowFinder = find.byKey(Key(entry.key));
          await tester.ensureVisible(rowFinder);
          await tester.tap(rowFinder);
          await tester.pumpAndSettle();

          expect(find.text(entry.value), findsOneWidget);

          final backFinder = find.byKey(const Key('profile_subpage_back'));
          expect(backFinder, findsOneWidget);
          await tester.tap(backFinder);
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('profile_scroll_view')), findsOneWidget);
        }
      },
    );

    testWidgets(
      'Unknown /more/xyz route shows friendly empty page without error',
      (tester) async {
        _tall(tester);
        await _open(tester, _app(), '/more/xyz');

        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('more_unknown_card')), findsOneWidget);
        expect(find.text(AppStrings.en.pfUnknownMoreBody), findsOneWidget);

        await tester.tap(find.byKey(const Key('more_unknown_back_button')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('profile_scroll_view')), findsOneWidget);
      },
    );
  });

  group('5. Hindi and Marathi: no unexpected English on /profile and subpages', () {
    final latinWordRegex = RegExp(r'[A-Za-z]+');
    const allowedTokens = <String>{
      'English',
      'UPI',
      'Google',
      'G',
      'VanMitra',
      'Sample',
    };

    void assertNoUnexpectedLatin(
      WidgetTester tester,
      String route,
      AppLanguage lang,
    ) {
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final textWidget in textWidgets) {
        final raw = textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '';
        for (final match in latinWordRegex.allMatches(raw)) {
          final word = match.group(0)!;
          expect(
            allowedTokens.contains(word),
            isTrue,
            reason:
                'Unexpected Latin word "$word" found in "$raw" on $route (${lang.name})',
          );
        }
      }
    }

    for (final lang in [AppLanguage.hi, AppLanguage.mr]) {
      testWidgets(
        'No unexpected English words on /profile and all subpages in ${lang.name}',
        (tester) async {
          const localizedCfrUser = AuthUser(
            name: 'सुनीता गावित',
            role: 'cfrholder',
            phone: '9422098765',
            villageId: 'ambai',
          );

          final routes = <String>[
            '/profile',
            '/about',
            '/credits',
            '/privacy',
            '/more/messages',
            '/more/barter',
            '/more/delivery',
            '/more/livelihood',
            '/more/xyz',
          ];

          _tall(tester);
          await _open(
            tester,
            _app(language: lang, user: localizedCfrUser),
            '/profile',
          );

          for (final route in routes) {
            uiV2Router.go(route);
            await tester.pumpAndSettle();
            assertNoUnexpectedLatin(tester, route, lang);
          }

          // Also check guest /profile in Hindi/Marathi
          await _open(tester, _app(language: lang, user: null), '/profile');
          assertNoUnexpectedLatin(tester, '/profile (guest)', lang);
        },
      );
    }
  });

  group('6. No overflow across sizes, themes, languages, and textScaler 1.5', () {
    const sizes = <Size>[
      Size(320, 568),
      Size(360, 800),
      Size(430, 932),
    ];
    const langs = <AppLanguage>[
      AppLanguage.en,
      AppLanguage.hi,
      AppLanguage.mr,
    ];
    const modes = <ThemeMode>[ThemeMode.light, ThemeMode.dark];

    testWidgets(
      '/profile renders without overflow for all 4 identities across 320x568, 360x800, 430x932, light/dark, en/hi/mr, textScaler 1.5',
      (tester) async {
        final identities = <AuthUser?>[
          null,
          _buyerUser,
          _gramSabhaUser,
          _cfrHolderUser,
        ];

        for (final size in sizes) {
          for (final mode in modes) {
            for (final lang in langs) {
              for (final identity in identities) {
                _tall(tester, w: size.width, h: size.height);
                await _open(
                  tester,
                  _app(
                    mode: mode,
                    language: lang,
                    textScale: 1.5,
                    user: identity,
                  ),
                  '/profile',
                );
                expect(
                  tester.takeException(),
                  isNull,
                  reason:
                      'Overflow on /profile size=$size mode=$mode lang=${lang.name} role=${identity?.role ?? "guest"}',
                );
              }
            }
          }
        }
      },
    );

    testWidgets(
      '/about, /credits, /privacy, /more/messages render without overflow across 320x568, 360x800, 430x932, light/dark, en/hi/mr, textScaler 1.5',
      (tester) async {
        const subRoutes = <String>[
          '/about',
          '/credits',
          '/privacy',
          '/more/messages',
        ];

        for (final size in sizes) {
          for (final mode in modes) {
            for (final lang in langs) {
              for (final route in subRoutes) {
                _tall(tester, w: size.width, h: size.height);
                await _open(
                  tester,
                  _app(
                    mode: mode,
                    language: lang,
                    textScale: 1.5,
                    user: _cfrHolderUser,
                  ),
                  route,
                );
                expect(
                  tester.takeException(),
                  isNull,
                  reason:
                      'Overflow on $route size=$size mode=$mode lang=${lang.name}',
                );
              }
            }
          }
        }
      },
    );
  });
}
