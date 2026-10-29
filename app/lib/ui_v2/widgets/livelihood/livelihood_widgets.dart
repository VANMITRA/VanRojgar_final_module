import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/livelihood/models/report.dart';
import '../../../../features/livelihood/models/scheme.dart';
import '../../../../features/livelihood/providers/detail_providers.dart';
import '../../l10n/livelihood_ui_strings.dart';
import '../community/community_widgets.dart';

/// Renders a trust / data source label with date and provider info.
class TrustLabelCard extends StatelessWidget {
  final TrustLabel trust;
  final LivelihoodUiStrings strings;

  const TrustLabelCard({
    super.key,
    required this.trust,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);

    return Container(
      padding: EdgeInsets.all(10.0 * s),
      decoration: BoxDecoration(
        color: tokens.chipBg,
        borderRadius: BorderRadius.circular(12.0 * s),
        border: Border.all(color: tokens.borders),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, size: 18.0 * s, color: tokens.primaryGreen),
          SizedBox(width: 8.0 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trust.source,
                  style: TextStyle(
                    fontSize: 12.5 * s,
                    fontWeight: FontWeight.w800,
                    color: tokens.heading,
                  ),
                ),
                SizedBox(height: 2.0 * s),
                Text(
                  trust.sourceDate,
                  style: TextStyle(fontSize: 11.5 * s, color: tokens.mutedText, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wildlife safety badge. NEVER suggests harm to wildlife.
class WildlifeRiskBadge extends StatelessWidget {
  final Wildlife risk;
  final LivelihoodUiStrings strings;

  const WildlifeRiskBadge({
    super.key,
    required this.risk,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);

    final bool isSafe = risk == Wildlife.low;
    final Color bg = isSafe ? tokens.primaryGreen.withValues(alpha: 0.15) : tokens.orange.withValues(alpha: 0.15);
    final Color fg = isSafe ? tokens.primaryGreen : tokens.orange;
    final String label = isSafe ? strings.lhWildlifeSafe : strings.lhWildlifeCaution;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0 * s, vertical: 3.0 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.0 * s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSafe ? Icons.eco_outlined : Icons.pets_outlined, size: 14.0 * s, color: fg),
          SizedBox(width: 5.0 * s),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 11.5 * s, fontWeight: FontWeight.w800, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reminder: Community forest is used only through the Gram Sabha.
class GramSabhaNoticeCard extends StatelessWidget {
  final LivelihoodUiStrings strings;

  const GramSabhaNoticeCard({super.key, required this.strings});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);

    return Container(
      padding: EdgeInsets.all(12.0 * s),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(12.0 * s),
        border: Border.all(color: tokens.borders),
      ),
      child: Row(
        children: [
          Icon(Icons.nature_people_outlined, size: 22.0 * s, color: tokens.primaryGreen),
          SizedBox(width: 10.0 * s),
          Expanded(
            child: Text(
              strings.lhGramSabhaOnly,
              style: TextStyle(fontSize: 13.0 * s, fontWeight: FontWeight.w700, color: tokens.heading),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card showing one livelihood idea with wildlife badge, tags, and navigation to details.
class IdeaCardWidget extends StatelessWidget {
  final IdeaCard idea;
  final LivelihoodUiStrings strings;
  final VoidCallback onTap;

  const IdeaCardWidget({
    super.key,
    required this.idea,
    required this.strings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final lang = strings.language.name;

    final String name = idea.name(lang);
    final String reason = strings.raw.reason(idea.reason);

    return Semantics(
      button: true,
      label: name,
      child: KeyedSubtree(
        key: Key('idea_card_${idea.code}'),
        child: CommunityCard(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 16.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                        height: 1.25,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 22.0 * s, color: tokens.mutedText),
                ],
              ),
              SizedBox(height: 8.0 * s),
              Wrap(
                spacing: 6.0 * s,
                runSpacing: 6.0 * s,
                children: [
                  WildlifeRiskBadge(risk: idea.wildlifeRisk, strings: strings),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.0 * s, vertical: 3.0 * s),
                    decoration: BoxDecoration(
                      color: tokens.chipBg,
                      borderRadius: BorderRadius.circular(8.0 * s),
                    ),
                    child: Text(
                      strings.lhIdeasDraftBadge,
                      style: TextStyle(fontSize: 11.0 * s, fontWeight: FontWeight.w700, color: tokens.chipText),
                    ),
                  ),
                ],
              ),
              if (reason.isNotEmpty) ...[
                SizedBox(height: 8.0 * s),
                Text(
                  reason,
                  style: TextStyle(fontSize: 13.5 * s, color: tokens.bodyText, height: 1.35),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Official government scheme card with link to official portal.
class SchemeCardWidget extends ConsumerWidget {
  final Scheme scheme;
  final LivelihoodUiStrings strings;

  const SchemeCardWidget({
    super.key,
    required this.scheme,
    required this.strings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final lang = strings.language.name;

    return KeyedSubtree(
      key: Key('scheme_card_${scheme.code}'),
      child: CommunityCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              scheme.name(lang),
              style: TextStyle(
                fontSize: 15.5 * s,
                fontWeight: FontWeight.w800,
                color: tokens.heading,
                height: 1.25,
              ),
            ),
            SizedBox(height: 4.0 * s),
            Text(
              scheme.runs(lang),
              style: TextStyle(fontSize: 12.5 * s, fontWeight: FontWeight.w600, color: tokens.mutedText),
            ),
            SizedBox(height: 8.0 * s),
            Text(
              scheme.what(lang),
              style: TextStyle(fontSize: 13.5 * s, color: tokens.bodyText, height: 1.35),
            ),
            if (scheme.officialUrl != null && scheme.officialUrl!.isNotEmpty) ...[
              SizedBox(height: 12.0 * s),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  key: Key('scheme_link_${scheme.code}'),
                  icon: Icon(Icons.open_in_new, size: 16.0 * s),
                  label: Text(strings.lhOpenSchemeLink),
                  onPressed: () {
                    final open = ref.read(urlOpenerProvider);
                    open(scheme.officialUrl!);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.primaryGreen,
                    side: BorderSide(color: tokens.primaryGreen),
                    minimumSize: Size(0, 48.0 * s),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Resource item card.
class ResourceCardWidget extends StatelessWidget {
  final ResourceItem item;
  final LivelihoodUiStrings strings;

  const ResourceCardWidget({
    super.key,
    required this.item,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final lang = strings.language.name;

    final String dist = '${(item.distanceM / 1000.0).toStringAsFixed(1)} km';
    final String name = item.name(lang);

    return KeyedSubtree(
      key: Key('resource_item_${item.id}'),
      child: CommunityCard(
        child: Row(
          children: [
            Container(
              width: 36.0 * s,
              height: 36.0 * s,
              decoration: BoxDecoration(
                color: tokens.chipBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.place_outlined, size: 20.0 * s, color: tokens.primaryGreen),
            ),
            SizedBox(width: 12.0 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : item.kind,
                    style: TextStyle(fontSize: 14.5 * s, fontWeight: FontWeight.w700, color: tokens.heading),
                  ),
                  SizedBox(height: 2.0 * s),
                  Text(
                    item.kind,
                    style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.0 * s),
            Text(
              dist,
              style: TextStyle(fontSize: 13.0 * s, fontWeight: FontWeight.w700, color: tokens.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
