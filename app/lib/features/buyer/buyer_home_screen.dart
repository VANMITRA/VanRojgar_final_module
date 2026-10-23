import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
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
import '../search/search_providers.dart';
import '../auth/auth_providers.dart';

class BuyerHomeScreen extends ConsumerWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.vr;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider).asData?.value;
    final bulkAsync = ref.watch(searchProvider({'minQty': 50}));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF091D12) : const Color(0xFF0C2C1C),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(searchProvider),
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
                          name: user?.name ?? 'Procurement Partner',
                          role: 'प्रमाणित खरेदीदार (Buyer)',
                          location: '${user?.businessName ?? "Direct Buyer"}, ${user?.city ?? "Nashik Hub"}',
                          onSync: () => ref.invalidate(searchProvider),
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
                          'थेट ग्रामसभेकडून शुद्ध आयुर्वेदिक व नैसर्गिक वनोपज खरेदी करा.',
                          'सर्व उत्पादने सामूहिक वनहक्क (CFR) ग्रामसभेद्वारे अधिकृत व तपासलेली आहेत.',
                        ]),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: SearchPill(
                            hintText: AppInputHints.buyerSearch(context),
                            readOnly: true,
                            onTap: () => context.go('/b/search'),
                          ),

                        ),
                        const MyRequestsSummary(portalPrefix: 'b'),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: VrText(
                                  'मोठा साठा व घाऊक खरेदी (Bulk Produce)',
                                  style: TextStyle(
                                    color: tokens.textPrimary,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => context.go('/b/search'),
                                child: VrText('All Listings', style: TextStyle(color: tokens.brandSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                        AsyncValueView<SearchResults>(
                          value: bulkAsync,
                          emptyMessage: 'No bulk listings available currently',
                          data: (results) {
                            if (results.listings.isEmpty) {
                              return const Center(child: Padding(padding: EdgeInsets.all(16), child: VrText('मोठ्या प्रमाणातील उत्पादने उपलब्ध नाहीत • No bulk listings available.')));
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
