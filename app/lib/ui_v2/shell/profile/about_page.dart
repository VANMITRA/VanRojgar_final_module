import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/profile_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/profile/profile_subpage_scaffold.dart';

/// About VanMitra page (`/about`).
/// Presents 5 short plain sentences describing VanMitra from the project documentation.
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    final sentences = strings.pfAboutSentences;

    return ProfileSubpageScaffold(
      title: strings.pfAboutTitle,
      children: [
        Material(
          key: const Key('about_card'),
          color: tokens.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0 * s),
            side: BorderSide(color: tokens.borders, width: 1.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(18.0 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    BrandLogo(size: 44.0 * s),
                    SizedBox(width: 12.0 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.appNameNative,
                            style: TextStyle(
                              fontSize: 20.0 * s,
                              fontWeight: FontWeight.w800,
                              color: tokens.heading,
                            ),
                          ),
                          SizedBox(height: 2.0 * s),
                          Text(
                            strings.tagline,
                            style: TextStyle(
                              fontSize: 13.0 * s,
                              color: tokens.mutedText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0 * s),
                Divider(height: 1.0, color: tokens.borders),
                SizedBox(height: 16.0 * s),
                for (int i = 0; i < sentences.length; i++) ...[
                  if (i > 0) SizedBox(height: 12.0 * s),
                  Text(
                    sentences[i],
                    key: Key('about_sentence_$i'),
                    style: TextStyle(
                      fontSize: 14.5 * s,
                      color: tokens.bodyText,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

