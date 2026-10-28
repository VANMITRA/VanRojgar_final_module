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
import '../../widgets/checkout/guest_gate_sheet.dart';

export 'checkout_done_page.dart';

/// Full-screen `/checkout` page.
/// Displays grouped request summaries per seller, Pickup/Delivery selection with availability
/// rules from listing fulfilment, village dropdown for Delivery, UPI / Cash on delivery payment
/// selection, optional seller note, grand total, guest gate sheet, and request submission.
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  late final TextEditingController _noteController;
  bool _showVillageError = false;
  bool _showBoundsError = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final initialNote = ref.read(checkoutChoicesProvider).note;
    _noteController = TextEditingController(text: initialNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleSendRequest({
    required List<CartLine> lines,
    required FulfilmentAvailability availability,
    required String? effectiveDeliveryPref,
    required CheckoutChoices choices,
  }) {
    if (lines.isEmpty || availability.bothDisabled || effectiveDeliveryPref == null) {
      return;
    }

    final needsVillage = effectiveDeliveryPref == 'delivery';
    final hasVillage = choices.dropVillageId != null && choices.dropVillageId!.isNotEmpty;
    final withinBounds = validateCartQuantitiesWithinBounds(lines);

    setState(() {
      _showVillageError = needsVillage && !hasVillage;
      _showBoundsError = !withinBounds;
    });

    if (_showVillageError || _showBoundsError) {
      return;
    }

    final user = ref.read(authUserProvider);
    if (user == null) {
      showGuestGateSheet(context);
      return;
    }

    final existing = ref.read(requestsProvider);
    final created = buildOrderRequests(
      lines: lines,
      deliveryPref: effectiveDeliveryPref,
      paymentMethod: choices.paymentMethod,
      dropVillageId: choices.dropVillageId,
      note: choices.note,
      buyer: user,
      startSequence: existing.length + 1,
      createdAt: DateTime.now(),
    );

    _submitted = true;
    ref.read(requestsProvider.notifier).state = [...existing, ...created];
    ref.read(lastSentRequestsProvider.notifier).state = created;

    // Clear cart & reset checkout state after building the requests
    ref.read(cartQuantitiesProvider.notifier).state = <String, int>{};
    ref.read(cartSellerChoiceProvider.notifier).state = const <String, String>{};
    ref.read(lastAddedImageProvider.notifier).state = null;
    ref.read(cartLineClampNoticeProvider.notifier).state = const {};
    ref.read(checkoutChoicesProvider.notifier).reset();

    context.go('/checkout/done');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final cart = ref.watch(cartQuantitiesProvider);
    final lines = ref.watch(cartLinesProvider).valueOrNull ?? const <CartLine>[];
    final choices = ref.watch(checkoutChoicesProvider);

    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    // Redirect to /cart if cart is empty (unless we just submitted an order)
    if (cart.isEmpty && !_submitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/cart');
        }
      });
      return const Scaffold(
        body: AppBackground(
          categorySlug: 'forest-produce',
          useSafeArea: true,
          child: SizedBox.shrink(),
        ),
      );
    }

    // Keep controller text in sync if checkoutChoicesProvider was reset externally
    if (_noteController.text != choices.note) {
      _noteController.value = TextEditingValue(
        text: choices.note,
        selection: TextSelection.collapsed(offset: choices.note.length),
      );
    }

    final groups = groupCartLinesBySeller(lines);
    final grandTotalPaise = computeCartGrandTotalPaise(lines);
    final availability = evaluateFulfilmentAvailability(lines);
    final effectiveDeliveryPref =
        availability.resolveEffectiveDeliveryPref(choices.deliveryPref);

    // Sync provider if availability forced the other fulfilment option
    if (effectiveDeliveryPref != null && effectiveDeliveryPref != choices.deliveryPref) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(checkoutChoicesProvider.notifier).setDeliveryPref(effectiveDeliveryPref);
        }
      });
    }

    void goBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/cart');
      }
    }

    final pickupUnsupportedNames = availability.sellersWithoutPickup
        .map((seller) => seller.localizedName(strings))
        .join(', ');
    final deliveryUnsupportedNames = availability.sellersWithoutDelivery
        .map((seller) => seller.localizedName(strings))
        .join(', ');

    return Scaffold(
      body: AppBackground(
        categorySlug: 'forest-produce',
        useSafeArea: true,
        child: Column(
          children: [
            // Top bar: back arrow and title "Checkout"
            Padding(
              padding: EdgeInsets.fromLTRB(4.0 * s, 4.0 * s, 16.0 * s, 4.0 * s),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('checkout_back'),
                    tooltip: strings.backLabel,
                    onPressed: goBack,
                    icon: Icon(Icons.arrow_back, color: tokens.heading),
                  ),
                  Expanded(
                    child: Text(
                      strings.coCheckoutTitle,
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
              child: lines.isEmpty
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: EdgeInsets.fromLTRB(16.0 * s, 8.0 * s, 16.0 * s, 24.0 * s),
                      children: [
                        // 1. "Your requests"
                        _SectionTitle(text: strings.coYourRequests, tokens: tokens, s: s),
                        SizedBox(height: 8.0 * s),
                        for (int i = 0; i < groups.length; i++) ...[
                          if (i > 0) SizedBox(height: 10.0 * s),
                          _SellerRequestSummaryCard(
                            group: groups[i],
                            language: language,
                            tokens: tokens,
                            s: s,
                          ),
                        ],
                        SizedBox(height: 20.0 * s),

                        // 2. "How do you want to receive it?"
                        _SectionTitle(text: strings.coHowReceive, tokens: tokens, s: s),
                        SizedBox(height: 8.0 * s),
                        _SelectableChoiceCard(
                          cardKey: const Key('checkout_pref_pickup'),
                          icon: Icons.storefront_outlined,
                          title: strings.coPickup,
                          selected: !availability.bothDisabled && effectiveDeliveryPref == 'pickup',
                          enabled: availability.pickupEnabled,
                          disabledReason: availability.pickupEnabled
                              ? null
                              : strings.coNotOfferedBy(pickupUnsupportedNames),
                          disabledReasonKey: const Key('pickup_disabled_reason'),
                          tokens: tokens,
                          s: s,
                          onTap: availability.pickupEnabled
                              ? () {
                                  setState(() => _showVillageError = false);
                                  ref
                                      .read(checkoutChoicesProvider.notifier)
                                      .setDeliveryPref('pickup');
                                }
                              : null,
                        ),
                        SizedBox(height: 10.0 * s),
                        _SelectableChoiceCard(
                          cardKey: const Key('checkout_pref_delivery'),
                          icon: Icons.local_shipping_outlined,
                          title: strings.coDelivery,
                          selected:
                              !availability.bothDisabled && effectiveDeliveryPref == 'delivery',
                          enabled: availability.deliveryEnabled,
                          disabledReason: availability.deliveryEnabled
                              ? null
                              : strings.coNotOfferedBy(deliveryUnsupportedNames),
                          disabledReasonKey: const Key('delivery_disabled_reason'),
                          tokens: tokens,
                          s: s,
                          onTap: availability.deliveryEnabled
                              ? () {
                                  ref
                                      .read(checkoutChoicesProvider.notifier)
                                      .setDeliveryPref('delivery');
                                }
                              : null,
                        ),
                        if (availability.bothDisabled) ...[
                          SizedBox(height: 10.0 * s),
                          Container(
                            key: const Key('checkout_mixed_fulfilment_error'),
                            padding: EdgeInsets.all(12.0 * s),
                            decoration: BoxDecoration(
                              color: tokens.card,
                              borderRadius: BorderRadius.circular(12.0 * s),
                              border: Border.all(color: tokens.orange, width: 1.5),
                            ),
                            child: Text(
                              strings.coMixedFulfilmentError,
                              style: TextStyle(
                                fontSize: 13.0 * s,
                                fontWeight: FontWeight.w700,
                                color: tokens.orange,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                        if (!availability.bothDisabled && effectiveDeliveryPref == 'delivery') ...[
                          SizedBox(height: 12.0 * s),
                          Material(
                            color: Colors.transparent,
                            child: DropdownButtonFormField<String>(
                              key: const Key('checkout_village_dropdown'),
                              initialValue: choices.dropVillageId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: strings.coDeliverToVillage,
                                errorText:
                                    _showVillageError ? strings.coChooseVillageError : null,
                                filled: true,
                                fillColor: tokens.card,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.0 * s,
                                  vertical: 12.0 * s,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0 * s),
                                  borderSide: BorderSide(color: tokens.borders),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0 * s),
                                  borderSide: BorderSide(color: tokens.borders),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0 * s),
                                  borderSide:
                                      BorderSide(color: tokens.primaryGreen, width: 1.5),
                                ),
                              ),
                              items: [
                                for (final v in pilotVillages)
                                  DropdownMenuItem<String>(
                                    value: v.id,
                                    child: Text(
                                      v.label(language),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: (value) {
                                setState(() => _showVillageError = false);
                                ref
                                    .read(checkoutChoicesProvider.notifier)
                                    .setDropVillageId(value);
                              },
                            ),
                          ),
                        ],
                        SizedBox(height: 20.0 * s),

                        // 3. "How will you pay?"
                        _SectionTitle(text: strings.coHowPay, tokens: tokens, s: s),
                        SizedBox(height: 8.0 * s),
                        _SelectableChoiceCard(
                          cardKey: const Key('checkout_pay_upi'),
                          icon: Icons.qr_code_2_outlined,
                          title: strings.coUpi,
                          selected: choices.paymentMethod == 'upi',
                          enabled: true,
                          tokens: tokens,
                          s: s,
                          onTap: () => ref
                              .read(checkoutChoicesProvider.notifier)
                              .setPaymentMethod('upi'),
                        ),
                        SizedBox(height: 10.0 * s),
                        _SelectableChoiceCard(
                          cardKey: const Key('checkout_pay_cod'),
                          icon: Icons.payments_outlined,
                          title: strings.coCashOnDelivery,
                          selected: choices.paymentMethod == 'cod',
                          enabled: true,
                          tokens: tokens,
                          s: s,
                          onTap: () => ref
                              .read(checkoutChoicesProvider.notifier)
                              .setPaymentMethod('cod'),
                        ),
                        SizedBox(height: 8.0 * s),
                        Text(
                          choices.paymentMethod == 'upi'
                              ? strings.coUpiExplanation
                              : strings.coCodExplanation,
                          key: const Key('checkout_payment_explanation'),
                          style: TextStyle(
                            fontSize: 12.5 * s,
                            color: tokens.mutedText,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 20.0 * s),

                        // 4. "Note for the seller (optional)"
                        _SectionTitle(text: strings.coNoteLabel, tokens: tokens, s: s),
                        SizedBox(height: 8.0 * s),
                        Material(
                          color: Colors.transparent,
                          child: TextField(
                            key: const Key('checkout_note_field'),
                            controller: _noteController,
                            maxLength: 300,
                            minLines: 2,
                            maxLines: 4,
                            onChanged: (val) =>
                                ref.read(checkoutChoicesProvider.notifier).setNote(val),
                            decoration: InputDecoration(
                              hintText: strings.coNoteHint,
                              filled: true,
                              fillColor: tokens.card,
                              contentPadding: EdgeInsets.all(12.0 * s),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0 * s),
                                borderSide: BorderSide(color: tokens.borders),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0 * s),
                                borderSide: BorderSide(color: tokens.borders),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0 * s),
                                borderSide:
                                    BorderSide(color: tokens.primaryGreen, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0 * s),

                        // 5. "Total"
                        Container(
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      strings.coTotalLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16.0 * s,
                                        fontWeight: FontWeight.w800,
                                        color: tokens.heading,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.0 * s),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        formatRupees(grandTotalPaise),
                                        key: const Key('checkout_grand_total'),
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 20.0 * s,
                                          fontWeight: FontWeight.w800,
                                          color: tokens.orange,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.0 * s),
                              Text(
                                strings.coSellersRequestsSummary(groups.length),
                                key: const Key('checkout_sellers_requests_summary'),
                                style: TextStyle(
                                  fontSize: 12.5 * s,
                                  color: tokens.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_showBoundsError) ...[
                          SizedBox(height: 10.0 * s),
                          Text(
                            strings.coQuantityBoundsError,
                            key: const Key('checkout_bounds_error'),
                            style: TextStyle(
                              fontSize: 12.5 * s,
                              fontWeight: FontWeight.w700,
                              color: tokens.orange,
                            ),
                          ),
                        ],
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
            if (lines.isNotEmpty)
              Material(
                color: tokens.card,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: tokens.borders)),
                  ),
                  padding: EdgeInsets.fromLTRB(16.0 * s, 10.0 * s, 16.0 * s, 10.0 * s),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('checkout_send_button'),
                      onPressed: availability.bothDisabled
                          ? null
                          : () => _handleSendRequest(
                                lines: lines,
                                availability: availability,
                                effectiveDeliveryPref: effectiveDeliveryPref,
                                choices: choices,
                              ),
                      style: FilledButton.styleFrom(
                        backgroundColor: tokens.primaryGreen,
                        foregroundColor: tokens.onPrimaryGreen,
                        disabledBackgroundColor: tokens.borders,
                        disabledForegroundColor: tokens.mutedText,
                        minimumSize: Size(0, 52.0 * s < 52.0 ? 52.0 : 52.0 * s),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0 * s),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          strings.coSendRequest,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 16.0 * s,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final VanRozgarColorTokens tokens;
  final double s;

  const _SectionTitle({
    required this.text,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.0 * s,
        fontWeight: FontWeight.w800,
        color: tokens.heading,
      ),
    );
  }
}

class _SellerRequestSummaryCard extends StatelessWidget {
  final SellerCartGroup group;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _SellerRequestSummaryCard({
    required this.group,
    required this.language,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(language);
    final sellerName = strings.coSellerName(
      group.sellerName,
      group.sellerType,
      group.sellerId,
    );
    final sellerType =
        group.sellerType == 'gramsabha' ? strings.sellerGramSabha : strings.sellerCfrHolder;

    return Container(
      key: Key('checkout_group_${group.sellerId}'),
      padding: EdgeInsets.all(12.0 * s),
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
                        fontSize: 14.5 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                      ),
                    ),
                    Text(
                      sellerType,
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
                    formatRupees(group.subtotalPaise),
                    key: Key('checkout_seller_total_${group.sellerId}'),
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
          ),
          SizedBox(height: 8.0 * s),
          Divider(height: 1.0, color: tokens.borders),
          SizedBox(height: 8.0 * s),
          for (int i = 0; i < group.lines.length; i++) ...[
            if (i > 0) SizedBox(height: 4.0 * s),
            _CompactLineRow(
              line: group.lines[i],
              language: language,
              tokens: tokens,
              s: s,
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactLineRow extends StatelessWidget {
  final CartLine line;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _CompactLineRow({
    required this.line,
    required this.language,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final title = line.product.localizedTitle(language);
    final unit = line.product.localizedUnit(language);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '$title × ${line.quantity} $unit',
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
              formatRupees(line.lineTotalPaise),
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
    );
  }
}

class _SelectableChoiceCard extends StatelessWidget {
  final Key cardKey;
  final IconData icon;
  final String title;
  final bool selected;
  final bool enabled;
  final String? disabledReason;
  final Key? disabledReasonKey;
  final VanRozgarColorTokens tokens;
  final double s;
  final VoidCallback? onTap;

  const _SelectableChoiceCard({
    required this.cardKey,
    required this.icon,
    required this.title,
    required this.selected,
    required this.enabled,
    this.disabledReason,
    this.disabledReasonKey,
    required this.tokens,
    required this.s,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = !enabled
        ? tokens.borders
        : (selected ? tokens.primaryGreen : tokens.borders);
    final bgColor = !enabled
        ? tokens.card.withValues(alpha: 0.55)
        : tokens.card;
    final textColor = !enabled ? tokens.mutedText : tokens.heading;

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0 * s),
        side: BorderSide(
          color: borderColor,
          width: selected && enabled ? 2.0 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: cardKey,
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.0 * s, vertical: 12.0 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 22.0 * s,
                    color: !enabled
                        ? tokens.mutedText
                        : (selected ? tokens.primaryGreen : tokens.heading),
                  ),
                  SizedBox(width: 10.0 * s),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.0 * s,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0 * s),
                  Icon(
                    selected && enabled
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 22.0 * s,
                    color: !enabled
                        ? tokens.borders
                        : (selected ? tokens.primaryGreen : tokens.mutedText),
                  ),
                ],
              ),
              if (!enabled && disabledReason != null) ...[
                SizedBox(height: 6.0 * s),
                Text(
                  disabledReason!,
                  key: disabledReasonKey,
                  style: TextStyle(
                    fontSize: 12.0 * s,
                    color: tokens.mutedText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
