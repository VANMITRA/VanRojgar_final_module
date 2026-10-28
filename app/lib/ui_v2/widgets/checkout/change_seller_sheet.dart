import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/checkout_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../models/catalog_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/checkout_providers.dart';
import '../../theme/van_rozgar_tokens.dart';

/// Opens the modal bottom sheet allowing the buyer to choose a seller (listing) for [product].
Future<void> showChangeSellerSheet(
  BuildContext context, {
  required ShopProduct product,
  required String currentListingId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _ChangeSellerSheet(
      product: product,
      currentListingId: currentListingId,
    ),
  );
}

class _ChangeSellerSheet extends ConsumerWidget {
  final ShopProduct product;
  final String currentListingId;

  const _ChangeSellerSheet({
    required this.product,
    required this.currentListingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.82;

    final sorted = sortListingsCheapestFirst(product.listings);
    final unit = product.localizedUnit(language);

    void selectListing(ShopListing listing) {
      final code = product.productCode;
      final currentChoices = ref.read(cartSellerChoiceProvider);
      ref.read(cartSellerChoiceProvider.notifier).state = {
        ...currentChoices,
        code: listing.id,
      };

      final currentCart = ref.read(cartQuantitiesProvider);
      final currentQty = currentCart[code] ?? listing.minOrderQuantity;
      final clamped = clampQuantityForListing(currentQty, listing);
      if (clamped.quantity != currentQty) {
        ref.read(cartQuantitiesProvider.notifier).state = {
          ...currentCart,
          code: clamped.quantity,
        };
      }
      final notices = Map<String, SellerQtyClampReason>.from(
        ref.read(cartLineClampNoticeProvider),
      );
      if (clamped.reason == SellerQtyClampReason.none) {
        notices.remove(code);
      } else {
        notices[code] = clamped.reason;
      }
      ref.read(cartLineClampNoticeProvider.notifier).state = notices;

      Navigator.of(context).pop();
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      child: Material(
        key: const Key('change_seller_sheet'),
        color: tokens.page,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0 * s)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0 * s, 12.0 * s, 16.0 * s, 16.0 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.0 * s,
                    height: 4.0 * s,
                    decoration: BoxDecoration(
                      color: tokens.borders,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
                SizedBox(height: 8.0 * s),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.coChooseSeller,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18.0 * s,
                              fontWeight: FontWeight.w800,
                              color: tokens.heading,
                            ),
                          ),
                          SizedBox(height: 2.0 * s),
                          Text(
                            product.localizedTitle(language),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.0 * s,
                              color: tokens.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('change_seller_close'),
                      tooltip: strings.backLabel,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: tokens.heading),
                    ),
                  ],
                ),
                SizedBox(height: 8.0 * s),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sorted.length,
                    separatorBuilder: (context, index) => SizedBox(height: 10.0 * s),
                    itemBuilder: (context, index) {
                      final listing = sorted[index];
                      final isLowest = index == 0;
                      final isSelected = listing.id == currentListingId;
                      return _SellerOptionCard(
                        listing: listing,
                        isLowest: isLowest,
                        isSelected: isSelected,
                        unit: unit,
                        language: language,
                        tokens: tokens,
                        s: s,
                        onTap: () => selectListing(listing),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SellerOptionCard extends StatelessWidget {
  final ShopListing listing;
  final bool isLowest;
  final bool isSelected;
  final String unit;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;
  final VoidCallback onTap;

  const _SellerOptionCard({
    required this.listing,
    required this.isLowest,
    required this.isSelected,
    required this.unit,
    required this.language,
    required this.tokens,
    required this.s,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(language);
    final sellerName = strings.coSellerName(
      listing.sellerName,
      listing.sellerType,
      listing.sellerId,
    );
    final sellerTypeLabel =
        listing.sellerType == 'gramsabha' ? strings.sellerGramSabha : strings.sellerCfrHolder;
    final hasDiscount = listing.discountPaise > 0 && listing.mrpPerUnitPaise > listing.pricePerUnitPaise;

    return Material(
      color: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0 * s),
        side: BorderSide(
          color: isSelected ? tokens.primaryGreen : tokens.borders,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('seller_option_${listing.id}'),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.0 * s),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.0 * s,
                height: 38.0 * s,
                decoration: BoxDecoration(
                  color: isSelected ? tokens.primaryGreen : tokens.chipBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected
                      ? Icons.check
                      : (listing.sellerType == 'gramsabha'
                          ? Icons.groups_outlined
                          : Icons.person_outline),
                  size: 20.0 * s,
                  color: isSelected ? tokens.onPrimaryGreen : tokens.chipText,
                ),
              ),
              SizedBox(width: 10.0 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                      ),
                    ),
                    SizedBox(height: 2.0 * s),
                    Text(
                      '$sellerTypeLabel · ${strings.sampleVillageValue}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0 * s,
                        color: tokens.mutedText,
                      ),
                    ),
                    SizedBox(height: 4.0 * s),
                    Text(
                      strings.qtyLeft(listing.quantityAvailable, unit),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0 * s,
                        color: tokens.mutedText,
                      ),
                    ),
                    Text(
                      strings.minOrderText(listing.minOrderQuantity, unit),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0 * s,
                        color: tokens.mutedText,
                      ),
                    ),
                    SizedBox(height: 4.0 * s),
                    Text(
                      strings.coOffers(strings.coFulfilmentText(listing.fulfilment)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5 * s,
                        color: tokens.mutedText,
                      ),
                    ),
                    if (isLowest || isSelected) ...[
                      SizedBox(height: 6.0 * s),
                      Wrap(
                        spacing: 6.0 * s,
                        runSpacing: 4.0 * s,
                        children: [
                          if (isLowest)
                            _TagPill(
                              text: strings.lowestPrice,
                              bg: tokens.primaryGreen,
                              fg: tokens.onPrimaryGreen,
                              s: s,
                            ),
                          if (isSelected)
                            _TagPill(
                              text: strings.coSelectedSeller,
                              bg: tokens.chipBg,
                              fg: tokens.chipText,
                              s: s,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.0 * s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatRupees(listing.pricePerUnitPaise),
                      style: TextStyle(
                        fontSize: 16.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.orange,
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatRupees(listing.mrpPerUnitPaise),
                        style: TextStyle(
                          fontSize: 11.5 * s,
                          color: tokens.mutedText,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  Text(
                    strings.perUnit(unit),
                    style: TextStyle(
                      fontSize: 11.0 * s,
                      color: tokens.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final double s;

  const _TagPill({
    required this.text,
    required this.bg,
    required this.fg,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0 * s, vertical: 3.0 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5 * s,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

