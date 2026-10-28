import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/sell_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../models/catalog_models.dart';
import '../../models/sell_models.dart';
import '../../theme/van_rozgar_tokens.dart';

/// Card displaying one of the seller's own listings on `/sell`, with status chip,
/// Sample badge, stock/sold counts, minimum order, fulfilment mode, and Edit / Pause-Resume / Remove actions.
class MyListingCard extends StatelessWidget {
  final MyListing listing;
  final ShopProduct? product;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double scale;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onRemove;

  const MyListingCard({
    super.key,
    required this.listing,
    required this.product,
    required this.language,
    required this.tokens,
    required this.scale,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final strings = AppStrings.of(language);
    final title = product?.localizedTitle(language) ?? listing.productCode;
    final unit = product?.localizedUnit(language) ?? '';
    final imageAsset = product?.imageAsset ?? 'assets/catalog/${listing.productCode}.jpg';
    final hasDiscount = listing.mrpPaise > listing.pricePaise;

    final fulfilmentText = switch (listing.fulfilment) {
      'pickup' => strings.fulfilPickup,
      'delivery' => strings.fulfilDelivery,
      _ => '${strings.fulfilPickup} · ${strings.fulfilDelivery}',
    };

    return Container(
      key: Key('my_listing_card_${listing.id}'),
      padding: EdgeInsets.all(14.0 * s),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(16.0 * s),
        border: Border.all(color: tokens.borders, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Catalog picture
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0 * s),
                child: Container(
                  width: 72.0 * s,
                  height: 72.0 * s,
                  color: VanRozgarTokens.picturePanel,
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.eco_outlined,
                      size: 32.0 * s,
                      color: tokens.primaryGreen.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.0 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status chip + Sample badge
                    Wrap(
                      spacing: 6.0 * s,
                      runSpacing: 4.0 * s,
                      children: [
                        Container(
                          key: Key('listing_status_${listing.id}'),
                          padding: EdgeInsets.symmetric(horizontal: 8.0 * s, vertical: 3.0 * s),
                          decoration: BoxDecoration(
                            color: listing.isActive ? tokens.primaryGreen : tokens.chipBg,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Text(
                            listing.isActive ? strings.slStatusActive : strings.slStatusPaused,
                            style: TextStyle(
                              fontSize: 10.5 * s,
                              fontWeight: FontWeight.w700,
                              color: listing.isActive ? tokens.onPrimaryGreen : tokens.chipText,
                            ),
                          ),
                        ),
                        if (listing.isSample)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0 * s, vertical: 3.0 * s),
                            decoration: BoxDecoration(
                              color: tokens.chipBg,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text(
                              strings.sampleBadge,
                              style: TextStyle(
                                fontSize: 10.5 * s,
                                fontWeight: FontWeight.w700,
                                color: tokens.chipText,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.0 * s),
                    // Product title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.0 * s),
                    // Price in orange + crossed-out MRP + per unit
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 6.0 * s,
                      runSpacing: 2.0 * s,
                      children: [
                        Text(
                          formatRupees(listing.pricePaise),
                          style: TextStyle(
                            fontSize: 17.0 * s,
                            fontWeight: FontWeight.w800,
                            color: tokens.orange,
                          ),
                        ),
                        if (hasDiscount)
                          Text(
                            formatRupees(listing.mrpPaise),
                            style: TextStyle(
                              fontSize: 12.0 * s,
                              color: tokens.mutedText,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (unit.isNotEmpty)
                          Text(
                            strings.perUnit(unit),
                            style: TextStyle(
                              fontSize: 12.0 * s,
                              color: tokens.mutedText,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.0 * s),
                    // N left · N sold
                    Wrap(
                      spacing: 8.0 * s,
                      runSpacing: 2.0 * s,
                      children: [
                        Text(
                          strings.qtyLeft(listing.quantityAvailable, unit),
                          style: TextStyle(
                            fontSize: 12.0 * s,
                            fontWeight: FontWeight.w600,
                            color: tokens.bodyText,
                          ),
                        ),
                        Text(
                          strings.soldQty(listing.quantitySold, unit),
                          style: TextStyle(
                            fontSize: 12.0 * s,
                            color: tokens.mutedText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.0 * s),
                    // Minimum order
                    Text(
                      strings.minOrderText(listing.minOrderQuantity, unit),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                    ),
                    SizedBox(height: 2.0 * s),
                    // Hand-over mode
                    Text(
                      fulfilmentText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0 * s),
          Divider(height: 1.0, color: tokens.borders),
          SizedBox(height: 8.0 * s),
          // Action buttons: Edit, Pause/Resume, Remove (at least 48dp tall, FittedBox prevents overflow)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: Key('edit_listing_${listing.id}'),
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.primaryGreen,
                    side: BorderSide(color: tokens.primaryGreen, width: 1.2),
                    minimumSize: const Size(48.0, 48.0),
                    padding: EdgeInsets.symmetric(horizontal: 8.0 * s),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0 * s)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      strings.slEditAction,
                      maxLines: 1,
                      style: TextStyle(fontSize: 13.0 * s, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.0 * s),
              Expanded(
                child: OutlinedButton(
                  key: Key('toggle_listing_${listing.id}'),
                  onPressed: onToggleStatus,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.heading,
                    side: BorderSide(color: tokens.borders, width: 1.2),
                    minimumSize: const Size(48.0, 48.0),
                    padding: EdgeInsets.symmetric(horizontal: 8.0 * s),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0 * s)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      listing.isActive ? strings.slPauseAction : strings.slResumeAction,
                      maxLines: 1,
                      style: TextStyle(fontSize: 13.0 * s, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.0 * s),
              Expanded(
                child: OutlinedButton(
                  key: Key('remove_listing_${listing.id}'),
                  onPressed: onRemove,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.outlinedControl,
                    side: BorderSide(color: tokens.borders, width: 1.2),
                    minimumSize: const Size(48.0, 48.0),
                    padding: EdgeInsets.symmetric(horizontal: 8.0 * s),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0 * s)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      strings.slRemoveAction,
                      maxLines: 1,
                      style: TextStyle(fontSize: 13.0 * s, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

