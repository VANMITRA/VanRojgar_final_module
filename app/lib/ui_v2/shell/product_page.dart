import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../l10n/shop_extra_strings.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import '../widgets/app_background.dart';
import '../widgets/min_order_dialog.dart';
import '../widgets/quantity_stepper.dart';

/// Product page: big picture, price, stock bar, the sellers (cheapest first) and an add-to-cart bar.
/// Opened from every product card (route /product/:code). Sample data only.
class ProductPage extends ConsumerWidget {
  final String productCode;

  const ProductPage({super.key, required this.productCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final product = ref.watch(productByCodeProvider(productCode)).valueOrNull;
    final cart = ref.watch(cartQuantitiesProvider);
    final choice = ref.watch(cartSellerChoiceProvider);
    final pending = ref.watch(_pendingQuantityProvider(productCode));
    final selected = product == null ? null : _selectedListing(product, choice[productCode]);

    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    void goBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }

    return Scaffold(
      body: AppBackground(
        categorySlug: product?.categorySlug ?? 'all',
        useSafeArea: true,
        child: Column(
          children: [
            // Back arrow
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.0 * s, 4.0 * s, 4.0 * s, 0),
                child: IconButton(
                  tooltip: strings.backLabel,
                  onPressed: goBack,
                  icon: Icon(Icons.arrow_back, color: tokens.heading),
                ),
              ),
            ),
            Expanded(
              child: product == null || selected == null
                  ? const SizedBox.shrink()
                  : _ProductBody(
                      product: product,
                      selected: selected,
                      onSelect: (listing) => _selectSeller(ref, product, listing),
                      language: language,
                      tokens: tokens,
                      s: s,
                    ),
            ),
            if (product != null && selected != null)
              _AddBar(
                product: product,
                selected: selected,
                inCart: cart[product.productCode],
                pending: pending == 0 ? selected.minOrderQuantity : pending,
                language: language,
                tokens: tokens,
                s: s,
              ),
          ],
        ),
      ),
    );
  }
}

/// Quantity picked on this page before the product is in the cart (0 = not touched: the seller's minimum).
final _pendingQuantityProvider = StateProvider.family<int, String>((ref, code) => 0);

/// The seller the buyer picked for [product], or the cheapest one.
ShopListing _selectedListing(ShopProduct product, String? chosenId) {
  for (final l in product.listings) {
    if (l.id == chosenId) return l;
  }
  return product.cheapestListing ?? product.listings.first;
}

/// Picks [listing] as the seller. A quantity below that seller's minimum order is raised to it.
void _selectSeller(WidgetRef ref, ShopProduct product, ShopListing listing) {
  final code = product.productCode;
  ref.read(cartSellerChoiceProvider.notifier).state = {...ref.read(cartSellerChoiceProvider), code: listing.id};
  final inCart = ref.read(cartQuantitiesProvider)[code];
  if (inCart != null && inCart < listing.minOrderQuantity) {
    ref.read(cartQuantitiesProvider.notifier).state = {...ref.read(cartQuantitiesProvider), code: listing.minOrderQuantity};
  }
  final pending = ref.read(_pendingQuantityProvider(code));
  if (pending != 0 && pending < listing.minOrderQuantity) {
    ref.read(_pendingQuantityProvider(code).notifier).state = listing.minOrderQuantity;
  }
}

class _ProductBody extends StatelessWidget {
  final ShopProduct product;
  final ShopListing selected;
  final void Function(ShopListing) onSelect;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _ProductBody({
    required this.product,
    required this.selected,
    required this.onSelect,
    required this.language,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(language);
    final unit = product.localizedUnit(language);
    final cheapest = selected;
    final isCheapestPick = selected.id == product.cheapestListing?.id && product.listings.length > 1;
    final sellers = [...product.listings]..sort((a, b) => a.pricePerUnitPaise.compareTo(b.pricePerUnitPaise));
    final soldTotal = product.totalSold;
    final left = product.totalAvailable;
    final total = soldTotal + left;
    final soldFraction = total > 0 ? soldTotal / total : 0.0;
    final minOrder = cheapest.minOrderQuantity;
    final hasDiscount = cheapest.discountPaise > 0;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.0 * s, 4.0 * s, 16.0 * s, 16.0 * s),
      children: [
        // Big picture
        ClipRRect(
          borderRadius: BorderRadius.circular(24.0 * s),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              color: VanRozgarTokens.picturePanel,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    product.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.eco_outlined,
                        size: 48.0 * s,
                        color: tokens.primaryGreen.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12.0 * s,
                    left: 12.0 * s,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Pill(text: strings.sampleBadge, background: Colors.white, color: tokens.primaryGreen, s: s),
                        if (product.isIllustration) ...[
                          SizedBox(height: 4.0 * s),
                          _Pill(
                            text: strings.illustrationTag,
                            background: Colors.white.withValues(alpha: 0.85),
                            color: tokens.mutedText,
                            s: s,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (product.notForEating)
                    Positioned(
                      bottom: 12.0 * s,
                      left: 12.0 * s,
                      child: _Pill(
                        text: strings.notForEating,
                        background: tokens.outlinedControl,
                        color: Colors.white,
                        s: s,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 16.0 * s),

        // Name and category
        Text(
          product.localizedTitle(language),
          style: TextStyle(
            fontSize: 24.0 * s,
            fontWeight: FontWeight.w800,
            color: tokens.heading,
            height: 1.15,
          ),
        ),
        SizedBox(height: 4.0 * s),
        Text(
          strings.categoryLabel(product.categorySlug),
          style: TextStyle(fontSize: 13.0 * s, color: tokens.mutedText),
        ),
        SizedBox(height: 12.0 * s),

        // Price
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8.0 * s,
          children: [
            Text(
              isCheapestPick
                  ? strings.priceFrom(formatRupees(selected.pricePerUnitPaise))
                  : formatRupees(selected.pricePerUnitPaise),
              style: TextStyle(
                fontSize: 24.0 * s,
                fontWeight: FontWeight.w800,
                color: tokens.orange,
              ),
            ),
            if (hasDiscount)
              Text(
                formatRupees(cheapest.mrpPerUnitPaise),
                style: TextStyle(
                  fontSize: 14.0 * s,
                  color: tokens.mutedText,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            Text(
              strings.perUnit(unit),
              style: TextStyle(fontSize: 13.0 * s, color: tokens.mutedText),
            ),
          ],
        ),
        if (hasDiscount) ...[
          SizedBox(height: 4.0 * s),
          Text(
            cheapest.discountPaise < 10000
                ? strings.offRupees(formatRupees(cheapest.discountPaise))
                : strings.offPercent(cheapest.discountPercent),
            style: TextStyle(
              fontSize: 13.0 * s,
              fontWeight: FontWeight.w700,
              color: tokens.primaryGreen,
            ),
          ),
        ],
        SizedBox(height: 16.0 * s),

        // Live stock bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0 * s),
          child: Stack(
            children: [
              Container(height: 8.0 * s, color: tokens.borders),
              FractionallySizedBox(
                widthFactor: soldFraction.clamp(0.0, 1.0),
                child: Container(height: 8.0 * s, color: tokens.primaryGreen),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.0 * s),
        Text(
          strings.soldLeftBar(soldTotal, left, unit),
          style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText),
        ),
        SizedBox(height: 4.0 * s),
        Text(
          strings.minOrderText(minOrder, unit),
          style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText),
        ),
        SizedBox(height: 20.0 * s),

        // Sellers, cheapest first
        Text(
          '${strings.productSellers} (${sellers.length})',
          style: TextStyle(
            fontSize: 18.0 * s,
            fontWeight: FontWeight.w800,
            color: tokens.heading,
          ),
        ),
        if (sellers.length > 1) ...[
          SizedBox(height: 2.0 * s),
          Text(strings.tapSeller, style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText)),
        ],
        SizedBox(height: 10.0 * s),
        for (int i = 0; i < sellers.length; i++) ...[
          if (i > 0) SizedBox(height: 10.0 * s),
          _SellerRow(
            listing: sellers[i],
            isSelected: sellers[i].id == selected.id,
            onTap: () => onSelect(sellers[i]),
            isLowest: sellers.length > 1 && i == 0,
            unit: unit,
            language: language,
            tokens: tokens,
            s: s,
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color color;
  final double s;

  const _Pill({required this.text, required this.background, required this.color, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0 * s, vertical: 4.0 * s),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(100.0)),
      child: Text(
        text,
        style: TextStyle(fontSize: 11.0 * s, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _SellerRow extends StatelessWidget {
  final ShopListing listing;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLowest;
  final String unit;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _SellerRow({
    required this.listing,
    required this.isSelected,
    required this.onTap,
    required this.isLowest,
    required this.unit,
    required this.language,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(language);
    final seller = listing.sellerType == 'gramsabha' ? strings.sellerGramSabha : strings.sellerCfrHolder;
    final hasDiscount = listing.discountPaise > 0;
    final fulfilment = switch (listing.fulfilment) {
      'pickup' => strings.fulfilPickup,
      'delivery' => strings.fulfilDelivery,
      _ => '${strings.fulfilPickup} · ${strings.fulfilDelivery}',
    };

    return Material(
      color: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0 * s),
        side: BorderSide(color: isSelected ? tokens.primaryGreen : tokens.borders, width: isSelected ? 2.0 : 1.0),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0 * s)),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.0 * s),
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.0 * s,
            height: 40.0 * s,
            decoration: BoxDecoration(color: tokens.chipBg, shape: BoxShape.circle),
            child: Icon(
              listing.sellerType == 'gramsabha' ? Icons.groups_outlined : Icons.person_outline,
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
                  listing.sellerName,
                  style: TextStyle(
                    fontSize: 14.0 * s,
                    fontWeight: FontWeight.w700,
                    color: tokens.heading,
                  ),
                ),
                Text(
                  '$seller · $fulfilment',
                  style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                ),
                SizedBox(height: 4.0 * s),
                Text(
                  strings.qtyLeft(listing.quantityAvailable, unit),
                  style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                ),
                Text(
                  strings.minOrderText(listing.minOrderQuantity, unit),
                  style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                ),
                if (isLowest || isSelected) ...[
                  SizedBox(height: 6.0 * s),
                  Wrap(
                    spacing: 6.0 * s,
                    runSpacing: 4.0 * s,
                    children: [
                      if (isLowest)
                        _Pill(
                          text: strings.lowestPrice,
                          background: tokens.primaryGreen,
                          color: tokens.onPrimaryGreen,
                          s: s,
                        ),
                      if (isSelected)
                        _Pill(
                          text: strings.sellerSelected,
                          background: tokens.chipBg,
                          color: tokens.chipText,
                          s: s,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.0 * s),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupees(listing.pricePerUnitPaise),
                style: TextStyle(
                  fontSize: 17.0 * s,
                  fontWeight: FontWeight.w800,
                  color: tokens.orange,
                ),
              ),
              if (hasDiscount)
                Text(
                  formatRupees(listing.mrpPerUnitPaise),
                  style: TextStyle(
                    fontSize: 11.5 * s,
                    color: tokens.mutedText,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Text(
                strings.perUnit(unit),
                style: TextStyle(fontSize: 11.0 * s, color: tokens.mutedText),
              ),
            ],
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class _AddBar extends ConsumerWidget {
  final ShopProduct product;
  final ShopListing selected;
  final int? inCart;
  final int pending;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final double s;

  const _AddBar({
    required this.product,
    required this.selected,
    required this.inCart,
    required this.pending,
    required this.language,
    required this.tokens,
    required this.s,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(language);
    final code = product.productCode;
    final unit = product.localizedUnit(language);
    final minOrder = selected.minOrderQuantity;
    final quantity = inCart ?? pending;
    final canAddMore = quantity < selected.quantityAvailable;
    final cart = ref.read(cartQuantitiesProvider.notifier);
    final pendingNotifier = ref.read(_pendingQuantityProvider(code).notifier);

    void setQuantity(int q) {
      if (inCart != null) {
        cart.state = {...ref.read(cartQuantitiesProvider), code: q};
      } else {
        pendingNotifier.state = q;
      }
    }

    void putInCart() {
      cart.add(code, quantity);
      ref.read(lastAddedImageProvider.notifier).state = product.imageAsset;
    }

    Future<void> buyNow() async {
      if (ref.read(authUserProvider) == null) {
        final signIn = await _askSignIn(context, strings, tokens, s);
        if (signIn == true && context.mounted) {
          context.push('/signin?redirect=${Uri.encodeQueryComponent('/product/$code')}');
        }
        return;
      }
      if (inCart == null) putInCart();
      if (context.mounted) context.push('/checkout');
    }

    ButtonStyle style(Color bg, Color fg, {Color? border}) => FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: Size(0, 48.0 * s),
          side: border == null ? null : BorderSide(color: border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0 * s)),
        );

    Widget label(String text) => FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(text, maxLines: 1, style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800)),
        );

    return Container(
      padding: EdgeInsets.fromLTRB(16.0 * s, 10.0 * s, 16.0 * s, 10.0 * s),
      decoration: BoxDecoration(
        color: tokens.card,
        border: Border(top: BorderSide(color: tokens.borders)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bill: price × quantity = total for the chosen seller
            Row(
              children: [
                Text(
                  strings.billTitle,
                  style: TextStyle(fontSize: 13.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                ),
                SizedBox(width: 8.0 * s),
                Expanded(
                  child: Text(
                    strings.billLine(formatRupees(selected.pricePerUnitPaise), quantity, unit),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText),
                  ),
                ),
                SizedBox(width: 8.0 * s),
                Text(
                  formatRupees(selected.pricePerUnitPaise * quantity),
                  style: TextStyle(fontSize: 17.0 * s, fontWeight: FontWeight.w800, color: tokens.orange),
                ),
              ],
            ),
            SizedBox(height: 8.0 * s),
            Row(
              children: [
                QuantityStepper(
                  quantity: quantity,
                  scale: s,
                  onMinus: () {
                    if (inCart != null) {
                      decrementWithMinOrderCheck(
                        context,
                        ref,
                        productCode: code,
                        title: product.localizedTitle(language),
                        minOrder: minOrder,
                        unit: unit,
                        strings: strings,
                      );
                    } else if (quantity > minOrder) {
                      setQuantity(quantity - 1);
                    }
                  },
                  onPlus: () {
                    if (canAddMore) setQuantity(quantity + 1);
                  },
                ),
                SizedBox(width: 10.0 * s),
                Expanded(
                  child: FilledButton(
                    onPressed: inCart == null ? putInCart : () => context.push('/cart'),
                    style: style(tokens.card, tokens.primaryGreen, border: tokens.primaryGreen),
                    child: label(inCart == null ? strings.addToCart : strings.viewCart),
                  ),
                ),
                SizedBox(width: 10.0 * s),
                Expanded(
                  child: FilledButton(
                    onPressed: buyNow,
                    style: style(tokens.primaryGreen, tokens.onPrimaryGreen),
                    child: label(strings.buyNow),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks a guest to sign in before buying. Returns true when they choose to sign in.
Future<bool?> _askSignIn(BuildContext context, AppStrings strings, VanRozgarColorTokens tokens, double s) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: tokens.card,
      title: Text(strings.buyNeedsSignIn, style: TextStyle(color: tokens.heading, fontWeight: FontWeight.w800)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(strings.notNow, style: TextStyle(color: tokens.mutedText)),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(backgroundColor: tokens.primaryGreen, foregroundColor: tokens.onPrimaryGreen),
          child: Text(strings.signInTitle),
        ),
      ],
    ),
  );
}