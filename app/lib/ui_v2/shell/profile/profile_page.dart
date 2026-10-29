import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/profile_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/community_providers.dart';
import '../../../../features/livelihood/providers/profile_providers.dart' as lh_profile;
import '../../l10n/livelihood_ui_strings.dart';
import '../../widgets/community/community_widgets.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../../widgets/app_background.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/profile/profile_subpage_scaffold.dart';
import '../../widgets/profile_auth_card.dart';

/// Phase 9 Profile tab (`/profile`, inside the bottom-navigation shell).
///
/// Top to bottom in one scrolling page:
/// 1. Account card (guest sign-in or signed-in profile + sign-out with confirmation)
/// 2. Settings (Language: English / हिन्दी / मराठी, Appearance: System / Light / Dark)
/// 3. My activity (when signed in: My orders, plus Sell on VanMitra for Gram Sabha / CFR holder)
/// 4. More (About VanMitra, Credits, Privacy, and role-filtered older features)
/// 5. Footer (BrandLogo, VanMitra, Demo version)
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final themeMode = ref.watch(uiV2ThemeModeProvider);
    final strings = AppStrings.of(language);
    final user = ref.watch(authUserProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final activityKeys = visibleActivityKeys(user);
    final moreKeys = visibleMoreKeys(user);

    Widget sectionHeading(String text) => Padding(
          padding: EdgeInsets.only(left: 4.0 * s, bottom: 8.0 * s),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16.0 * s,
              fontWeight: FontWeight.w800,
              color: tokens.heading,
            ),
          ),
        );

    Widget cardContainer({required Widget child, EdgeInsetsGeometry? padding}) => Material(
          color: tokens.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0 * s),
            side: BorderSide(color: tokens.borders, width: 1.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: padding ?? EdgeInsets.all(16.0 * s),
            child: child,
          ),
        );

    return AppBackground(
      categorySlug: 'forest-produce',
      useSafeArea: true,
      child: SingleChildScrollView(
        key: const Key('profile_scroll_view'),
        padding: EdgeInsets.fromLTRB(
          16.0 * s,
          16.0 * s,
          16.0 * s,
          bottomInset + 28.0 * s + (cartCount > 0 ? 76.0 * s : 0.0),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.navProfile,
                  style: TextStyle(
                    fontSize: 24.0 * s,
                    fontWeight: FontWeight.w800,
                    color: tokens.heading,
                  ),
                ),
                SizedBox(height: 14.0 * s),

                // 1. Account card
                cardContainer(
                  child: const ProfileAuthCard(),
                ),
                SizedBox(height: 20.0 * s),

                // 2. Settings (Language & Appearance)
                sectionHeading(strings.pfSettingsSectionTitle),
                cardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        strings.languageLabel,
                        style: TextStyle(
                          fontSize: 14.0 * s,
                          fontWeight: FontWeight.w700,
                          color: tokens.heading,
                        ),
                      ),
                      SizedBox(height: 8.0 * s),
                      Wrap(
                        spacing: 8.0 * s,
                        runSpacing: 8.0 * s,
                        children: [
                          _ChoiceButton(
                            buttonKey: const Key('profile_lang_en'),
                            label: 'English',
                            selected: language == AppLanguage.en,
                            tokens: tokens,
                            scale: s,
                            onTap: () =>
                                ref.read(uiV2LanguageProvider.notifier).state = AppLanguage.en,
                          ),
                          _ChoiceButton(
                            buttonKey: const Key('profile_lang_hi'),
                            label: 'हिन्दी',
                            selected: language == AppLanguage.hi,
                            tokens: tokens,
                            scale: s,
                            onTap: () =>
                                ref.read(uiV2LanguageProvider.notifier).state = AppLanguage.hi,
                          ),
                          _ChoiceButton(
                            buttonKey: const Key('profile_lang_mr'),
                            label: 'मराठी',
                            selected: language == AppLanguage.mr,
                            tokens: tokens,
                            scale: s,
                            onTap: () =>
                                ref.read(uiV2LanguageProvider.notifier).state = AppLanguage.mr,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0 * s),
                      Divider(height: 1.0, color: tokens.borders),
                      SizedBox(height: 16.0 * s),
                      Text(
                        strings.pfAppearanceLabel,
                        style: TextStyle(
                          fontSize: 14.0 * s,
                          fontWeight: FontWeight.w700,
                          color: tokens.heading,
                        ),
                      ),
                      SizedBox(height: 8.0 * s),
                      Wrap(
                        spacing: 8.0 * s,
                        runSpacing: 8.0 * s,
                        children: [
                          _ChoiceButton(
                            buttonKey: const Key('profile_theme_system'),
                            label: strings.themeSystem,
                            icon: Icons.brightness_auto_outlined,
                            selected: themeMode == ThemeMode.system,
                            tokens: tokens,
                            scale: s,
                            onTap: () =>
                                ref.read(uiV2ThemeModeProvider.notifier).state = ThemeMode.system,
                          ),
                          _ChoiceButton(
                            buttonKey: const Key('profile_theme_light'),
                            label: strings.themeLight,
                            icon: Icons.light_mode_outlined,
                            selected: themeMode == ThemeMode.light,
                            tokens: tokens,
                            scale: s,
                            onTap: () =>
                                ref.read(uiV2ThemeModeProvider.notifier).state = ThemeMode.light,
                          ),
                          _ChoiceButton(
                            buttonKey: const Key('profile_theme_dark'),
                            label: strings.themeDark,
                            icon: Icons.dark_mode_outlined,
                            selected: themeMode == ThemeMode.dark,
                            tokens: tokens,
                            scale: s,
                            onTap: () =>
                                ref.read(uiV2ThemeModeProvider.notifier).state = ThemeMode.dark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. My activity (only when signed in)
                if (activityKeys.isNotEmpty) ...[
                  SizedBox(height: 20.0 * s),
                  sectionHeading(strings.pfMyActivityTitle),
                  if (user != null && isCfrHolderRole(user.role)) ...[
                    Consumer(
                      builder: (context, ref, _) {
                        final lhProf = ref.watch(lh_profile.profileProvider);
                        final hasDetails = lhProf?.hasDetails ?? false;
                        final lhStrings = LivelihoodUiStrings.of(context, language);
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.0 * s),
                          child: cardContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36.0 * s,
                                      height: 36.0 * s,
                                      decoration: BoxDecoration(
                                        color: tokens.primaryGreen.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.forest_outlined, size: 20.0 * s, color: tokens.primaryGreen),
                                    ),
                                    SizedBox(width: 10.0 * s),
                                    Expanded(
                                      child: Text(
                                        lhStrings.lhTitle,
                                        style: TextStyle(
                                          fontSize: 15.0 * s,
                                          fontWeight: FontWeight.w800,
                                          color: tokens.heading,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0 * s),
                                if (!hasDetails)
                                  CommunityPrimaryButton(
                                    key: const Key('profile_livelihood_create_btn'),
                                    label: lhStrings.lhCreateReport,
                                    onPressed: () => context.push('/livelihood/details'),
                                  )
                                else
                                  CommunityPrimaryButton(
                                    key: const Key('profile_livelihood_view_btn'),
                                    label: lhStrings.lhViewReport,
                                    onPressed: () => context.push('/livelihood/report'),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  cardContainer(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (int i = 0; i < activityKeys.length; i++) ...[
                          if (i > 0) Divider(height: 1.0, color: tokens.borders),
                          if (activityKeys[i] == 'orders')
                            ProfileMenuRow(
                              rowKey: const Key('profile_activity_orders'),
                              icon: Icons.receipt_long_outlined,
                              title: strings.pfMyOrders,
                              onTap: () => context.go('/orders'),
                              tokens: tokens,
                              scale: s,
                            )
                          else if (activityKeys[i] == 'sell')
                            ProfileMenuRow(
                              rowKey: const Key('profile_activity_sell'),
                              icon: Icons.storefront_outlined,
                              title: strings.pfSellOnVanMitra,
                              onTap: () => context.push('/sell'),
                              tokens: tokens,
                              scale: s,
                            ),
                        ],
                      ],
                    ),
                  ),
                ],

                // 4. More
                SizedBox(height: 20.0 * s),
                sectionHeading(strings.pfMoreSectionTitle),
                cardContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (int i = 0; i < moreKeys.length; i++) ...[
                        if (i > 0) Divider(height: 1.0, color: tokens.borders),
                        _buildMoreRow(context, moreKeys[i], strings, tokens, s),
                      ],
                    ],
                  ),
                ),

                // 5. Footer
                SizedBox(height: 24.0 * s),
                Column(
                  key: const Key('profile_footer'),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BrandLogo(size: 32.0 * s),
                        SizedBox(width: 8.0 * s),
                        Flexible(
                          child: Text(
                            strings.appNameNative,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.0 * s,
                              fontWeight: FontWeight.w800,
                              color: tokens.heading,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreRow(
    BuildContext context,
    String key,
    AppStrings strings,
    VanRozgarColorTokens tokens,
    double s,
  ) {
    switch (key) {
      case 'about':
        return ProfileMenuRow(
          rowKey: const Key('profile_more_about'),
          icon: Icons.info_outline,
          title: strings.pfAboutTitle,
          onTap: () => context.push('/about'),
          tokens: tokens,
          scale: s,
        );
      case 'credits':
        return ProfileMenuRow(
          rowKey: const Key('profile_more_credits'),
          icon: Icons.menu_book_outlined,
          title: strings.pfCreditsTitle,
          onTap: () => context.push('/credits'),
          tokens: tokens,
          scale: s,
        );
      case 'privacy':
        return ProfileMenuRow(
          rowKey: const Key('profile_more_privacy'),
          icon: Icons.privacy_tip_outlined,
          title: strings.pfPrivacyTitle,
          onTap: () => context.push('/privacy'),
          tokens: tokens,
          scale: s,
        );
      case 'livelihood':
        return ProfileMenuRow(
          rowKey: const Key('profile_more_livelihood'),
          icon: Icons.agriculture_outlined,
          title: strings.pfMoreLivelihoodTitle,
          onTap: () => context.push('/more/livelihood'),
          tokens: tokens,
          scale: s,
        );
      case 'messages':
        return Consumer(
          builder: (context, ref, _) {
            final unread = ref.watch(unreadMessagesProvider).asData?.value ?? 0;
            return ProfileMenuRow(
              rowKey: const Key('profile_more_messages'),
              icon: Icons.notifications_none,
              title: strings.pfMoreMessagesTitle,
              onTap: () => context.push('/more/messages'),
              tokens: tokens,
              scale: s,
              trailing: unread > 0
                  ? Container(
                      key: const Key('profile_messages_badge'),
                      padding: EdgeInsets.symmetric(horizontal: 7.0 * s, vertical: 2.0 * s),
                      decoration: BoxDecoration(
                        color: tokens.primaryGreen,
                        borderRadius: BorderRadius.circular(12.0 * s),
                      ),
                      child: Text(unread.toString(),
                        style: TextStyle(
                          fontSize: 11.5 * s,
                          fontWeight: FontWeight.w800,
                          color: tokens.onPrimaryGreen,
                        ),
                      ),
                    )
                  : null,
            );
          },
        );
      case 'barter':
        return ProfileMenuRow(
          rowKey: const Key('profile_more_barter'),
          icon: Icons.swap_horiz,
          title: strings.pfMoreBarterTitle,
          onTap: () => context.push('/more/barter'),
          tokens: tokens,
          scale: s,
        );
      case 'delivery':
      default:
        return ProfileMenuRow(
          rowKey: const Key('profile_more_delivery'),
          icon: Icons.two_wheeler,
          title: strings.pfMoreDeliveryTitle,
          onTap: () => context.push('/more/delivery'),
          tokens: tokens,
          scale: s,
        );
    }
  }
}

/// Interactive choice pill on a `Material` surface with a guaranteed >= 48x48 dp touch target.
class _ChoiceButton extends StatelessWidget {
  final Key buttonKey;
  final String label;
  final IconData? icon;
  final bool selected;
  final VanRozgarColorTokens tokens;
  final double scale;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.buttonKey,
    required this.label,
    this.icon,
    required this.selected,
    required this.tokens,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final bg = selected ? tokens.primaryGreen : tokens.chipBg;
    final fg = selected ? tokens.onPrimaryGreen : tokens.chipText;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: bg,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? tokens.primaryGreen : tokens.borders,
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: buttonKey,
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 64.0,
              minHeight: 48.0,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 14.0 * s,
                vertical: 8.0 * s,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 17.0 * s, color: fg),
                    SizedBox(width: 6.0 * s),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13.5 * s,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

