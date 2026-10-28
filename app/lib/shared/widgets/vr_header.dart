import 'package:flutter/material.dart';
import 'vr_text.dart';
import '../../core/theme/tokens.dart';
import 'appearance_sheet.dart';

class VrHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final String activeLanguage;
  final ValueChanged<String>? onLanguageChanged;
  final bool isOnline;

  const VrHeader({
    super.key,
    this.title = 'VanMitra • वनमित्र',
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.activeLanguage = 'mr',
    this.onLanguageChanged,
    this.isOnline = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66.0);

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0C2B1C),
            Color(0xFF14462B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        bottom: 10,
        left: 14,
        right: 14,
      ),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Container(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.arrow_back, color: tokens.onBrand, size: 24),
              ),
            )
          else ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.forest, color: tokens.onBrand, size: 18),
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                VrText(
                  title,
                  style: TextStyle(
                    color: tokens.onBrand,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                VrText(
                  subtitle ?? 'nashik',
                  style: TextStyle(
                    color: tokens.onBrand.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Connection status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? tokens.success : tokens.error,
                  ),
                ),
                const SizedBox(width: 4),
                VrText(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(color: tokens.onBrand, fontSize: 9.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Language Selector Dropdown pill (video 00:06, 00:58)
          PopupMenuButton<String>(
            initialValue: activeLanguage,
            onSelected: onLanguageChanged,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'mr', child: VrText('मराठी (MR)')),
              const PopupMenuItem(value: 'en', child: VrText('English (EN)')),
              const PopupMenuItem(value: 'hi', child: VrText('हिंदी (HI)')),
              const PopupMenuItem(value: 'kn', child: VrText('कोंकणी (KN)')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VrText(
                    _formatLangLabel(activeLanguage),
                    style: TextStyle(color: tokens.onBrand, fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down, color: tokens.onBrand, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Appearance / Settings quick action
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.tune, color: tokens.onBrand, size: 20),
            tooltip: 'Appearance & Settings',
            onPressed: () => AppearanceSheet.show(context),
          ),
        ],
      ),
    );
  }

  String _formatLangLabel(String lang) {
    switch (lang) {
      case 'en': return 'EN';
      case 'hi': return 'हिंदी';
      case 'kn': return 'कों';
      default: return 'मराठी';
    }
  }
}
