import 'dart:ui';
import 'vr_text.dart';
import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';

class UserHeroCard extends StatelessWidget {
  final String name;
  final String role;
  final String location;
  final VoidCallback? onSync;
  final bool isSyncing;

  const UserHeroCard({
    super.key,
    required this.name,
    required this.role,
    required this.location,
    this.onSync,
    this.isSyncing = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'V';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              // Translucent frosted glass matching reference Image 2
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Vibrant Orange Avatar circle matching reference Image 2
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF9233),
                        Color(0xFFE86B17),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8D20).withValues(alpha: 0.40),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: VrText(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: VrText(
                              '${l10n?.hello ?? "Hello"}, $name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Green glass role pill matching reference Image 2
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0x334CAF50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0x6681C784),
                              ),
                            ),
                            child: VrText(
                              role,
                              style: const TextStyle(
                                color: Color(0xFFA5D6A7),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Color(0xFFFFA726),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: VrText(
                              location,
                              style: const TextStyle(
                                color: Color(0xFFD4E6DC),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Frosted round sync action button matching reference Image 2
                if (onSync != null)
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: isSyncing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.sync,
                              color: Color(0xFFD4E6DC),
                              size: 20,
                            ),
                      tooltip: 'Sync Data',
                      onPressed: isSyncing ? null : onSync,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
