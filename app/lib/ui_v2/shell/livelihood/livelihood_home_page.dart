import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/livelihood/providers/profile_providers.dart';
import '../../l10n/livelihood_ui_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/profile_providers.dart';
import '../../widgets/community/community_widgets.dart';
import '../../widgets/livelihood/livelihood_widgets.dart';

/// `/livelihood`: Home of the Livelihood module.
class LivelihoodHomePage extends ConsumerStatefulWidget {
  const LivelihoodHomePage({super.key});

  @override
  ConsumerState<LivelihoodHomePage> createState() => _LivelihoodHomePageState();
}

class _LivelihoodHomePageState extends ConsumerState<LivelihoodHomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = LivelihoodUiStrings.of(context, language);
    final user = ref.watch(authUserProvider);

    // 1. Guest check
    if (user == null) {
      return CommunityPage(
        title: strings.lhTitle,
        body: CommunityCentered(
          child: CommunityGuestCard(
            icon: Icons.agriculture_outlined,
            body: strings.lhGuestBody,
          ),
        ),
      );
    }

    // 2. Role check (CFR holder only)
    if (!isCfrHolderRole(user.role)) {
      return CommunityPage(
        title: strings.lhTitle,
        body: CommunityCentered(
          child: KeyedSubtree(
            key: const Key('lh_not_cfr'),
            child: CommunityMessageCard(
              icon: Icons.agriculture_outlined,
              title: strings.lhNotCfrTitle,
              body: strings.lhNotCfrBody,
            ),
          ),
        ),
      );
    }

    // 3. CFR holder content
    final profile = ref.watch(profileProvider);
    final bool hasDetails = profile?.hasDetails ?? false;

    return CommunityPage(
      title: strings.lhTitle,
      body: CommunityScroll(
        scrollKey: const Key('lh_home_scroll'),
        children: [
          // Hero card
          KeyedSubtree(
            key: const Key('lh_home_hero'),
            child: CommunityCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44.0 * s,
                        height: 44.0 * s,
                        decoration: BoxDecoration(
                          color: tokens.primaryGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.forest_outlined, size: 24.0 * s, color: tokens.primaryGreen),
                      ),
                      SizedBox(width: 12.0 * s),
                      Expanded(
                        child: Text(
                          user.name.isNotEmpty ? user.name : strings.lhTitle,
                          style: TextStyle(
                            fontSize: 17.0 * s,
                            fontWeight: FontWeight.w800,
                            color: tokens.heading,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0 * s),
                  Text(
                    hasDetails ? strings.lhDetailsSaved : strings.lhNoDetailsYet,
                    style: TextStyle(fontSize: 13.5 * s, color: tokens.bodyText, height: 1.35),
                  ),
                  SizedBox(height: 16.0 * s),
                  if (!hasDetails) ...[
                    CommunityPrimaryButton(
                      key: const Key('lh_home_create_btn'),
                      label: strings.lhCreateReport,
                      onPressed: () => context.push('/livelihood/details'),
                    ),
                  ] else ...[
                    CommunityPrimaryButton(
                      key: const Key('lh_home_view_btn'),
                      label: strings.lhViewReport,
                      onPressed: () => context.push('/livelihood/report'),
                    ),
                    SizedBox(height: 10.0 * s),
                    CommunitySecondaryButton(
                      key: const Key('lh_home_edit_btn'),
                      label: strings.lhUpdateDetails,
                      onPressed: () => context.push('/livelihood/details'),
                    ),
                    SizedBox(height: 10.0 * s),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        key: const Key('lh_home_delete_btn'),
                        icon: Icon(Icons.delete_outline, size: 18.0 * s, color: tokens.mutedText),
                        label: Text(strings.lhDeleteAnswers, style: TextStyle(color: tokens.mutedText)),
                        onPressed: () async {
                          final ok = await showCommunityConfirm(
                            context,
                            title: strings.lhDeleteConfirmTitle,
                            body: strings.lhDeleteConfirmBody,
                            confirmLabel: strings.lhDeleteConfirmOk,
                            cancelLabel: strings.lhCancel,
                          );
                          if (ok && context.mounted) {
                            await ref.read(profileProvider.notifier).delete();
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0 * s),

          // Community forest reminder
          GramSabhaNoticeCard(strings: strings),
          SizedBox(height: 20.0 * s),

          // Hub section
          Text(
            strings.lhHubSection,
            style: TextStyle(fontSize: 16.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
          ),
          SizedBox(height: 10.0 * s),

          _HubRow(
            rowKey: const Key('lh_home_schemes'),
            icon: Icons.account_balance_outlined,
            title: strings.lhHubSchemes,
            subtitle: strings.lhHubSchemesSub,
            onTap: () => context.push('/livelihood/schemes'),
          ),
          SizedBox(height: 8.0 * s),
          _HubRow(
            rowKey: const Key('lh_home_resources'),
            icon: Icons.place_outlined,
            title: strings.lhHubResources,
            subtitle: strings.lhHubResourcesSub,
            onTap: () => context.push('/livelihood/resources'),
          ),
          SizedBox(height: 8.0 * s),
          _HubRow(
            rowKey: const Key('lh_home_map'),
            icon: Icons.map_outlined,
            title: strings.lhHubMap,
            subtitle: strings.lhHubMapSub,
            onTap: () => context.push('/livelihood/map'),
          ),
          SizedBox(height: 8.0 * s),
          _HubRow(
            rowKey: const Key('lh_home_policy'),
            icon: Icons.pets_outlined,
            title: strings.lhHubPolicy,
            subtitle: strings.lhHubPolicySub,
            onTap: () => context.push('/livelihood/policy'),
          ),
        ],
      ),
    );
  }
}

class _HubRow extends StatelessWidget {
  final Key rowKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubRow({
    required this.rowKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);

    return Semantics(
      button: true,
      label: '$title: $subtitle',
      child: KeyedSubtree(
        key: rowKey,
        child: CommunityCard(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 36.0 * s,
                height: 36.0 * s,
                decoration: BoxDecoration(color: tokens.chipBg, shape: BoxShape.circle),
                child: Icon(icon, size: 20.0 * s, color: tokens.primaryGreen),
              ),
              SizedBox(width: 12.0 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 14.5 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                    ),
                    SizedBox(height: 2.0 * s),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText, height: 1.25),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 22.0 * s, color: tokens.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}

