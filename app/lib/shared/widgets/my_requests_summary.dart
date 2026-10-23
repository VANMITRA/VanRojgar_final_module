import 'package:flutter/material.dart';
import '../utils/product_image.dart';
import 'vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import '../../features/trade/trade_providers.dart';
import '../models/trade_request.dart';
import 'status_count_chips.dart';
import 'empty_state.dart';

class MyRequestsSummary extends ConsumerWidget {
  final String portalPrefix; // 'v' or 'b'

  const MyRequestsSummary({
    super.key,
    required this.portalPrefix,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.vr;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final requestsAsync = ref.watch(requestsProvider('mine'));

    return requestsAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (requests) {
        if (requests.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162E20) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2EBE5),
              ),
            ),
            child: EmptyState(
              icon: Icons.inbox_outlined,
              title: locale == 'mr' ? 'अजून कोणतीही मागणी नाही' : 'No requests yet',
              helper: locale == 'mr'
                  ? 'आपण केलेल्या खरेदी मागण्या येथे दिसतील'
                  : 'Produce requests you make will appear here with live status',
            ),
          );
        }

        final pendingCount = requests.where((r) => r.status == 'pending').length;
        final approvedCount = requests.where((r) => r.status == 'approved').length;
        final rejectedCount = requests.where((r) => r.status == 'rejected' || r.status == 'cancelled').length;
        final counteredCount = requests.where((r) => r.status == 'countered').length;

        final recent = requests.take(3).toList();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162E20) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2EBE5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 4),
                child: Row(
                  children: [
                    VrText(
                      locale == 'mr' ? 'माझ्या मागण्यांची सद्यस्थिती' : 'My Requests Status',
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.go('/$portalPrefix/requests'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VrText(
                            locale == 'mr' ? 'सर्व पहा' : 'View all',
                            style: TextStyle(
                              color: tokens.brandSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_forward_ios, size: 11, color: tokens.brandSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Chips
              StatusCountChips(
                totalCount: requests.length,
                pendingCount: pendingCount,
                approvedCount: approvedCount,
                rejectedCount: rejectedCount,
                counteredCount: counteredCount > 0 ? counteredCount : null,
                onSelect: (_) => context.go('/$portalPrefix/requests'),
              ),

              const Divider(height: 16, thickness: 1),

              // 3 newest requests as compact rows
              ...recent.map((req) => _buildCompactRow(context, req, tokens, locale, isDark)),

              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactRow(
    BuildContext context,
    TradeRequestModel req,
    VrTokens tokens,
    String locale,
    bool isDark,
  ) {
    final title = req.listing?.localizedTitle(locale) ??
        (locale == 'en' ? 'Forest Produce' : 'वन उत्पाद');

    final village = req.listing?.village ?? req.dropVillage ?? '';

    // Status pill
    Color pillColor;
    IconData pillIcon;
    String pillText;

    switch (req.status) {
      case 'approved':
        pillColor = tokens.success;
        pillIcon = Icons.check_circle;
        pillText = locale == 'mr' ? 'मंजूर' : 'Approved';
        break;
      case 'rejected':
      case 'cancelled':
        pillColor = tokens.error;
        pillIcon = Icons.cancel;
        pillText = locale == 'mr' ? 'नाकारले' : 'Rejected';
        break;
      case 'countered':
        pillColor = const Color(0xFF2F5FB3);
        pillIcon = Icons.swap_horiz;
        pillText = locale == 'mr' ? 'प्रति-ऑफर' : 'Counter';
        break;
      default:
        pillColor = tokens.warning;
        pillIcon = Icons.schedule;
        pillText = locale == 'mr' ? 'प्रलंबित' : 'Pending';
    }

    return InkWell(
      onTap: () => context.go('/$portalPrefix/requests'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tokens.brandSecondary.withValues(alpha: 0.1),
                  border: Border.all(color: tokens.outline.withValues(alpha: 0.5)),
                ),
                child: ProductImage(
                  req.listing?.displayImageUrl ?? 'assets/products/forest.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.forest, color: tokens.brandSecondary, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VrText(
                    title,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  VrText(
                    '${req.quantity} ${req.unit}${village.isNotEmpty ? ' • $village' : ''}',
                    style: TextStyle(
                      color: tokens.textMuted,
                      fontSize: 11.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: pillColor.withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: pillColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(pillIcon, size: 12, color: pillColor),
                  const SizedBox(width: 4),
                  VrText(
                    pillText,
                    style: TextStyle(
                      color: pillColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
