import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/trade/payment_card.dart';
import 'package:vanrozgar/shared/models/order.dart';

OrderModel order({String payment = 'demo_pending', String? method, String status = 'approved', String fulfilment = 'pickup', String? reference}) =>
    OrderModel.fromJson({
      '_id': 'o1',
      'requestId': 'r1',
      'buyerId': 'b1',
      'sellerId': 's1',
      'line': {
        'listingId': 'l1',
        'title': {'mr': 'मध', 'en': 'Honey'},
        'quantity': 3,
        'unit': 'jar',
        'pricePerUnitPaise': 10000,
        'totalPaise': 30000,
      },
      'orderStatus': status,
      'paymentStatus': payment,
      'paymentMethod': method,
      'payment': {'reference': reference},
      'fulfilment': {'method': fulfilment},
      'timeline': [],
      'createdAt': '2026-10-26T00:00:00Z',
    });

void main() {
  test('the buyer chooses UPI or cash once; nobody else can', () {
    final o = order();
    expect(paymentActions(o, isBuyer: true, isSeller: false), ['choose_upi', 'choose_cod']);
    expect(paymentActions(o, isBuyer: false, isSeller: true), isEmpty);
    expect(paymentActions(order(status: 'cancelled'), isBuyer: true, isSeller: false), isEmpty);
    expect(paymentActions(order(payment: 'cod_pending', method: 'cod'), isBuyer: true, isSeller: false), isEmpty);
  });

  test('UPI: buyer pays and reports; only the seller can confirm', () {
    final waiting = order(payment: 'awaiting_payment', method: 'upi');
    expect(paymentActions(waiting, isBuyer: true, isSeller: false), ['pay_upi', 'report']);
    expect(paymentActions(waiting, isBuyer: false, isSeller: true), isEmpty);
    final reported = order(payment: 'payment_reported', method: 'upi', reference: '412345678901');
    expect(paymentActions(reported, isBuyer: true, isSeller: false), isEmpty);
    expect(paymentActions(reported, isBuyer: false, isSeller: true), ['confirm']);
    expect(paymentActions(order(payment: 'payment_confirmed', method: 'upi'), isBuyer: false, isSeller: true), isEmpty);
  });

  test('cash on delivery: pickup orders let the seller mark cash after handover; delivery orders leave it to the partner', () {
    expect(paymentActions(order(payment: 'cod_pending', method: 'cod'), isBuyer: false, isSeller: true), isEmpty, reason: 'not handed over yet');
    expect(paymentActions(order(payment: 'cod_pending', method: 'cod', status: 'handed_over'), isBuyer: false, isSeller: true), ['cash']);
    expect(paymentActions(order(payment: 'cod_pending', method: 'cod', status: 'handed_over', fulfilment: 'delivery'), isBuyer: false, isSeller: true), isEmpty);
    expect(paymentActions(order(payment: 'cod_pending', method: 'cod', status: 'handed_over'), isBuyer: true, isSeller: false), isEmpty);
  });

  test('no summary says the money arrived before the seller confirmed', () {
    final reported = paymentSummary(order(payment: 'payment_reported', method: 'upi'));
    expect(reported, contains('must confirm'));
    expect(reported.toLowerCase(), isNot(contains('arrived\n')));
    expect(paymentSummary(order(payment: 'payment_confirmed', method: 'upi')), contains('Seller confirmed'));
  });

  testWidgets('the card shows the two choices and the plain-language note', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(home: Scaffold(body: PaymentCard(order: order(), isBuyer: true, isSeller: false))),
    ));
    expect(find.textContaining('Pay by UPI'), findsOneWidget);
    expect(find.textContaining('Cash on delivery'), findsWidgets);
    expect(find.textContaining('not chosen'), findsOneWidget);
  });
}
