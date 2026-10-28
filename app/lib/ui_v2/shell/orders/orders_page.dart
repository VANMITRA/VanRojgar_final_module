import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/orders_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../models/order_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/orders_providers.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../../widgets/app_background.dart';
import '../../widgets/orders/order_card.dart';

/// The Orders tab (`/orders`, inside the main shell).
///
/// - Guest: shows a sign-in card with "Sign in" and "Create account" buttons.
/// - Buyer: shows "Active" and "Past" segments with order cards.
/// - Seller (Gram Sabha / CFR holder): shows "New requests", "In progress", and "Done" segments.
class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final user = ref.watch(authUserProvider);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    if (user == null) {
      return AppBackground(
        categorySlug: 'forest-produce',
        useSafeArea: true,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0 * s,
              vertical: 24.0 * s,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460.0),
              child: Container(
                key: const Key('orders_guest_card'),
                padding: EdgeInsets.all(20.0 * s),
                decoration: BoxDecoration(
                  color: tokens.card,
                  borderRadius: BorderRadius.circular(16.0 * s),
                  border: Border.all(color: tokens.borders),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 60.0 * s,
                        height: 60.0 * s,
                        decoration: BoxDecoration(
                          color: tokens.chipBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 30.0 * s,
                          color: tokens.chipText,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0 * s),
                    Text(
                      strings.odGuestTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                      ),
                    ),
                    SizedBox(height: 8.0 * s),
                    Text(
                      strings.odGuestSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5 * s,
                        color: tokens.bodyText,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 20.0 * s),
                    FilledButton(
                      key: const Key('orders_guest_signin'),
                      onPressed: () => context.push('/signin'),
                      style: FilledButton.styleFrom(
                        backgroundColor: tokens.primaryGreen,
                        foregroundColor: tokens.onPrimaryGreen,
                        minimumSize: Size(0, 48.0 * s),
                        shape: const StadiumBorder(),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          strings.signInTitle,
                          maxLines: 1,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0 * s),
                    OutlinedButton(
                      key: const Key('orders_guest_signup'),
                      onPressed: () => context.push('/signup'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tokens.primaryGreen,
                        side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                        minimumSize: Size(0, 48.0 * s),
                        shape: const StadiumBorder(),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          strings.createAccountTitle,
                          maxLines: 1,
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

    final isSeller = user.role == 'gramsabha' || user.role == 'cfrholder';
    final visibleOrders = ref.watch(visibleOrdersProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final List<({Key key, String label})> segments = isSeller
        ? [
            (key: const Key('orders_seg_new'), label: strings.odSegNewRequests),
            (key: const Key('orders_seg_in_progress'), label: strings.odSegInProgress),
            (key: const Key('orders_seg_done'), label: strings.odSegDone),
          ]
        : [
            (key: const Key('orders_seg_active'), label: strings.odSegActive),
            (key: const Key('orders_seg_past'), label: strings.odSegPast),
          ];

    final activeSegment = _selectedSegment.clamp(0, segments.length - 1);

    final List<OrderView> filteredOrders;
    final String emptyMessage;
    if (isSeller) {
      if (activeSegment == 0) {
        filteredOrders = visibleOrders.where((o) => o.status.isNewRequestForSeller).toList();
        emptyMessage = strings.odEmptySellerNew;
      } else if (activeSegment == 1) {
        filteredOrders = visibleOrders.where((o) => o.status.isInProgressForSeller).toList();
        emptyMessage = strings.odEmptySellerInProgress;
      } else {
        filteredOrders = visibleOrders.where((o) => o.status.isDoneForSeller).toList();
        emptyMessage = strings.odEmptySellerDone;
      }
    } else {
      if (activeSegment == 0) {
        filteredOrders = visibleOrders.where((o) => o.status.isActiveForBuyer).toList();
        emptyMessage = strings.odEmptyBuyerActive;
      } else {
        filteredOrders = visibleOrders.where((o) => o.status.isPastForBuyer).toList();
        emptyMessage = strings.odEmptyBuyerPast;
      }
    }

    return AppBackground(
      categorySlug: 'forest-produce',
      useSafeArea: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.0 * s, 12.0 * s, 16.0 * s, 8.0 * s),
            child: Text(
              strings.navOrders,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22.0 * s,
                fontWeight: FontWeight.w800,
                color: tokens.heading,
              ),
            ),
          ),

          // Non-scrolling segmented control
          Padding(
            padding: EdgeInsets.fromLTRB(16.0 * s, 4.0 * s, 16.0 * s, 10.0 * s),
            child: Material(
              color: tokens.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0 * s),
                side: BorderSide(color: tokens.borders),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(4.0 * s),
                child: Row(
                  children: [
                    for (int i = 0; i < segments.length; i++) ...[
                      if (i > 0) SizedBox(width: 4.0 * s),
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == activeSegment,
                          label: segments[i].label,
                          child: Material(
                            color: i == activeSegment ? tokens.primaryGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.0 * s),
                            child: InkWell(
                              key: segments[i].key,
                              borderRadius: BorderRadius.circular(10.0 * s),
                              onTap: () => setState(() => _selectedSegment = i),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 48.0),
                                padding: EdgeInsets.symmetric(horizontal: 8.0 * s, vertical: 6.0 * s),
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    segments[i].label,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 13.5 * s,
                                      fontWeight: FontWeight.w800,
                                      color: i == activeSegment
                                          ? tokens.onPrimaryGreen
                                          : tokens.bodyText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Orders list or empty state
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.0 * s),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420.0),
                        child: Container(
                          key: const Key('orders_empty_card'),
                          width: double.infinity,
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
                                size: 38.0 * s,
                                color: tokens.primaryGreen.withValues(alpha: 0.65),
                              ),
                              SizedBox(height: 12.0 * s),
                              Text(
                                emptyMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.5 * s,
                                  color: tokens.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      16.0 * s,
                      4.0 * s,
                      16.0 * s,
                      bottomInset + 24.0 * s + (cartCount > 0 ? 76.0 * s : 0.0),
                    ),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.0 * s),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return OrderCard(
                        order: order,
                        isSellerView: isSeller,
                        language: language,
                        scale: s,
                        onTap: () => context.push('/orders/${order.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

