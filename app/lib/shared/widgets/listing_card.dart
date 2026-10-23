import 'package:flutter/material.dart';
import '../utils/product_image.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format_inr.dart';
import '../models/listing.dart';
import 'badges.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    final locale = Localizations.localeOf(context).languageCode;
    final primaryTitle = listing.localizedTitle(locale);
    final secondaryTitle = listing.localizedSubtitle(locale);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Produce Image Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: tokens.brandSecondary.withValues(alpha: 0.1),
                          border: Border.all(color: tokens.outline.withValues(alpha: 0.5)),
                        ),
                        child: ProductImage(
                          listing.displayImageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: tokens.brandSecondary),
                              ),
                            );
                          },
                          errorBuilder: (context, _, __) => Center(
                            child: Icon(Icons.forest, color: tokens.brandSecondary, size: 28),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            primaryTitle,
                            style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (secondaryTitle.isNotEmpty && secondaryTitle != primaryTitle) ...[
                            const SizedBox(height: 1),
                            Text(
                              secondaryTitle,
                              style: TextStyle(
                                color: tokens.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: tokens.textMuted),
                              const SizedBox(width: 2),
                              Text(
                                '${listing.village}, ${listing.taluka}',
                                style: TextStyle(color: tokens.textMuted, fontSize: 12),
                              ),
                              if (listing.distanceKm != null) ...[
                                Text(' • ', style: TextStyle(color: tokens.textMuted, fontSize: 12)),
                                Text(
                                  '${listing.distanceKm!.toStringAsFixed(1)} km',
                                  style: TextStyle(color: tokens.brandSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatInr(listing.pricePerUnitPaise, unit: listing.unit),
                          style: TextStyle(
                            color: tokens.actionPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${listing.quantityAvailable} ${listing.unit} उपलब्ध (Available)',
                          style: TextStyle(color: tokens.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ModeBadge(mode: listing.mode),
                        const SizedBox(width: 6),
                        if (listing.gramSabha != null)
                          TrustTag(status: listing.gramSabha!.verificationStatus),
                      ],
                    ),
                  ],
                ),
                if (listing.rightsNotOnRecord) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.chipWarningBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 12, color: tokens.warning),
                        const SizedBox(width: 4),
                        Text(
                          'Rights not on record (तपासणी प्रलंबित)',
                          style: TextStyle(color: tokens.warning, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
