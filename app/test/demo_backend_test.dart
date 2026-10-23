import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanrozgar/core/demo/demo_backend.dart';
import 'package:vanrozgar/core/network/app_exception.dart';
import 'package:vanrozgar/core/security/token_store.dart';
import 'package:vanrozgar/shared/models/listing.dart';
import 'package:vanrozgar/shared/models/order.dart';
import 'package:vanrozgar/shared/models/trade_request.dart';
import 'package:vanrozgar/shared/models/user.dart';

Future<UserModel> loginAs(String phone, String pw) async {
  final res = await DemoBackend.handle('POST', '/auth/login', data: {'phone': phone, 'password': pw});
  await TokenStore.saveToken(res['token']);
  return UserModel.fromJson(res['user']);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('offline demo: browse, request, reject with reason, approve, order flow', () async {
    expect(await DemoBackend.canLogin('9822011001', 'wrong'), isFalse);
    expect(await DemoBackend.canLogin('+91 98220 11001', 'VanRozgar@2026'), isTrue);
    await DemoBackend.activate();

    final buyer = await loginAs('9822033333', 'VanRozgar@2026');
    expect(buyer.role, 'buyer');
    final cats = await DemoBackend.handle('GET', '/categories');
    expect((cats as List).length, 5);

    final found = await DemoBackend.handle('GET', '/search', query: {'q': 'honey'});
    final listings = (found['listings'] as List).map((e) => ListingModel.fromJson(e)).toList();
    expect(listings.length, 10);
    expect((await DemoBackend.handle('GET', '/search', query: {'q': 'bamboo'}))['listings'].length, 15);
    expect((await DemoBackend.handle('GET', '/gramsabhas') as List).length, 10);

    final target = listings.first;
    // bulk rule
    expect(() => DemoBackend.handle('POST', '/requests', data: {'listingId': target.id, 'quantity': 50}), throwsA(isA<AppException>()));
    final req1 = await DemoBackend.handle('POST', '/requests', data: {'listingId': target.id, 'quantity': 2});
    final req2 = await DemoBackend.handle('POST', '/requests', data: {'listingId': target.id, 'quantity': 1});

    final mine = (await DemoBackend.handle('GET', '/requests', query: {'scope': 'mine'}) as List).map((e) => TradeRequestModel.fromJson(e)).toList();
    expect(mine.map((r) => r.status), everyElement('pending'));

    // Gram Sabha of that village decides
    final ownerPhone = '+91${(await _ownerPhone(target.ownerId))}';
    await loginAs(ownerPhone, 'VanRozgar@2026');
    final incoming = await DemoBackend.handle('GET', '/requests', query: {'scope': 'incoming'}) as List;
    expect(incoming.length, 2);
    await expectLater(DemoBackend.handle('PATCH', '/requests/${req1['_id']}/status', data: {'action': 'reject'}), throwsA(isA<AppException>()));
    await DemoBackend.handle('PATCH', '/requests/${req1['_id']}/status', data: {'action': 'reject', 'note': 'Stock reserved for local use'});
    final ap = await DemoBackend.handle('PATCH', '/requests/${req2['_id']}/status', data: {'action': 'approve'});
    final order = OrderModel.fromJson(ap['order']);
    expect(order.orderStatus, 'approved');
    final stock = (await DemoBackend.handle('GET', '/listings/${target.id}'))['quantityAvailable'];
    expect(stock, target.quantityAvailable - 1);

    // Buyer sees status + reason
    await loginAs('9822033333', 'VanRozgar@2026');
    final after = (await DemoBackend.handle('GET', '/requests', query: {'scope': 'mine'}) as List).map((e) => TradeRequestModel.fromJson(e)).toList();
    expect(after.map((r) => r.status).toSet(), {'rejected', 'approved'});
    expect(after.firstWhere((r) => r.status == 'rejected').decisionNote, 'Stock reserved for local use');
    await expectLater(DemoBackend.handle('POST', '/orders/${order.id}/confirm-received'), throwsA(isA<AppException>()));
    await loginAs(ownerPhone, 'VanRozgar@2026');
    await DemoBackend.handle('POST', '/orders/${order.id}/handover');
    await loginAs('9822033333', 'VanRozgar@2026');
    final done = await DemoBackend.handle('POST', '/orders/${order.id}/confirm-received');
    expect(done['orderStatus'], 'closed');
    expect(((await DemoBackend.handle('GET', '/messages')) as List), isNotEmpty);
    expect((await DemoBackend.handle('GET', '/meta'))['notices'], isNotEmpty);
  });

  test('offline demo: delivery option, profile data and persistence', () async {
    await DemoBackend.activate();
    await loginAs('9822022222', 'VanRozgar@2026');
    await expectLater(DemoBackend.handle('GET', '/delivery-partners/me'), throwsA(isA<AppException>()));
    final p = await DemoBackend.handle('POST', '/delivery-partners/applications', data: {'vehicleType': 'tempo', 'vehicleNumber': 'MH15AB1234', 'capacityKg': 500, 'serviceTalukas': ['Nashik']});
    expect(p['approvalStatus'], 'pending');
    expect((await DemoBackend.handle('GET', '/delivery-partners/me'))['approvalStatus'], 'pending');
    expect((await DemoBackend.handle('GET', '/orders', query: {'scope': 'buying'}) as List), isEmpty);
    expect(((await DemoBackend.handle('GET', '/gramsabhas/gs_matori'))['gramSabha']['village']['en']), 'Matori');
  });
}

Future<String> _ownerPhone(String ownerId) async {
  // user ids are "u_<10-digit phone>"
  return ownerId.substring(2);
}
