import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/catalog_models.dart';
import '../product_card.dart';

/// Live preview card on the new/edit listing form that reuses [ProductCard] so the seller sees
/// how their listing looks in the shop. Wrapped in [IgnorePointer] so tapping the preview does not
/// navigate away from the form or change the buyer cart.
class SellPreviewCard extends StatelessWidget {
  final ShopProduct product;
  final String sellerRole;
  final String sellerName;
  final int quantityTotal;
  final int quantitySold;
  final int mrpPaise;
  final int pricePaise;
  final int minOrderQuantity;
  final String fulfilment;
  final double scale;

  const SellPreviewCard({
    super.key,
    required this.product,
    required this.sellerRole,
    required this.sellerName,
    required this.quantityTotal,
    this.quantitySold = 0,
    required this.mrpPaise,
    required this.pricePaise,
    required this.minOrderQuantity,
    required this.fulfilment,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final safePrice = pricePaise > 0 ? pricePaise : (product.startingAtPaise > 0 ? product.startingAtPaise : 5000);
    final safeMrp = mrpPaise >= safePrice ? mrpPaise : safePrice;
    final safeTotal = math.max(1, quantityTotal);
    final safeSold = quantitySold.clamp(0, safeTotal);
    final safeMinOrder = minOrderQuantity.clamp(1, safeTotal);

    final previewListing = ShopListing(
      id: 'preview-listing',
      sellerId: 'preview-seller',
      sellerName: sellerName,
      sellerType: sellerRole == 'gramsabha' ? 'gramsabha' : 'cfrholder',
      fulfilment: fulfilment,
      pricePerUnitPaise: safePrice,
      mrpPerUnitPaise: safeMrp,
      quantityTotal: safeTotal,
      quantitySold: safeSold,
      minOrderQuantity: safeMinOrder,
      daysAgo: 0,
      isSample: true,
    );

    final previewProduct = ShopProduct(
      productCode: product.productCode,
      categorySlug: product.categorySlug,
      imageAsset: product.imageAsset,
      title: product.title,
      unit: product.unit,
      notForEating: product.notForEating,
      listings: <ShopListing>[previewListing],
      isIllustration: product.isIllustration,
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 220.0 * scale),
        child: IgnorePointer(
          child: ProductCard(
            key: const Key('sell_live_preview_card'),
            product: previewProduct,
            listing: previewListing,
            cardType: ProductCardType.newArrival,
            showStockBar: true,
            onTap: () {},
          ),
        ),
      ),
    );
  }
}

