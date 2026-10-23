import 'package:flutter/material.dart';
import '../../core/localization/app_input_hints.dart';
import '../../core/theme/tokens.dart';

class SearchPill extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onFilterTap;
  final bool readOnly;
  final VoidCallback? onTap;

  const SearchPill({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final effectiveHint = hintText ?? AppInputHints.searchForest(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: tokens.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search, color: tokens.textMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted?.call(),
              decoration: InputDecoration(
                hintText: effectiveHint,
                hintStyle: TextStyle(color: tokens.textMuted, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            Container(
              height: 24,
              width: 1,
              color: tokens.outline,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
            IconButton(
              icon: Icon(Icons.tune, color: tokens.brandSecondary, size: 20),
              onPressed: onFilterTap,
              tooltip: 'Filters',
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
