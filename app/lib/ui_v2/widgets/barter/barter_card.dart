import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/community_strings.dart';
import '../../models/community_models.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../community/community_widgets.dart';

/// Card showing one barter offer inside the `/barter` lists.
class BarterCard extends StatelessWidget {
  final BarterOffer offer;
  final AppStrings strings;
  final VoidCallback onTap;

  const BarterCard({
    super.key,
    required this.offer,
    required this.strings,
    required this.onTap,
  });

  Color _statusBg(String status, VanRozgarColorTokens tokens) {
    switch (status) {
      case 'accepted':
        return tokens.primaryGreen.withValues(alpha: 0.15);
      case 'rejected':
        return tokens.mutedText.withValues(alpha: 0.15);
      case 'countered':
        return tokens.orange.withValues(alpha: 0.15);
      default:
        return tokens.chipBg;
    }
  }

  Color _statusFg(String status, VanRozgarColorTokens tokens) {
    switch (status) {
      case 'accepted':
        return tokens.primaryGreen;
      case 'rejected':
        return tokens.mutedText;
      case 'countered':
        return tokens.orange;
      default:
        return tokens.chipText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);

    final statusText = strings.btStatusLabel(offer.status);
    final partyText = offer.isIncoming
        ? strings.btFromParty(offer.otherPartyName)
        : strings.btToParty(offer.otherPartyName);

    final wantedName = offer.wantedTitle.isNotEmpty ? offer.wantedTitle : strings.btOfferedItem;

    return Semantics(
      button: true,
      label: '${strings.btTitle}: ${offer.offeredTitle} -> $wantedName ($statusText)',
      child: KeyedSubtree(
        key: Key('barter_card_${offer.id}'),
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
                      partyText,
                      style: TextStyle(
                        fontSize: 13.0 * s,
                        fontWeight: FontWeight.w700,
                        color: tokens.mutedText,
                      ),
                    ),
                  ),
                  Container(
                    key: Key('barter_status_${offer.id}'),
                    padding: EdgeInsets.symmetric(horizontal: 8.0 * s, vertical: 3.0 * s),
                    decoration: BoxDecoration(
                      color: _statusBg(offer.status, tokens),
                      borderRadius: BorderRadius.circular(10.0 * s),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11.5 * s,
                        fontWeight: FontWeight.w800,
                        color: _statusFg(offer.status, tokens),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0 * s),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${strings.btOffered}: ',
                    style: TextStyle(fontSize: 13.0 * s, color: tokens.mutedText),
                  ),
                  Expanded(
                    child: Text(
                      '${offer.offeredTitle} (${strings.btQuantity(offer.offeredQuantity, offer.offeredUnit)})',
                      style: TextStyle(
                        fontSize: 14.5 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.0 * s),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${strings.btWanted}: ',
                    style: TextStyle(fontSize: 13.0 * s, color: tokens.mutedText),
                  ),
                  Expanded(
                    child: Text(
                      '$wantedName (${strings.btQuantity(offer.wantedQuantity, offer.wantedUnit)})',
                      style: TextStyle(
                        fontSize: 14.0 * s,
                        fontWeight: FontWeight.w600,
                        color: tokens.bodyText,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0 * s),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      communityDate(offer.createdAt),
                      style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20.0 * s, color: tokens.mutedText),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

