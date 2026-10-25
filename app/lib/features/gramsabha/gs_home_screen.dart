import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/notice_strip.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/request_card.dart';
import '../../shared/widgets/async_value_view.dart';
import '../../shared/widgets/landscape_banner.dart';
import '../../shared/widgets/user_hero_card.dart';
import '../../shared/widgets/action_card.dart';
import '../../shared/widgets/reject_reason_sheet.dart';
import '../../shared/widgets/breadcrumb.dart';
import '../../shared/widgets/preference_card.dart';
import '../auth/auth_providers.dart';
import '../listings/listing_providers.dart';
import '../trade/trade_providers.dart';

class GsHomeScreen extends ConsumerStatefulWidget {
  const GsHomeScreen({super.key});

  @override
  ConsumerState<GsHomeScreen> createState() => _GsHomeScreenState();
}

class _GsHomeScreenState extends ConsumerState<GsHomeScreen> {
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    ref.invalidate(myListingsProvider);
    ref.invalidate(requestsProvider('incoming'));
    ref.invalidate(ordersProvider('selling'));
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isSyncing = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: VrText('✓ ${l10n?.syncStatus ?? "Data Synchronized"}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<String> _getNotices(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'mr') {
      return const [
        'तेंदू व महुआ हंगाम: ग्रामसभेची वनोपज उत्पादने तातडीने नोंदवा.',
        'सामूहिक वनहक्क (CFR) कलम ३(१)(क) अंतर्गत वनोपज मालकी व थेट विक्री अधिकार सुरक्षित.',
        '५० एककापेक्षा जास्त खरेदीसाठी संवर्धन कारण बंधनकारक आहे.',
        'पायलट चाचणी: नाशिक जिल्ह्यातील १६ ग्रामसभा थेट बाजारपेठेशी जोडल्या आहेत.',
      ];
    } else if (lang == 'hi') {
      return const [
        'तेंदू और महुआ सीजन: ग्रामसभा के वनोत्पाद तुरंत पंजीकृत करें।',
        'सामुदायिक वन अधिकार (CFR) धारा 3(1)(ग) के तहत वनोपज स्वामित्व एवं सीधी बिक्री सुरक्षित।',
        '50 इकाइयों से अधिक खरीद के लिए संवर्धन कारण अनिवार्य है।',
        'पायलट प्रोजेक्ट: नासिक जिले की 16 ग्रामसभाएं सीधे बाजार से जुड़ी हैं।',
      ];
    } else {
      return const [
        'Tendu & Mahua season: Register Gram Sabha forest produce promptly.',
        'Community Forest Rights (CFR) Sec 3(1)(c) secures forest produce ownership and direct sales.',
        'Orders of 50 units or more require sustainable purpose reason.',
        'Pilot test: 16 Gram Sabhas in Nashik connected directly to marketplace.',
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;

    final myListingsAsync = ref.watch(myListingsProvider);
    final requestsAsync = ref.watch(requestsProvider('incoming'));
    final ordersAsync = ref.watch(ordersProvider('selling'));

    final listingsCount = myListingsAsync.asData?.value.length ?? 0;
    final requestsCount = requestsAsync.asData?.value.where((r) => r.status == 'pending').length ?? 0;
    final ordersCount = ordersAsync.asData?.value.where((o) => o.orderStatus != 'closed' && o.orderStatus != 'cancelled').length ?? 0;

    final displayName = user?.name ?? (l10n?.gramSabhaRole ?? 'Gram Sabha');
    final locationName = '${user?.village ?? "harsul"}_${user?.taluka ?? "trimbak"}_${user?.district ?? "nashik"}';
    final isPendingVerification = user?.status == 'pending';

    return Container(
      color: isDark ? const Color(0xFF091D12) : const Color(0xFF103622),
      child: RefreshIndicator(
        onRefresh: _handleSync,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Breadcrumb(segments: ['डॅशबोर्ड • Dashboard']),
              // Top Section: Landscape Banner + User Hero Card
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
                        name: displayName,
                        role: l10n?.gramSabhaRole ?? 'GRAM SABHA',
                        location: locationName,
                        isSyncing: _isSyncing,
                        onSync: _handleSync,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Curved Lower Container (Authentic Clean VanMitra Surface)
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

                    // Notice Card
                    NoticeStrip(notices: _getNotices(context)),

                    // Pending Verification Banner if not verified
                    if (isPendingVerification) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFD54F)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: VrText(
                                l10n?.pendingBadge ?? 'पडताळणी प्रलंबित — उत्पादने विना-प्रमाणित टॅगसह दिसतील (Verification pending)',
                                style: const TextStyle(
                                  color: Color(0xFFE65100),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),

                    // Section: 4 Summary Stat Cards Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                      child: Row(
                        children: [
                          VrText(
                            l10n?.forestProduceAndTrade ?? 'Forest Produce & Trade',
                            style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => context.push('/gs/listings'),
                            child: VrText(
                              l10n?.viewAll ?? 'View All',
                              style: TextStyle(
                                color: tokens.brandSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2x2 Stat Cards Grid (childAspectRatio 1.15 prevents overflow)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                        children: [
                          StatCard(
                            icon: Icons.inventory_2_outlined,
                            value: '$listingsCount',
                            label: l10n?.activeListingsStat ?? 'Active Listings',
                            iconColor: tokens.brandSecondary,
                            onTap: () => context.push('/gs/listings'),
                          ),
                          StatCard(
                            icon: Icons.inbox_outlined,
                            value: '$requestsCount',
                            label: l10n?.newRequestsStat ?? 'New Requests',
                            iconColor: tokens.actionPrimary,
                            onTap: () => context.push('/gs/requests'),
                          ),
                          StatCard(
                            icon: Icons.local_shipping_outlined,
                            value: '$ordersCount',
                            label: l10n?.ordersStat ?? 'Orders',
                            iconColor: const Color(0xFF2F5FB3),
                            onTap: () => context.push('/gs/orders'),
                          ),
                          StatCard(
                            icon: Icons.currency_rupee,
                            value: '₹ —',
                            label: l10n?.totalEarningsStat ?? 'Total Earnings',
                            iconColor: tokens.success,
                            onTap: () => context.push('/gs/orders'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),
                    PreferenceCard(
                      icon: Icons.forest_outlined,
                      title: l10n?.forestProduceAndTrade ?? 'वनोपज व व्यापार • Forest Produce & Trade',
                      subtitle: '$listingsCount ${l10n?.myListingsCardSub ?? "नोंदणीकृत उत्पादने • View all listings"}',
                      onTap: () => context.push('/gs/listings'),
                    ),

                    // Primary CTA: Add Listing Button (Solid Clean Orange Pill)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: tokens.actionPrimary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.actionPrimary.withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => context.push('/gs/listings/new'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: VrText(
                                    l10n?.addNewListing ?? '+ Add New Listing',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Section: Quick Operations & Records
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: VrText(
                          l10n?.gsManagementTitle ?? 'Gram Sabha Produce Management',
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    VrActionCard(
                      icon: Icons.inventory_outlined,
                      iconColor: tokens.brandSecondary,
                      title: l10n?.myListingsCardTitle ?? 'My Forest Listings',
                      subtitle: '$listingsCount ${l10n?.myListingsCardSub ?? "registered products"}',
                      badgeText: '$listingsCount ${l10n?.activeBadge ?? "Active"}',
                      badgeColor: tokens.brandSecondary,
                      onTap: () => context.push('/gs/listings'),
                    ),
                    VrActionCard(
                      icon: Icons.swap_horiz_outlined,
                      iconColor: tokens.actionPrimary,
                      title: l10n?.requestsCardTitle ?? 'Buyer Requests & Inquiries',
                      subtitle: '$requestsCount ${l10n?.requestsCardSub ?? "pending requests"}',
                      badgeText: requestsCount > 0 ? '$requestsCount ${l10n?.pendingBadge ?? "Pending"}' : null,
                      badgeColor: tokens.actionPrimary,
                      onTap: () => context.push('/gs/requests'),
                    ),
                    VrActionCard(
                      icon: Icons.local_shipping_outlined,
                      iconColor: const Color(0xFF2F5FB3),
                      title: l10n?.ordersCardTitle ?? 'Direct Buyer Orders',
                      subtitle: '$ordersCount ${l10n?.ordersCardSub ?? "orders in fulfillment"}',
                      badgeText: ordersCount > 0 ? '$ordersCount ${l10n?.inProgressBadge ?? "In Progress"}' : null,
                      badgeColor: const Color(0xFF2F5FB3),
                      onTap: () => context.push('/gs/orders'),
                    ),
                    VrActionCard(
                      icon: Icons.help_outline,
                      iconColor: const Color(0xFF2E7D32),
                      title: l10n?.helpCardTitle ?? 'Help & FRA 2006 Rules',
                      subtitle: l10n?.helpCardSub ?? 'Forest Rights Act guidelines & helpline',
                      onTap: () => context.push('/gs/profile'),
                    ),

                    // Section: Recent Incoming Requests
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: VrText(
                              l10n?.requestsCardTitle ?? 'Buyer Requests',
                              style: TextStyle(
                                color: tokens.textPrimary,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
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
                            onPressed: () => context.push('/gs/requests'),
                            child: VrText(
                              l10n?.viewAll ?? 'View All',
                              style: TextStyle(
                                color: tokens.brandSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AsyncValueView(
                      value: requestsAsync,
                      emptyMessage: l10n?.requestsCardSub ?? 'No requests yet',
                      data: (reqs) {
                        final pending = reqs.where((r) => r.status == 'pending').take(3).toList();
                        if (pending.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: VrText(
                                l10n?.requestsCardSub ?? 'No pending requests',
                                style: TextStyle(color: tokens.textMuted),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: pending.map((r) => RequestCard(
                            request: r,
                            isSeller: true,
                            onApprove: () async {
                              final api = ref.read(apiClientProvider);
                              await api.patch('/requests/${r.id}/status', data: {'action': 'approve'});
                              ref.invalidate(requestsProvider('incoming'));
                              ref.invalidate(ordersProvider('selling'));
                            },
                            onReject: () {
                              showRejectReasonSheet(
                                context: context,
                                ref: ref,
                                requestId: r.id,
                              );
                            },
                          )).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 120), // Generous space so floating nav never cuts content
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
