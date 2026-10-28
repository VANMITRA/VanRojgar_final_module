import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/sell_catalog.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/sell_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../models/catalog_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/sell_providers.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../../widgets/app_background.dart';
import '../../widgets/sell/my_listing_card.dart';

/// Returns true only when [user] is a seller (`'gramsabha'` or `'cfrholder'`).
bool isSellerUser(AuthUser? user) {
  if (user == null) return false;
  return user.role == 'gramsabha' || user.role == 'cfrholder';
}

/// Top-level `/sell` screen: shows the seller's listings with Add, Edit, Pause/Resume, and Remove,
/// or a clear role-gate message for guests and buyers.
class SellPage extends ConsumerWidget {
  const SellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final user = ref.watch(authUserProvider);
    final listings = ref.watch(myListingsProvider);
    final catalog = ref.watch(sellCatalogProvider).valueOrNull ?? const <ShopProduct>[];
    final byCode = <String, ShopProduct>{for (final p in catalog) p.productCode: p};

    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    void goBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/profile');
      }
    }

    return Scaffold(
      body: AppBackground(
        categorySlug: 'forest-produce',
        useSafeArea: true,
        child: Column(
          children: [
            // Top bar: back arrow and title
            Padding(
              padding: EdgeInsets.fromLTRB(4.0 * s, 4.0 * s, 16.0 * s, 4.0 * s),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('sell_back_button'),
                    tooltip: strings.backLabel,
                    onPressed: goBack,
                    icon: Icon(Icons.arrow_back, color: tokens.heading),
                  ),
                  Expanded(
                    child: Text(
                      strings.slMyListingsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !isSellerUser(user)
                  ? SellRoleGateView(
                      user: user,
                      strings: strings,
                      tokens: tokens,
                      scale: s,
                      redirectPath: '/sell',
                    )
                  : listings.isEmpty
                      ? _EmptyListingsView(
                          strings: strings,
                          tokens: tokens,
                          scale: s,
                          onAdd: () => context.push('/sell/new'),
                        )
                      : ListView(
                          padding: EdgeInsets.fromLTRB(16.0 * s, 8.0 * s, 16.0 * s, 24.0 * s),
                          children: [
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 560.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Primary green "Add a listing" button
                                    FilledButton.icon(
                                      key: const Key('sell_add_listing_button'),
                                      onPressed: () => context.push('/sell/new'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: tokens.primaryGreen,
                                        foregroundColor: tokens.onPrimaryGreen,
                                        minimumSize: Size(0, 48.0 * s),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.0 * s),
                                        ),
                                      ),
                                      icon: Icon(Icons.add, size: 20.0 * s),
                                      label: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          strings.slAddListingButton,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 15.0 * s,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.0 * s),
                                    for (int i = 0; i < listings.length; i++) ...[
                                      if (i > 0) SizedBox(height: 12.0 * s),
                                      MyListingCard(
                                        listing: listings[i],
                                        product: byCode[listings[i].productCode],
                                        language: language,
                                        tokens: tokens,
                                        scale: s,
                                        onEdit: () => context.push('/sell/edit/${listings[i].id}'),
                                        onToggleStatus: () {
                                          final current = ref.read(myListingsProvider);
                                          final item = listings[i];
                                          ref.read(myListingsProvider.notifier).state = item.isActive
                                              ? pauseListing(current, item.id)
                                              : resumeListing(current, item.id);
                                        },
                                        onRemove: () async {
                                          final item = listings[i];
                                          final title = byCode[item.productCode]?.localizedTitle(language) ??
                                              item.productCode;
                                          final confirmed = await _confirmRemoveDialog(
                                            context,
                                            title: title,
                                            strings: strings,
                                            tokens: tokens,
                                            scale: s,
                                          );
                                          if (confirmed == true) {
                                            final current = ref.read(myListingsProvider);
                                            ref.read(myListingsProvider.notifier).state =
                                                removeListing(current, item.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared role gate shown when a guest or a buyer visits `/sell`, `/sell/new`, or `/sell/edit/:id`.
class SellRoleGateView extends StatelessWidget {
  final AuthUser? user;
  final AppStrings strings;
  final VanRozgarColorTokens tokens;
  final double scale;
  final String redirectPath;

  const SellRoleGateView({
    super.key,
    required this.user,
    required this.strings,
    required this.tokens,
    required this.scale,
    required this.redirectPath,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final isGuest = user == null;
    final encodedRedirect = Uri.encodeQueryComponent(redirectPath);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.0 * s),
        child: Container(
          key: const Key('sell_role_gate_card'),
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 440.0),
          padding: EdgeInsets.all(20.0 * s),
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: BorderRadius.circular(16.0 * s),
            border: Border.all(color: tokens.borders),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56.0 * s,
                  height: 56.0 * s,
                  decoration: BoxDecoration(
                    color: tokens.chipBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.storefront_outlined,
                    size: 28.0 * s,
                    color: tokens.chipText,
                  ),
                ),
              ),
              SizedBox(height: 14.0 * s),
              Text(
                strings.slSellerOnlyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0 * s,
                  fontWeight: FontWeight.w800,
                  color: tokens.heading,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 8.0 * s),
              Text(
                isGuest ? strings.slSellerOnlyGuestBody : strings.slSellerOnlyBuyerBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5 * s,
                  color: tokens.bodyText,
                  height: 1.4,
                ),
              ),
              if (isGuest) ...[
                SizedBox(height: 18.0 * s),
                FilledButton(
                  key: const Key('sell_guest_signin'),
                  onPressed: () => context.push('/signin?redirect=$encodedRedirect'),
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.primaryGreen,
                    foregroundColor: tokens.onPrimaryGreen,
                    minimumSize: Size(0, 48.0 * s),
                    shape: const StadiumBorder(),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      strings.signInTitle,
                      style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                SizedBox(height: 10.0 * s),
                OutlinedButton(
                  key: const Key('sell_guest_signup'),
                  onPressed: () => context.push('/signup?redirect=$encodedRedirect'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.primaryGreen,
                    side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                    minimumSize: Size(0, 48.0 * s),
                    shape: const StadiumBorder(),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      strings.createAccountTitle,
                      style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyListingsView extends StatelessWidget {
  final AppStrings strings;
  final VanRozgarColorTokens tokens;
  final double scale;
  final VoidCallback onAdd;

  const _EmptyListingsView({
    required this.strings,
    required this.tokens,
    required this.scale,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.0 * s),
        child: Container(
          key: const Key('sell_empty_state'),
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 440.0),
          padding: EdgeInsets.all(22.0 * s),
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: BorderRadius.circular(16.0 * s),
            border: Border.all(color: tokens.borders),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.eco_outlined,
                size: 40.0 * s,
                color: tokens.primaryGreen.withValues(alpha: 0.75),
              ),
              SizedBox(height: 12.0 * s),
              Text(
                strings.slEmptyListings,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5 * s,
                  color: tokens.bodyText,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.0 * s),
              FilledButton.icon(
                key: const Key('sell_add_listing_button'),
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.primaryGreen,
                  foregroundColor: tokens.onPrimaryGreen,
                  minimumSize: Size(0, 48.0 * s),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0 * s),
                  ),
                ),
                icon: Icon(Icons.add, size: 20.0 * s),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    strings.slAddListingButton,
                    maxLines: 1,
                    style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> _confirmRemoveDialog(
  BuildContext context, {
  required String title,
  required AppStrings strings,
  required VanRozgarColorTokens tokens,
  required double scale,
}) {
  final s = scale;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      key: const Key('remove_listing_dialog'),
      backgroundColor: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0 * s),
        side: BorderSide(color: tokens.borders),
      ),
      title: Text(
        strings.slRemoveDialogTitle,
        style: TextStyle(
          fontSize: 18.0 * s,
          fontWeight: FontWeight.w800,
          color: tokens.heading,
        ),
      ),
      content: Text(
        strings.slRemoveDialogBody(title),
        style: TextStyle(
          fontSize: 14.0 * s,
          color: tokens.bodyText,
        ),
      ),
      actions: [
        TextButton(
          key: const Key('remove_dialog_cancel'),
          onPressed: () => Navigator.of(ctx).pop(false),
          style: TextButton.styleFrom(minimumSize: const Size(48.0, 48.0)),
          child: Text(
            strings.slCancelAction,
            style: TextStyle(color: tokens.mutedText, fontWeight: FontWeight.w700),
          ),
        ),
        FilledButton(
          key: const Key('remove_dialog_confirm'),
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: tokens.primaryGreen,
            foregroundColor: tokens.onPrimaryGreen,
            minimumSize: const Size(48.0, 48.0),
          ),
          child: Text(
            strings.slRemoveAction,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

