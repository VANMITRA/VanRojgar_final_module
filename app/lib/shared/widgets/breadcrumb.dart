import 'package:flutter/material.dart';
import 'vr_text.dart';
import '../../core/theme/tokens.dart';

class Breadcrumb extends StatelessWidget {
  final List<String> segments;

  const Breadcrumb({
    super.key,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    return Container(
      height: 36,
      width: double.infinity,
      color: tokens.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          for (int i = 0; i < segments.length; i++) ...[
            VrText(
              segments[i],
              style: TextStyle(
                color: (i == segments.length - 1) ? tokens.textPrimary : tokens.textMuted,
                fontSize: 12.5,
                fontWeight: (i == segments.length - 1) ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (i < segments.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: VrText('›', style: TextStyle(color: tokens.textMuted, fontSize: 13)),
              ),
          ],
        ],
      ),
    );
  }
}
