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

/// Simple full-screen cart opened from the floating "View cart" pill.
/// It lists what was added, with a quantity stepper per line. Totals and checkout come in a later phase.
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
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.0 * s, 8.0 * s, 16.0 * s, 24.0 * s),
                      itemCount: lines.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12.0 * s),
                      itemBuilder: (context, index) =>
                          _CartLineCard(line: lines[index], language: language, tokens: tokens, s: s),
                    ),
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
              Icon(Icons.eco_outlined, size: 40.0 * s, color: tokens.primaryGreen.withValues(alpha: 0.7)),
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
    final minOrder = product.cheapestListing?.minOrderQuantity ?? 1;

    return Container(
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0 * s, vertical: 3.0 * s),
                  decoration: BoxDecoration(
                    color: tokens.chipBg,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(
                    strings.sampleBadge,
                    style: TextStyle(
                      fontSize: 10.0 * s,
                      fontWeight: FontWeight.w700,
                      color: tokens.chipText,
                    ),
                  ),
                ),
                SizedBox(height: 10.0 * s),
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
                      onPlus: () => ref.read(cartQuantitiesProvider.notifier).increment(product.productCode),
                    ),
                    const Spacer(),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatRupees(line.lineTotalPaise),
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
