import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/orders_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/shell/checkout/checkout_done_page.dart';
import 'package:vanrozgar/ui_v2/shell/orders/orders_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

/// Phases 6 and 7 together: a request sent from checkout shows up in the Orders tab.

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
        {'id': 'm1', 'sellerId': 'seller-1', 'sellerName': 'Sample Gram Sabha 1', 'sellerType': 'gramsabha', 'fulfilment': 'both', 'pricePerUnitPaise': 9000, 'mrpPerUnitPaise': 12000, 'quantityTotal': 100, 'quantitySold': 20, 'minOrderQuantity': 2, 'daysAgo': 3},
      ],
    },
  ],
};

void main() {
  testWidgets('a request sent from checkout is added to the orders of the signed-in buyer', (tester) async {
    tester.view.physicalSize = const Size(720, 3600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    uiV2LandingSeen.value = true;
    uiV2Router.go('/checkout');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(ProviderScope(
      overrides: [
        uiV2LanguageProvider.overrideWith((ref) => AppLanguage.en),
        uiV2ThemeModeProvider.overrideWith((ref) => ThemeMode.light),
        shopRepositoryProvider.overrideWithValue(SampleShopRepository.fromMap(_data)),
        cartQuantitiesProvider.overrideWith((ref) => {'fruit_mango': 3}),
        authUserProvider.overrideWith((ref) => const AuthUser(name: 'Asha', role: 'buyer', phone: '+919876543210')),
      ],
      child: MaterialApp.router(
        theme: VanRozgarTheme.lightTheme,
        darkTheme: VanRozgarTheme.darkTheme,
        routerConfig: uiV2Router,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('checkout_send_button')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutDonePage), findsOneWidget);

    final container = ProviderScope.containerOf(tester.element(find.byType(CheckoutDonePage)));
    final sent = container.read(ordersProvider).where((o) => !o.isSample).toList();
    expect(sent, hasLength(1));
    expect(sent.first.sellerId, 'seller-1');
    expect(sent.first.totalPaise, 27000);
    expect(sent.first.lines.first.minOrderQuantity, 2);
    expect(sent.first.lines.first.availableStock, 80);
    expect(container.read(visibleOrdersProvider).any((o) => o.id == sent.first.id), isTrue);

    uiV2Router.go('/orders');
    await tester.pumpAndSettle();
    expect(find.byType(OrdersPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
