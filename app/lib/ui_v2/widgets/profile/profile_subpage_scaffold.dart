import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/profile_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../app_background.dart';

/// Shared full-screen frame for `/about`, `/credits`, and `/privacy`.
/// Includes `AppBackground`, a top bar with a 48x48 back button, a muted draft-translation
/// banner in Hindi and Marathi modes, and a scrollable content area that works with large fonts.
class ProfileSubpageScaffold extends ConsumerWidget {
  final String title;
  final List<Widget> children;
  final bool showDraftNotice;

  const ProfileSubpageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.showDraftNotice = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    void goBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/profile');
      }
    }

    final draftText = strings.pfDraftNotice;

    return Scaffold(
      body: AppBackground(
        categorySlug: 'forest-produce',
        useSafeArea: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.0 * s, 4.0 * s, 16.0 * s, 4.0 * s),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: strings.backLabel,
                    child: IconButton(
                      key: const Key('profile_subpage_back'),
                      tooltip: strings.backLabel,
                      constraints: const BoxConstraints(
                        minWidth: 48.0,
                        minHeight: 48.0,
                      ),
                      onPressed: goBack,
                      icon: Icon(Icons.arrow_back, color: tokens.heading),
                    ),
                  ),
                  SizedBox(width: 4.0 * s),
                  Expanded(
                    child: Text(
                      title,
                      key: const Key('profile_subpage_title'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16.0 * s,
                  8.0 * s,
                  16.0 * s,
                  28.0 * s,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDraftNotice && draftText.isNotEmpty) ...[
                          Container(
                            key: const Key('profile_draft_notice'),
                            padding: EdgeInsets.all(12.0 * s),
                            decoration: BoxDecoration(
                              color: tokens.chipBg,
                              borderRadius: BorderRadius.circular(12.0 * s),
                              border: Border.all(color: tokens.borders),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.translate_rounded,
                                  size: 18.0 * s,
                                  color: tokens.chipText,
                                ),
                                SizedBox(width: 8.0 * s),
                                Expanded(
                                  child: Text(
                                    draftText,
                                    style: TextStyle(
                                      fontSize: 12.5 * s,
                                      color: tokens.mutedText,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.0 * s),
                        ],
                        ...children,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable navigable row (48 dp or taller) with a leading icon, title, and trailing chevron.
/// Must be placed inside a `Material` card so its `InkWell` ripple renders properly.
class ProfileMenuRow extends StatelessWidget {
  final Key rowKey;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final VanRozgarColorTokens tokens;
  final double scale;
  final Widget? trailing;

  const ProfileMenuRow({
    super.key,
    required this.rowKey,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.tokens,
    required this.scale,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        key: rowKey,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52.0),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14.0 * s,
              vertical: 10.0 * s,
            ),
            child: Row(
              children: [
                Container(
                  width: 36.0 * s,
                  height: 36.0 * s,
                  decoration: BoxDecoration(
                    color: tokens.chipBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 19.0 * s,
                    color: tokens.chipText,
                  ),
                ),
                SizedBox(width: 12.0 * s),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5 * s,
                      fontWeight: FontWeight.w700,
                      color: tokens.heading,
                      height: 1.25,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  trailing!,
                  SizedBox(width: 8.0 * s),
                ],
                Icon(
                  Icons.chevron_right,
                  size: 22.0 * s,
                  color: tokens.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

