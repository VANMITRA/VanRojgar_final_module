import 'package:flutter/material.dart';
import 'vr_text.dart';
import '../../core/theme/tokens.dart';

class StatusCountChips extends StatelessWidget {
  final int approvedCount;
  final int pendingCount;
  final int rejectedCount;
  final int totalCount;
  final int? counteredCount;
  final String? activeFilter;
  final ValueChanged<String?>? onSelect;

  const StatusCountChips({
    super.key,
    required this.approvedCount,
    required this.pendingCount,
    required this.rejectedCount,
    required this.totalCount,
    this.counteredCount,
    this.activeFilter,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    Widget buildChip({
      required String label,
      required String? value,
      required Color textColor,
      required Color bgColor,
      required IconData icon,
    }) {
      final isSelected = activeFilter == value;

      return GestureDetector(
        onTap: () => onSelect?.call(isSelected ? null : value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? textColor.withValues(alpha: 0.25) : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? textColor : textColor.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
              VrText(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            buildChip(
              label: '$totalCount Total',
              value: null,
              textColor: tokens.textPrimary,
              bgColor: tokens.surface,
              icon: Icons.list_alt,
            ),
            const SizedBox(width: 8),
            buildChip(
              label: '$approvedCount Approved',
              value: 'approved',
              textColor: tokens.success,
              bgColor: tokens.chipSuccessBg,
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(width: 8),
            buildChip(
              label: '$pendingCount Pending',
              value: 'pending',
              textColor: tokens.warning,
              bgColor: tokens.chipWarningBg,
              icon: Icons.access_time,
            ),
            const SizedBox(width: 8),
            buildChip(
              label: '$rejectedCount Rejected',
              value: 'rejected',
              textColor: tokens.error,
              bgColor: tokens.chipErrorBg,
              icon: Icons.cancel_outlined,
            ),
            if (counteredCount != null) ...[
              const SizedBox(width: 8),
              buildChip(
                label: '$counteredCount Counter',
                value: 'countered',
                textColor: const Color(0xFF2F5FB3),
                bgColor: const Color(0xFF2F5FB3).withValues(alpha: 0.12),
                icon: Icons.swap_horiz,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
