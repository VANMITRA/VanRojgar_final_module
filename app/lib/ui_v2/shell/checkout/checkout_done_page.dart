import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/villages.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/checkout_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../models/catalog_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/checkout_providers.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../../widgets/app_background.dart';

/// Success page `/checkout/done` shown after submitting requests from `/checkout`.
class CheckoutDonePage extends ConsumerWidget {
  const CheckoutDonePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final lastSent = ref.watch(lastSentRequestsProvider);
    final allRequests = ref.watch(requestsProvider);
    final requests = lastSent.isNotEmpty ? lastSent : allRequests;

    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    if (requests.isEmpty) {
      return Scaffold(
        body: AppBackground(
          categorySlug: 'forest-produce',
          useSafeArea: true,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0 * s),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: EdgeInsets.all(24.0 * s),
                decoration: BoxDecoration(
                  color: tokens.card,
                  borderRadius: BorderRadius.circular(16.0 * s),
                  border: Border.all(color: tokens.borders),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 40.0 * s,
                      color: tokens.primaryGreen.withValues(alpha: 0.7),
                    ),
                    SizedBox(height: 12.0 * s),
                    Text(
                      strings.coNoRecentRequests,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15.0 * s, color: tokens.bodyText),
                    ),
                    SizedBox(height: 16.0 * s),
                    OutlinedButton(
                      key: const Key('done_continue_shopping'),
                      onPressed: () => context.go('/'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tokens.primaryGreen,
                        side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                        minimumSize: Size(0, 48.0 * s),
                        shape: const StadiumBorder(),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          strings.continueShopping,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: AppBackground(
        categorySlug: 'forest-produce',
        useSafeArea: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.0 * s, 20.0 * s, 16.0 * s, 24.0 * s),
          children: [
            // Big check icon + title + subtitle
            Center(
              child: Container(
                width: 64.0 * s,
                height: 64.0 * s,
                decoration: BoxDecoration(
                  color: tokens.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 36.0 * s,
                  color: tokens.onPrimaryGreen,
                ),
              ),
            ),
            SizedBox(height: 14.0 * s),
            Text(
              strings.coRequestSentTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0 * s,
                fontWeight: FontWeight.w800,
                color: tokens.heading,
              ),
            ),
            SizedBox(height: 6.0 * s),
            Text(
              strings.coRequestSentSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5 * s,
                color: tokens.bodyText,
                height: 1.35,
              ),
            ),
            SizedBox(height: 18.0 * s),

            // One card per request
            for (int i = 0; i < requests.length; i++) ...[
              if (i > 0) SizedBox(height: 12.0 * s),
              _RequestResultCard(
                request: requests[i],
                language: language,
                tokens: tokens,
                s: s,
              ),
            ],
            SizedBox(height: 20.0 * s),

            // Action buttons
            FilledButton(
              key: const Key('done_view_requests'),
              onPressed: () => context.go('/orders'),
              style: FilledButton.styleFrom(
                backgroundColor: tokens.primaryGreen,
                foregroundColor: tokens.onPrimaryGreen,
                minimumSize: Size(0, 50.0 * s),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0 * s),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  strings.coViewMyRequests,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15.0 * s,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0 * s),
            OutlinedButton(
              key: const Key('done_continue_shopping'),
              onPressed: () => context.go('/'),
              style: OutlinedButton.styleFrom(
                foregroundColor: tokens.primaryGreen,
                side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                minimumSize: Size(0, 50.0 * s),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0 * s),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  strings.continueShopping,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15.0 * s,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.0 * s),
            Text(
              strings.demoNote,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5 * s,
                color: tokens.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestResultCard extends StatelessWidget {
  final OrderRequest request;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _RequestResultCard({
    required this.request,
    required this.language,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(language);
    final sellerName = strings.coSellerName(
      request.sellerName,
      request.sellerType,
      request.sellerId,
    );
    final sellerTypeLabel =
        request.sellerType == 'gramsabha' ? strings.sellerGramSabha : strings.sellerCfrHolder;
    final deliveryLabel =
        request.deliveryPref == 'delivery' ? strings.coDelivery : strings.coPickup;
    final paymentLabel =
        request.paymentMethod == 'upi' ? strings.coUpi : strings.coCashOnDelivery;

    String? villageLabel;
    if (request.deliveryPref == 'delivery' && request.dropVillageId != null) {
      for (final v in pilotVillages) {
        if (v.id == request.dropVillageId) {
          villageLabel = v.label(language);
          break;
        }
      }
    }

    return Container(
      key: Key('request_card_${request.id}'),
      padding: EdgeInsets.all(14.0 * s),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(16.0 * s),
        border: Border.all(color: tokens.borders),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                      ),
                    ),
                    Text(
                      sellerTypeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0 * s,
                        color: tokens.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.0 * s),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatRupees(request.totalPaise),
                    key: Key('request_total_${request.id}'),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16.0 * s,
                      fontWeight: FontWeight.w800,
                      color: tokens.orange,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0 * s),
          Wrap(
            spacing: 6.0 * s,
            runSpacing: 4.0 * s,
            children: [
              _StatusChip(
                text: strings.coWaitingForSeller,
                bg: tokens.chipBg,
                fg: tokens.chipText,
                s: s,
              ),
              _StatusChip(
                text: strings.sampleBadge,
                bg: tokens.chipBg,
                fg: tokens.chipText,
                s: s,
              ),
            ],
          ),
          SizedBox(height: 10.0 * s),
          Divider(height: 1.0, color: tokens.borders),
          SizedBox(height: 8.0 * s),
          for (int i = 0; i < request.lines.length; i++) ...[
            if (i > 0) SizedBox(height: 4.0 * s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${request.lines[i].localizedTitle(language)} × ${request.lines[i].quantity} ${request.lines[i].localizedUnit(language)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.0 * s,
                      color: tokens.bodyText,
                    ),
                  ),
                ),
                SizedBox(width: 8.0 * s),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatRupees(request.lines[i].lineTotalPaise),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13.0 * s,
                        fontWeight: FontWeight.w700,
                        color: tokens.heading,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 10.0 * s),
          Wrap(
            spacing: 8.0 * s,
            runSpacing: 4.0 * s,
            children: [
              Text(
                villageLabel != null ? '$deliveryLabel ($villageLabel)' : deliveryLabel,
                style: TextStyle(
                  fontSize: 12.0 * s,
                  fontWeight: FontWeight.w600,
                  color: tokens.mutedText,
                ),
              ),
              Text(
                '·',
                style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
              ),
              Text(
                paymentLabel,
                style: TextStyle(
                  fontSize: 12.0 * s,
                  fontWeight: FontWeight.w600,
                  color: tokens.mutedText,
                ),
              ),
            ],
          ),
          if (request.note.isNotEmpty) ...[
            SizedBox(height: 6.0 * s),
            Text(
              request.note,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.0 * s,
                fontStyle: FontStyle.italic,
                color: tokens.mutedText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final double s;

  const _StatusChip({
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
        style: TextStyle(
          fontSize: 11.0 * s,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
