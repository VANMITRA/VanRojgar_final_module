import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/l10n/checkout_strings.dart';
import 'package:vanrozgar/ui_v2/models/catalog_models.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/checkout_providers.dart';

ShopProduct _makeProduct(
  String code,
  String en,
  List<ShopListing> listings,
) {
  return ShopProduct(
    productCode: code,
    categorySlug: 'fruit',
    imageAsset: 'assets/catalog/$code.jpg',
    title: {'en': en, 'hi': 'हिं-$en', 'mr': 'मरा-$en'},
    unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
    notForEating: false,
    listings: listings,
  );
}

ShopListing _makeListing({
  required String id,
  required String sellerId,
  required String sellerName,
  String sellerType = 'gramsabha',
  String fulfilment = 'both',
  required int price,
  int? mrp,
  int total = 100,
  int sold = 10,
  int minOrder = 1,
}) {
  return ShopListing(
    id: id,
    sellerId: sellerId,
    sellerName: sellerName,
    sellerType: sellerType,
    fulfilment: fulfilment,
    pricePerUnitPaise: price,
    mrpPerUnitPaise: mrp ?? price,
    quantityTotal: total,
    quantitySold: sold,
    minOrderQuantity: minOrder,
    daysAgo: 2,
  );
}

void main() {
  group('Pure functions: grouping by seller and totals', () {
    test('groupCartLinesBySeller groups lines by seller in first-added order and computes subtotals', () {
      final lA1 = _makeListing(
        id: 'l-a1',
        sellerId: 'seller-1',
        sellerName: 'Sample Gram Sabha 1',
        price: 10000,
      );
      final lB1 = _makeListing(
        id: 'l-b1',
        sellerId: 'seller-2',
        sellerName: 'Sample CFR holder 2',
        sellerType: 'cfrholder',
        fulfilment: 'pickup',
        price: 5000,
      );
      final lA2 = _makeListing(
        id: 'l-a2',
        sellerId: 'seller-1',
        sellerName: 'Sample Gram Sabha 1',
        price: 8000,
      );

      final p1 = _makeProduct('p1', 'Mango', [lA1]);
      final p2 = _makeProduct('p2', 'Amla', [lB1]);
      final p3 = _makeProduct('p3', 'Bael', [lA2]);

      final lines = [
        CartLine(p1, 2, lA1), // 20000
        CartLine(p2, 3, lB1), // 15000
        CartLine(p3, 1, lA2), // 8000
      ];

      final groups = groupCartLinesBySeller(lines);
      expect(groups.length, 2);
      expect(groups[0].sellerId, 'seller-1');
      expect(groups[0].lines.map((l) => l.product.productCode), ['p1', 'p3']);
      expect(groups[0].subtotalPaise, 28000);
      expect(groups[0].offersPickup, isTrue);
      expect(groups[0].offersDelivery, isTrue);

      expect(groups[1].sellerId, 'seller-2');
      expect(groups[1].lines.map((l) => l.product.productCode), ['p2']);
      expect(groups[1].subtotalPaise, 15000);
      expect(groups[1].offersPickup, isTrue);
      expect(groups[1].offersDelivery, isFalse);

      expect(computeCartGrandTotalPaise(lines), 43000);
    });

    test('sortListingsCheapestFirst orders listings by price ascending', () {
      final l1 = _makeListing(id: '1', sellerId: 's1', sellerName: 'S1', price: 12000);
      final l2 = _makeListing(id: '2', sellerId: 's2', sellerName: 'S2', price: 8500);
      final l3 = _makeListing(id: '3', sellerId: 's3', sellerName: 'S3', price: 9900);
      final sorted = sortListingsCheapestFirst([l1, l2, l3]);
      expect(sorted.map((l) => l.id), ['2', '3', '1']);
    });

    test('clampQuantityForListing raises below minimum and lowers above available stock', () {
      final listing = _makeListing(
        id: 'l1',
        sellerId: 's1',
        sellerName: 'S1',
        price: 5000,
        total: 25,
        sold: 10, // 15 available
        minOrder: 5,
      );

      final raised = clampQuantityForListing(2, listing);
      expect(raised.quantity, 5);
      expect(raised.reason, SellerQtyClampReason.raisedToMin);

      final lowered = clampQuantityForListing(20, listing);
      expect(lowered.quantity, 15);
      expect(lowered.reason, SellerQtyClampReason.loweredToStock);

      final unchanged = clampQuantityForListing(10, listing);
      expect(unchanged.quantity, 10);
      expect(unchanged.reason, SellerQtyClampReason.none);
    });

    test('validateCartQuantitiesWithinBounds checks minOrder and stock', () {
      final listing = _makeListing(
        id: 'l1',
        sellerId: 's1',
        sellerName: 'S1',
        price: 5000,
        total: 20,
        sold: 10, // 10 available
        minOrder: 3,
      );
      final product = _makeProduct('p1', 'Mango', [listing]);

      expect(validateCartQuantitiesWithinBounds(const []), isFalse);
      expect(validateCartQuantitiesWithinBounds([CartLine(product, 2, listing)]), isFalse);
      expect(validateCartQuantitiesWithinBounds([CartLine(product, 11, listing)]), isFalse);
      expect(validateCartQuantitiesWithinBounds([CartLine(product, 5, listing)]), isTrue);
    });
  });

  group('Pure functions: fulfilment availability and request building', () {
    test('evaluateFulfilmentAvailability handles both, pickup-only, delivery-only and mixed', () {
      final bothL = _makeListing(
        id: 'b',
        sellerId: 's-both',
        sellerName: 'Sample Gram Sabha 1',
        fulfilment: 'both',
        price: 5000,
      );
      final pickupL = _makeListing(
        id: 'p',
        sellerId: 's-pick',
        sellerName: 'Sample CFR holder 2',
        sellerType: 'cfrholder',
        fulfilment: 'pickup',
        price: 6000,
      );
      final deliveryL = _makeListing(
        id: 'd',
        sellerId: 's-del',
        sellerName: 'Sample Gram Sabha 3',
        fulfilment: 'delivery',
        price: 7000,
      );

      final pBoth = _makeProduct('p1', 'Bamboo', [bothL]);
      final pPick = _makeProduct('p2', 'Amla', [pickupL]);
      final pDel = _makeProduct('p3', 'Mango', [deliveryL]);

      // Only 'both'
      final a1 = evaluateFulfilmentAvailability([CartLine(pBoth, 1, bothL)]);
      expect(a1.pickupEnabled, isTrue);
      expect(a1.deliveryEnabled, isTrue);
      expect(a1.bothDisabled, isFalse);

      // Pickup-only + both -> delivery disabled
      final a2 = evaluateFulfilmentAvailability([
        CartLine(pBoth, 1, bothL),
        CartLine(pPick, 1, pickupL),
      ]);
      expect(a2.pickupEnabled, isTrue);
      expect(a2.deliveryEnabled, isFalse);
      expect(a2.sellersWithoutDelivery.single.sellerId, 's-pick');
      expect(a2.resolveEffectiveDeliveryPref('delivery'), 'pickup');

      // Delivery-only + both -> pickup disabled
      final a3 = evaluateFulfilmentAvailability([
        CartLine(pBoth, 1, bothL),
        CartLine(pDel, 1, deliveryL),
      ]);
      expect(a3.pickupEnabled, isFalse);
      expect(a3.deliveryEnabled, isTrue);
      expect(a3.sellersWithoutPickup.single.sellerId, 's-del');
      expect(a3.resolveEffectiveDeliveryPref('pickup'), 'delivery');

      // Mixed pickup-only + delivery-only -> both disabled
      final a4 = evaluateFulfilmentAvailability([
        CartLine(pPick, 1, pickupL),
        CartLine(pDel, 1, deliveryL),
      ]);
      expect(a4.pickupEnabled, isFalse);
      expect(a4.deliveryEnabled, isFalse);
      expect(a4.bothDisabled, isTrue);
      expect(a4.resolveEffectiveDeliveryPref('pickup'), isNull);
    });

    test('buildOrderRequests creates one OrderRequest per seller group with sequential ids', () {
      final l1 = _makeListing(
        id: 'l1',
        sellerId: 'seller-1',
        sellerName: 'Sample Gram Sabha 1',
        price: 9000,
      );
      final l2 = _makeListing(
        id: 'l2',
        sellerId: 'seller-2',
        sellerName: 'Sample CFR holder 2',
        sellerType: 'cfrholder',
        price: 6000,
      );
      final l3 = _makeListing(
        id: 'l3',
        sellerId: 'seller-1',
        sellerName: 'Sample Gram Sabha 1',
        price: 4000,
      );

      final p1 = _makeProduct('p1', 'Mango', [l1]);
      final p2 = _makeProduct('p2', 'Amla', [l2]);
      final p3 = _makeProduct('p3', 'Bael', [l3]);

      final now = DateTime.utc(2026, 10, 28, 12, 0);
      const buyer = AuthUser(
        name: 'Ramesh Deshmukh',
        role: 'buyer',
        phone: '+919876543210',
      );

      final requests = buildOrderRequests(
        lines: [
          CartLine(p1, 5, l1), // 45000
          CartLine(p2, 2, l2), // 12000
          CartLine(p3, 3, l3), // 12000
        ],
        deliveryPref: 'delivery',
        paymentMethod: 'upi',
        dropVillageId: 'dongargaon',
        note: '  Please pack in crates  ',
        buyer: buyer,
        startSequence: 1,
        createdAt: now,
      );

      expect(requests.length, 2);
      expect(requests[0].id, 'req-1');
      expect(requests[0].sellerId, 'seller-1');
      expect(requests[0].lines.length, 2);
      expect(requests[0].lines.map((l) => l.listingId), ['l1', 'l3']);
      expect(requests[0].totalPaise, 57000);
      expect(requests[0].deliveryPref, 'delivery');
      expect(requests[0].paymentMethod, 'upi');
      expect(requests[0].dropVillageId, 'dongargaon');
      expect(requests[0].note, 'Please pack in crates');
      expect(requests[0].status, 'pending');
      expect(requests[0].buyerName, 'Ramesh Deshmukh');
      expect(requests[0].buyerPhone, '+919876543210');

      expect(requests[1].id, 'req-2');
      expect(requests[1].sellerId, 'seller-2');
      expect(requests[1].lines.length, 1);
      expect(requests[1].totalPaise, 12000);
    });

    test('coSellerName localizes sample English seller names in Hindi and Marathi', () {
      expect(
        AppStrings.en.coSellerName('Sample Gram Sabha 1', 'gramsabha', 'seller-1'),
        'Sample Gram Sabha 1',
      );
      expect(
        AppStrings.hi.coSellerName('Sample Gram Sabha 1', 'gramsabha', 'seller-1'),
        'नमूना ग्राम सभा 1',
      );
      expect(
        AppStrings.mr.coSellerName('Sample CFR holder 3', 'cfrholder', 'seller-3'),
        'नमुना सीएफआर धारक 3',
      );
    });
  });
}

