import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/profile_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../../widgets/profile/profile_subpage_scaffold.dart';

/// Privacy page (`/privacy`).
/// Readable version of `docs/PRIVACY.md` with short titled sections.
class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    final sections = strings.pfPrivacySections;

    return ProfileSubpageScaffold(
      title: strings.pfPrivacyTitle,
      children: [
        for (int i = 0; i < sections.length; i++) ...[
          if (i > 0) SizedBox(height: 12.0 * s),
          Material(
            key: Key('privacy_section_$i'),
            color: tokens.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0 * s),
              side: BorderSide(color: tokens.borders, width: 1.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    sections[i].heading,
                    style: TextStyle(
                      fontSize: 15.5 * s,
                      fontWeight: FontWeight.w800,
                      color: tokens.heading,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6.0 * s),
                  Text(
                    sections[i].body,
                    style: TextStyle(
                      fontSize: 14.0 * s,
                      color: tokens.bodyText,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

