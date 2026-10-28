import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/l10n/orders_strings.dart';
import 'package:vanrozgar/ui_v2/models/order_models.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/orders_providers.dart';

OrderView _makeOrder({
  String id = 'test-1',
  String sellerId = 'seller-1',
  String buyerPhone = '+919876543210',
  bool isDemoBuyer = false,
  String paymentMethod = 'upi',
  OrderStatus status = OrderStatus.pending,
  OrderCounterOffer? counterOffer,
  List<OrderLine>? lines,
}) {
  return OrderView(
    id: id,
    sellerId: sellerId,
    sellerName: 'Sample Gram Sabha 1',
    sellerType: 'gramsabha',
    buyerName: 'Sample Buyer',
    buyerPhone: buyerPhone,
    isDemoBuyer: isDemoBuyer,
    deliveryPref: 'pickup',
    paymentMethod: paymentMethod,
    status: status,
    counterOffer: counterOffer,
    lines: lines ??
        const [
          OrderLine(
            productCode: 'fruit_mango',
            title: {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
            unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            quantity: 10,
            unitPricePaise: 9400,
            mrpPerUnitPaise: 12000,
            minOrderQuantity: 5,
            availableStock: 100,
          ),
        ],
    events: [
      OrderStatusEvent(
        status: status,
        at: DateTime.utc(2026, 10, 20, 10, 0),
      ),
    ],
  );
}

void main() {
  group('Order models and totals', () {
    test('computes line totals and order total in paise from lines', () {
      final order = _makeOrder(
        lines: const [
          OrderLine(
            productCode: 'fruit_mango',
            title: {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
            unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            quantity: 5,
            unitPricePaise: 9900,
          ),
          OrderLine(
            productCode: 'bamboo',
            title: {'en': 'Bamboo', 'hi': 'बाँस', 'mr': 'बांबू'},
            unit: {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
            quantity: 3,
            unitPricePaise: 11200,
          ),
        ],
      );
      expect(order.lines[0].lineTotalPaise, 49500);
      expect(order.lines[1].lineTotalPaise, 33600);
      expect(order.totalPaise, 83100);
    });

    test('product summary formats single and multi-line orders in all 3 languages', () {
      final order = _makeOrder(
        lines: const [
          OrderLine(
            productCode: 'fruit_mango',
            title: {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
            unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            quantity: 5,
            unitPricePaise: 9900,
          ),
          OrderLine(
            productCode: 'bamboo',
            title: {'en': 'Bamboo', 'hi': 'बाँस', 'mr': 'बांबू'},
            unit: {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
            quantity: 2,
            unitPricePaise: 11200,
          ),
          OrderLine(
            productCode: 'fruit_awla',
            title: {'en': 'Amla', 'hi': 'आँवला', 'mr': 'आवळा'},
            unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            quantity: 5,
            unitPricePaise: 6000,
          ),
        ],
      );
      expect(AppStrings.en.odProductSummary(order.lines), 'Mango x 5 kg + 2 more');
      expect(AppStrings.hi.odProductSummary(order.lines), 'आम × 5 किग्रा + 2 और');
      expect(AppStrings.mr.odProductSummary(order.lines), 'आंबा × 5 किलो + 2 इतर');
    });
  });

  group('Pure state-change functions: allowed and refused moves', () {
    test('approveOrder transitions pending -> approved and refuses other statuses', () {
      final pending = _makeOrder(status: OrderStatus.pending);
      final approved = approveOrder(pending, at: DateTime.utc(2026, 10, 21));
      expect(approved.status, OrderStatus.approved);
      expect(approved.events.length, 2);
      expect(approved.events.last.status, OrderStatus.approved);

      for (final s in OrderStatus.values.where((s) => s != OrderStatus.pending)) {
        expect(
          () => approveOrder(_makeOrder(status: s)),
          throwsA(isA<OrderActionException>()),
        );
      }
    });

    test('rejectOrder requires a non-empty reason and only works from pending', () {
      final pending = _makeOrder(status: OrderStatus.pending);
      expect(() => rejectOrder(pending, reason: '   '), throwsA(isA<OrderActionException>()));

      final rejected = rejectOrder(pending, reason: 'Out of seasonal stock');
      expect(rejected.status, OrderStatus.rejected);
      expect(rejected.rejectionReason, 'Out of seasonal stock');
      expect(rejected.events.last.status, OrderStatus.rejected);
      expect(rejected.events.last.note, 'Out of seasonal stock');

      expect(
        () => rejectOrder(rejected, reason: 'Again'),
        throwsA(isA<OrderActionException>()),
      );
    });

    test('counterOrder enforces minOrder, stock, and MRP rules, and only works from pending', () {
      final pending = _makeOrder(status: OrderStatus.pending); // min 5, stock 100, mrp 12000

      // Below minimum order (4 < 5)
      expect(
        () => counterOrder(pending, quantity: 4, unitPricePaise: 9000),
        throwsA(isA<OrderActionException>()),
      );
      // Above available stock (101 > 100)
      expect(
        () => counterOrder(pending, quantity: 101, unitPricePaise: 9000),
        throwsA(isA<OrderActionException>()),
      );
      // Price above MRP (12500 > 12000)
      expect(
        () => counterOrder(pending, quantity: 10, unitPricePaise: 12500),
        throwsA(isA<OrderActionException>()),
      );
      // Price zero or negative
      expect(
        () => counterOrder(pending, quantity: 10, unitPricePaise: 0),
        throwsA(isA<OrderActionException>()),
      );
      // Neither quantity nor price given
      expect(
        () => counterOrder(pending),
        throwsA(isA<OrderActionException>()),
      );

      // Valid counter offer at exact MRP and valid quantity
      final countered = counterOrder(
        pending,
        quantity: 20,
        unitPricePaise: 12000,
        note: 'Can supply 20 kg at MRP',
      );
      expect(countered.status, OrderStatus.countered);
      expect(countered.counterOffer?.quantity, 20);
      expect(countered.counterOffer?.unitPricePaise, 12000);
      expect(countered.counterOffer?.totalPaise, 240000);
      expect(countered.events.last.status, OrderStatus.countered);

      // Refused when not pending
      expect(
        () => counterOrder(countered, quantity: 15, unitPricePaise: 9000),
        throwsA(isA<OrderActionException>()),
      );
    });

    test('acceptCounter updates quantity, unitPricePaise, and totalPaise, and moves to approved', () {
      final pending = _makeOrder(status: OrderStatus.pending);
      final countered = counterOrder(pending, quantity: 8, unitPricePaise: 8500);
      final accepted = acceptCounter(countered);

      expect(accepted.status, OrderStatus.approved);
      expect(accepted.lines.first.quantity, 8);
      expect(accepted.lines.first.unitPricePaise, 8500);
      expect(accepted.totalPaise, 68000);
      expect(accepted.events.last.status, OrderStatus.approved);

      expect(() => acceptCounter(pending), throwsA(isA<OrderActionException>()));
      expect(() => acceptCounter(accepted), throwsA(isA<OrderActionException>()));
    });

    test('declineCounter moves countered -> cancelled and refuses other statuses', () {
      final pending = _makeOrder(status: OrderStatus.pending);
      final countered = counterOrder(pending, quantity: 8, unitPricePaise: 8500);
      final declined = declineCounter(countered);

      expect(declined.status, OrderStatus.cancelled);
      expect(declined.events.last.status, OrderStatus.cancelled);

      expect(() => declineCounter(pending), throwsA(isA<OrderActionException>()));
    });

    test('cancelOrder only works while pending', () {
      final pending = _makeOrder(status: OrderStatus.pending);
      final cancelled = cancelOrder(pending);
      expect(cancelled.status, OrderStatus.cancelled);
      expect(cancelled.events.last.status, OrderStatus.cancelled);

      final approved = approveOrder(pending);
      expect(() => cancelOrder(approved), throwsA(isA<OrderActionException>()));
      expect(() => cancelOrder(cancelled), throwsA(isA<OrderActionException>()));
    });

    test('UPI payment flow: reportPayment (6..30 chars) -> confirmPayment -> markCompleted', () {
      final approvedUpi = approveOrder(_makeOrder(paymentMethod: 'upi'));

      // Cannot complete UPI order before payment is reported and confirmed
      expect(() => markCompleted(approvedUpi), throwsA(isA<OrderActionException>()));
      expect(() => confirmPayment(approvedUpi), throwsA(isA<OrderActionException>()));

      // Reference too short (< 6) or too long (> 30)
      expect(
        () => reportPayment(approvedUpi, reference: '12345'),
        throwsA(isA<OrderActionException>()),
      );
      expect(
        () => reportPayment(approvedUpi, reference: '1234567890123456789012345678901'),
        throwsA(isA<OrderActionException>()),
      );

      // Valid 6..30 char reference
      final reported = reportPayment(approvedUpi, reference: 'UTR987654321');
      expect(reported.status, OrderStatus.paymentReported);
      expect(reported.paymentReference, 'UTR987654321');
      expect(() => markCompleted(reported), throwsA(isA<OrderActionException>()));

      final confirmed = confirmPayment(reported);
      expect(confirmed.status, OrderStatus.paymentConfirmed);

      final completed = markCompleted(confirmed);
      expect(completed.status, OrderStatus.completed);
      expect(() => markCompleted(completed), throwsA(isA<OrderActionException>()));
    });

    test('COD flow: reportPayment is refused; markCompleted is allowed right after approval', () {
      final approvedCod = approveOrder(_makeOrder(paymentMethod: 'cod'));
      expect(
        () => reportPayment(approvedCod, reference: '12345678'),
        throwsA(isA<OrderActionException>()),
      );
      final completed = markCompleted(approvedCod);
      expect(completed.status, OrderStatus.completed);
    });
  });

  group('Demo identity and provider helpers', () {
    test('ordersForUser filters for guest, buyer, gramsabha, and cfrholder', () {
      final demoOrder = _makeOrder(
        id: 'd1',
        sellerId: 'seller-1',
        buyerPhone: '+919000000001',
        isDemoBuyer: true,
      );
      final buyerOwnOrder = _makeOrder(
        id: 'b1',
        sellerId: 'seller-3',
        buyerPhone: '+919876543210',
        isDemoBuyer: false,
      );
      final otherBuyerOrder = _makeOrder(
        id: 'b2',
        sellerId: 'seller-1',
        buyerPhone: '+919111111111',
        isDemoBuyer: false,
      );
      final all = [demoOrder, buyerOwnOrder, otherBuyerOrder];

      // Guest sees nothing
      expect(ordersForUser(null, all), isEmpty);

      // Buyer sees their own phone orders + demo buyer orders
      const buyer = AuthUser(name: 'Asha', role: 'buyer', phone: '9876543210');
      expect(ordersForUser(buyer, all).map((o) => o.id), ['d1', 'b1']);

      // Gram Sabha and CFR holder are treated as seller-1
      const gs = AuthUser(name: 'GS', role: 'gramsabha', phone: '9999999999', villageId: 'ambai');
      const cfr = AuthUser(name: 'CFR', role: 'cfrholder', phone: '9999999998', villageId: 'ambai');
      expect(ordersForUser(gs, all).map((o) => o.id), ['d1', 'b2']);
      expect(ordersForUser(cfr, all).map((o) => o.id), ['d1', 'b2']);
    });

    test('ordersProvider is seeded with 8 sample orders and addOrders appends new requests', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = container.read(ordersProvider);
      expect(initial.length, 8);
      expect(initial.every((o) => o.isSample), isTrue);

      final extra = _makeOrder(id: 'ord-extra');
      addOrders(container, [extra]);
      final updated = container.read(ordersProvider);
      expect(updated.length, 9);
      expect(updated.last.id, 'ord-extra');
    });
  });
}

