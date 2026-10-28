import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/orders_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../models/catalog_models.dart';
import '../../models/order_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/orders_providers.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../../widgets/app_background.dart';
import '../../widgets/orders/order_action_sheets.dart';
import '../../widgets/orders/order_status_chip.dart';

/// Full-screen order/request detail page (`/orders/:id`, outside the bottom-bar shell).
class OrderDetailPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final user = ref.watch(authUserProvider);
    final order = ref.watch(orderByIdProvider(orderId));
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    final isSellerView = user?.role == 'gramsabha' || user?.role == 'cfrholder';

    void goBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/orders');
      }
    }

    return Scaffold(
      body: AppBackground(
        categorySlug: 'forest-produce',
        useSafeArea: true,
        child: Column(
          children: [
            // Top bar with back arrow and title
            Padding(
              padding: EdgeInsets.fromLTRB(4.0 * s, 4.0 * s, 16.0 * s, 4.0 * s),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('order_detail_back'),
                    tooltip: strings.backLabel,
                    onPressed: goBack,
                    icon: Icon(Icons.arrow_back, color: tokens.heading),
                  ),
                  Expanded(
                    child: Text(
                      strings.odDetailTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: order == null
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0 * s),
                        child: Text(
                          strings.odNotFound,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15.0 * s, color: tokens.mutedText),
                        ),
                      ),
                    )
                  : _OrderDetailBody(
                      order: order,
                      isSellerView: isSellerView,
                      language: language,
                      tokens: tokens,
                      s: s,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  final OrderView order;
  final bool isSellerView;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _OrderDetailBody({
    required this.order,
    required this.isSellerView,
    required this.language,
    required this.tokens,
    required this.s,
  });

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(16.0 * s),
        border: Border.all(color: tokens.borders),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(language);
    final partyLabel = isSellerView ? strings.odBuyerLabel : strings.odSellerLabel;
    final partyName = isSellerView
        ? strings.odLocalizePartyName(order.buyerName)
        : strings.odLocalizePartyName(order.sellerName);
    final partySubtitle = isSellerView
        ? order.buyerPhone
        : (order.sellerType == 'gramsabha' ? strings.sellerGramSabha : strings.sellerCfrHolder);

    final deliveryText = order.deliveryPref == 'delivery'
        ? strings.fulfilDelivery
        : strings.fulfilPickup;
    final villageName = strings.odVillageName(order.dropVillageId);
    final fullDeliveryText =
        (order.deliveryPref == 'delivery' && villageName.isNotEmpty)
            ? '$deliveryText · $villageName'
            : deliveryText;

    final counter = order.counterOffer;
    final firstUnit =
        order.lines.isNotEmpty ? order.lines.first.localizedUnit(language) : '';

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.0 * s, 4.0 * s, 16.0 * s, 24.0 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // 1. Header card: status chip, Sample badge, ID, date, party
        Container(
          padding: EdgeInsets.all(16.0 * s),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.0 * s,
                runSpacing: 6.0 * s,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OrderStatusChip(
                    key: const Key('order_detail_status_chip'),
                    status: order.status,
                    language: language,
                    scale: s,
                  ),
                ],
              ),
              SizedBox(height: 10.0 * s),
              Wrap(
                spacing: 10.0 * s,
                runSpacing: 4.0 * s,
                children: [
                  Text(
                    strings.odOrderIdLabel(order.id),
                    style: TextStyle(
                      fontSize: 14.0 * s,
                      fontWeight: FontWeight.w800,
                      color: tokens.heading,
                    ),
                  ),
                  Text(
                    strings.odFormatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 13.0 * s,
                      color: tokens.mutedText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0 * s),
              Divider(height: 1.0, color: tokens.borders),
              SizedBox(height: 12.0 * s),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.0 * s,
                    height: 40.0 * s,
                    decoration: BoxDecoration(
                      color: tokens.chipBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSellerView
                          ? Icons.person_outline
                          : (order.sellerType == 'gramsabha'
                              ? Icons.groups_outlined
                              : Icons.person_outline),
                      size: 22.0 * s,
                      color: tokens.chipText,
                    ),
                  ),
                  SizedBox(width: 12.0 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partyLabel,
                          style: TextStyle(
                            fontSize: 12.0 * s,
                            color: tokens.mutedText,
                          ),
                        ),
                        SizedBox(height: 2.0 * s),
                        Text(
                          partyName,
                          style: TextStyle(
                            fontSize: 15.0 * s,
                            fontWeight: FontWeight.w800,
                            color: tokens.heading,
                          ),
                        ),
                        Text(
                          partySubtitle,
                          style: TextStyle(
                            fontSize: 12.5 * s,
                            color: tokens.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.0 * s),

        // 2. Counter-offer banner when present
        if (counter != null) ...[
          Container(
            key: const Key('order_counter_offer_card'),
            padding: EdgeInsets.all(14.0 * s),
            decoration: BoxDecoration(
              color: tokens.chipBg.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16.0 * s),
              border: Border.all(color: tokens.primaryGreen, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.odCounterOfferHeading,
                  style: TextStyle(
                    fontSize: 13.5 * s,
                    fontWeight: FontWeight.w800,
                    color: tokens.heading,
                  ),
                ),
                SizedBox(height: 4.0 * s),
                Text(
                  strings.odCounterOfferSummary(
                    counter.quantity,
                    firstUnit,
                    formatRupees(counter.unitPricePaise),
                  ),
                  style: TextStyle(
                    fontSize: 14.0 * s,
                    fontWeight: FontWeight.w700,
                    color: tokens.orange,
                  ),
                ),
                if (counter.note != null && counter.note!.isNotEmpty) ...[
                  SizedBox(height: 4.0 * s),
                  Text(
                    strings.odLocalizeNote(counter.note!),
                    style: TextStyle(
                      fontSize: 12.5 * s,
                      color: tokens.bodyText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12.0 * s),
        ],

        // 3. Lines and Total card
        Container(
          padding: EdgeInsets.all(16.0 * s),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.odItemsHeading,
                style: TextStyle(
                  fontSize: 16.0 * s,
                  fontWeight: FontWeight.w800,
                  color: tokens.heading,
                ),
              ),
              SizedBox(height: 12.0 * s),
              for (int i = 0; i < order.lines.length; i++) ...[
                if (i > 0) ...[
                  SizedBox(height: 10.0 * s),
                  Divider(height: 1.0, color: tokens.borders),
                  SizedBox(height: 10.0 * s),
                ],
                _OrderLineRow(
                  line: order.lines[i],
                  language: language,
                  tokens: tokens,
                  s: s,
                ),
              ],
              SizedBox(height: 12.0 * s),
              Divider(height: 1.0, color: tokens.borders),
              SizedBox(height: 12.0 * s),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.odTotalLabel,
                      style: TextStyle(
                        fontSize: 15.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        formatRupees(order.totalPaise),
                        key: const Key('order_detail_total'),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 19.0 * s,
                          fontWeight: FontWeight.w800,
                          color: tokens.orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.0 * s),

        // 4. Delivery, payment method, payment reference, note, rejection reason
        Container(
          padding: EdgeInsets.all(16.0 * s),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                label: strings.odDeliveryPrefLabel,
                value: fullDeliveryText,
                tokens: tokens,
                s: s,
              ),
              SizedBox(height: 10.0 * s),
              _InfoRow(
                label: strings.odPaymentMethodLabel,
                value: strings.odPaymentMethodText(order.paymentMethod),
                tokens: tokens,
                s: s,
              ),
              if (order.paymentReference != null && order.paymentReference!.isNotEmpty) ...[
                SizedBox(height: 10.0 * s),
                _InfoRow(
                  label: strings.odPaymentRefLabel,
                  value: order.paymentReference!,
                  tokens: tokens,
                  s: s,
                ),
              ],
              if (order.note.isNotEmpty) ...[
                SizedBox(height: 10.0 * s),
                _InfoRow(
                  label: strings.odNoteLabel,
                  value: strings.odLocalizeNote(order.note),
                  tokens: tokens,
                  s: s,
                ),
              ],
              if (order.rejectionReason != null && order.rejectionReason!.isNotEmpty) ...[
                SizedBox(height: 10.0 * s),
                _InfoRow(
                  label: strings.odRejectionReasonLabel,
                  value: strings.odLocalizeNote(order.rejectionReason!),
                  tokens: tokens,
                  s: s,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.0 * s),

        // 5. Actions card (only shown when at least one action is allowed for this role & status)
        _OrderActionsSection(
          order: order,
          isSellerView: isSellerView,
          language: language,
          tokens: tokens,
          s: s,
        ),

        // 6. Vertical status timeline
        Container(
          key: const Key('order_detail_timeline_card'),
          padding: EdgeInsets.all(16.0 * s),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.odTimelineHeading,
                style: TextStyle(
                  fontSize: 16.0 * s,
                  fontWeight: FontWeight.w800,
                  color: tokens.heading,
                ),
              ),
              SizedBox(height: 12.0 * s),
              for (int i = 0; i < order.events.length; i++)
                _TimelineStep(
                  event: order.events[i],
                  isLast: i == order.events.length - 1,
                  language: language,
                  tokens: tokens,
                  s: s,
                ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}

class _OrderLineRow extends StatelessWidget {
  final OrderLine line;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _OrderLineRow({
    required this.line,
    required this.language,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(language);
    final unit = line.localizedUnit(language);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0 * s),
          child: Container(
            width: 56.0 * s,
            height: 56.0 * s,
            color: VanRozgarTokens.picturePanel,
            child: Image.asset(
              line.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.eco_outlined,
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
              Text(
                line.localizedTitle(language),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.5 * s,
                  fontWeight: FontWeight.w700,
                  color: tokens.heading,
                ),
              ),
              SizedBox(height: 2.0 * s),
              Text(
                strings.billLine(formatRupees(line.unitPricePaise), line.quantity, unit),
                style: TextStyle(
                  fontSize: 12.5 * s,
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
            alignment: Alignment.centerRight,
            child: Text(
              formatRupees(line.lineTotalPaise),
              maxLines: 1,
              style: TextStyle(
                fontSize: 15.0 * s,
                fontWeight: FontWeight.w800,
                color: tokens.orange,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VanRozgarColorTokens tokens;
  final double s;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0 * s,
            color: tokens.mutedText,
          ),
        ),
        SizedBox(height: 2.0 * s),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.0 * s,
            fontWeight: FontWeight.w600,
            color: tokens.heading,
          ),
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final OrderStatusEvent event;
  final bool isLast;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _TimelineStep({
    required this.event,
    required this.isLast,
    required this.language,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(language);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24.0 * s,
            child: Column(
              children: [
                Container(
                  width: 12.0 * s,
                  height: 12.0 * s,
                  margin: EdgeInsets.only(top: 4.0 * s),
                  decoration: BoxDecoration(
                    color: isLast ? tokens.primaryGreen : tokens.chipBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tokens.primaryGreen,
                      width: 2.0,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.0,
                      color: tokens.borders,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.0 * s),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0.0 : 14.0 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.odStatusLabel(event.status),
                    style: TextStyle(
                      fontSize: 14.0 * s,
                      fontWeight: FontWeight.w700,
                      color: tokens.heading,
                    ),
                  ),
                  SizedBox(height: 2.0 * s),
                  Text(
                    strings.odFormatDate(event.at),
                    style: TextStyle(
                      fontSize: 12.0 * s,
                      color: tokens.mutedText,
                    ),
                  ),
                  if (event.note != null && event.note!.isNotEmpty) ...[
                    SizedBox(height: 4.0 * s),
                    Text(
                      strings.odLocalizeNote(event.note!),
                      style: TextStyle(
                        fontSize: 12.5 * s,
                        color: tokens.bodyText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderActionsSection extends ConsumerWidget {
  final OrderView order;
  final bool isSellerView;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _OrderActionsSection({
    required this.order,
    required this.isSellerView,
    required this.language,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(language);
    final buttons = <Widget>[];

    Widget primaryBtn({
      required Key key,
      required String label,
      required VoidCallback onPressed,
    }) {
      return FilledButton(
        key: key,
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primaryGreen,
          foregroundColor: tokens.onPrimaryGreen,
          minimumSize: Size(0, 48.0 * s),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0 * s)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    Widget secondaryBtn({
      required Key key,
      required String label,
      required VoidCallback onPressed,
    }) {
      return OutlinedButton(
        key: key,
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.primaryGreen,
          side: BorderSide(color: tokens.primaryGreen, width: 1.5),
          minimumSize: Size(0, 48.0 * s),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0 * s)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    if (isSellerView) {
      if (canApproveOrder(order)) {
        buttons.add(
          primaryBtn(
            key: const Key('order_action_approve'),
            label: strings.odBtnApprove,
            onPressed: () {
              final next = approveOrder(order);
              replaceOrderInState(ref, next);
            },
          ),
        );
      }
      if (canCounterOrder(order)) {
        buttons.add(
          secondaryBtn(
            key: const Key('order_action_counter'),
            label: strings.odBtnCounter,
            onPressed: () async {
              final res = await showCounterOfferSheet(
                context,
                line: order.lines.first,
                language: language,
              );
              if (res != null && context.mounted) {
                final next = counterOrder(
                  order,
                  quantity: res.quantity,
                  unitPricePaise: res.unitPricePaise,
                  note: res.note,
                );
                replaceOrderInState(ref, next);
              }
            },
          ),
        );
      }
      if (canRejectOrder(order)) {
        buttons.add(
          secondaryBtn(
            key: const Key('order_action_reject'),
            label: strings.odBtnReject,
            onPressed: () async {
              final reason = await showRejectOrderSheet(
                context,
                language: language,
              );
              if (reason != null && context.mounted) {
                final next = rejectOrder(order, reason: reason);
                replaceOrderInState(ref, next);
              }
            },
          ),
        );
      }
      if (canConfirmPayment(order)) {
        buttons.add(
          primaryBtn(
            key: const Key('order_action_confirm_payment'),
            label: strings.odBtnConfirmPayment,
            onPressed: () {
              final next = confirmPayment(order);
              replaceOrderInState(ref, next);
            },
          ),
        );
      }
      if (canMarkCompleted(order)) {
        buttons.add(
          primaryBtn(
            key: const Key('order_action_mark_completed'),
            label: strings.odBtnMarkCompleted,
            onPressed: () {
              final next = markCompleted(order);
              replaceOrderInState(ref, next);
            },
          ),
        );
      }
    } else {
      if (canAcceptCounter(order)) {
        buttons.add(
          primaryBtn(
            key: const Key('order_action_accept_counter'),
            label: strings.odBtnAcceptOffer,
            onPressed: () {
              final next = acceptCounter(order);
              replaceOrderInState(ref, next);
            },
          ),
        );
      }
      if (canDeclineCounter(order)) {
        buttons.add(
          secondaryBtn(
            key: const Key('order_action_decline_counter'),
            label: strings.odBtnDeclineOffer,
            onPressed: () {
              final next = declineCounter(order);
              replaceOrderInState(ref, next);
            },
          ),
        );
      }
      if (canReportPayment(order)) {
        buttons.add(
          primaryBtn(
            key: const Key('order_action_paid'),
            label: strings.odBtnIHavePaid,
            onPressed: () async {
              final refText = await showPaymentReferenceSheet(
                context,
                language: language,
              );
              if (refText != null && context.mounted) {
                final next = reportPayment(order, reference: refText);
                replaceOrderInState(ref, next);
              }
            },
          ),
        );
      }
      if (canCancelOrder(order)) {
        buttons.add(
          secondaryBtn(
            key: const Key('order_action_cancel'),
            label: strings.odBtnCancelRequest,
            onPressed: () async {
              final confirmed = await showCancelOrderSheet(
                context,
                language: language,
              );
              if (confirmed == true && context.mounted) {
                final next = cancelOrder(order);
                replaceOrderInState(ref, next);
              }
            },
          ),
        );
      }
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0 * s),
      child: Container(
        padding: EdgeInsets.all(16.0 * s),
        decoration: BoxDecoration(
          color: tokens.card,
          borderRadius: BorderRadius.circular(16.0 * s),
          border: Border.all(color: tokens.borders),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < buttons.length; i++) ...[
              if (i > 0) SizedBox(height: 10.0 * s),
              buttons[i],
            ],
          ],
        ),
      ),
    );
  }
}

