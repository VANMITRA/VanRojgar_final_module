import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/tokens.dart';

/// The item code of a listing (`VR-K7M2QX`) with a copy button. It is the same code the website shows,
/// and typing it into the search finds this listing.
class ItemCodeChip extends StatelessWidget {
  final String code;

  const ItemCodeChip({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_2, size: 18, color: tokens.textMuted),
          const SizedBox(width: 8),
          Text(
            'Item code • वस्तू कोड',
            style: TextStyle(color: tokens.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 10),
          SelectableText(
            code,
            key: const Key('item-code-text'),
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          IconButton(
            key: const Key('item-code-copy'),
            tooltip: 'Copy',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied $code')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
