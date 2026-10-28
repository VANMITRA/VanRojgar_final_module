// Turns the server's delivery, message and barter records into the models the screens read.
import '../models/community_models.dart';

int _int(Object? v) => v is num ? v.round() : int.tryParse('$v') ?? 0;
double _num(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
DateTime _date(Object? v) => DateTime.tryParse('${v ?? ''}')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);

Map<String, dynamic> _map(Object? v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

Map<String, String> _text(Object? raw) {
  final m = _map(raw);
  return {
    if (m['en'] != null) 'en': m['en'].toString(),
    if (m['mr'] != null) 'mr': m['mr'].toString(),
    if (m['hi'] != null) 'hi': m['hi'].toString(),
  };
}

DeliveryPartnerProfile deliveryProfileFromServer(Map<String, dynamic> p) {
  final vehicle = _map(p['vehicle']);
  return DeliveryPartnerProfile(
    approvalStatus: (p['approvalStatus'] ?? 'pending').toString(),
    vehicleType: (vehicle['type'] ?? '').toString(),
    vehicleNumber: (vehicle['number'] ?? '').toString(),
    capacityKg: _int(vehicle['capacityKg']),
    serviceTalukas: [for (final t in (p['serviceTalukas'] as List? ?? const [])) t.toString()],
    available: p['available'] == true,
    earningsPaise: _int(p['earningsPaise']),
    jobsCompleted: _int(p['jobsCompleted']),
    reviewNote: p['reviewNote'] as String?,
  );
}

DeliveryJob deliveryJobFromServer(Map<String, dynamic> j) {
  final pickup = _map(j['pickup']);
  final drop = _map(j['drop']);
  return DeliveryJob(
    id: (j['_id'] ?? j['id'] ?? '').toString(),
    pickupVillage: (pickup['village'] ?? '').toString(),
    pickupTaluka: (pickup['taluka'] ?? '').toString(),
    dropVillage: (drop['village'] ?? '').toString(),
    dropTaluka: (drop['taluka'] ?? '').toString(),
    goodsSummary: (j['goodsSummary'] ?? '').toString(),
    weightKg: _num(j['weightKg']),
    distanceKm: _num(j['distanceKm']),
    feePaise: _int(j['feePaise']),
    collectCashPaise: _int(j['collectCashPaise']),
    cashCollected: j['cashCollected'] == true,
    status: (j['status'] ?? 'available').toString(),
    timeline: [
      for (final s in (j['timeline'] as List? ?? const []).whereType<Map>())
        DeliveryStep(status: (s['status'] ?? '').toString(), at: _date(s['at']), note: s['note'] as String?),
    ],
  );
}

AppMessage messageFromServer(Map<String, dynamic> m) {
  return AppMessage(
    id: (m['_id'] ?? m['id'] ?? '').toString(),
    type: (m['type'] ?? '').toString(),
    title: _text(m['title']),
    body: _text(m['body']),
    orderId: m['orderId']?.toString(),
    requestId: m['requestId']?.toString(),
    barterId: m['barterId']?.toString(),
    readAt: m['readAt'] == null ? null : _date(m['readAt']),
    createdAt: _date(m['createdAt']),
  );
}

/// A barter record (`GET /barter-requests`, with the wanted listing and both people filled in).
/// [incoming] is true when the list was asked with scope=incoming.
BarterOffer barterOfferFromServer(Map<String, dynamic> b, {required bool incoming}) {
  final offered = _map(b['offered']);
  final wanted = _map(b['wanted']);
  final listing = _map(b['toListId']);
  final title = _text(listing['title']);
  final other = _map(incoming ? b['fromUserId'] : b['toOwnerId']);
  return BarterOffer(
    id: (b['_id'] ?? b['id'] ?? '').toString(),
    status: (b['status'] ?? 'pending').toString(),
    wantedListingId: (listing['_id'] ?? b['toListId'] ?? '').toString(),
    wantedTitle: title['en'] ?? title['mr'] ?? '',
    wantedUnit: (listing['unit'] ?? '').toString(),
    offeredTitle: (offered['title'] ?? '').toString(),
    offeredQuantity: _int(offered['quantity']),
    offeredUnit: (offered['unit'] ?? '').toString(),
    wantedQuantity: _int(wanted['quantity']),
    note: b['note'] as String?,
    isIncoming: incoming,
    otherPartyName: (other['name'] ?? '').toString(),
    versions: [
      for (final v in (b['versions'] as List? ?? const []).whereType<Map>())
        BarterVersion(
          version: _int(v['version']),
          offeredTitle: (_map(v['offered'])['title'] ?? '').toString(),
          offeredQuantity: _int(_map(v['offered'])['quantity']),
          offeredUnit: (_map(v['offered'])['unit'] ?? '').toString(),
          wantedQuantity: _int(_map(v['wanted'])['quantity']),
          note: v['note'] as String?,
          at: _date(v['at']),
        ),
    ],
    createdAt: _date(b['createdAt']),
  );
}
