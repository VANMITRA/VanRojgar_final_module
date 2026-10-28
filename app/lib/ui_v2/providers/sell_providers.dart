import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../l10n/sell_strings.dart';
import '../models/sell_models.dart';

/// Fields validated on the new/edit listing form.
enum ListingField {
  product,
  quantity,
  mrp,
  price,
  minOrder,
  fulfilment,
}

/// One validation error returned by [validateListing].
class ListingFieldError {
  final ListingField field;
  final String code;
  final String message;

  const ListingFieldError({
    required this.field,
    required this.code,
    required this.message,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListingFieldError &&
        other.field == field &&
        other.code == code &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(field, code, message);
}

/// Half-filled form state kept in a provider so going back and returning preserves user input.
class ListingDraft {
  final String? productCode;
  final String quantityText;
  final String mrpRupeesText;
  final String priceRupeesText;
  final String minOrderText;
  final String fulfilment;

  const ListingDraft({
    this.productCode,
    this.quantityText = '',
    this.mrpRupeesText = '',
    this.priceRupeesText = '',
    this.minOrderText = '1',
    this.fulfilment = 'both',
  });

  factory ListingDraft.fromListing(MyListing listing) {
    return ListingDraft(
      productCode: listing.productCode,
      quantityText: '${listing.quantityTotal}',
      mrpRupeesText: formatPaiseForInput(listing.mrpPaise),
      priceRupeesText: formatPaiseForInput(listing.pricePaise),
      minOrderText: '${listing.minOrderQuantity}',
      fulfilment: listing.fulfilment,
    );
  }

  ListingDraft copyWith({
    String? productCode,
    bool clearProductCode = false,
    String? quantityText,
    String? mrpRupeesText,
    String? priceRupeesText,
    String? minOrderText,
    String? fulfilment,
  }) {
    return ListingDraft(
      productCode: clearProductCode ? null : (productCode ?? this.productCode),
      quantityText: quantityText ?? this.quantityText,
      mrpRupeesText: mrpRupeesText ?? this.mrpRupeesText,
      priceRupeesText: priceRupeesText ?? this.priceRupeesText,
      minOrderText: minOrderText ?? this.minOrderText,
      fulfilment: fulfilment ?? this.fulfilment,
    );
  }
}

final RegExp _rupeesRe = RegExp(r'^\d+(\.\d{1,2})?$');
final RegExp _wholeIntRe = RegExp(r'^\d+$');

/// Parses a rupee string (up to 2 decimal places) into integer paise.
/// Returns `null` if [text] is empty, negative, or has more than 2 decimal digits.
int? parseRupeesToPaise(String text) {
  final trimmed = text.trim();
  if (!_rupeesRe.hasMatch(trimmed)) return null;
  final parts = trimmed.split('.');
  final whole = int.tryParse(parts[0]);
  if (whole == null) return null;
  int paisePart = 0;
  if (parts.length == 2) {
    final frac = parts[1].padRight(2, '0');
    paisePart = int.tryParse(frac) ?? 0;
  }
  return whole * 100 + paisePart;
}

/// Parses a whole number string into an integer. Returns `null` for non-digits or empty text.
int? parseWholeNumber(String text) {
  final trimmed = text.trim();
  if (!_wholeIntRe.hasMatch(trimmed)) return null;
  return int.tryParse(trimmed);
}

/// Formats integer paise into a plain rupee string for a text field (e.g. `9900` -> `'99'`, `9950` -> `'99.50'`).
String formatPaiseForInput(int paise) {
  final whole = paise ~/ 100;
  final rem = paise % 100;
  if (rem == 0) return '$whole';
  return '$whole.${rem.toString().padLeft(2, '0')}';
}

/// Computes the live discount percentage ONLY when `pricePaise < mrpPaise` and both are positive.
/// Returns `null` when there is no discount (`pricePaise >= mrpPaise`) or inputs are invalid.
int? liveDiscountPercent({required int? mrpPaise, required int? pricePaise}) {
  if (mrpPaise == null || pricePaise == null) return null;
  if (mrpPaise <= 0 || pricePaise <= 0) return null;
  if (pricePaise >= mrpPaise) return null;
  final discount = mrpPaise - pricePaise;
  final rounded = ((discount * 100) / mrpPaise).round();
  return rounded < 1 ? 1 : rounded;
}

/// Validates listing inputs and returns all field errors (empty list when valid).
///
/// Mirrors the server rules in `server/src/validators/listing.schema.js` and
/// `server/src/services/listing.service.js`:
/// - A catalog product must be chosen.
/// - Quantity must be a whole number > 0 and >= [quantitySold].
/// - MRP and selling price must be > 0, and selling price cannot exceed MRP.
/// - Minimum order must be >= 1 and <= [quantityTotal].
/// - Fulfilment must be `'pickup'`, `'delivery'`, or `'both'`.
List<ListingFieldError> validateListing({
  required String? productCode,
  required int? quantityTotal,
  int quantitySold = 0,
  required int? mrpPaise,
  required int? pricePaise,
  required int? minOrderQuantity,
  String fulfilment = 'both',
  AppLanguage language = AppLanguage.en,
  String unit = '',
}) {
  final strings = AppStrings.of(language);
  final errors = <ListingFieldError>[];

  if (productCode == null || productCode.trim().isEmpty) {
    errors.add(
      ListingFieldError(
        field: ListingField.product,
        code: 'product_required',
        message: strings.slErrProductRequired,
      ),
    );
  }

  if (quantityTotal == null || quantityTotal <= 0) {
    errors.add(
      ListingFieldError(
        field: ListingField.quantity,
        code: 'quantity_positive',
        message: strings.slErrQuantityPositive,
      ),
    );
  } else if (quantityTotal < quantitySold) {
    errors.add(
      ListingFieldError(
        field: ListingField.quantity,
        code: 'quantity_below_sold',
        message: strings.slErrQuantityBelowSold(quantitySold, unit),
      ),
    );
  }

  if (mrpPaise == null || mrpPaise <= 0) {
    errors.add(
      ListingFieldError(
        field: ListingField.mrp,
        code: 'mrp_positive',
        message: strings.slErrMrpPositive,
      ),
    );
  }

  if (pricePaise == null || pricePaise <= 0) {
    errors.add(
      ListingFieldError(
        field: ListingField.price,
        code: 'price_positive',
        message: strings.slErrPricePositive,
      ),
    );
  } else if (mrpPaise != null && mrpPaise > 0 && pricePaise > mrpPaise) {
    errors.add(
      ListingFieldError(
        field: ListingField.price,
        code: 'price_above_mrp',
        message: strings.slErrPriceAboveMrp,
      ),
    );
  }

  if (minOrderQuantity == null || minOrderQuantity < 1) {
    errors.add(
      ListingFieldError(
        field: ListingField.minOrder,
        code: 'min_order_positive',
        message: strings.slErrMinOrderPositive,
      ),
    );
  } else if (quantityTotal != null && quantityTotal > 0 && minOrderQuantity > quantityTotal) {
    errors.add(
      ListingFieldError(
        field: ListingField.minOrder,
        code: 'min_order_above_quantity',
        message: strings.slErrMinOrderAboveQuantity,
      ),
    );
  }

  if (fulfilment != 'pickup' && fulfilment != 'delivery' && fulfilment != 'both') {
    errors.add(
      ListingFieldError(
        field: ListingField.fulfilment,
        code: 'fulfilment_invalid',
        message: strings.slErrFulfilmentRequired,
      ),
    );
  }

  return errors;
}

/// Validates a [ListingDraft] directly using [validateListing].
List<ListingFieldError> validateListingDraft(
  ListingDraft draft, {
  int quantitySold = 0,
  AppLanguage language = AppLanguage.en,
  String unit = '',
}) {
  return validateListing(
    productCode: draft.productCode,
    quantityTotal: parseWholeNumber(draft.quantityText),
    quantitySold: quantitySold,
    mrpPaise: parseRupeesToPaise(draft.mrpRupeesText),
    pricePaise: parseRupeesToPaise(draft.priceRupeesText),
    minOrderQuantity: parseWholeNumber(draft.minOrderText),
    fulfilment: draft.fulfilment,
    language: language,
    unit: unit,
  );
}

/// Pure function: adds [newListing] at the top of [current].
List<MyListing> createListing(List<MyListing> current, MyListing newListing) {
  return <MyListing>[newListing, ...current];
}

/// Pure function: replaces the listing with `updated.id` in [current].
List<MyListing> updateListing(List<MyListing> current, MyListing updated) {
  return <MyListing>[
    for (final item in current)
      if (item.id == updated.id) updated else item,
  ];
}

/// Pure function: marks the listing with [id] as `'paused'`.
List<MyListing> pauseListing(List<MyListing> current, String id) {
  return <MyListing>[
    for (final item in current)
      if (item.id == id) item.copyWith(status: 'paused') else item,
  ];
}

/// Pure function: marks the listing with [id] as `'active'`.
List<MyListing> resumeListing(List<MyListing> current, String id) {
  return <MyListing>[
    for (final item in current)
      if (item.id == id) item.copyWith(status: 'active') else item,
  ];
}

/// Pure function: removes the listing with [id] from [current].
List<MyListing> removeListing(List<MyListing> current, String id) {
  return current.where((item) => item.id != id).toList(growable: false);
}

/// Three initial sample listings (all marked `isSample: true`).
final List<MyListing> initialSampleMyListings = <MyListing>[
  MyListing(
    id: 'sample-my-1',
    productCode: 'fruit_mango',
    quantityTotal: 120,
    quantitySold: 25,
    mrpPaise: 12000,
    pricePaise: 9600,
    minOrderQuantity: 5,
    fulfilment: 'both',
    status: 'active',
    createdAt: DateTime.utc(2026, 10, 20),
    isSample: true,
  ),
  MyListing(
    id: 'sample-my-2',
    productCode: 'bamboo',
    quantityTotal: 80,
    quantitySold: 20,
    mrpPaise: 14000,
    pricePaise: 11200,
    minOrderQuantity: 2,
    fulfilment: 'pickup',
    status: 'active',
    createdAt: DateTime.utc(2026, 10, 18),
    isSample: true,
  ),
  MyListing(
    id: 'sample-my-3',
    productCode: 'fruit_awla',
    quantityTotal: 60,
    quantitySold: 10,
    mrpPaise: 7500,
    pricePaise: 6000,
    minOrderQuantity: 5,
    fulfilment: 'delivery',
    status: 'paused',
    createdAt: DateTime.utc(2026, 10, 15),
    isSample: true,
  ),
];

/// In-memory seller listings provider seeded with 3 sample listings.
final myListingsProvider = StateProvider<List<MyListing>>((ref) {
  return initialSampleMyListings;
});

/// Provider keeping the in-progress new-listing draft across navigation.
final listingDraftProvider = StateProvider<ListingDraft>((ref) {
  return const ListingDraft();
});
