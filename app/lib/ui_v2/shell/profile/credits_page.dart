import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/profile_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../../widgets/profile/profile_subpage_scaffold.dart';

/// Credits page (`/credits`).
/// Readable version of `CREDITS.md` grouped by section, with each row shown as a card.
class CreditsPage extends ConsumerWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    final groups = strings.pfCreditGroups;

    return ProfileSubpageScaffold(
      title: strings.pfCreditsTitle,
      children: [
        for (int g = 0; g < groups.length; g++) ...[
          if (g > 0) SizedBox(height: 18.0 * s),
          Padding(
            padding: EdgeInsets.only(left: 4.0 * s, bottom: 8.0 * s),
            child: Text(
              groups[g].heading,
              key: Key('credits_group_heading_$g'),
              style: TextStyle(
                fontSize: 16.5 * s,
                fontWeight: FontWeight.w800,
                color: tokens.heading,
              ),
            ),
          ),
          for (int i = 0; i < groups[g].items.length; i++) ...[
            if (i > 0) SizedBox(height: 10.0 * s),
            _CreditCard(
              cardKey: Key('credit_card_${g}_$i'),
              item: groups[g].items[i],
              strings: strings,
              tokens: tokens,
              scale: s,
            ),
          ],
        ],
      ],
    );
  }
}

class _CreditCard extends StatelessWidget {
  final Key cardKey;
  final ProfileCreditItem item;
  final AppStrings strings;
  final VanRozgarColorTokens tokens;
  final double scale;

  const _CreditCard({
    required this.cardKey,
    required this.item,
    required this.strings,
    required this.tokens,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Material(
      key: cardKey,
      color: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0 * s),
        side: BorderSide(color: tokens.borders, width: 1.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.0 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.what,
              style: TextStyle(
                fontSize: 14.5 * s,
                fontWeight: FontWeight.w800,
                color: tokens.heading,
                height: 1.3,
              ),
            ),
            SizedBox(height: 8.0 * s),
            Text(
              '${strings.pfCreditsSourceLabel}: ${item.source}',
              style: TextStyle(
                fontSize: 13.5 * s,
                color: tokens.bodyText,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            SizedBox(height: 4.0 * s),
            Text(
              '${strings.pfCreditsTermsLabel}: ${item.terms}',
              style: TextStyle(
                fontSize: 13.0 * s,
                color: tokens.mutedText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

