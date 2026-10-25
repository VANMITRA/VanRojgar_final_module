import 'package:flutter/material.dart';
import '../../shared/utils/product_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format_inr.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/async_value_view.dart';
import '../listings/listing_providers.dart';
import '../auth/auth_providers.dart';
import '../trade/request_sheet.dart';
import '../../shared/utils/livelihood_link.dart';
import '../../shared/widgets/item_code_chip.dart';

class ListingDetailScreen extends ConsumerWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.vr;
    final listingAsync = ref.watch(listingDetailProvider(listingId));
    final currentUser = ref.watch(authControllerProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('उत्पादन तपशील • Details')),
      body: SafeArea(
        child: AsyncValueView(
          value: listingAsync,
          emptyMessage: 'Listing not found',
          data: (listing) {
            final isOwner = currentUser?.id == listing.ownerId;
            final reportRoute = livelihoodRouteFor(currentUser?.role,
                village: listing.village, taluka: listing.taluka, product: listing.productCode);
            final canBarter = (listing.mode == 'barter' || listing.mode == 'both') && currentUser?.role != 'buyer';

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image / Icon Hero Box
                        // Product Photography Hero Box
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            height: 210,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: tokens.surface,
                              border: Border.all(color: tokens.outline),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ProductImage(
                                  listing.displayImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: tokens.brandPrimary.withValues(alpha: 0.08),
                                    child: Center(child: Icon(Icons.forest, size: 64, color: tokens.brandSecondary)),
                                  ),
                                ),
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.65),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.60),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified, color: Color(0xFF66BB6A), size: 14),
                                        SizedBox(width: 5),
                                        Text(
                                          'CFR Nashik Authenticated Harvest',
                                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final locale = Localizations.localeOf(context).languageCode;
                                      final primary = listing.localizedTitle(locale);
                                      final secondary = listing.localizedSubtitle(locale);
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            primary,
                                            style: TextStyle(
                                              color: tokens.textPrimary,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          if (secondary.isNotEmpty && secondary != primary) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              secondary,
                                              style: TextStyle(color: tokens.textMuted, fontSize: 14),
                                            ),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            ModeBadge(mode: listing.mode),
                          ],
                        ),
                        if (listing.itemCode != null && listing.itemCode!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Align(alignment: Alignment.centerLeft, child: ItemCodeChip(code: listing.itemCode!)),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: tokens.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: tokens.outline),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatInr(listing.pricePerUnitPaise, unit: listing.unit),
                                    style: TextStyle(
                                      color: tokens.actionPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'दर (Rate)',
                                    style: TextStyle(color: tokens.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${listing.quantityAvailable} ${listing.unit}',
                                    style: TextStyle(
                                      color: tokens.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'शिल्लक साठा (In Stock)',
                                    style: TextStyle(color: tokens.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (listing.description != null && listing.description!.isNotEmpty) ...[
                          Text(
                            'तपशील (Description)',
                            style: TextStyle(color: tokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            listing.description!,
                            style: TextStyle(color: tokens.textPrimary, fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Trust & Source Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: tokens.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: tokens.brandSecondary.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.verified, color: tokens.brandSecondary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'उत्पादक आणि विश्वासार्हता (Provenance)',
                                    style: TextStyle(color: tokens.brandSecondary, fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: tokens.brandPrimary,
                                  child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
                                ),
                                title: Text(
                                  'ग्रामसभा ${listing.village}',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(
                                  '${listing.taluka}, जिल्हा नाशिक${listing.distanceKm != null ? " • ${listing.distanceKm!.toStringAsFixed(1)} km" : ""}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push('/gramsabhas/${listing.gramSabhaId}'),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.eco, size: 16, color: tokens.brandSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'शाश्वत वन संकलन प्रमाणित (Sustainable Harvest Confirmed)',
                                      style: TextStyle(color: tokens.textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (reportRoute != null) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.agriculture_outlined, size: 18),
                            onPressed: () => context.go(reportRoute),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            label: const Text(
                              'या परिसरात काय पिकवता येईल • See what land near here can produce',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Sticky Action Bar
                if (isOwner) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      border: Border(top: BorderSide(color: tokens.outline)),
                    ),
                    child: Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => context.push('/gs/listings/${listing.id}/edit'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          label: const Text('संपादित करा • Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(listing.status == 'active' ? Icons.pause_circle_outline : Icons.play_circle_outline),
                            onPressed: () async {
                              try {
                                final newStatus = listing.status == 'active' ? 'paused' : 'active';
                                await ref.read(apiClientProvider).patch('/listings/${listing.id}/status', data: {'status': newStatus});
                                ref.invalidate(listingDetailProvider(listingId));
                                ref.invalidate(myListingsProvider);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(newStatus == 'paused' ? 'उत्पादन तात्पुरते थांबवले (Listing paused)' : 'उत्पादन सुरू केले (Listing activated)')),
                                );
                              } catch (_) {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: listing.status == 'active' ? tokens.warning : tokens.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            label: Text(
                              listing.status == 'active' ? 'थांबवा (Pause)' : 'सुरू करा (Activate)',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      border: Border(top: BorderSide(color: tokens.outline)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (canBarter) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.push('/barter/new/${listing.id}'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: tokens.actionPrimary, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: Text(
                                'वस्तुविनिमय (Barter)',
                                style: TextStyle(color: tokens.actionPrimary, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (_) => RequestSheet(listing: listing),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tokens.actionPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 2,
                            ),
                            child: const Text(
                              'खरेदी विनंती (Request to Buy)',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
