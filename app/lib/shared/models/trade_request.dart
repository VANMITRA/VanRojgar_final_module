import 'listing.dart';

class TradeRequestModel {
  final String id;
  final String listingId;
  final String requesterId;
  final String? requesterName;
  final String? requesterVillage;
  final String requesterRole;
  final String sellerId;
  final double quantity;
  final String unit;
  final String deliveryPref;
  final String? dropVillage;
  final String? reason;
  final String status; // 'pending' | 'approved' | 'rejected' | 'countered' | 'cancelled'
  final String? decisionNote;
  final Map<String, dynamic>? counter;
  final ListingModel? listing;
  final String createdAt;

  TradeRequestModel({
    required this.id,
    required this.listingId,
    required this.requesterId,
    this.requesterName,
    this.requesterVillage,
    required this.requesterRole,
    required this.sellerId,
    required this.quantity,
    required this.unit,
    this.deliveryPref = 'pickup',
    this.dropVillage,
    this.reason,
    this.status = 'pending',
    this.decisionNote,
    this.counter,
    this.listing,
    required this.createdAt,
  });

  factory TradeRequestModel.fromJson(Map<String, dynamic> json) {
    ListingModel? list;
    if (json['listingId'] is Map<String, dynamic>) {
      list = ListingModel.fromJson(json['listingId']);
    }

    String? reqName;
    String? reqVillage;
    if (json['requesterId'] is Map<String, dynamic>) {
      reqName = json['requesterId']['name'];
      reqVillage = json['requesterId']['village'];
    }

    return TradeRequestModel(
      id: json['_id'] ?? json['id'] ?? '',
      listingId: list?.id ?? (json['listingId'] is String ? json['listingId'] : ''),
      requesterId: json['requesterId'] is Map ? json['requesterId']['_id'] : json['requesterId'] ?? '',
      requesterName: reqName,
      requesterVillage: reqVillage,
      requesterRole: json['requesterRole'] ?? 'villager',
      sellerId: json['sellerId'] is Map ? json['sellerId']['_id'] : json['sellerId'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] ?? 'kg',
      deliveryPref: json['deliveryPref'] ?? 'pickup',
      dropVillage: json['dropVillage'],
      reason: json['reason'],
      status: json['status'] ?? 'pending',
      decisionNote: json['decisionNote'],
      counter: json['counter'] as Map<String, dynamic>?,
      listing: list,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
