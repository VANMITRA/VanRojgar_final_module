import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vanrozgar/ui_v2/api/order_mapping.dart';
import 'package:vanrozgar/ui_v2/api/v2_api_client.dart';
import 'package:vanrozgar/ui_v2/data/auth_repository.dart';
import 'package:vanrozgar/ui_v2/models/order_models.dart';

Map<String, dynamic> _request({String status = 'pending', Map<String, dynamic>? counter, String? decisionNote}) => {
      '_id': 'r1',
      'status': status,
      'quantity': 10,
      'unit': 'kg',
      'deliveryPref': 'delivery',
      'dropVillage': 'Dongargaon',
      'paymentMethod': 'upi',
      'reason': 'For the market',
      'decisionNote': decisionNote,
      'counter': counter,
      'createdAt': '2026-10-20T10:00:00.000Z',
      'history': [
        {'status': 'pending', 'at': '2026-10-20T10:00:00.000Z'},
        if (status != 'pending') {'status': status, 'at': '2026-10-20T11:00:00.000Z', 'note': decisionNote},
      ],
      'listingId': {
        '_id': 'l1',
        'ownerType': 'cfrholder',
        'productCode': 'honey',
        'title': {'en': 'Honey', 'mr': 'मध'},
        'unit': 'kg',
        'pricePerUnitPaise': 50000,
        'mrpPerUnitPaise': 60000,
        'minOrderQuantity': 2,
        'quantityAvailable': 80,
      },
      'requesterId': {'_id': 'b1', 'name': 'Asha', 'phone': '+919876543210'},
      'sellerId': {'_id': 's1', 'name': 'Ravi', 'phone': '+919000000001'},
    };

Map<String, dynamic> _order({String orderStatus = 'approved', String payment = 'awaiting_payment', String? reference}) => {
      'requestId': 'r1',
      'orderStatus': orderStatus,
      'paymentStatus': payment,
      'payment': {'reference': reference},
      'line': {'quantity': 10, 'unit': 'kg', 'pricePerUnitPaise': 50000, 'title': {'en': 'Honey', 'mr': 'मध'}},
    };

http.Response _json(Object data, [int status = 200]) =>
    http.Response(jsonEncode({'success': true, 'data': data}), status, headers: {'content-type': 'application/json'});

void main() {
  group('requests and orders become order views', () {
    test('a new request is pending with the listing details', () {
      final v = orderViewFromServer(_request());
      expect(v.id, 'r1');
      expect(v.status, OrderStatus.pending);
      expect(v.sellerName, 'Ravi');
      expect(v.sellerType, 'cfrholder');
      expect(v.buyerName, 'Asha');
      expect(v.lines.single.quantity, 10);
      expect(v.lines.single.unitPricePaise, 50000);
      expect(v.totalPaise, 500000);
      expect(v.lines.single.minOrderQuantity, 2);
      expect(v.deliveryPref, 'delivery');
      expect(v.dropVillageId, 'dongargaon');
      expect(v.paymentMethod, 'upi');
      expect(v.note, 'For the market');
      expect(v.isSample, false);
    });

    test('a countered request carries the offer', () {
      final v = orderViewFromServer(_request(status: 'countered', counter: {'quantity': 6, 'pricePerUnitPaise': 52000, 'note': 'Less stock'}));
      expect(v.status, OrderStatus.countered);
      expect(v.counterOffer!.quantity, 6);
      expect(v.counterOffer!.totalPaise, 312000);
    });

    test('a rejected request keeps the reason', () {
      final v = orderViewFromServer(_request(status: 'rejected', decisionNote: 'Out of season'));
      expect(v.status, OrderStatus.rejected);
      expect(v.rejectionReason, 'Out of season');
    });

    test('an approved request moves on with its order: payment reported, confirmed, delivered, cancelled', () {
      OrderStatus of(Map<String, dynamic> order) => orderViewFromServer(_request(status: 'approved'), order: order).status;
      expect(of(_order()), OrderStatus.approved);
      expect(of(_order(payment: 'payment_reported', reference: 'REF123')), OrderStatus.paymentReported);
      expect(of(_order(payment: 'payment_confirmed')), OrderStatus.paymentConfirmed);
      expect(of(_order(payment: 'cash_received')), OrderStatus.paymentConfirmed);
      expect(of(_order(orderStatus: 'delivered', payment: 'payment_confirmed')), OrderStatus.completed);
      expect(of(_order(orderStatus: 'cancelled')), OrderStatus.cancelled);
      expect(orderViewFromServer(_request(status: 'approved'), order: _order(payment: 'payment_reported', reference: 'REF123')).paymentReference, 'REF123');
    });

    test('requests are paired with their orders and listed newest first', () {
      final older = _request()..['_id'] = 'r0'..['createdAt'] = '2026-10-19T10:00:00.000Z'..['history'] = [];
      final views = orderViewsFromServer([older, _request(status: 'approved')], [_order(payment: 'payment_confirmed')]);
      expect(views.map((v) => v.id), ['r1', 'r0']);
      expect(views.first.status, OrderStatus.paymentConfirmed);
      expect(views.last.status, OrderStatus.pending);
    });

    test('village names and ids convert both ways', () {
      expect(villageIdFromName('Dongargaon'), 'dongargaon');
      expect(villageIdFromName('  met chandrachi '), 'met-chandrachi');
      expect(villageIdFromName('Nowhere'), isNull);
      expect(villageNameFromId('met-chandrachi'), 'Met Chandrachi');
      expect(villageIdFromName(null), isNull);
    });
  });

  group('sign in and create account', () {
    test('sign in keeps the token and returns the user', () async {
      late Map<String, dynamic> sent;
      final storage = MemoryTokenStorage();
      final repo = AuthRepository(
        V2ApiClient(
          baseUrl: 'https://shop.test',
          client: MockClient((req) async {
            sent = jsonDecode(req.body) as Map<String, dynamic>;
            return _json({'token': 'abc', 'user': {'name': 'Asha', 'role': 'villager', 'phone': '+919876543210', 'village': 'Harsul'}});
          }),
        ),
        storage,
      );
      final user = await repo.signIn(phone: '9876543210', pin: '123456');
      expect(sent, {'phone': '9876543210', 'password': '123456'});
      expect(await storage.read(), 'abc');
      expect(user.role, 'cfrholder'); // an old villager is a CFR holder
      expect(user.name, 'Asha');
    });

    test('a wrong PIN is reported and no token is kept', () async {
      final storage = MemoryTokenStorage();
      final repo = AuthRepository(
        V2ApiClient(
          baseUrl: 'https://shop.test',
          client: MockClient((req) async =>
              http.Response(jsonEncode({'success': false, 'error': {'code': 'UNAUTHENTICATED', 'message': 'Invalid phone number or password'}}), 401)),
        ),
        storage,
      );
      await expectLater(repo.signIn(phone: '9876543210', pin: '000000'), throwsA(isA<V2ApiException>().having((e) => e.statusCode, 'status', 401)));
      expect(await storage.read(), isNull);
    });

    test('create account sends the village name and, for a Gram Sabha, the taluka', () async {
      late Map<String, dynamic> sent;
      final repo = AuthRepository(
        V2ApiClient(
          baseUrl: 'https://shop.test',
          client: MockClient((req) async {
            sent = jsonDecode(req.body) as Map<String, dynamic>;
            return _json({'token': 't', 'user': {'name': 'GS', 'role': 'gramsabha', 'phone': '+919000000009', 'village': 'Dongargaon'}}, 201);
          }),
        ),
        MemoryTokenStorage(),
      );
      await repo.signUp(role: 'gramsabha', name: 'GS', phone: '9000000009', pin: '123456', language: 'mr', villageId: 'dongargaon');
      expect(sent['village'], 'Dongargaon');
      expect(sent['taluka'], 'Deola');
      expect(sent['role'], 'gramsabha');
      expect(sent['language'], 'mr');
    });

    test('restore returns the user of a saved token, and forgets a token the server refuses', () async {
      final storage = MemoryTokenStorage();
      await storage.write('old');
      var accept = true;
      final repo = AuthRepository(
        V2ApiClient(
          baseUrl: 'https://shop.test',
          tokenProvider: storage.read,
          client: MockClient((req) async => accept
              ? _json({'name': 'Asha', 'role': 'buyer', 'phone': '+919876543210'})
              : http.Response(jsonEncode({'success': false, 'error': {'code': 'UNAUTHENTICATED', 'message': 'Expired'}}), 401)),
        ),
        storage,
      );
      expect((await repo.restore())!.name, 'Asha');
      accept = false;
      expect(await repo.restore(), isNull);
      expect(await storage.read(), isNull);
      expect(await repo.restore(), isNull); // no token at all
    });

    test('sign out drops the token even when the server cannot be reached', () async {
      final storage = MemoryTokenStorage();
      await storage.write('t');
      final repo = AuthRepository(
        V2ApiClient(baseUrl: 'https://shop.test', client: MockClient((req) async => throw http.ClientException('offline'))),
        storage,
      );
      await repo.signOut();
      expect(await storage.read(), isNull);
    });
  });
}
