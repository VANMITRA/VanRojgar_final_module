import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/profile_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/profile_providers.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../../widgets/profile/profile_subpage_scaffold.dart';

/// Entry-point summary page for the older app features (`/more/:key`, where `key` is
/// `messages`, `barter`, `delivery`, or `livelihood`).
/// For an unknown key (such as `/more/xyz`), renders a friendly empty page without crashing.
class MoreFeaturePage extends ConsumerWidget {
  final String featureKey;

  const MoreFeaturePage({
    super.key,
    required this.featureKey,
  });

  static IconData _iconForKey(String key) {
    switch (key) {
      case 'messages':
        return Icons.notifications_none;
      case 'barter':
        return Icons.swap_horiz;
      case 'delivery':
        return Icons.two_wheeler;
      case 'livelihood':
        return Icons.agriculture_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    final isKnown = isKnownMoreFeatureKey(featureKey);
    final title = strings.pfMorePageTitle(featureKey);
    final sentences = strings.pfMorePageSentences(featureKey);

    if (!isKnown) {
      return ProfileSubpageScaffold(
        title: title,
        showDraftNotice: false,
        children: [
          Material(
            key: const Key('more_unknown_card'),
            color: tokens.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0 * s),
              side: BorderSide(color: tokens.borders, width: 1.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.0 * s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56.0 * s,
                    height: 56.0 * s,
                    decoration: BoxDecoration(
                      color: tokens.chipBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: 28.0 * s,
                      color: tokens.chipText,
                    ),
                  ),
                  SizedBox(height: 12.0 * s),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0 * s,
                      fontWeight: FontWeight.w800,
                      color: tokens.heading,
                    ),
                  ),
                  SizedBox(height: 8.0 * s),
                  Text(
                    strings.pfUnknownMoreBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0 * s,
                      color: tokens.bodyText,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16.0 * s),
                  OutlinedButton(
                    key: const Key('more_unknown_back_button'),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tokens.primaryGreen,
                      side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                      minimumSize: const Size(0, 48.0),
                      shape: const StadiumBorder(),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        strings.backLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ProfileSubpageScaffold(
      title: title,
      children: [
        Material(
          key: Key('more_feature_card_$featureKey'),
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
                    Container(
                      width: 48.0 * s,
                      height: 48.0 * s,
                      decoration: BoxDecoration(
                        color: tokens.chipBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconForKey(featureKey),
                        size: 24.0 * s,
                        color: tokens.chipText,
                      ),
                    ),
                    SizedBox(width: 12.0 * s),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18.0 * s,
                          fontWeight: FontWeight.w800,
                          color: tokens.heading,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0 * s),
                for (int i = 0; i < sentences.length; i++) ...[
                  if (i > 0) SizedBox(height: 10.0 * s),
                  Text(
                    sentences[i],
                    key: Key('more_${featureKey}_sentence_$i'),
                    style: TextStyle(
                      fontSize: 14.5 * s,
                      color: tokens.bodyText,
                      height: 1.45,
                    ),
                  ),
                ],
                SizedBox(height: 16.0 * s),
                Divider(height: 1.0, color: tokens.borders),
                SizedBox(height: 12.0 * s),
                Row(
                  children: [
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 16.0 * s,
                      color: tokens.mutedText,
                    ),
                    SizedBox(width: 6.0 * s),
                    Expanded(
                      child: Text(
                        strings.pfOpensInFullApp,
                        key: const Key('more_opens_in_full_app'),
                        style: TextStyle(
                          fontSize: 13.0 * s,
                          fontWeight: FontWeight.w600,
                          color: tokens.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

