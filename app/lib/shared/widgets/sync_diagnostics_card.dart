import 'package:flutter/material.dart';
import 'vr_text.dart';
import '../../core/theme/tokens.dart';

class SyncDiagnosticsCard extends StatelessWidget {
  const SyncDiagnosticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162E20) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2EBE5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_sync_outlined, color: tokens.brandSecondary, size: 20),
                  const SizedBox(width: 8),
                  VrText(
                    'Offline Queue • ऑफलाइन रांग',
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tokens.chipSuccessBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: VrText(
                  'Synced',
                  style: TextStyle(
                    color: tokens.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          VrText(
            'Offline queue is planned (phase F4). Data currently synchronizes directly with the server.',
            style: TextStyle(
              color: tokens.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.sync, size: 16),
              label: const VrText('Sync now • आता समक्रमित करा', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.actionPrimary.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: null, // Disabled as per U7 instruction
            ),
          ),
        ],
      ),
    );
  }
}
