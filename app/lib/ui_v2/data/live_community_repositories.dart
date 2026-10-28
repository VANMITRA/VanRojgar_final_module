import '../api/community_mapping.dart';
import '../api/v2_api_client.dart';
import '../models/community_models.dart';
import 'community_repositories.dart';

List<Map<String, dynamic>> _list(Object? data) =>
    (data is List ? data : const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

/// Delivery partner data from the shop server.
class LiveDeliveryRepository implements DeliveryRepository {
  final V2ApiClient api;
  LiveDeliveryRepository(this.api);

  @override
  Future<DeliveryPartnerProfile?> myProfile() async {
    try {
      final data = await api.get('/delivery-partners/me');
      return data is Map ? deliveryProfileFromServer(Map<String, dynamic>.from(data)) : null;
    } on V2ApiException catch (e) {
      if (e.statusCode == 404) return null; // never applied
      rethrow;
    }
  }

  @override
  Future<void> apply(DeliveryApplication a) => api.post('/delivery-partners/applications', body: {
        'vehicleType': a.vehicleType,
        'vehicleNumber': a.vehicleNumber,
        'capacityKg': a.capacityKg,
        'licenceNumber': a.licenceNumber,
        'serviceTalukas': a.serviceTalukas,
      });

  @override
  Future<void> setAvailable(bool available) => api.patch('/delivery-partners/me/availability', body: {'available': available});

  @override
  Future<List<DeliveryJob>> openJobs() async => _list(await api.get('/deliveries/jobs')).map(deliveryJobFromServer).toList();

  @override
  Future<void> acceptJob(String jobId) => api.post('/deliveries/jobs/$jobId/accept');

  @override
  Future<void> updateJobStatus(String jobId, String status, {String? note}) => api.patch(
        '/deliveries/jobs/$jobId/status',
        body: {'status': status, if (note != null && note.isNotEmpty) 'note': note},
      );

  @override
  Future<List<DeliveryJob>> myJobs() async => _list(await api.get('/deliveries/mine')).map(deliveryJobFromServer).toList();
}

/// Notices from the shop server.
class LiveMessagesRepository implements MessagesRepository {
  final V2ApiClient api;
  LiveMessagesRepository(this.api);

  @override
  Future<List<AppMessage>> messages() async => _list(await api.get('/messages')).map(messageFromServer).toList();

  @override
  Future<int> unreadCount() async {
    final data = await api.get('/messages/unread-count');
    final n = data is Map ? data['unreadCount'] : null;
    return n is num ? n.round() : 0;
  }

  @override
  Future<void> markRead(List<String> messageIds) => api.post('/messages/read', body: {'messageIds': messageIds});
}

/// Barter offers on the shop server. A buyer account cannot barter (the server answers 403).
class LiveBarterRepository implements BarterRepository {
  final V2ApiClient api;
  LiveBarterRepository(this.api);

  @override
  Future<List<BarterOffer>> offers({required bool incoming}) async {
    final data = await api.get('/barter-requests', query: {'scope': incoming ? 'incoming' : 'mine'});
    return _list(data).map((b) => barterOfferFromServer(b, incoming: incoming)).toList();
  }

  @override
  Future<void> create(NewBarterOffer o) => api.post('/barter-requests', body: {
        'toListId': o.wantedListingId,
        'offeredTitle': o.offeredTitle,
        'offeredQuantity': o.offeredQuantity,
        'offeredUnit': o.offeredUnit,
        'wantedQuantity': o.wantedQuantity,
        if (o.note != null && o.note!.isNotEmpty) 'note': o.note,
      });

  @override
  Future<void> respond(
    String offerId,
    String action, {
    String? counterOfferedTitle,
    int? counterOfferedQuantity,
    int? counterWantedQuantity,
    String? note,
  }) =>
      api.post('/barter-requests/$offerId/respond', body: {
        'action': action,
        if (counterOfferedTitle != null) 'counterOfferedTitle': counterOfferedTitle,
        if (counterOfferedQuantity != null) 'counterOfferedQuantity': counterOfferedQuantity,
        if (counterWantedQuantity != null) 'counterWantedQuantity': counterWantedQuantity,
        if (note != null && note.isNotEmpty) 'note': note,
      });
}
