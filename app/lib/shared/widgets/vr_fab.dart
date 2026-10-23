import 'package:flutter/material.dart';
import 'vr_text.dart';
import '../../core/theme/tokens.dart';

class VrFab extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const VrFab({
    super.key,
    required this.label,
    this.icon = Icons.add,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: tokens.actionPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: Icon(icon, size: 20),
      label: VrText(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}
