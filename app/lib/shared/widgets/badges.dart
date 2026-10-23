import 'package:flutter/material.dart';
import 'vr_text.dart';
import '../../core/theme/tokens.dart';

class TrustTag extends StatelessWidget {
  final String status;

  const TrustTag({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (status == 'verified') {
      bg = tokens.chipSuccessBg;
      fg = tokens.brandSecondary;
      label = 'Verified';
      icon = Icons.verified;
    } else if (status == 'verified_seed') {
      bg = tokens.chipDefaultBg;
      fg = tokens.brandSecondary;
      label = 'Demo Data';
      icon = Icons.science_outlined;
    } else if (status == 'rejected') {
      bg = tokens.chipErrorBg;
      fg = tokens.error;
      label = 'Rejected';
      icon = Icons.cancel;
    } else {
      bg = tokens.chipWarningBg;
      fg = tokens.warning;
      label = 'Pending';
      icon = Icons.hourglass_top;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 3),
          VrText(
            label,
            style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class ModeBadge extends StatelessWidget {
  final String mode;

  const ModeBadge({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    String label;
    Color color;

    if (mode == 'barter') {
      label = 'Barter';
      color = const Color(0xFF6B46C1);
    } else if (mode == 'both') {
      label = 'Buy & Barter';
      color = tokens.actionPrimary;
    } else {
      label = 'Buy';
      color = tokens.brandSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: VrText(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class RightsBadge extends StatelessWidget {
  final String clause;

  const RightsBadge({super.key, required this.clause});

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    String label = clause;
    if (clause.contains('3(1)(c)')) label = 'MFP 3(1)(c)';
    if (clause.contains('3(1)(d)')) label = 'Water/Grazing 3(1)(d)';
    if (clause.contains('3(1)(i)')) label = 'CFR Protect 3(1)(i)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tokens.brandPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 12, color: tokens.brandPrimary),
          const SizedBox(width: 4),
          VrText(
            label,
            style: TextStyle(color: tokens.brandPrimary, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class DemoDataChip extends StatelessWidget {
  const DemoDataChip({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tokens.textMuted.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: VrText(
        'Demo data',
        style: TextStyle(color: tokens.textMuted, fontSize: 9, fontWeight: FontWeight.w600),
      ),
    );
  }
}
