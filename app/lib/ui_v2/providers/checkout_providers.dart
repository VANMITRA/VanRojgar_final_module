import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../l10n/checkout_strings.dart';
import '../models/catalog_models.dart';
import 'catalog_providers.dart';

/// Reason a cart line's quantity was clamped after switching sellers.
enum SellerQtyClampReason {
  none,
  raisedToMin,
  loweredToStock,
}

/// Seller metadata for displaying unsupported fulfilment reasons.
class SellerSummary {
  final String sellerId;
  final String sellerName;
  final String sellerType;

  const SellerSummary({
    required this.sellerId,
    required this.sellerName,
    required this.sellerType,
  });

  String localizedName(AppStrings strings) =>
      strings.coSellerName(sellerName, sellerType, sellerId);
}

/// A group of cart lines belonging to the same seller, ordered by first appearance in the cart.
class SellerCartGroup {
  final String sellerId;
  final String sellerName;
  final String sellerType;
  final List<CartLine> lines;
  final int subtotalPaise;
  final bool offersPickup;
  final bool offersDelivery;

  const SellerCartGroup({
    required this.sellerId,
    required this.sellerName,
    required this.sellerType,
    required this.lines,
    required this.subtotalPaise,
    required this.offersPickup,
    required this.offersDelivery,
  });

  String get effectiveFulfilment {
    if (offersPickup && offersDelivery) return 'both';
    if (offersPickup) return 'pickup';
    if (offersDelivery) return 'delivery';
    return 'none';
  }
}

/// Groups cart lines by `sellerId` (falling back to `listing.id`), preserving first-added order.
List<SellerCartGroup> groupCartLinesBySeller(List<CartLine> lines) {
  final order = <String>[];
  final bySeller = <String, List<CartLine>>{};

  for (final line in lines) {
    final key = line.sellerId.isNotEmpty ? line.sellerId : line.listing.id;
    final bucket = bySeller[key];
    if (bucket == null) {
      order.add(key);
      bySeller[key] = [line];
    } else {
      bucket.add(line);
    }
  }

  final groups = <SellerCartGroup>[];
  for (final key in order) {
    final groupLines = bySeller[key]!;
    final first = groupLines.first.listing;
    final subtotal = groupLines.fold<int>(0, (sum, l) => sum + l.lineTotalPaise);
    final canPickup = groupLines.every(
      (l) => l.listing.fulfilment == 'pickup' || l.listing.fulfilment == 'both',
    );
    final canDeliver = groupLines.every(
      (l) => l.listing.fulfilment == 'delivery' || l.listing.fulfilment == 'both',
    );
    groups.add(
      SellerCartGroup(
        sellerId: key,
        sellerName: first.sellerName,
        sellerType: first.sellerType,
        lines: List<CartLine>.unmodifiable(groupLines),
        subtotalPaise: subtotal,
        offersPickup: canPickup,
        offersDelivery: canDeliver,
      ),
    );
  }
  return List<SellerCartGroup>.unmodifiable(groups);
}

/// Computes the grand total in paise across all cart lines.
int computeCartGrandTotalPaise(List<CartLine> lines) {
  return lines.fold<int>(0, (sum, line) => sum + line.lineTotalPaise);
}

/// Returns a new list of listings sorted cheapest first (by `pricePerUnitPaise` ascending).
List<ShopListing> sortListingsCheapestFirst(List<ShopListing> listings) {
  final copy = [...listings];
  copy.sort((a, b) => a.pricePerUnitPaise.compareTo(b.pricePerUnitPaise));
  return copy;
}

/// Clamps [currentQty] to [listing]'s minimum order quantity and available stock.
/// Never lets the quantity go below `minOrderQuantity` or above `quantityAvailable`.
({int quantity, SellerQtyClampReason reason}) clampQuantityForListing(
  int currentQty,
  ShopListing listing,
) {
  final minOrder = math.max(1, listing.minOrderQuantity);
  final stock = listing.quantityAvailable;

  if (stock > 0 && currentQty > stock) {
    return (quantity: stock, reason: SellerQtyClampReason.loweredToStock);
  }
  if (currentQty < minOrder) {
    final target = stock > 0 ? math.min(minOrder, stock) : minOrder;
    return (quantity: target, reason: SellerQtyClampReason.raisedToMin);
  }
  return (quantity: currentQty, reason: SellerQtyClampReason.none);
}

/// Checks whether every line's quantity is within its chosen listing's minimum order and stock.
bool validateCartQuantitiesWithinBounds(List<CartLine> lines) {
  if (lines.isEmpty) return false;
  for (final line in lines) {
    final minOrder = math.max(1, line.listing.minOrderQuantity);
    final stock = line.listing.quantityAvailable;
    if (line.quantity < minOrder) return false;
    if (line.quantity > stock) return false;
  }
  return true;
}

/// Availability of Pickup and Delivery across all chosen listings in the cart.
class FulfilmentAvailability {
  final bool pickupEnabled;
  final bool deliveryEnabled;
  final List<SellerSummary> sellersWithoutPickup;
  final List<SellerSummary> sellersWithoutDelivery;

  const FulfilmentAvailability({
    required this.pickupEnabled,
    required this.deliveryEnabled,
    required this.sellersWithoutPickup,
    required this.sellersWithoutDelivery,
  });

  bool get bothDisabled => !pickupEnabled && !deliveryEnabled;

  /// Resolves the effective delivery preference given the cart's availability constraints.
  String? resolveEffectiveDeliveryPref(String preferred) {
    if (bothDisabled) return null;
    if (preferred == 'pickup' && !pickupEnabled && deliveryEnabled) {
      return 'delivery';
    }
    if (preferred == 'delivery' && !deliveryEnabled && pickupEnabled) {
      return 'pickup';
    }
    return preferred;
  }
}

/// Evaluates whether Pickup and Delivery are allowed for the current cart lines.
FulfilmentAvailability evaluateFulfilmentAvailability(List<CartLine> lines) {
  if (lines.isEmpty) {
    return const FulfilmentAvailability(
      pickupEnabled: true,
      deliveryEnabled: true,
      sellersWithoutPickup: [],
      sellersWithoutDelivery: [],
    );
  }

  final noPickupIds = <String>{};
  final noPickup = <SellerSummary>[];
  final noDeliveryIds = <String>{};
  final noDelivery = <SellerSummary>[];

  for (final line in lines) {
    final f = line.listing.fulfilment;
    final sellerKey = line.sellerId.isNotEmpty ? line.sellerId : line.listing.id;
    final summary = SellerSummary(
      sellerId: sellerKey,
      sellerName: line.listing.sellerName,
      sellerType: line.listing.sellerType,
    );
    if (f == 'delivery') {
      if (noPickupIds.add(sellerKey)) {
        noPickup.add(summary);
      }
    } else if (f == 'pickup') {
      if (noDeliveryIds.add(sellerKey)) {
        noDelivery.add(summary);
      }
    }
  }

  return FulfilmentAvailability(
    pickupEnabled: noPickup.isEmpty,
    deliveryEnabled: noDelivery.isEmpty,
    sellersWithoutPickup: List<SellerSummary>.unmodifiable(noPickup),
    sellersWithoutDelivery: List<SellerSummary>.unmodifiable(noDelivery),
  );
}

/// Per-product inline note shown on a cart line when switching sellers clamped its quantity.
final cartLineClampNoticeProvider =
    StateProvider<Map<String, SellerQtyClampReason>>((ref) => const {});

/// Buyer's in-progress choices on the Checkout page (persisted across guest sign-in/sign-up).
class CheckoutChoices {
  final String deliveryPref; // 'pickup' | 'delivery'
  final String paymentMethod; // 'upi' | 'cod'
  final String? dropVillageId;
  final String note;

  const CheckoutChoices({
    this.deliveryPref = 'pickup',
    this.paymentMethod = 'cod',
    this.dropVillageId,
    this.note = '',
  });

  CheckoutChoices copyWith({
    String? deliveryPref,
    String? paymentMethod,
    String? dropVillageId,
    bool clearDropVillage = false,
    String? note,
  }) {
    return CheckoutChoices(
      deliveryPref: deliveryPref ?? this.deliveryPref,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      dropVillageId: clearDropVillage ? null : (dropVillageId ?? this.dropVillageId),
      note: note ?? this.note,
    );
  }
}

class CheckoutChoicesNotifier extends StateNotifier<CheckoutChoices> {
  CheckoutChoicesNotifier() : super(const CheckoutChoices());

  void setDeliveryPref(String pref) {
    state = state.copyWith(deliveryPref: pref);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setDropVillageId(String? villageId) {
    if (villageId == null) {
      state = state.copyWith(clearDropVillage: true);
    } else {
      state = state.copyWith(dropVillageId: villageId);
    }
  }

  void setNote(String note) {
    final trimmed = note.length > 300 ? note.substring(0, 300) : note;
    state = state.copyWith(note: trimmed);
  }

  void reset() {
    state = const CheckoutChoices();
  }
}

final checkoutChoicesProvider =
    StateNotifierProvider<CheckoutChoicesNotifier, CheckoutChoices>((ref) {
  return CheckoutChoicesNotifier();
});

/// One line inside an [OrderRequest].
class OrderRequestLine {
  final String productCode;
  final String listingId;
  final Map<String, String> title;
  final Map<String, String> unit;
  final int quantity;
  final int unitPricePaise;

  const OrderRequestLine({
    required this.productCode,
    required this.listingId,
    required this.title,
    required this.unit,
    required this.quantity,
    required this.unitPricePaise,
  });

  int get lineTotalPaise => unitPricePaise * quantity;

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
}

/// Immutable buyer-facing order request (one per seller group).
class OrderRequest {
  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerType;
  final List<OrderRequestLine> lines;
  final int totalPaise;
  final String deliveryPref; // 'pickup' | 'delivery'
  final String paymentMethod; // 'upi' | 'cod'
  final String? dropVillageId;
  final String note;
  final String status; // 'pending'
  final DateTime createdAt;
  final String buyerName;
  final String buyerPhone;

  const OrderRequest({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.sellerType,
    required this.lines,
    required this.totalPaise,
    required this.deliveryPref,
    required this.paymentMethod,
    this.dropVillageId,
    required this.note,
    this.status = 'pending',
    required this.createdAt,
    required this.buyerName,
    required this.buyerPhone,
  });
}

/// Pure function that builds one [OrderRequest] per seller group from [lines].
List<OrderRequest> buildOrderRequests({
  required List<CartLine> lines,
  required String deliveryPref,
  required String paymentMethod,
  required String? dropVillageId,
  required String note,
  required AuthUser buyer,
  required int startSequence,
  required DateTime createdAt,
}) {
  final groups = groupCartLinesBySeller(lines);
  final requests = <OrderRequest>[];
  var seq = startSequence;

  for (final group in groups) {
    final reqLines = group.lines
        .map(
          (l) => OrderRequestLine(
            productCode: l.product.productCode,
            listingId: l.listing.id,
            title: Map<String, String>.unmodifiable(l.product.title),
            unit: Map<String, String>.unmodifiable(l.product.unit),
            quantity: l.quantity,
            unitPricePaise: l.unitPricePaise,
          ),
        )
        .toList(growable: false);

    requests.add(
      OrderRequest(
        id: 'req-$seq',
        sellerId: group.sellerId,
        sellerName: group.sellerName,
        sellerType: group.sellerType,
        lines: List<OrderRequestLine>.unmodifiable(reqLines),
        totalPaise: group.subtotalPaise,
        deliveryPref: deliveryPref,
        paymentMethod: paymentMethod,
        dropVillageId: deliveryPref == 'delivery' ? dropVillageId : null,
        note: note.trim(),
        status: 'pending',
        createdAt: createdAt,
        buyerName: buyer.name,
        buyerPhone: buyer.phone,
      ),
    );
    seq++;
  }

  return List<OrderRequest>.unmodifiable(requests);
}

/// All order requests created during this demo session.
final requestsProvider = StateProvider<List<OrderRequest>>((ref) => const []);

/// The batch of requests created by the most recent checkout submission (shown on `/checkout/done`).
final lastSentRequestsProvider = StateProvider<List<OrderRequest>>((ref) => const []);

