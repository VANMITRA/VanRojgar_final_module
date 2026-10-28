import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_models.dart';
import 'catalog_providers.dart';
import 'checkout_providers.dart';

/// Error thrown when an order transition or input validation fails.
/// Extends [StateError] and implements [Exception] so both error and exception matchers catch it.
class OrderActionException extends StateError implements Exception {
  OrderActionException(super.message);
}

/// Demo seller ID used for any signed-in Gram Sabha or CFR holder in the UI demo.
const String demoSellerId = 'seller-1';

/// Normalizes a phone string so `+919876543210` and `9876543210` compare equal.
String normalizeOrderPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('91')) {
    return digits.substring(2);
  }
  return digits;
}

/// Demo identity rule (Phase 7):
/// - Guest (`user == null`): sees no orders.
/// - Signed-in `buyer`: sees orders whose `buyerPhone` matches their phone PLUS all sample
///   orders marked as the demo buyer (`isDemoBuyer == true`).
/// - Signed-in `gramsabha` or `cfrholder`: treated as seller `seller-1` and sees incoming
///   requests where `sellerId == 'seller-1'`.
List<OrderView> ordersForUser(AuthUser? user, List<OrderView> allOrders) {
  if (user == null) return const <OrderView>[];
  if (user.role == 'gramsabha' || user.role == 'cfrholder') {
    return allOrders.where((o) => o.sellerId == demoSellerId).toList(growable: false);
  }
  final normalizedUserPhone = normalizeOrderPhone(user.phone);
  return allOrders.where((o) {
    if (o.isDemoBuyer) return true;
    return normalizedUserPhone.isNotEmpty &&
        normalizeOrderPhone(o.buyerPhone) == normalizedUserPhone;
  }).toList(growable: false);
}

// ---- Pure permission checks --------------------------------------------------------------------

bool canApproveOrder(OrderView order) => order.status == OrderStatus.pending;

bool canRejectOrder(OrderView order) => order.status == OrderStatus.pending;

bool canCounterOrder(OrderView order) =>
    order.status == OrderStatus.pending && order.lines.isNotEmpty;

bool canAcceptCounter(OrderView order) =>
    order.status == OrderStatus.countered && order.counterOffer != null;

bool canDeclineCounter(OrderView order) => order.status == OrderStatus.countered;

bool canCancelOrder(OrderView order) => order.status == OrderStatus.pending;

bool canReportPayment(OrderView order) =>
    order.status == OrderStatus.approved && order.paymentMethod == 'upi';

bool canConfirmPayment(OrderView order) =>
    order.status == OrderStatus.paymentReported && order.paymentMethod == 'upi';

bool canMarkCompleted(OrderView order) =>
    (order.paymentMethod == 'upi' && order.status == OrderStatus.paymentConfirmed) ||
    (order.paymentMethod == 'cod' && order.status == OrderStatus.approved);

// ---- Pure validation helpers -------------------------------------------------------------------

bool isValidPaymentReference(String reference) {
  final trimmed = reference.trim();
  return trimmed.length >= 6 && trimmed.length <= 30;
}

bool isValidRejectReason(String reason) {
  return reason.trim().isNotEmpty;
}

enum CounterValidationError {
  none,
  belowMinOrder,
  aboveStock,
  invalidPrice,
  aboveMrp,
}

CounterValidationError validateCounterValues(
  OrderLine line, {
  required int quantity,
  required int unitPricePaise,
}) {
  if (quantity < line.minOrderQuantity) {
    return CounterValidationError.belowMinOrder;
  }
  if (quantity > line.availableStock) {
    return CounterValidationError.aboveStock;
  }
  if (unitPricePaise <= 0) {
    return CounterValidationError.invalidPrice;
  }
  if (unitPricePaise > line.mrpPerUnitPaise) {
    return CounterValidationError.aboveMrp;
  }
  return CounterValidationError.none;
}

// ---- Pure state-change functions ---------------------------------------------------------------

/// Seller approves a pending request.
OrderView approveOrder(OrderView order, {DateTime? at}) {
  if (!canApproveOrder(order)) {
    throw OrderActionException('Cannot approve order in status ${order.status.wireName}');
  }
  final timestamp = at ?? DateTime.now();
  return order.copyWith(
    status: OrderStatus.approved,
    events: [
      ...order.events,
      OrderStatusEvent(status: OrderStatus.approved, at: timestamp),
    ],
  );
}

/// Seller rejects a pending request with a required non-empty [reason].
OrderView rejectOrder(OrderView order, {required String reason, DateTime? at}) {
  if (!canRejectOrder(order)) {
    throw OrderActionException('Cannot reject order in status ${order.status.wireName}');
  }
  final trimmed = reason.trim();
  if (!isValidRejectReason(trimmed)) {
    throw OrderActionException('Rejection reason is required');
  }
  final timestamp = at ?? DateTime.now();
  return order.copyWith(
    status: OrderStatus.rejected,
    rejectionReason: trimmed,
    events: [
      ...order.events,
      OrderStatusEvent(status: OrderStatus.rejected, at: timestamp, note: trimmed),
    ],
  );
}

/// Seller sends a counter-offer on a pending request.
/// Validates that quantity is within `[minOrderQuantity, availableStock]` and
/// `unitPricePaise` is in `(0, mrpPerUnitPaise]`.
OrderView counterOrder(
  OrderView order, {
  int? quantity,
  int? unitPricePaise,
  String? note,
  DateTime? at,
}) {
  if (!canCounterOrder(order)) {
    throw OrderActionException('Cannot counter order in status ${order.status.wireName}');
  }
  if (quantity == null && unitPricePaise == null) {
    throw OrderActionException('Counter offer must specify quantity or price');
  }
  final line = order.lines.first;
  final newQty = quantity ?? line.quantity;
  final newPrice = unitPricePaise ?? line.unitPricePaise;
  final err = validateCounterValues(line, quantity: newQty, unitPricePaise: newPrice);
  switch (err) {
    case CounterValidationError.belowMinOrder:
      throw OrderActionException(
        'Counter quantity ($newQty) is below minimum order (${line.minOrderQuantity})',
      );
    case CounterValidationError.aboveStock:
      throw OrderActionException(
        'Counter quantity ($newQty) exceeds available stock (${line.availableStock})',
      );
    case CounterValidationError.invalidPrice:
      throw OrderActionException('Counter price must be greater than zero');
    case CounterValidationError.aboveMrp:
      throw OrderActionException(
        'Counter price ($newPrice) cannot exceed MRP (${line.mrpPerUnitPaise})',
      );
    case CounterValidationError.none:
      break;
  }

  final cleanNote = (note != null && note.trim().isNotEmpty) ? note.trim() : null;
  final offer = OrderCounterOffer(
    quantity: newQty,
    unitPricePaise: newPrice,
    note: cleanNote,
  );
  final timestamp = at ?? DateTime.now();
  return order.copyWith(
    status: OrderStatus.countered,
    counterOffer: offer,
    events: [
      ...order.events,
      OrderStatusEvent(status: OrderStatus.countered, at: timestamp, note: cleanNote),
    ],
  );
}

/// Buyer accepts the seller's counter-offer, updating the line quantity and price and moving to `approved`.
OrderView acceptCounter(OrderView order, {DateTime? at}) {
  if (!canAcceptCounter(order)) {
    throw OrderActionException('Cannot accept counter offer in status ${order.status.wireName}');
  }
  final offer = order.counterOffer!;
  final updatedFirst = order.lines.first.copyWith(
    quantity: offer.quantity,
    unitPricePaise: offer.unitPricePaise,
  );
  final updatedLines = <OrderLine>[
    updatedFirst,
    ...order.lines.skip(1),
  ];
  final timestamp = at ?? DateTime.now();
  return order.copyWith(
    lines: updatedLines,
    status: OrderStatus.approved,
    events: [
      ...order.events,
      OrderStatusEvent(status: OrderStatus.approved, at: timestamp),
    ],
  );
}

/// Buyer declines the seller's counter-offer, cancelling the request.
OrderView declineCounter(OrderView order, {DateTime? at}) {
  if (!canDeclineCounter(order)) {
    throw OrderActionException('Cannot decline counter offer in status ${order.status.wireName}');
  }
  final timestamp = at ?? DateTime.now();
  return order.copyWith(
    status: OrderStatus.cancelled,
    events: [
      ...order.events,
      OrderStatusEvent(status: OrderStatus.cancelled, at: timestamp),
    ],
  );
}

/// Buyer cancels a pending request.
OrderView cancelOrder(OrderView order, {DateTime? at}) {
  if (!canCancelOrder(order)) {
    throw OrderActionException('Cannot cancel order in status ${order.status.wireName}');
  }
  final timestamp = at ?? DateTime.now();
  return order.copyWith(
    status: OrderStatus.cancelled,
    events: [
      ...order.events,
      OrderStatusEvent(status: OrderStatus.cancelled, at: timestamp),
    ],
  );
}

/// Buyer reports a UPI payment after seller approval with a 6–30 character reference.
OrderView reportPayment(OrderView order, {required String reference, DateTime? at}) {
  if (!canReportPayment(order)) {
    throw OrderActionException('Cannot report payment in status ${order.status.wireName}');
  }
  final trimmed = reference.trim();
  if (!isValidPaymentReference(trimmed)) {
    throw OrderActionException('Payment reference must be between 6 and 30 characters');
  }
  final timestamp = at ?? DateTime.now();
  return order.copyWith(
    status: OrderStatus.paymentReported,
    paymentReference: trimmed,
    events: [
      ...order.events,
      OrderStatusEvent(status: OrderStatus.paymentReported, at: timestamp, note: trimmed),
    ],
  );
}

/// Seller confirms receipt of a reported UPI payment.
OrderView confirmPayment(OrderView order, {DateTime? at}) {
  if (!canConfirmPayment(order)) {
    throw OrderActionException('Cannot confirm payment in status ${order.status.wireName}');
  }
  final timestamp = at ?? DateTime.now();
  return order.copyWith(
    status: OrderStatus.paymentConfirmed,
    events: [
      ...order.events,
      OrderStatusEvent(status: OrderStatus.paymentConfirmed, at: timestamp),
    ],
  );
}

/// Seller marks an order completed (after UPI payment confirmation, or after approval for COD).
OrderView markCompleted(OrderView order, {DateTime? at}) {
  if (!canMarkCompleted(order)) {
    throw OrderActionException('Cannot mark completed in status ${order.status.wireName}');
  }
  final timestamp = at ?? DateTime.now();
  return order.copyWith(
    status: OrderStatus.completed,
    events: [
      ...order.events,
      OrderStatusEvent(status: OrderStatus.completed, at: timestamp),
    ],
  );
}

// ---- Seeded sample orders (real product codes & titles from sample_catalog.json) ---------------

final List<OrderView> sampleSeedOrders = List<OrderView>.unmodifiable([
  OrderView(
    id: 'ord-1001',
    sellerId: 'seller-1',
    sellerName: 'Sample Gram Sabha 1',
    sellerType: 'gramsabha',
    buyerName: 'Sample Buyer',
    buyerPhone: '+919000000001',
    isSample: true,
    isDemoBuyer: true,
    deliveryPref: 'delivery',
    dropVillageId: 'dongargaon',
    paymentMethod: 'upi',
    note: 'Sample request for wholesale market supply',
    status: OrderStatus.pending,
    lines: const [
      OrderLine(
        productCode: 'fruit_chinch',
        title: {'en': 'Tamarind', 'hi': 'इमली', 'mr': 'चिंच'},
        unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
        quantity: 10,
        unitPricePaise: 7500,
        mrpPerUnitPaise: 9000,
        minOrderQuantity: 5,
        availableStock: 270,
        imageAsset: 'assets/catalog/fruit_chinch.jpg',
      ),
      OrderLine(
        productCode: 'fruit_awla',
        title: {'en': 'Amla', 'hi': 'आँवला', 'mr': 'आवळा'},
        unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
        quantity: 5,
        unitPricePaise: 6000,
        mrpPerUnitPaise: 6000,
        minOrderQuantity: 5,
        availableStock: 450,
        imageAsset: 'assets/catalog/fruit_awla.jpg',
      ),
    ],
    events: [
      OrderStatusEvent(
        status: OrderStatus.pending,
        at: DateTime.utc(2026, 10, 26, 10, 15),
      ),
    ],
  ),
  OrderView(
    id: 'ord-1002',
    sellerId: 'seller-1',
    sellerName: 'Sample Gram Sabha 1',
    sellerType: 'gramsabha',
    buyerName: 'Sample Buyer',
    buyerPhone: '+919000000001',
    isSample: true,
    isDemoBuyer: true,
    deliveryPref: 'pickup',
    paymentMethod: 'upi',
    note: 'Sample pickup request from village collection center',
    status: OrderStatus.countered,
    lines: const [
      OrderLine(
        productCode: 'fruit_karvand',
        title: {'en': 'Karonda', 'hi': 'करौंदा', 'mr': 'करवंद'},
        unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
        quantity: 25,
        unitPricePaise: 9600,
        mrpPerUnitPaise: 12500,
        minOrderQuantity: 5,
        availableStock: 32,
        imageAsset: 'assets/catalog/fruit_karvand.jpg',
      ),
    ],
    counterOffer: const OrderCounterOffer(
      quantity: 20,
      unitPricePaise: 9000,
      note: 'Current harvest stock is 20 kg at ₹90 per kg',
    ),
    events: [
      OrderStatusEvent(
        status: OrderStatus.pending,
        at: DateTime.utc(2026, 10, 24, 9, 30),
      ),
      OrderStatusEvent(
        status: OrderStatus.countered,
        at: DateTime.utc(2026, 10, 24, 14, 10),
        note: 'Current harvest stock is 20 kg at ₹90 per kg',
      ),
    ],
  ),
  OrderView(
    id: 'ord-1003',
    sellerId: 'seller-1',
    sellerName: 'Sample Gram Sabha 1',
    sellerType: 'gramsabha',
    buyerName: 'Sample Buyer',
    buyerPhone: '+919000000001',
    isSample: true,
    isDemoBuyer: true,
    deliveryPref: 'delivery',
    dropVillageId: 'ambai',
    paymentMethod: 'upi',
    note: 'Sample seasonal fruit order',
    status: OrderStatus.approved,
    lines: const [
      OrderLine(
        productCode: 'fruit_khirni',
        title: {'en': 'Khirni', 'hi': 'खिरनी', 'mr': 'खिरणी'},
        unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
        quantity: 10,
        unitPricePaise: 9700,
        mrpPerUnitPaise: 12600,
        minOrderQuantity: 5,
        availableStock: 300,
        imageAsset: 'assets/catalog/fruit_khirni.jpg',
      ),
    ],
    events: [
      OrderStatusEvent(
        status: OrderStatus.pending,
        at: DateTime.utc(2026, 10, 23, 11, 0),
      ),
      OrderStatusEvent(
        status: OrderStatus.approved,
        at: DateTime.utc(2026, 10, 23, 15, 20),
      ),
    ],
  ),
  OrderView(
    id: 'ord-1004',
    sellerId: 'seller-1',
    sellerName: 'Sample Gram Sabha 1',
    sellerType: 'gramsabha',
    buyerName: 'Sample Buyer',
    buyerPhone: '+919000000001',
    isSample: true,
    isDemoBuyer: true,
    deliveryPref: 'pickup',
    paymentMethod: 'upi',
    paymentReference: '430198765432',
    status: OrderStatus.paymentReported,
    lines: const [
      OrderLine(
        productCode: 'fruit_kawath',
        title: {'en': 'Wood apple', 'hi': 'कैथ', 'mr': 'कवठ'},
        unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
        quantity: 15,
        unitPricePaise: 6200,
        mrpPerUnitPaise: 6200,
        minOrderQuantity: 5,
        availableStock: 180,
        imageAsset: 'assets/catalog/fruit_kawath.jpg',
      ),
    ],
    events: [
      OrderStatusEvent(
        status: OrderStatus.pending,
        at: DateTime.utc(2026, 10, 21, 8, 45),
      ),
      OrderStatusEvent(
        status: OrderStatus.approved,
        at: DateTime.utc(2026, 10, 21, 12, 0),
      ),
      OrderStatusEvent(
        status: OrderStatus.paymentReported,
        at: DateTime.utc(2026, 10, 21, 16, 30),
        note: '430198765432',
      ),
    ],
  ),
  OrderView(
    id: 'ord-1005',
    sellerId: 'seller-1',
    sellerName: 'Sample Gram Sabha 1',
    sellerType: 'gramsabha',
    buyerName: 'Sample Buyer',
    buyerPhone: '+919000000001',
    isSample: true,
    isDemoBuyer: true,
    deliveryPref: 'delivery',
    dropVillageId: 'devgaon',
    paymentMethod: 'upi',
    paymentReference: '430198765433',
    status: OrderStatus.paymentConfirmed,
    lines: const [
      OrderLine(
        productCode: 'fruit_bor',
        title: {'en': 'Ber', 'hi': 'बेर', 'mr': 'बोर'},
        unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
        quantity: 10,
        unitPricePaise: 7500,
        mrpPerUnitPaise: 7500,
        minOrderQuantity: 5,
        availableStock: 20,
        imageAsset: 'assets/catalog/fruit_bor.jpg',
      ),
    ],
    events: [
      OrderStatusEvent(
        status: OrderStatus.pending,
        at: DateTime.utc(2026, 10, 19, 10, 0),
      ),
      OrderStatusEvent(
        status: OrderStatus.approved,
        at: DateTime.utc(2026, 10, 19, 13, 0),
      ),
      OrderStatusEvent(
        status: OrderStatus.paymentReported,
        at: DateTime.utc(2026, 10, 19, 17, 0),
        note: '430198765433',
      ),
      OrderStatusEvent(
        status: OrderStatus.paymentConfirmed,
        at: DateTime.utc(2026, 10, 20, 9, 15),
      ),
    ],
  ),
  OrderView(
    id: 'ord-1006',
    sellerId: 'seller-1',
    sellerName: 'Sample Gram Sabha 1',
    sellerType: 'gramsabha',
    buyerName: 'Sample Buyer',
    buyerPhone: '+919000000001',
    isSample: true,
    isDemoBuyer: true,
    deliveryPref: 'pickup',
    paymentMethod: 'cod',
    status: OrderStatus.completed,
    lines: const [
      OrderLine(
        productCode: 'fruit_awla',
        title: {'en': 'Amla', 'hi': 'आँवला', 'mr': 'आवळा'},
        unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
        quantity: 20,
        unitPricePaise: 6000,
        mrpPerUnitPaise: 6000,
        minOrderQuantity: 5,
        availableStock: 450,
        imageAsset: 'assets/catalog/fruit_awla.jpg',
      ),
    ],
    events: [
      OrderStatusEvent(
        status: OrderStatus.pending,
        at: DateTime.utc(2026, 10, 14, 9, 0),
      ),
      OrderStatusEvent(
        status: OrderStatus.approved,
        at: DateTime.utc(2026, 10, 14, 11, 30),
      ),
      OrderStatusEvent(
        status: OrderStatus.completed,
        at: DateTime.utc(2026, 10, 15, 16, 0),
      ),
    ],
  ),
  OrderView(
    id: 'ord-1007',
    sellerId: 'seller-3',
    sellerName: 'Sample CFR holder 3',
    sellerType: 'cfrholder',
    buyerName: 'Sample Buyer',
    buyerPhone: '+919000000001',
    isSample: true,
    isDemoBuyer: true,
    deliveryPref: 'delivery',
    dropVillageId: 'bhatode',
    paymentMethod: 'cod',
    rejectionReason: 'Harvest batch already sold to local mandi',
    status: OrderStatus.rejected,
    lines: const [
      OrderLine(
        productCode: 'fruit_mango',
        title: {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
        unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
        quantity: 10,
        unitPricePaise: 9900,
        mrpPerUnitPaise: 9900,
        minOrderQuantity: 5,
        availableStock: 225,
        imageAsset: 'assets/catalog/fruit_mango.jpg',
      ),
    ],
    events: [
      OrderStatusEvent(
        status: OrderStatus.pending,
        at: DateTime.utc(2026, 10, 12, 10, 0),
      ),
      OrderStatusEvent(
        status: OrderStatus.rejected,
        at: DateTime.utc(2026, 10, 12, 15, 45),
        note: 'Harvest batch already sold to local mandi',
      ),
    ],
  ),
  OrderView(
    id: 'ord-1008',
    sellerId: 'seller-1',
    sellerName: 'Sample Gram Sabha 1',
    sellerType: 'gramsabha',
    buyerName: 'Sample Buyer',
    buyerPhone: '+919000000001',
    isSample: true,
    isDemoBuyer: true,
    deliveryPref: 'pickup',
    paymentMethod: 'upi',
    status: OrderStatus.cancelled,
    lines: const [
      OrderLine(
        productCode: 'bamboo',
        title: {'en': 'Bamboo', 'hi': 'बाँस', 'mr': 'बांबू'},
        unit: {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
        quantity: 5,
        unitPricePaise: 11200,
        mrpPerUnitPaise: 14600,
        minOrderQuantity: 2,
        availableStock: 90,
        imageAsset: 'assets/catalog/bamboo.jpg',
      ),
    ],
    events: [
      OrderStatusEvent(
        status: OrderStatus.pending,
        at: DateTime.utc(2026, 10, 10, 8, 20),
      ),
      OrderStatusEvent(
        status: OrderStatus.cancelled,
        at: DateTime.utc(2026, 10, 10, 9, 5),
      ),
    ],
  ),
]);

/// In-memory orders provider seeded with 8 sample orders across all statuses.
final ordersProvider = StateProvider<List<OrderView>>((ref) {
  return sampleSeedOrders;
});

/// Appends newly created orders (for example from checkout at merge time) to [ordersProvider].
/// Accepts a [WidgetRef], [Ref], or [ProviderContainer].
void addOrders(dynamic ref, List<OrderView> newOrders) {
  if (newOrders.isEmpty) return;
  final notifier = ref.read(ordersProvider.notifier) as StateController<List<OrderView>>;
  notifier.state = [...notifier.state, ...newOrders];
}

/// Turns the requests sent from checkout into orders for the Orders tab. [cartLines] (the cart as it was
/// when the buyer pressed "Send request") supply the MRP, minimum order and stock of each chosen listing.
List<OrderView> orderViewsFromRequests(List<OrderRequest> requests, List<CartLine> cartLines) {
  return [
    for (final r in requests)
      OrderView(
        id: r.id,
        sellerId: r.sellerId,
        sellerName: r.sellerName,
        sellerType: r.sellerType,
        buyerName: r.buyerName,
        buyerPhone: r.buyerPhone,
        deliveryPref: r.deliveryPref,
        paymentMethod: r.paymentMethod,
        dropVillageId: r.dropVillageId,
        note: r.note,
        status: OrderStatus.pending,
        isSample: false,
        events: [OrderStatusEvent(status: OrderStatus.pending, at: r.createdAt)],
        lines: [
          for (final l in r.lines)
            _orderLineFor(l, cartLines),
        ],
      ),
  ];
}

OrderLine _orderLineFor(OrderRequestLine l, List<CartLine> cartLines) {
  for (final c in cartLines) {
    if (c.product.productCode == l.productCode && c.listing.id == l.listingId) {
      return OrderLine(
        productCode: l.productCode,
        title: l.title,
        unit: l.unit,
        quantity: l.quantity,
        unitPricePaise: l.unitPricePaise,
        mrpPerUnitPaise: c.listing.mrpPerUnitPaise,
        minOrderQuantity: c.listing.minOrderQuantity,
        availableStock: c.listing.quantityAvailable,
        imageAsset: c.product.imageAsset,
      );
    }
  }
  return OrderLine(
    productCode: l.productCode,
    title: l.title,
    unit: l.unit,
    quantity: l.quantity,
    unitPricePaise: l.unitPricePaise,
  );
}

/// Replaces a single updated order in [ordersProvider] by its `id`.
void replaceOrderInState(WidgetRef ref, OrderView updated) {
  final notifier = ref.read(ordersProvider.notifier);
  notifier.state = [
    for (final existing in notifier.state)
      if (existing.id == updated.id) updated else existing,
  ];
}

/// Orders visible to the currently signed-in user according to [ordersForUser].
final visibleOrdersProvider = Provider<List<OrderView>>((ref) {
  final user = ref.watch(authUserProvider);
  final all = ref.watch(ordersProvider);
  return ordersForUser(user, all);
});

/// Looks up a single order by `id` in [ordersProvider].
final orderByIdProvider = Provider.family<OrderView?, String>((ref, id) {
  final all = ref.watch(ordersProvider);
  for (final order in all) {
    if (order.id == id) return order;
  }
  return null;
});

