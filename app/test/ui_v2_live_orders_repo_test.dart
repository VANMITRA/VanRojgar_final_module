import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vanrozgar/ui_v2/api/v2_api_client.dart';
import 'package:vanrozgar/ui_v2/data/live_orders_repository.dart';
import 'package:vanrozgar/ui_v2/models/order_models.dart';

http.Response _json(Object data, [int status = 200]) =>
    http.Response(jsonEncode({'success': true, 'data': data}), status, headers: {'content-type': 'application/json'});

Map<String, dynamic> _request(String id, String status) => {
      '_id': id,
      'status': status,
      'quantity': 5,
      'unit': 'kg',
      'deliveryPref': 'pickup',
      'paymentMethod': 'cod',
      'createdAt': '2026-10-20T10:00:00.000Z',
      'history': [],
      'listingId': {'_id': 'l1', 'ownerType': 'gramsabha', 'productCode': 'honey', 'title': {'en': 'Honey'}, 'unit': 'kg', 'pricePerUnitPaise': 50000},
      'requesterId': {'_id': 'b', 'name': 'Asha', 'phone': '+919876543210'},
      'sellerId': {'_id': 's', 'name': 'Ravi'},
    };

class _Call {
  final String method;
  final String path;
  final String query;
  final Map<String, dynamic>? body;
  _Call(this.method, this.path, this.query, this.body);
  @override
  String toString() => '$method $path${query.isEmpty ? '' : '?$query'}';
}

LiveOrdersRepository _repo(List<_Call> calls, http.Response Function(http.Request) answer) {
  return LiveOrdersRepository(V2ApiClient(
    baseUrl: 'https://s.test',
    client: MockClient((r) async {
      calls.add(_Call(r.method, r.url.path.replaceFirst('/api/v1', ''), r.url.query, r.body.isEmpty ? null : jsonDecode(r.body) as Map<String, dynamic>));
      return answer(r);
    }),
  ));
}

void main() {
  test('checkout sends the cart and reports what the server created and refused', () async {
    final calls = <_Call>[];
    final repo = _repo(calls, (r) => _json({
          'created': [
            {'listingId': 'l1', 'quantity': 5, 'request': {'_id': 'r1'}},
          ],
          'failed': [
            {'listingId': 'l2', 'code': 'VALIDATION_ERROR', 'message': 'Below the minimum order'},
          ],
        }, 201));
    final outcome = await repo.checkout(
      items: const [CheckoutItem('l1', 5), CheckoutItem('l2', 1)],
      deliveryPref: 'delivery',
      paymentMethod: 'upi',
      dropVillageId: 'dongargaon',
      note: '  For the market ',
    );
    expect(calls.single.toString(), 'POST /shop/cart/checkout');
    expect(calls.single.body, {
      'items': [
        {'listingId': 'l1', 'quantity': 5},
        {'listingId': 'l2', 'quantity': 1},
      ],
      'deliveryPref': 'delivery',
      'paymentMethod': 'upi',
      'dropVillage': 'Dongargaon',
      'reason': 'For the market',
    });
    expect(outcome.createdRequestIds, ['r1']);
    expect(outcome.failedMessages, {'l2': 'Below the minimum order'});
    expect(outcome.hasFailures, true);
  });

  test('pickup sends no village and an empty note is left out', () async {
    final calls = <_Call>[];
    final repo = _repo(calls, (r) => _json({'created': [], 'failed': []}));
    await repo.checkout(items: const [CheckoutItem('l1', 2)], deliveryPref: 'pickup', paymentMethod: 'cod', dropVillageId: 'dongargaon', note: '  ');
    expect(calls.single.body!.containsKey('dropVillage'), false);
    expect(calls.single.body!.containsKey('reason'), false);
  });

  test('as buyer and as seller ask for the right lists and pair requests with orders', () async {
    final calls = <_Call>[];
    final repo = _repo(calls, (r) {
      if (r.url.path.endsWith('/requests')) return _json([_request('r1', 'approved')]);
      return _json([
        {'_id': 'o1', 'requestId': 'r1', 'orderStatus': 'approved', 'paymentStatus': 'payment_reported', 'payment': {'reference': 'REF'}, 'line': {'quantity': 5, 'pricePerUnitPaise': 50000}},
      ]);
    });
    final buyer = await repo.asBuyer();
    expect(buyer.single.status, OrderStatus.paymentReported);
    await repo.asSeller();
    expect(calls.map((c) => c.toString()), [
      'GET /requests?scope=mine',
      'GET /orders?scope=buying',
      'GET /requests?scope=incoming',
      'GET /orders?scope=selling',
    ]);
  });

  test('the seller and buyer decisions go to the right addresses with the right bodies', () async {
    final calls = <_Call>[];
    final repo = _repo(calls, (r) => _json({}));
    await repo.approve('r1');
    await repo.reject('r1', 'Out of season');
    await repo.counter('r1', quantity: 3, unitPricePaise: 52500, note: 'less');
    await repo.cancel('r1');
    await repo.acceptCounter('r1');
    await repo.declineCounter('r1');
    expect(calls.map((c) => c.toString()), [
      'PATCH /requests/r1/status',
      'PATCH /requests/r1/status',
      'POST /requests/r1/counter',
      'PATCH /requests/r1/status',
      'POST /requests/r1/counter/accept',
      'POST /requests/r1/counter/decline',
    ]);
    expect(calls[0].body, {'action': 'approve'});
    expect(calls[1].body, {'action': 'reject', 'note': 'Out of season'});
    expect(calls[2].body, {'quantity': 3, 'pricePerUnitRupees': 525.0, 'note': 'less'});
    expect(calls[3].body, {'action': 'cancel'});
  });

  test('payment and hand-over steps find the order of the request first', () async {
    final calls = <_Call>[];
    final repo = _repo(calls, (r) {
      if (r.method == 'GET') {
        return _json(r.url.queryParameters['scope'] == 'buying'
            ? [
                {'_id': 'o7', 'requestId': 'r1'}
              ]
            : []);
      }
      return _json({});
    });
    await repo.reportPayment('r1', 'REF123');
    expect(calls.last.toString(), 'POST /orders/o7/payment/report');
    expect(calls.last.body, {'reference': 'REF123'});
    await repo.confirmPayment('r1');
    await repo.cashReceived('r1');
    await repo.handOver('r1');
    await repo.confirmReceived('r1');
    expect(calls.where((c) => c.method == 'POST').map((c) => c.path), [
      '/orders/o7/payment/report',
      '/orders/o7/payment/confirm',
      '/orders/o7/payment/cash-received',
      '/orders/o7/handover',
      '/orders/o7/confirm-received',
    ]);
  });

  test('a request without an order yet is reported, not guessed', () async {
    final repo = _repo([], (r) => _json([]));
    await expectLater(repo.confirmPayment('r9'), throwsA(isA<V2ApiException>().having((e) => e.statusCode, 'status', 404)));
    expect(await repo.orderIdForRequest('r9'), isNull);
  });
}
