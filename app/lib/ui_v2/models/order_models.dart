import 'package:flutter/foundation.dart';
import '../l10n/app_strings.dart';

/// Real request and order lifecycle statuses mirrored from the marketplace server
/// (`server/src/models/Request.js` and `server/src/models/Order.js`).
enum OrderStatus {
  pending('pending'),
  approved('approved'),
  countered('countered'),
  rejected('rejected'),
  paymentReported('payment_reported'),
  paymentConfirmed('payment_confirmed'),
  completed('completed'),
  cancelled('cancelled');

  final String wireName;
  const OrderStatus(this.wireName);

  /// Buyer "Active" segment: ongoing requests and orders.
  bool get isActiveForBuyer {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.approved:
      case OrderStatus.countered:
      case OrderStatus.paymentReported:
      case OrderStatus.paymentConfirmed:
        return true;
      case OrderStatus.rejected:
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return false;
    }
  }

  /// Buyer "Past" segment: finished, rejected, or cancelled orders.
  bool get isPastForBuyer => !isActiveForBuyer;

  /// Seller "New requests" segment: waiting for initial seller decision.
  bool get isNewRequestForSeller => this == OrderStatus.pending;

  /// Seller "In progress" segment: countered or approved and moving through payment/completion.
  bool get isInProgressForSeller {
    switch (this) {
      case OrderStatus.approved:
      case OrderStatus.countered:
      case OrderStatus.paymentReported:
      case OrderStatus.paymentConfirmed:
        return true;
      case OrderStatus.pending:
      case OrderStatus.rejected:
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return false;
    }
  }

  /// Seller "Done" segment: completed, rejected, or cancelled.
  bool get isDoneForSeller {
    switch (this) {
      case OrderStatus.rejected:
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return true;
      case OrderStatus.pending:
      case OrderStatus.approved:
      case OrderStatus.countered:
      case OrderStatus.paymentReported:
      case OrderStatus.paymentConfirmed:
        return false;
    }
  }
}

/// One product line inside an [OrderView]. Money is always an integer in paise.
@immutable
class OrderLine {
  final String productCode;
  final Map<String, String> title;
  final Map<String, String> unit;
  final int quantity;
  final int unitPricePaise;
  final int mrpPerUnitPaise;
  final int minOrderQuantity;
  final int availableStock;
  final String imageAsset;

  const OrderLine({
    required this.productCode,
    required this.title,
    required this.unit,
    required this.quantity,
    required this.unitPricePaise,
    int? mrpPerUnitPaise,
    this.minOrderQuantity = 1,
    this.availableStock = 500,
    String? imageAsset,
  })  : mrpPerUnitPaise = mrpPerUnitPaise ?? unitPricePaise,
        imageAsset = imageAsset ?? 'assets/catalog/$productCode.jpg';

  int get lineTotalPaise => quantity * unitPricePaise;

  String localizedTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.en:
        return title['en'] ?? '';
      case AppLanguage.hi:
        return title['hi'] ?? title['en'] ?? '';
      case AppLanguage.mr:
        return title['mr'] ?? title['en'] ?? '';
    }
  }

  String localizedUnit(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.en:
        return unit['en'] ?? '';
      case AppLanguage.hi:
        return unit['hi'] ?? unit['en'] ?? '';
      case AppLanguage.mr:
        return unit['mr'] ?? unit['en'] ?? '';
    }
  }

  OrderLine copyWith({
    String? productCode,
    Map<String, String>? title,
    Map<String, String>? unit,
    int? quantity,
    int? unitPricePaise,
    int? mrpPerUnitPaise,
    int? minOrderQuantity,
    int? availableStock,
    String? imageAsset,
  }) {
    return OrderLine(
      productCode: productCode ?? this.productCode,
      title: title ?? this.title,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPricePaise: unitPricePaise ?? this.unitPricePaise,
      mrpPerUnitPaise: mrpPerUnitPaise ?? this.mrpPerUnitPaise,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      availableStock: availableStock ?? this.availableStock,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}

/// Optional seller counter-offer proposing a new quantity and/or unit price in paise.
@immutable
class OrderCounterOffer {
  final int quantity;
  final int unitPricePaise;
  final String? note;

  const OrderCounterOffer({
    required this.quantity,
    required this.unitPricePaise,
    this.note,
  });

  int get totalPaise => quantity * unitPricePaise;
}

/// A single timestamped status transition in an order's timeline.
@immutable
class OrderStatusEvent {
  final OrderStatus status;
  final DateTime at;
  final String? note;

  const OrderStatusEvent({
    required this.status,
    required this.at,
    this.note,
  });
}

/// Immutable view model representing a buyer's request / order to a single seller.
@immutable
class OrderView {
  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerType; // 'gramsabha' | 'cfrholder'
  final String buyerName;
  final String buyerPhone;
  final List<OrderLine> lines;
  final String deliveryPref; // 'pickup' | 'delivery'
  final String paymentMethod; // 'upi' | 'cod'
  final String? dropVillageId;
  final String note;
  final OrderStatus status;
  final List<OrderStatusEvent> events;
  final OrderCounterOffer? counterOffer;
  final String? paymentReference;
  final String? rejectionReason;
  final bool isSample;
  final bool isDemoBuyer;

  const OrderView({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.sellerType,
    required this.buyerName,
    required this.buyerPhone,
    required this.lines,
    required this.deliveryPref,
    required this.paymentMethod,
    this.dropVillageId,
    this.note = '',
    required this.status,
    required this.events,
    this.counterOffer,
    this.paymentReference,
    this.rejectionReason,
    this.isSample = true,
    this.isDemoBuyer = false,
  });

  /// Total order amount in paise, computed from [lines].
  int get totalPaise => lines.fold<int>(0, (sum, line) => sum + line.lineTotalPaise);

  /// Timestamp of the initial request creation.
  DateTime get createdAt =>
      events.isNotEmpty ? events.first.at : DateTime.utc(2026, 10, 20, 9, 0);

  /// Timestamp of the most recent status event.
  DateTime get updatedAt =>
      events.isNotEmpty ? events.last.at : createdAt;

  OrderView copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? sellerType,
    String? buyerName,
    String? buyerPhone,
    List<OrderLine>? lines,
    String? deliveryPref,
    String? paymentMethod,
    String? dropVillageId,
    String? note,
    OrderStatus? status,
    List<OrderStatusEvent>? events,
    OrderCounterOffer? counterOffer,
    bool clearCounterOffer = false,
    String? paymentReference,
    String? rejectionReason,
    bool? isSample,
    bool? isDemoBuyer,
  }) {
    return OrderView(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerType: sellerType ?? this.sellerType,
      buyerName: buyerName ?? this.buyerName,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      lines: lines ?? this.lines,
      deliveryPref: deliveryPref ?? this.deliveryPref,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      dropVillageId: dropVillageId ?? this.dropVillageId,
      note: note ?? this.note,
      status: status ?? this.status,
      events: events ?? this.events,
      counterOffer: clearCounterOffer ? null : (counterOffer ?? this.counterOffer),
      paymentReference: paymentReference ?? this.paymentReference,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isSample: isSample ?? this.isSample,
      isDemoBuyer: isDemoBuyer ?? this.isDemoBuyer,
    );
  }
}

