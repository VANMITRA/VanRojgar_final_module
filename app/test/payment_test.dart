import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/delivery/delivery_jobs_screen.dart';
import 'package:vanrozgar/features/trade/payment_card.dart';
import 'package:vanrozgar/shared/models/order.dart';

OrderModel _order({
  String method = 'upi',
  String status = 'awaiting_payment',
  String fulfilment = 'pickup',
  String orderStatus = 'approved',
  String? reference,
}) =>
    OrderModel.fromJson({
      '_id': 'o1',
      'requestId': 'r1',
      'buyerId': 'buyer',
      'sellerId': 'seller',
      'line': {
        'listingId': 'l1',
        'title': {'mr': 'बांबू', 'en': 'Bamboo poles'},
        'quantity': 3,
        'unit': 'piece',
        'pricePerUnitPaise': 10000,
        'totalPaise': 30000,
      },
      'orderStatus': orderStatus,
      'paymentMethod': method,
      'paymentStatus': status,
      'fulfilment': {'method': fulfilment},
      if (reference != null) 'payment': {'reference': reference},
      'timeline': [],
      'createdAt': '2026-10-26',
    });

Future<void> _pump(WidgetTester tester, OrderModel order, {bool buyer = false, bool seller = false}) async {
  await tester.binding.setSurfaceSize(const Size(420, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: PaymentCard(order: order, isBuyer: buyer, isSeller: seller)))),
  ));
}

void main() {
  test('an order from the server carries the payment method, the reference and how it is fulfilled', () {
    final o = _order(status: 'payment_reported', reference: 'REF123456789', fulfilment: 'delivery');
    expect(o.paymentMethod, 'upi');
    expect(o.paymentStatus, 'payment_reported');
    expect(o.paymentReference, 'REF123456789');
    expect(o.fulfilmentMethod, 'delivery');
    final old = OrderModel.fromJson({..._json(), 'paymentStatus': 'demo_pending'}..remove('paymentMethod'));
    expect(old.paymentMethod, 'cod', reason: 'older orders have no method');
  });

  testWidgets('UPI, waiting: the buyer can open a UPI app and report the payment; the seller only waits', (tester) async {
    await _pump(tester, _order(), buyer: true);
    expect(find.textContaining('Open UPI app'), findsOneWidget);
    expect(find.textContaining('I have paid'), findsOneWidget);
    expect(find.textContaining('cannot see your bank'), findsOneWidget);

    await _pump(tester, _order(), seller: true);
    expect(find.textContaining('Waiting for the buyer'), findsOneWidget);
    expect(find.textContaining('Open UPI app'), findsNothing);
    expect(find.textContaining('confirm'), findsNothing);
  });

  testWidgets('a reference that is too short is refused before anything is sent', (tester) async {
    await _pump(tester, _order(), buyer: true);
    await tester.enterText(find.byType(TextField), '12');
    await tester.tap(find.textContaining('I have paid'));
    await tester.pump();
    expect(find.textContaining('Enter the payment reference'), findsOneWidget);
  });

  testWidgets('UPI, reported: the seller can confirm; nobody else can; it is not called confirmed yet', (tester) async {
    final o = _order(status: 'payment_reported', reference: 'REF123456789');
    await _pump(tester, o, seller: true);
    expect(find.textContaining('not yet confirmed'), findsOneWidget);
    expect(find.textContaining('REF123456789'), findsOneWidget);
    expect(find.textContaining('Money arrived, confirm'), findsOneWidget);

    await _pump(tester, o, buyer: true);
    expect(find.textContaining('Money arrived, confirm'), findsNothing);
    expect(find.textContaining('seller will confirm'), findsOneWidget);
  });

  testWidgets('UPI, confirmed: says the seller confirmed', (tester) async {
    await _pump(tester, _order(status: 'payment_confirmed', reference: 'REF123456789'), buyer: true);
    expect(find.textContaining('confirmed by the seller'), findsOneWidget);
  });

  testWidgets('cash on delivery: a delivery order is collected by the partner, a pickup by the seller', (tester) async {
    await _pump(tester, _order(method: 'cod', status: 'cod_pending', fulfilment: 'delivery'), seller: true);
    expect(find.textContaining('delivery partner collects'), findsOneWidget);
    expect(find.textContaining('Cash received'), findsNothing, reason: 'the seller does not take cash on a delivery order');

    await _pump(tester, _order(method: 'cod', status: 'cod_pending'), seller: true);
    expect(find.textContaining('Cash received'), findsOneWidget);

    await _pump(tester, _order(method: 'cod', status: 'cod_pending'), buyer: true);
    expect(find.textContaining('Cash received'), findsNothing);

    await _pump(tester, _order(method: 'cod', status: 'cash_received'), buyer: true);
    expect(find.textContaining('marked as received in cash'), findsOneWidget);
  });

  testWidgets('older and barter orders do not pretend to have a payment', (tester) async {
    await _pump(tester, _order(status: 'not_required'));
    expect(find.textContaining('barter'), findsOneWidget);
    await _pump(tester, _order(status: 'demo_pending'));
    expect(find.textContaining('no payment inside the app'), findsOneWidget);
  });

  test('delivery partner steps follow the server statuses and cash appears once the goods are on the way', () {
    expect(nextDeliveryStep('accepted')?.$1, 'picked_up');
    expect(nextDeliveryStep('picked_up')?.$1, 'on_the_way');
    expect(nextDeliveryStep('on_the_way')?.$1, 'delivered');
    expect(nextDeliveryStep('available'), isNull);
    expect(nextDeliveryStep('delivered'), isNull);

    Map<String, dynamic> job(String status, {int cash = 30000, bool collected = false}) =>
        {'status': status, 'collectCashPaise': cash, 'cashCollected': collected};
    expect(canMarkCash(job('accepted')), isFalse);
    expect(canMarkCash(job('picked_up')), isFalse);
    expect(canMarkCash(job('on_the_way')), isTrue);
    expect(canMarkCash(job('delivered')), isTrue);
    expect(canMarkCash(job('on_the_way', collected: true)), isFalse);
    expect(canMarkCash(job('on_the_way', cash: 0)), isFalse, reason: 'a UPI order has no cash to collect');
  });
}

Map<String, dynamic> _json() => {
      '_id': 'o1',
      'buyerId': 'b',
      'sellerId': 's',
      'line': {'title': {'mr': 'x', 'en': 'x'}, 'quantity': 1, 'unit': 'kg', 'pricePerUnitPaise': 100, 'totalPaise': 100},
      'paymentMethod': 'upi',
      'timeline': [],
    };
