import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../l10n/checkout_strings.dart';
import '../l10n/shop_extra_strings.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import '../providers/checkout_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import '../widgets/app_background.dart';
import '../widgets/checkout/change_seller_sheet.dart';
import '../widgets/min_order_dialog.dart';
import '../widgets/quantity_stepper.dart';

/// Full-screen cart opened from the floating "View cart" pill.
/// Groups lines by seller, supports switching sellers per product, and shows the sticky
/// grand-total bar leading to `/checkout`.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final cart = ref.watch(cartQuantitiesProvider);
    final lines = ref.watch(cartLinesProvider).valueOrNull ?? const <CartLine>[];

    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    // Silently clamp any out-of-bounds quantities on the Cart page
    if (lines.isNotEmpty) {
      Map<String, int>? clampedUpdates;
      for (final line in lines) {
        final res = clampQuantityForListing(line.quantity, line.listing);
        if (res.quantity != line.quantity) {
          clampedUpdates ??= Map<String, int>.from(cart);
          clampedUpdates[line.product.productCode] = res.quantity;
        }
      }
      if (clampedUpdates != null) {
        final nextMap = clampedUpdates;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ref.read(cartQuantitiesProvider.notifier).state = nextMap;
          }
        });
      }
    }

    final groups = groupCartLinesBySeller(lines);
    final grandTotalPaise = computeCartGrandTotalPaise(lines);

    void goBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }

    return Scaffold(
      body: AppBackground(
        categorySlug: 'forest-produce',
        useSafeArea: true,
        child: Column(
          children: [
            // Top bar: back arrow and the title
            Padding(
              padding: EdgeInsets.fromLTRB(4.0 * s, 4.0 * s, 16.0 * s, 4.0 * s),
              child: Row(
                children: [
                  IconButton(
                    tooltip: strings.backLabel,
                    onPressed: goBack,
                    icon: Icon(Icons.arrow_back, color: tokens.heading),
                  ),
                  Expanded(
                    child: Text(
                      strings.navCart,
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
              child: cart.isEmpty
                  ? _EmptyCart(strings: strings, tokens: tokens, s: s)
                  : lines.isEmpty
                      ? const SizedBox.shrink()
                      : ListView(
                          padding: EdgeInsets.fromLTRB(16.0 * s, 8.0 * s, 16.0 * s, 24.0 * s),
                          children: [
                            for (int g = 0; g < groups.length; g++) ...[
                              if (g > 0) SizedBox(height: 16.0 * s),
                              _SellerGroupSection(
                                group: groups[g],
                                language: language,
                                tokens: tokens,
                                s: s,
                              ),
                            ],
                            SizedBox(height: 16.0 * s),
                            Text(
                              strings.coCartApprovalNote,
                              key: const Key('cart_approval_note'),
                              style: TextStyle(
                                fontSize: 12.5 * s,
                                color: tokens.mutedText,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
            ),
            if (cart.isNotEmpty && lines.isNotEmpty)
              _CartStickyBottomBar(
                grandTotalPaise: grandTotalPaise,
                sellerCount: groups.length,
                strings: strings,
                tokens: tokens,
                s: s,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final AppStrings strings;
  final VanRozgarColorTokens tokens;
  final double s;

  const _EmptyCart({required this.strings, required this.tokens, required this.s});

  @override
  Widget build(BuildContext context) {
    return Center(
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
                Icons.eco_outlined,
                size: 40.0 * s,
                color: tokens.primaryGreen.withValues(alpha: 0.7),
              ),
              SizedBox(height: 12.0 * s),
              Text(
                strings.cartEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.0 * s, color: tokens.bodyText),
              ),
              SizedBox(height: 16.0 * s),
              OutlinedButton(
                onPressed: () => context.go('/'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tokens.primaryGreen,
                  side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                  minimumSize: Size(0, 48.0 * s),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  strings.continueShopping,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerGroupSection extends StatelessWidget {
  final SellerCartGroup group;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _SellerGroupSection({
    required this.group,
    required this.language,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(language);
    final sellerDisplayName = strings.coSellerName(
      group.sellerName,
      group.sellerType,
      group.sellerId,
    );
    final sellerTypeLabel =
        group.sellerType == 'gramsabha' ? strings.sellerGramSabha : strings.sellerCfrHolder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Seller group header card
        Container(
          key: Key('cart_seller_group_${group.sellerId}'),
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
                  Container(
                    width: 36.0 * s,
                    height: 36.0 * s,
                    decoration: BoxDecoration(
                      color: tokens.chipBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      group.sellerType == 'gramsabha'
                          ? Icons.groups_outlined
                          : Icons.person_outline,
                      size: 20.0 * s,
                      color: tokens.chipText,
                    ),
                  ),
                  SizedBox(width: 10.0 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sellerDisplayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.0 * s,
                            fontWeight: FontWeight.w800,
                            color: tokens.heading,
                          ),
                        ),
                        SizedBox(height: 2.0 * s),
                        Text(
                          sellerTypeLabel,
                          style: TextStyle(
                            fontSize: 12.0 * s,
                            fontWeight: FontWeight.w600,
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
                        formatRupees(group.subtotalPaise),
                        key: Key('seller_subtotal_${group.sellerId}'),
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
                  if (group.offersPickup)
                    _OfferChip(text: strings.coPickup, tokens: tokens, s: s),
                  if (group.offersDelivery)
                    _OfferChip(text: strings.coDelivery, tokens: tokens, s: s),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8.0 * s),
        for (int i = 0; i < group.lines.length; i++) ...[
          if (i > 0) SizedBox(height: 8.0 * s),
          _CartLineCard(
            line: group.lines[i],
            language: language,
            tokens: tokens,
            s: s,
          ),
        ],
      ],
    );
  }
}

class _OfferChip extends StatelessWidget {
  final String text;
  final VanRozgarColorTokens tokens;
  final double s;

  const _OfferChip({
    required this.text,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0 * s, vertical: 3.0 * s),
      decoration: BoxDecoration(
        color: tokens.chipBg,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.0 * s,
          fontWeight: FontWeight.w700,
          color: tokens.chipText,
        ),
      ),
    );
  }
}

class _CartLineCard extends ConsumerWidget {
  final CartLine line;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _CartLineCard({
    required this.line,
    required this.language,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(language);
    final product = line.product;
    final unit = product.localizedUnit(language);
    // Use the CHOSEN listing's minimum order quantity and stock
    final minOrder = line.listing.minOrderQuantity;
    final maxStock = line.listing.quantityAvailable;
    final clampReason =
        ref.watch(cartLineClampNoticeProvider)[product.productCode] ?? SellerQtyClampReason.none;

    String? inlineClampMessage;
    if (clampReason == SellerQtyClampReason.raisedToMin) {
      inlineClampMessage = strings.coQtyAdjustedToMin(minOrder, unit);
    } else if (clampReason == SellerQtyClampReason.loweredToStock) {
      inlineClampMessage = strings.coQtyAdjustedToStock(maxStock, unit);
    }

    return Container(
      key: Key('cart_line_${product.productCode}'),
      padding: EdgeInsets.all(12.0 * s),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(16.0 * s),
        border: Border.all(color: tokens.borders),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0 * s),
            child: Container(
              width: 64.0 * s,
              height: 64.0 * s,
              color: VanRozgarTokens.picturePanel,
              child: Image.asset(
                product.imageAsset,
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
                  product.localizedTitle(language),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.0 * s,
                    fontWeight: FontWeight.w700,
                    color: tokens.heading,
                  ),
                ),
                SizedBox(height: 2.0 * s),
                Text(
                  '${formatRupees(line.unitPricePaise)} ${strings.perUnit(unit)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                ),
                SizedBox(height: 6.0 * s),
                Wrap(
                  spacing: 8.0 * s,
                  runSpacing: 4.0 * s,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: TextButton(
                        key: Key('change_seller_${product.productCode}'),
                        onPressed: () => showChangeSellerSheet(
                          context,
                          product: product,
                          currentListingId: line.listing.id,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: tokens.primaryGreen,
                          minimumSize: const Size(48.0, 48.0),
                          padding: EdgeInsets.symmetric(horizontal: 8.0 * s, vertical: 4.0 * s),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          strings.coChangeSeller,
                          style: TextStyle(
                            fontSize: 12.5 * s,
                            fontWeight: FontWeight.w800,
                            color: tokens.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (inlineClampMessage != null) ...[
                  SizedBox(height: 4.0 * s),
                  Text(
                    inlineClampMessage,
                    key: Key('clamp_note_${product.productCode}'),
                    style: TextStyle(
                      fontSize: 11.5 * s,
                      fontWeight: FontWeight.w600,
                      color: tokens.orange,
                    ),
                  ),
                ],
                SizedBox(height: 8.0 * s),
                Row(
                  children: [
                    QuantityStepper(
                      quantity: line.quantity,
                      scale: s,
                      onMinus: () => decrementWithMinOrderCheck(
                        context,
                        ref,
                        productCode: product.productCode,
                        title: product.localizedTitle(language),
                        minOrder: minOrder,
                        unit: unit,
                        strings: strings,
                      ),
                      onPlus: () {
                        if (line.quantity < maxStock) {
                          ref.read(cartQuantitiesProvider.notifier).increment(product.productCode);
                        }
                      },
                    ),
                    const Spacer(),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatRupees(line.lineTotalPaise),
                          key: Key('line_total_${product.productCode}'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartStickyBottomBar extends StatelessWidget {
  final int grandTotalPaise;
  final int sellerCount;
  final AppStrings strings;
  final VanRozgarColorTokens tokens;
  final double s;

  const _CartStickyBottomBar({
    required this.grandTotalPaise,
    required this.sellerCount,
    required this.strings,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tokens.card,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.borders)),
        ),
        padding: EdgeInsets.fromLTRB(16.0 * s, 10.0 * s, 16.0 * s, 10.0 * s),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      strings.coTotalAmount(formatRupees(grandTotalPaise)),
                      key: const Key('cart_grand_total'),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 18.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.orange,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.0 * s),
                  Text(
                    strings.coSellersRequestsSummary(sellerCount),
                    key: const Key('cart_sellers_requests_summary'),
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
            SizedBox(width: 12.0 * s),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.45),
              child: FilledButton(
                key: const Key('cart_continue_button'),
                onPressed: () => context.push('/checkout'),
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.primaryGreen,
                  foregroundColor: tokens.onPrimaryGreen,
                  minimumSize: Size(0, 48.0 * s),
                  padding: EdgeInsets.symmetric(horizontal: 20.0 * s, vertical: 10.0 * s),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0 * s),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    strings.coContinue,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15.0 * s,
                      fontWeight: FontWeight.w800,
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
