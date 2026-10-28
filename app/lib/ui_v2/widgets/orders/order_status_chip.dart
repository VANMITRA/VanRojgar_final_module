import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/orders_strings.dart';
import '../../models/order_models.dart';
import '../../theme/van_rozgar_tokens.dart';

/// Status chip displaying plain-language order/request status in English, Hindi, or Marathi.
/// Uses only theme color tokens (`primaryGreen`, `chipBg`, `outlinedControl`, `borders`).
class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  final AppLanguage language;
  final double scale;

  const OrderStatusChip({
    super.key,
    required this.status,
    required this.language,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(language);
    final s = scale;

    final (Color bg, Color fg, Color? borderColor) = switch (status) {
      OrderStatus.approved ||
      OrderStatus.paymentConfirmed ||
      OrderStatus.completed =>
        (tokens.primaryGreen, tokens.onPrimaryGreen, null),
      OrderStatus.pending ||
      OrderStatus.countered ||
      OrderStatus.paymentReported =>
        (tokens.chipBg, tokens.chipText, null),
      OrderStatus.rejected ||
      OrderStatus.cancelled =>
        (tokens.page, tokens.mutedText, tokens.borders),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0 * s, vertical: 4.0 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.0),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Text(
        strings.odStatusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5 * s,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

