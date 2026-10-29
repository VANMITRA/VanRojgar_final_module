// Turns the server's requests and orders into the `OrderView` the Orders screens read.
// On the server a buyer's wish is a REQUEST (pending, approved, rejected, countered, cancelled); once the seller
// approves, an ORDER exists next to it (payment and delivery steps). The screens show them as one thing.
import '../data/villages.dart';
import '../models/order_models.dart';
import 'server_mapping.dart';

int _int(Object? v) => v is num ? v.round() : int.tryParse('$v') ?? 0;

String _idOf(Object? v) {
  if (v is Map) return (v['_id'] ?? v['id'] ?? '').toString();
  return (v ?? '').toString();
}

DateTime? _date(Object? v) => DateTime.tryParse('${v ?? ''}')?.toLocal();

Map<String, String> _title(Object? raw) {
  final m = raw is Map ? raw : const {};
  final en = (m['en'] ?? m['mr'] ?? m['hi'] ?? '').toString();
  return {'en': en, 'hi': (m['hi'] ?? en).toString(), 'mr': (m['mr'] ?? en).toString()};
}

/// The id of a pilot village by its English name (the server stores the name), or null.
String? villageIdFromName(String? name) {
  if (name == null) return null;
  final n = name.trim().toLowerCase();
  for (final v in pilotVillages) {
    if (v.nameEn.toLowerCase() == n) return v.id;
  }
  return null;
}

/// The village name the server wants for a pilot village id (the English name).
String? villageNameFromId(String? id) {
  if (id == null) return null;
  for (final v in pilotVillages) {
    if (v.id == id) return v.nameEn;
  }
  return null;
}

OrderStatus? _statusFromWire(String? s) {
  for (final st in OrderStatus.values) {
    if (st.wireName == s) return st;
  }
  return null;
}

/// The status the buyer and seller see: the request's status, moved on by the order's payment and delivery steps.
OrderStatus orderStatusFrom(String requestStatus, Map<String, dynamic>? order) {
  if (order != null && requestStatus == 'approved') {
    final orderStatus = (order['orderStatus'] ?? '').toString();
    final payment = (order['paymentStatus'] ?? '').toString();
    if (orderStatus == 'cancelled') return OrderStatus.cancelled;
    if (orderStatus == 'delivered' || orderStatus == 'closed') return OrderStatus.completed;
    if (payment == 'payment_confirmed' || payment == 'cash_received' || payment == 'completed') {
      return OrderStatus.paymentConfirmed;
    }
    if (payment == 'payment_reported') return OrderStatus.paymentReported;
    return OrderStatus.approved;
  }
  return _statusFromWire(requestStatus) ?? OrderStatus.pending;
}

/// One request (as sent by `GET /requests`, with the listing and both people filled in) and its order, if any.
OrderView orderViewFromServer(Map<String, dynamic> request, {Map<String, dynamic>? order}) {
  final listing = request['listingId'] is Map ? Map<String, dynamic>.from(request['listingId'] as Map) : <String, dynamic>{};
  final buyer = request['requesterId'] is Map ? Map<String, dynamic>.from(request['requesterId'] as Map) : <String, dynamic>{};
  final seller = request['sellerId'] is Map ? Map<String, dynamic>.from(request['sellerId'] as Map) : <String, dynamic>{};
  final line = order != null && order['line'] is Map ? Map<String, dynamic>.from(order['line'] as Map) : null;

  final unit = (request['unit'] ?? listing['unit'] ?? '').toString();
  final code = appProductCode((listing['productCode'] ?? '').toString());
  final quantity = line != null ? _int(line['quantity']) : _int(request['quantity']);
  final price = line != null ? _int(line['pricePerUnitPaise']) : _int(listing['pricePerUnitPaise']);
  final status = orderStatusFrom((request['status'] ?? 'pending').toString(), order);

  final counter = request['counter'] is Map ? Map<String, dynamic>.from(request['counter'] as Map) : null;
  final hasCounter = status == OrderStatus.countered && counter != null && counter['quantity'] != null;

  final events = <OrderStatusEvent>[
    for (final h in (request['history'] as List? ?? const []).whereType<Map>())
      if (_statusFromWire(h['status']?.toString()) != null && _date(h['at']) != null)
        OrderStatusEvent(status: _statusFromWire(h['status']?.toString())!, at: _date(h['at'])!, note: h['note'] as String?),
  ];
  final created = _date(request['createdAt']);
  if (events.isEmpty && created != null) events.add(OrderStatusEvent(status: OrderStatus.pending, at: created));

  final payment = order != null && order['payment'] is Map ? Map<String, dynamic>.from(order['payment'] as Map) : null;

  return OrderView(
    id: _idOf(request),
    sellerId: _idOf(request['sellerId']),
    sellerName: (seller['name'] ?? '').toString(),
    sellerType: (listing['ownerType'] ?? 'gramsabha').toString() == 'gramsabha' ? 'gramsabha' : 'cfrholder',
    buyerName: (buyer['name'] ?? '').toString(),
    buyerPhone: (buyer['phone'] ?? '').toString(),
    lines: [
      OrderLine(
        productCode: code,
        title: _title(line?['title'] ?? listing['title']),
        unit: unitNames(unit),
        quantity: quantity,
        unitPricePaise: price,
        mrpPerUnitPaise: listing['mrpPerUnitPaise'] == null ? price : _int(listing['mrpPerUnitPaise']),
        minOrderQuantity: listing['minOrderQuantity'] == null ? 1 : _int(listing['minOrderQuantity']),
        availableStock: _int(listing['quantityAvailable']),
        imageAsset: 'assets/catalog/$code.jpg',
      ),
    ],
    deliveryPref: (request['deliveryPref'] ?? 'pickup').toString(),
    paymentMethod: (request['paymentMethod'] ?? 'cod').toString(),
    dropVillageId: villageIdFromName(request['dropVillage'] as String?),
    note: (request['reason'] ?? '').toString(),
    status: status,
    events: events,
    counterOffer: hasCounter
        ? OrderCounterOffer(
            quantity: _int(counter['quantity']),
            unitPricePaise: counter['pricePerUnitPaise'] == null ? price : _int(counter['pricePerUnitPaise']),
            note: counter['note'] as String?,
          )
        : null,
    paymentReference: payment?['reference'] as String?,
    rejectionReason: status == OrderStatus.rejected ? request['decisionNote'] as String? : null,
    isSample: false,
  );
}

/// Pairs each request with its order (by `requestId`) and builds the views, newest first.
List<OrderView> orderViewsFromServer(List<Map<String, dynamic>> requests, List<Map<String, dynamic>> orders) {
  final byRequest = <String, Map<String, dynamic>>{
    for (final o in orders) _idOf(o['requestId']): o,
  };
  final views = [
    for (final r in requests) orderViewFromServer(r, order: byRequest[_idOf(r)]),
  ];
  views.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return views;
}
