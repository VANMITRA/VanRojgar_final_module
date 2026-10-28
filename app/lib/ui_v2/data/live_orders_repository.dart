import '../api/order_mapping.dart';
import '../api/v2_api_client.dart';
import '../models/order_models.dart';

/// One line of the cart sent at checkout.
class CheckoutItem {
  final String listingId;
  final int quantity;
  const CheckoutItem(this.listingId, this.quantity);
}

/// What the server did with a checkout: the requests it created and the products it could not request.
class CheckoutOutcome {
  final List<String> createdRequestIds;
  final Map<String, String> failedMessages; // listing id -> why

  const CheckoutOutcome({required this.createdRequestIds, required this.failedMessages});
  bool get hasFailures => failedMessages.isNotEmpty;
}

/// Requests and orders on the shop server: send them, read them, and every step the buyer and the seller take.
class LiveOrdersRepository {
  final V2ApiClient api;
  LiveOrdersRepository(this.api);

  List<Map<String, dynamic>> _list(Object? data) =>
      (data is List ? data : const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

  /// Sends the cart: one request per listing (the server makes them; each seller decides on their own).
  Future<CheckoutOutcome> checkout({
    required List<CheckoutItem> items,
    required String deliveryPref,
    required String paymentMethod,
    String? dropVillageId,
    String? note,
  }) async {
    final village = villageNameFromId(dropVillageId);
    final data = await api.post('/shop/cart/checkout', body: {
      'items': [for (final i in items) {'listingId': i.listingId, 'quantity': i.quantity}],
      'deliveryPref': deliveryPref,
      'paymentMethod': paymentMethod,
      if (deliveryPref == 'delivery' && village != null) 'dropVillage': village,
      if (note != null && note.trim().isNotEmpty) 'reason': note.trim(),
    });
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final created = _list(map['created']);
    final failed = _list(map['failed']);
    return CheckoutOutcome(
      createdRequestIds: [
        for (final c in created)
          if (c['request'] is Map) ((c['request'] as Map)['_id'] ?? (c['request'] as Map)['id'] ?? '').toString(),
      ],
      failedMessages: {for (final f in failed) (f['listingId'] ?? '').toString(): (f['message'] ?? '').toString()},
    );
  }

  /// The requests I sent (as a buyer) with their orders.
  Future<List<OrderView>> asBuyer() async => _views(scope: 'mine', orderScope: 'buying');

  /// The requests that came in to me (as a seller) with their orders.
  Future<List<OrderView>> asSeller() async => _views(scope: 'incoming', orderScope: 'selling');

  Future<List<OrderView>> _views({required String scope, required String orderScope}) async {
    final requests = _list(await api.get('/requests', query: {'scope': scope}));
    final orders = _list(await api.get('/orders', query: {'scope': orderScope}));
    return orderViewsFromServer(requests, orders);
  }

  // ---- The seller's decision -----------------------------------------------------------------------

  Future<void> approve(String requestId) => api.patch('/requests/$requestId/status', body: {'action': 'approve'});

  Future<void> reject(String requestId, String reason) =>
      api.patch('/requests/$requestId/status', body: {'action': 'reject', 'note': reason});

  /// The seller proposes another quantity and/or price (paise).
  Future<void> counter(String requestId, {int? quantity, int? unitPricePaise, String? note}) => api.post(
        '/requests/$requestId/counter',
        body: {
          if (quantity != null) 'quantity': quantity,
          if (unitPricePaise != null) 'pricePerUnitRupees': unitPricePaise / 100,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );

  // ---- The buyer's side -----------------------------------------------------------------------------

  Future<void> cancel(String requestId) => api.patch('/requests/$requestId/status', body: {'action': 'cancel'});

  Future<void> acceptCounter(String requestId) => api.post('/requests/$requestId/counter/accept');

  Future<void> declineCounter(String requestId) => api.post('/requests/$requestId/counter/decline');

  // ---- After approval: the order (payment and hand-over) ---------------------------------------------

  /// The server's order id for an approved request, or null when there is none yet.
  Future<String?> orderIdForRequest(String requestId) async {
    for (final scope in const ['buying', 'selling']) {
      for (final o in _list(await api.get('/orders', query: {'scope': scope}))) {
        final r = o['requestId'];
        final rid = r is Map ? (r['_id'] ?? r['id']) : r;
        if ('$rid' == requestId) return (o['_id'] ?? o['id']).toString();
      }
    }
    return null;
  }

  Future<String> _orderId(String requestId) async {
    final id = await orderIdForRequest(requestId);
    if (id == null) {
      throw const V2ApiException(statusCode: 404, code: 'NOT_FOUND', message: 'This request has no order yet.');
    }
    return id;
  }

  /// UPI: the buyer says "I have paid" and types the payment reference.
  Future<void> reportPayment(String requestId, String reference) async =>
      api.post('/orders/${await _orderId(requestId)}/payment/report', body: {'reference': reference});

  /// UPI: the seller confirms the money arrived.
  Future<void> confirmPayment(String requestId) async => api.post('/orders/${await _orderId(requestId)}/payment/confirm');

  /// Cash on delivery: the cash was received.
  Future<void> cashReceived(String requestId) async => api.post('/orders/${await _orderId(requestId)}/payment/cash-received');

  /// The seller hands the goods over.
  Future<void> handOver(String requestId) async => api.post('/orders/${await _orderId(requestId)}/handover');

  /// The buyer confirms they received the goods.
  Future<void> confirmReceived(String requestId) async => api.post('/orders/${await _orderId(requestId)}/confirm-received');
}
