import 'package:flutter/material.dart';
import 'vr_text.dart';
import '../../core/theme/tokens.dart';
import '../models/user.dart';

class ProfileHero extends StatelessWidget {
  final UserModel user;

  const ProfileHero({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'V';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.brandPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Orange circle avatar with initial
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: tokens.actionPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: VrText(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: VrText(
                        user.role.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: tokens.onBrand,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                VrText(
                  user.name,
                  style: TextStyle(
                    color: tokens.onBrand,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: tokens.onBrand.withValues(alpha: 0.7)),
                    const SizedBox(width: 2),
                    VrText(
                      '${user.village ?? user.city ?? 'Nashik'}, ${user.taluka ?? 'Maharashtra'}',
                      style: TextStyle(
                        color: tokens.onBrand.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
