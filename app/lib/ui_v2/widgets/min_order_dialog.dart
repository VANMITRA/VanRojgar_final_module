import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../l10n/shop_extra_strings.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';

/// Handles the "-" button of a quantity stepper.
///
/// Above the seller's minimum order the quantity just goes down by 1. AT the minimum, the item is NOT
/// removed silently: a message explains the minimum order and the buyer chooses "Keep in cart" or
/// "Remove".
Future<void> decrementWithMinOrderCheck(
  BuildContext context,
  WidgetRef ref, {
  required String productCode,
  required String title,
  required int minOrder,
  required String unit,
  required AppStrings strings,
}) async {
  final notifier = ref.read(cartQuantitiesProvider.notifier);
  final current = ref.read(cartQuantitiesProvider)[productCode] ?? 0;
  if (current > minOrder) {
    notifier.decrement(productCode, minOrder);
    return;
  }

  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final tokens = theme.extension<VanRozgarColorTokens>() ??
      (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);

  final remove = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      key: const Key('min_order_dialog'),
      title: Text(
        strings.minOrderDialogTitle,
        style: TextStyle(fontWeight: FontWeight.w800, color: tokens.heading),
      ),
      content: Text(
        strings.minOrderDialogBody(title, minOrder, unit),
        style: TextStyle(color: tokens.bodyText, height: 1.4),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowAlignment: OverflowBarAlignment.end,
      actions: [
        TextButton(
          key: const Key('min_order_remove'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          child: Text(
            strings.removeFromCart,
            style: TextStyle(fontWeight: FontWeight.w700, color: tokens.mutedText),
          ),
        ),
        FilledButton(
          key: const Key('min_order_keep'),
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: FilledButton.styleFrom(
            backgroundColor: tokens.primaryGreen,
            foregroundColor: tokens.onPrimaryGreen,
            minimumSize: const Size(48, 48),
          ),
          child: Text(strings.keepInCart, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );

  if (remove == true) {
    notifier.remove(productCode);
  }
}
