import 'package:flutter/material.dart';
import '../theme/van_rozgar_tokens.dart';

/// The green "- 5 +" quantity stepper shared by the product card, the Product page and the Cart page.
/// Fixed-size tap areas (an IconButton insists on 48 dp, which does not fit in this pill).
class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final double scale;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final s = scale;

    return Container(
      width: 96.0 * s,
      height: 34.0 * s,
      decoration: BoxDecoration(
        color: tokens.primaryGreen,
        borderRadius: BorderRadius.circular(10.0 * s),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: '-',
            child: InkWell(
              onTap: onMinus,
              child: SizedBox(
                width: 30.0 * s,
                height: double.infinity,
                child: Icon(Icons.remove, size: 16.0 * s, color: tokens.onPrimaryGreen),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '$quantity',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.0 * s,
                  fontWeight: FontWeight.w800,
                  color: tokens.onPrimaryGreen,
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: '+',
            child: InkWell(
              onTap: onPlus,
              child: SizedBox(
                width: 30.0 * s,
                height: double.infinity,
                child: Icon(Icons.add, size: 16.0 * s, color: tokens.onPrimaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
