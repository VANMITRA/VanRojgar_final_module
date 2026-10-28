import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_input_hints.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/landscape_banner.dart';
import '../../shared/widgets/user_hero_card.dart';
import '../../shared/widgets/search_pill.dart';
import '../../shared/widgets/notice_strip.dart';
import '../../shared/widgets/listing_card.dart';
import '../../shared/widgets/async_value_view.dart';
import '../../shared/widgets/my_requests_summary.dart';
import '../../shared/widgets/breadcrumb.dart';
import '../listings/listing_providers.dart';
import '../search/search_providers.dart';
import '../auth/auth_providers.dart';

class VillagerHomeScreen extends ConsumerWidget {
  const VillagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.vr;
    final user = ref.watch(authControllerProvider).asData?.value;
    final categoriesAsync = ref.watch(categoriesProvider);
    final nearbyAsync = ref.watch(searchProvider(stableSearchParams({if (user?.taluka != null && user!.taluka!.isNotEmpty) 'taluka': user.taluka!})));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF091D12) : const Color(0xFF0C2C1C),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoriesProvider);
            ref.invalidate(searchProvider);
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Breadcrumb(segments: ['मुख्यपृष्ठ • Home']),
                SizedBox(
                  height: 185,
                  child: Stack(
                    children: [
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 125,
                        child: LandscapeBanner(height: 125),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: UserHeroCard(
                          name: user?.name ?? 'ग्रामस्थ बंधू-भगिनी',
                          role: 'स्थानिक ग्रामस्थ',
                          location: '${user?.village ?? "नाशिक"}, ${user?.taluka ?? "महाराष्ट्र"}',
                          onSync: () {
                            ref.invalidate(categoriesProvider);
                            ref.invalidate(searchProvider);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F2218) : const Color(0xFFF4F7F5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        const SizedBox(height: 14),
                        const NoticeStrip(notices: [
                          'वनमित्र: आपल्या गावातील वनसंपत्तीचा थेट व्यापार.',
                          'वाहन आहे? डिलिव्हरी पार्टनर बना आणि नियमित रोजगार मिळवा.',
                        ]),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: SearchPill(
                            hintText: AppInputHints.searchForest(context),
                            readOnly: true,
                            onTap: () => context.go('/v/search'),
                          ),

                        ),
                        const MyRequestsSummary(portalPrefix: 'v'),
                // Livelihood Delivery Partner Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: tokens.actionPrimary.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.actionPrimary.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tokens.actionPrimary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.two_wheeler, color: tokens.actionPrimary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.isDeliveryApplicant == true ? 'डिलिव्हरी पार्टनर पोर्टल' : 'वाहन आहे? रोजगाराची संधी!',
                              style: TextStyle(color: tokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.isDeliveryApplicant == true ? 'उपलब्ध कामे पहा किंवा स्थिती तपासा' : 'वनोपज पोहोचवून ₹ प्रति किमी दराने कमवा.',
                              style: TextStyle(color: tokens.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => context.push('/delivery/jobs'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tokens.actionPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('कामे (Jobs)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () => context.push('/delivery/apply'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('अर्जाची स्थिती', style: TextStyle(color: tokens.brandSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Barter Quick Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: tokens.outline),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz, color: tokens.brandSecondary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'पारंपरिक वस्तूविनिमय (Barter Offers)',
                            style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/barter/offers'),
                          child: const Text('ऑफर्स पहा • View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Categories Quick Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    'वनोपज श्रेणी (Categories)',
                    style: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: categoriesAsync.when(
                    data: (cats) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: cats.length,
                      itemBuilder: (ctx, i) {
                        final cat = cats[i];
                        return GestureDetector(
                          onTap: () => context.go('/v/search'),
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tokens.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: tokens.outline),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.forest, color: tokens.brandSecondary, size: 24),
                                const SizedBox(height: 6),
                                Text(
                                  cat.localizedName(Localizations.localeOf(context).languageCode),
                                  style: TextStyle(color: tokens.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
                // Nearby Listings
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'जवळची उत्पादने (Available Near You)',
                    style: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                AsyncValueView<SearchResults>(
                  value: nearbyAsync,
                  emptyMessage: 'सध्या जवळची उत्पादने उपलब्ध नाहीत',
                  data: (results) {
                    if (results.listings.isEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('कोणतीही उत्पादने सापडली नाहीत.')));
                    }
                    return Column(
                      children: results.listings.map((item) => ListingCard(
                        listing: item,
                        onTap: () => context.push('/listings/${item.id}'),
                      )).toList(),
                    );
                  },
                ),
                const SizedBox(height: 120),
                    ],
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
