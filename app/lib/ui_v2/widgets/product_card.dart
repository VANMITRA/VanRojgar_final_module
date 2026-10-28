import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../l10n/shop_extra_strings.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import 'min_order_dialog.dart';
import 'quantity_picker_sheet.dart';
import 'quantity_stepper.dart';

enum ProductCardType { topDeal, bestSeller, newArrival, grid }

/// Sold share (0 to 1) of one listing, or of the whole product when no listing is given.
double _soldFraction(ShopListing? listing, ShopProduct product) {
  final sold = (listing?.quantitySold ?? product.totalSold).toDouble();
  final left = (listing?.quantityAvailable ?? product.totalAvailable).toDouble();
  final total = sold + left;
  return total > 0 ? (sold / total).clamp(0.0, 1.0) : 0.0;
}

/// Reusable product card component conforming to Phase 3 design rules.
class ProductCard extends ConsumerWidget {
  final ShopProduct product;
  final ShopListing? listing;
  final ProductCardType cardType;
  final VoidCallback? onTap;

  /// Show the live "62 kg sold · 38 kg left" bar under the name (Category page).
  final bool showStockBar;

  /// ADD opens the quantity picker sheet instead of adding the minimum at once (Category page).
  final bool useQuantityPicker;

  const ProductCard({
    super.key,
    required this.product,
    this.listing,
    this.cardType = ProductCardType.grid,
    this.onTap,
    this.showStockBar = false,
    this.useQuantityPicker = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final cart = ref.watch(cartQuantitiesProvider);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final s = (screenWidth / 360.0).clamp(0.85, 1.25);

    final title = product.localizedTitle(language);
    final unit = product.localizedUnit(language);
    final activeListing = listing ?? product.cheapestListing;
    final minOrder = activeListing?.minOrderQuantity ?? 1;

    // Price and MRP resolution
    final int pricePaise;
    final String priceStr;
    final int mrpPaise;
    final int discountPaise;
    final int discountPercent;

    if (cardType == ProductCardType.bestSeller || cardType == ProductCardType.newArrival) {
      pricePaise = listing?.pricePerUnitPaise ?? product.startingAtPaise;
      priceStr = formatRupees(pricePaise);
      mrpPaise = listing?.mrpPerUnitPaise ?? pricePaise;
      discountPaise = listing?.discountPaise ?? 0;
      discountPercent = listing?.discountPercent ?? 0;
    } else {
      pricePaise = product.startingAtPaise;
      priceStr = strings.priceFrom(formatRupees(pricePaise));
      mrpPaise = product.cheapestListing?.mrpPerUnitPaise ?? pricePaise;
      discountPaise = product.cheapestListing?.discountPaise ?? 0;
      discountPercent = product.bestDiscountPercent;
    }

    final hasDiscount = discountPaise > 0 && mrpPaise > pricePaise;
    final currentQty = cart[product.productCode] ?? 0;

    // Last row pill text
    final String pillText;
    switch (cardType) {
      case ProductCardType.bestSeller:
        final sold = listing?.quantitySold ?? product.totalSold;
        pillText = strings.soldQty(sold, unit);
        break;
      case ProductCardType.newArrival:
        final sellerType = listing?.sellerType ?? 'gramsabha';
        pillText = sellerType == 'gramsabha' ? strings.sellerGramSabha : strings.sellerCfrHolder;
        break;
      case ProductCardType.topDeal:
      case ProductCardType.grid:
        pillText = strings.sellersCount(product.sellerCount);
        break;
    }

    final semanticsLabel = '$title, $priceStr, ${strings.perUnit(unit)}, ${strings.sampleBadge}';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Container(
        decoration: BoxDecoration(
          color: tokens.card,
          borderRadius: BorderRadius.circular(16.0 * s),
          border: Border.all(color: tokens.borders, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // Tapping a card opens its Product page
          onTap: onTap ??
              () {
                GoRouter.maybeOf(context)?.push('/product/${product.productCode}');
              },
          borderRadius: BorderRadius.circular(16.0 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Square Picture Panel
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  color: VanRozgarTokens.picturePanel,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        product.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.eco_outlined,
                              size: 32.0 * s,
                              color: tokens.primaryGreen.withValues(alpha: 0.6),
                            ),
                          );
                        },
                      ),
                      // Top-left: Sample Badge Pill
                      Positioned(
                        top: 8.0 * s,
                        left: 8.0 * s,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.0 * s,
                                vertical: 3.0 * s,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: Text(
                                strings.sampleBadge,
                                style: TextStyle(
                                  fontSize: 10.0 * s,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.primaryGreen,
                                ),
                              ),
                            ),
                            // A picture that still has to be checked against a real photo
                            if (product.isIllustration) ...[
                              SizedBox(height: 4.0 * s),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.0 * s,
                                  vertical: 3.0 * s,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Text(
                                  strings.illustrationTag,
                                  style: TextStyle(
                                    fontSize: 10.0 * s,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.mutedText,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Bottom-left: Not for eating flag
                      if (product.notForEating)
                        Positioned(
                          bottom: 8.0 * s,
                          left: 8.0 * s,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.0 * s,
                              vertical: 3.0 * s,
                            ),
                            decoration: BoxDecoration(
                              color: tokens.outlinedControl,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text(
                              strings.notForEating,
                              style: TextStyle(
                                fontSize: 10.0 * s,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 2. Unit & ADD / Stepper Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0 * s),
                child: SizedBox(
                  height: 40.0 * s,
                  child: Row(
                    children: [
                      // Unit text on the left
                      Expanded(
                        child: Text(
                          strings.perUnit(unit),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.0 * s,
                            color: tokens.mutedText,
                          ),
                        ),
                      ),
                      // ADD button or Stepper on the right
                      if (currentQty == 0)
                        Semantics(
                          button: true,
                          label: '${strings.addButton} $title',
                          child: InkWell(
                            onTap: () {
                              if (useQuantityPicker) {
                                showQuantityPickerSheet(context, product: product, language: language);
                                return;
                              }
                              ref.read(cartQuantitiesProvider.notifier).add(product.productCode, minOrder);
                              ref.read(lastAddedImageProvider.notifier).state = product.imageAsset;
                            },
                            borderRadius: BorderRadius.circular(10.0 * s),
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 48.0,
                                minHeight: 48.0,
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 72.0 * s,
                                height: 34.0 * s,
                                decoration: BoxDecoration(
                                  color: tokens.card,
                                  borderRadius: BorderRadius.circular(10.0 * s),
                                  border: Border.all(
                                    color: tokens.primaryGreen,
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  strings.addButton,
                                  style: TextStyle(
                                    fontSize: 14.0 * s,
                                    fontWeight: FontWeight.w800,
                                    color: tokens.primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        QuantityStepper(
                          quantity: currentQty,
                          scale: s,
                          onMinus: () {
                            decrementWithMinOrderCheck(
                              context,
                              ref,
                              productCode: product.productCode,
                              title: title,
                              minOrder: minOrder,
                              unit: unit,
                              strings: strings,
                            );
                          },
                          onPlus: () {
                            ref.read(cartQuantitiesProvider.notifier).increment(product.productCode);
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // 3. Price & Strikethrough MRP
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        priceStr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.0 * s,
                          fontWeight: FontWeight.w800,
                          color: tokens.orange,
                        ),
                      ),
                    ),
                    if (hasDiscount) ...[
                      SizedBox(width: 6.0 * s),
                      Text(
                        formatRupees(mrpPaise),
                        style: TextStyle(
                          fontSize: 11.5 * s,
                          color: tokens.mutedText,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 4. Discount Line (only when discount > 0)
              if (hasDiscount)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0 * s, vertical: 2.0 * s),
                  child: Text(
                    discountPaise < 10000
                        ? strings.offRupees(formatRupees(discountPaise))
                        : strings.offPercent(discountPercent),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5 * s,
                      fontWeight: FontWeight.w700,
                      color: tokens.primaryGreen,
                    ),
                  ),
                ),

              // 5. Localized Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0 * s, vertical: 3.0 * s),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.0 * s,
                    fontWeight: FontWeight.w600,
                    color: tokens.heading,
                    height: 1.25,
                  ),
                ),
              ),

              // 5b. Live stock bar: "62 kg sold · 38 kg left"
              if (showStockBar)
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0 * s, 4.0 * s, 10.0 * s, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3.0 * s),
                        child: Stack(
                          children: [
                            Container(height: 6.0 * s, color: tokens.borders),
                            FractionallySizedBox(
                              widthFactor: _soldFraction(listing, product),
                              child: Container(height: 6.0 * s, color: tokens.primaryGreen),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.0 * s),
                      Text(
                        strings.soldLeftBar(
                          listing?.quantitySold ?? product.totalSold,
                          listing?.quantityAvailable ?? product.totalAvailable,
                          unit,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.5 * s, color: tokens.mutedText),
                      ),
                    ],
                  ),
                ),

              // 6. Last Row Pill
              Padding(
                padding: EdgeInsets.only(left: 10.0 * s, right: 10.0 * s, bottom: 10.0 * s, top: 4.0 * s),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0 * s,
                    vertical: 3.0 * s,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.chipBg,
                    borderRadius: BorderRadius.circular(8.0 * s),
                  ),
                  child: Text(
                    pillText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.0 * s,
                      fontWeight: FontWeight.w500,
                      color: tokens.chipText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
