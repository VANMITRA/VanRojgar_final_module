import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vanrozgar/ui_v2/api/community_mapping.dart';
import 'package:vanrozgar/ui_v2/api/v2_api_client.dart';
import 'package:vanrozgar/ui_v2/data/live_community_repositories.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/community_models.dart';

/// Delivery partner, messages and barter with real server data (the answers of the server are faked here).

http.Response _json(Object data, [int status = 200]) =>
    http.Response(jsonEncode({'success': true, 'data': data}), status, headers: {'content-type': 'application/json'});

http.Response _error(int status, String code) =>
    http.Response(jsonEncode({'success': false, 'error': {'code': code, 'message': 'x'}}), status);

Map<String, dynamic> _job() => {
      '_id': 'j1',
      'pickup': {'village': 'Dongargaon', 'taluka': 'Deola'},
      'drop': {'village': 'Ambai', 'taluka': 'Trimbakeshwar'},
      'goodsSummary': '50 kg Honey',
      'weightKg': 50,
      'distanceKm': 22.5,
      'feePaise': 45000,
      'collectCashPaise': 250000,
      'cashCollected': false,
      'status': 'accepted',
      'timeline': [
        {'status': 'available', 'at': '2026-10-20T10:00:00.000Z'},
        {'status': 'accepted', 'at': '2026-10-20T11:00:00.000Z', 'note': 'ok'},
      ],
    };

void main() {
  group('delivery partner', () {
    test('profile and job are read from the server answers', () {
      final p = deliveryProfileFromServer({
        'approvalStatus': 'approved',
        'vehicle': {'type': 'tempo', 'number': 'MH15 AB 1234', 'capacityKg': 800},
        'serviceTalukas': ['Deola', 'Dindori'],
        'available': true,
        'earningsPaise': 120000,
        'jobsCompleted': 4,
      });
      expect(p.isApproved, true);
      expect(p.vehicleType, 'tempo');
      expect(p.capacityKg, 800);
      expect(p.serviceTalukas, ['Deola', 'Dindori']);
      expect(p.earningsPaise, 120000);

      final j = deliveryJobFromServer(_job());
      expect(j.id, 'j1');
      expect(j.pickupTaluka, 'Deola');
      expect(j.dropVillage, 'Ambai');
      expect(j.weightKg, 50);
      expect(j.distanceKm, 22.5);
      expect(j.collectCashPaise, 250000);
      expect(j.timeline, hasLength(2));
      expect(j.timeline.last.note, 'ok');
    });

    test('a partner who never applied has no profile (404 means null)', () async {
      final repo = LiveDeliveryRepository(V2ApiClient(baseUrl: 'https://s.test', client: MockClient((r) async => _error(404, 'NOT_FOUND'))));
      expect(await repo.myProfile(), isNull);
    });

    test('other errors are not hidden', () async {
      final repo = LiveDeliveryRepository(V2ApiClient(baseUrl: 'https://s.test', client: MockClient((r) async => _error(500, 'INTERNAL'))));
      await expectLater(repo.myProfile(), throwsA(isA<V2ApiException>()));
    });

    test('apply, availability, jobs, accept and status send the right requests', () async {
      final seen = <String>[];
      Map<String, dynamic>? lastBody;
      final repo = LiveDeliveryRepository(V2ApiClient(
        baseUrl: 'https://s.test',
        client: MockClient((r) async {
          seen.add('${r.method} ${r.url.path}');
          lastBody = r.body.isEmpty ? null : jsonDecode(r.body) as Map<String, dynamic>;
          if (r.url.path.endsWith('/deliveries/jobs') || r.url.path.endsWith('/deliveries/mine')) return _json([_job()]);
          return _json({});
        }),
      ));
      await repo.apply(const DeliveryApplication(
          vehicleType: 'bike', vehicleNumber: 'MH15 X 1', capacityKg: 100, licenceNumber: 'LIC1234', serviceTalukas: ['Deola']));
      expect(lastBody, {'vehicleType': 'bike', 'vehicleNumber': 'MH15 X 1', 'capacityKg': 100, 'licenceNumber': 'LIC1234', 'serviceTalukas': ['Deola']});
      await repo.setAvailable(false);
      expect(lastBody, {'available': false});
      expect((await repo.openJobs()).single.id, 'j1');
      expect((await repo.myJobs()).single.id, 'j1');
      await repo.acceptJob('j1');
      await repo.updateJobStatus('j1', 'picked_up', note: 'loaded');
      expect(lastBody, {'status': 'picked_up', 'note': 'loaded'});
      expect(seen, [
        'POST /api/v1/delivery-partners/applications',
        'PATCH /api/v1/delivery-partners/me/availability',
        'GET /api/v1/deliveries/jobs',
        'GET /api/v1/deliveries/mine',
        'POST /api/v1/deliveries/jobs/j1/accept',
        'PATCH /api/v1/deliveries/jobs/j1/status',
      ]);
    });
  });

  group('messages', () {
    test('Marathi and English text are kept and Hindi shows English', () {
      final m = messageFromServer({
        '_id': 'm1',
        'type': 'request_approved',
        'title': {'mr': 'मंजूर', 'en': 'Approved'},
        'body': {'mr': 'तुमची विनंती मंजूर', 'en': 'Your request was approved'},
        'orderId': 'o1',
        'readAt': null,
        'createdAt': '2026-10-21T08:00:00.000Z',
      });
      expect(m.isRead, false);
      expect(m.orderId, 'o1');
      expect(m.localizedTitle(AppLanguage.mr), 'मंजूर');
      expect(m.localizedTitle(AppLanguage.hi), 'Approved');
      expect(m.localizedBody(AppLanguage.en), 'Your request was approved');
    });

    test('list, unread count and mark read', () async {
      Map<String, dynamic>? body;
      final repo = LiveMessagesRepository(V2ApiClient(
        baseUrl: 'https://s.test',
        client: MockClient((r) async {
          if (r.url.path.endsWith('/unread-count')) return _json({'unreadCount': 3});
          if (r.url.path.endsWith('/messages/read')) {
            body = jsonDecode(r.body) as Map<String, dynamic>;
            return _json({'success': true});
          }
          return _json([
            {'_id': 'a', 'type': 't', 'title': {'en': 'A'}, 'body': {'en': 'a'}, 'createdAt': '2026-10-21T08:00:00.000Z'},
          ]);
        }),
      ));
      expect((await repo.messages()).single.id, 'a');
      expect(await repo.unreadCount(), 3);
      await repo.markRead(['a', 'b']);
      expect(body, {'messageIds': ['a', 'b']});
    });
  });

  group('barter', () {
    Map<String, dynamic> offer() => {
          '_id': 'b1',
          'status': 'countered',
          'toListId': {'_id': 'l9', 'title': {'en': 'Bamboo', 'mr': 'बांबू'}, 'unit': 'bundle'},
          'fromUserId': {'name': 'Asha'},
          'toOwnerId': {'name': 'Ravi'},
          'offered': {'title': 'Honey', 'quantity': 2, 'unit': 'kg'},
          'wanted': {'quantity': 10},
          'note': 'fair?',
          'versions': [
            {'version': 1, 'offered': {'title': 'Honey', 'quantity': 2, 'unit': 'kg'}, 'wanted': {'quantity': 10}, 'at': '2026-10-21T08:00:00.000Z'},
            {'version': 2, 'offered': {'title': 'Honey', 'quantity': 3, 'unit': 'kg'}, 'wanted': {'quantity': 8}, 'note': 'counter', 'at': '2026-10-22T08:00:00.000Z'},
          ],
          'createdAt': '2026-10-21T08:00:00.000Z',
        };

    test('an offer shows the wanted listing and the other person', () {
      final incoming = barterOfferFromServer(offer(), incoming: true);
      expect(incoming.wantedListingId, 'l9');
      expect(incoming.wantedTitle, 'Bamboo');
      expect(incoming.wantedUnit, 'bundle');
      expect(incoming.otherPartyName, 'Asha');
      expect(incoming.versions, hasLength(2));
      expect(incoming.versions.last.offeredQuantity, 3);
      final outgoing = barterOfferFromServer(offer(), incoming: false);
      expect(outgoing.otherPartyName, 'Ravi');
      expect(outgoing.isIncoming, false);
    });

    test('the right scope is asked, and create and respond send the right bodies', () async {
      final calls = <String>[];
      Map<String, dynamic>? body;
      final repo = LiveBarterRepository(V2ApiClient(
        baseUrl: 'https://s.test',
        client: MockClient((r) async {
          calls.add('${r.method} ${r.url.path}${r.url.hasQuery ? '?${r.url.query}' : ''}');
          body = r.body.isEmpty ? null : jsonDecode(r.body) as Map<String, dynamic>;
          return r.method == 'GET' ? _json([offer()]) : _json({});
        }),
      ));
      expect((await repo.offers(incoming: true)).single.isIncoming, true);
      await repo.offers(incoming: false);
      await repo.create(const NewBarterOffer(
          wantedListingId: 'l9', offeredTitle: 'Honey', offeredQuantity: 2, offeredUnit: 'kg', wantedQuantity: 10, note: 'fair?'));
      expect(body, {'toListId': 'l9', 'offeredTitle': 'Honey', 'offeredQuantity': 2, 'offeredUnit': 'kg', 'wantedQuantity': 10, 'note': 'fair?'});
      await repo.respond('b1', 'counter', counterOfferedQuantity: 3, counterWantedQuantity: 8);
      expect(body, {'action': 'counter', 'counterOfferedQuantity': 3, 'counterWantedQuantity': 8});
      await repo.respond('b1', 'accept');
      expect(body, {'action': 'accept'});
      expect(calls, [
        'GET /api/v1/barter-requests?scope=incoming',
        'GET /api/v1/barter-requests?scope=mine',
        'POST /api/v1/barter-requests',
        'POST /api/v1/barter-requests/b1/respond',
        'POST /api/v1/barter-requests/b1/respond',
      ]);
    });
  });
}
