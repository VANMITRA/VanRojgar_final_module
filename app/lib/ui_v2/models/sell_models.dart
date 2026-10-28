import 'dart:math' as math;

/// Immutable seller listing model for Phase 8 (Sell page).
///
/// Money is always stored as an integer in paise (`mrpPaise`, `pricePaise`).
/// `status` is `'active'` or `'paused'`.
/// `fulfilment` is `'pickup'`, `'delivery'`, or `'both'`.
class MyListing {
  final String id;
  final String productCode;
  final int quantityTotal;
  final int quantitySold;
  final int mrpPaise;
  final int pricePaise;
  final int minOrderQuantity;
  final String fulfilment; // 'pickup' | 'delivery' | 'both'
  final String status; // 'active' | 'paused'
  final DateTime createdAt;
  final bool isSample;

  const MyListing({
    required this.id,
    required this.productCode,
    required this.quantityTotal,
    this.quantitySold = 0,
    required this.mrpPaise,
    required this.pricePaise,
    this.minOrderQuantity = 1,
    this.fulfilment = 'both',
    this.status = 'active',
    required this.createdAt,
    this.isSample = false,
  });

  /// Remaining stock (`quantityTotal - quantitySold`, clamped to >= 0).
  int get quantityAvailable => math.max(0, quantityTotal - quantitySold);

  /// Discount per unit in paise (`mrpPaise - pricePaise`, clamped to >= 0).
  int get discountPaise => math.max(0, mrpPaise - pricePaise);

  /// Rounded discount percentage (`0` when `pricePaise >= mrpPaise` or `mrpPaise <= 0`).
  int get discountPercent =>
      mrpPaise > 0 && pricePaise < mrpPaise ? ((discountPaise * 100) / mrpPaise).round() : 0;

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';

  MyListing copyWith({
    String? id,
    String? productCode,
    int? quantityTotal,
    int? quantitySold,
    int? mrpPaise,
    int? pricePaise,
    int? minOrderQuantity,
    String? fulfilment,
    String? status,
    DateTime? createdAt,
    bool? isSample,
  }) {
    return MyListing(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      quantityTotal: quantityTotal ?? this.quantityTotal,
      quantitySold: quantitySold ?? this.quantitySold,
      mrpPaise: mrpPaise ?? this.mrpPaise,
      pricePaise: pricePaise ?? this.pricePaise,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      fulfilment: fulfilment ?? this.fulfilment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isSample: isSample ?? this.isSample,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyListing &&
        other.id == id &&
        other.productCode == productCode &&
        other.quantityTotal == quantityTotal &&
        other.quantitySold == quantitySold &&
        other.mrpPaise == mrpPaise &&
        other.pricePaise == pricePaise &&
        other.minOrderQuantity == minOrderQuantity &&
        other.fulfilment == fulfilment &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.isSample == isSample;
  }

  @override
  int get hashCode => Object.hash(
        id,
        productCode,
        quantityTotal,
        quantitySold,
        mrpPaise,
        pricePaise,
        minOrderQuantity,
        fulfilment,
        status,
        createdAt,
        isSample,
      );
}

