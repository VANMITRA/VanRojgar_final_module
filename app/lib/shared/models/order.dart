import '../../core/localization/forest_produce_dictionary.dart';
import '../utils/product_image.dart';

class OrderLine {
  final String listingId;
  final String titleMr;
  final String titleEn;
  final double quantity;
  final String unit;
  final int pricePerUnitPaise;
  final int totalPaise;

  OrderLine({
    required this.listingId,
    required this.titleMr,
    required this.titleEn,
    required this.quantity,
    required this.unit,
    required this.pricePerUnitPaise,
    required this.totalPaise,
  });

  /// Returns title adapted to active language (supporting Hindi translation fallback).
  String localizedTitle(String locale) => ForestProduceDictionary.resolveTitle(
        en: titleEn,
        mr: titleMr,
        locale: locale,
      );

  /// High quality photography URL for the product in order line.
  String get displayImageUrl {
    return productAsset(titleEn, titleMr);
  }


  factory OrderLine.fromJson(Map<String, dynamic> json) {
    final titleMap = json['title'] as Map<String, dynamic>?;
    return OrderLine(
      listingId: json['listingId'] is Map ? json['listingId']['_id'] : json['listingId'] ?? '',
      titleMr: titleMap?['mr'] ?? '',
      titleEn: titleMap?['en'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] ?? 'kg',
      pricePerUnitPaise: (json['pricePerUnitPaise'] as num?)?.toInt() ?? 0,
      totalPaise: (json['totalPaise'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrderModel {
  final String id;
  final String requestId;
  final String buyerId;
  final String? buyerName;
  final String? buyerPhone;
  final String sellerId;
  final String? sellerName;
  final String? sellerPhone;
  final OrderLine line;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod; // 'upi' | 'cod'
  final String? paymentReference;
  final String fulfilmentMethod; // 'pickup' | 'delivery'
  final List<Map<String, dynamic>> timeline;
  final String createdAt;

  OrderModel({
    required this.id,
    required this.requestId,
    required this.buyerId,
    this.buyerName,
    this.buyerPhone,
    required this.sellerId,
    this.sellerName,
    this.sellerPhone,
    required this.line,
    required this.orderStatus,
    required this.paymentStatus,
    this.paymentMethod = 'cod',
    this.paymentReference,
    this.fulfilmentMethod = 'pickup',
    required this.timeline,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String? bName;
    String? bPhone;
    if (json['buyerId'] is Map<String, dynamic>) {
      bName = json['buyerId']['name'];
      bPhone = json['buyerId']['phone'];
    }

    String? sName;
    String? sPhone;
    if (json['sellerId'] is Map<String, dynamic>) {
      sName = json['sellerId']['name'];
      sPhone = json['sellerId']['phone'];
    }

    final timelineRaw = json['timeline'] as List? ?? [];

    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      requestId: json['requestId'] is Map ? json['requestId']['_id'] : json['requestId'] ?? '',
      buyerId: json['buyerId'] is Map ? json['buyerId']['_id'] : json['buyerId'] ?? '',
      buyerName: bName,
      buyerPhone: bPhone,
      sellerId: json['sellerId'] is Map ? json['sellerId']['_id'] : json['sellerId'] ?? '',
      sellerName: sName,
      sellerPhone: sPhone,
      line: OrderLine.fromJson(json['line'] ?? {}),
      orderStatus: json['orderStatus'] ?? 'approved',
      paymentStatus: json['paymentStatus'] ?? 'demo_pending',
      paymentMethod: json['paymentMethod'] ?? 'cod',
      paymentReference: (json['payment'] as Map?)?['reference'] as String?,
      fulfilmentMethod: (json['fulfilment'] as Map?)?['method'] as String? ?? 'pickup',
      timeline: timelineRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      createdAt: json['createdAt'] ?? '',
    );
  }
}
