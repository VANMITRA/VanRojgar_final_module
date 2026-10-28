import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../l10n/shop_extra_strings.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import 'quantity_stepper.dart';

/// The ADD button on the Category page opens this sheet: it shows the seller's minimum order,
/// lets the buyer choose the quantity (starting at the minimum) and adds it to the cart.
Future<void> showQuantityPickerSheet(
  BuildContext context, {
  required ShopProduct product,
  required AppLanguage language,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _QuantityPickerSheet(product: product, language: language),
  );
}

class _QuantityPickerSheet extends ConsumerStatefulWidget {
  final ShopProduct product;
  final AppLanguage language;

  const _QuantityPickerSheet({required this.product, required this.language});

  @override
  ConsumerState<_QuantityPickerSheet> createState() => _QuantityPickerSheetState();
}

class _QuantityPickerSheetState extends ConsumerState<_QuantityPickerSheet> {
  late int _quantity = widget.product.cheapestListing?.minOrderQuantity ?? 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(widget.language);
    final product = widget.product;
    final unit = product.localizedUnit(widget.language);
    final minOrder = product.cheapestListing?.minOrderQuantity ?? 1;
    final maxQty = product.cheapestListing?.quantityAvailable ?? 9999;
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);
    final total = product.startingAtPaise * _quantity;

    return SafeArea(
      top: false,
      child: Material(
        key: const Key('quantity_picker'),
        color: tokens.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0 * s)),
          side: BorderSide(color: tokens.borders),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0 * s, 12.0 * s, 20.0 * s, 20.0 * s),
          child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.0 * s,
                  height: 4.0 * s,
                  decoration: BoxDecoration(
                    color: tokens.borders,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              SizedBox(height: 14.0 * s),
              Text(
                strings.pickerTitle,
                style: TextStyle(
                  fontSize: 18.0 * s,
                  fontWeight: FontWeight.w800,
                  color: tokens.heading,
                ),
              ),
              SizedBox(height: 12.0 * s),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0 * s),
                    child: Container(
                      width: 56.0 * s,
                      height: 56.0 * s,
                      color: VanRozgarTokens.picturePanel,
                      child: Image.asset(
                        product.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.eco_outlined, color: tokens.primaryGreen.withValues(alpha: 0.6)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.0 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.localizedTitle(widget.language),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.0 * s,
                            fontWeight: FontWeight.w700,
                            color: tokens.heading,
                          ),
                        ),
                        SizedBox(height: 2.0 * s),
                        Text(
                          '${formatRupees(product.startingAtPaise)} ${strings.perUnit(unit)}',
                          style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText),
                        ),
                        Text(
                          strings.minOrderText(minOrder, unit),
                          style: TextStyle(
                            fontSize: 12.5 * s,
                            fontWeight: FontWeight.w600,
                            color: tokens.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0 * s),
              Row(
                children: [
                  // "-" stops at the minimum (nothing is in the cart yet, so there is nothing to remove)
                  QuantityStepper(
                    quantity: _quantity,
                    scale: s,
                    onMinus: () {
                      if (_quantity > minOrder) setState(() => _quantity--);
                    },
                    onPlus: () {
                      if (_quantity < maxQty) setState(() => _quantity++);
                    },
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        strings.pickerTotal(formatRupees(total)),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 17.0 * s,
                          fontWeight: FontWeight.w800,
                          color: tokens.orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0 * s),
              FilledButton(
                key: const Key('quantity_picker_add'),
                onPressed: () {
                  ref.read(cartQuantitiesProvider.notifier).add(product.productCode, _quantity);
                  ref.read(lastAddedImageProvider.notifier).state = product.imageAsset;
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.primaryGreen,
                  foregroundColor: tokens.onPrimaryGreen,
                  minimumSize: Size(0, 52.0 * s),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0 * s)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    strings.addToCart,
                    maxLines: 1,
                    style: TextStyle(fontSize: 16.0 * s, fontWeight: FontWeight.w800),
                  ),
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
