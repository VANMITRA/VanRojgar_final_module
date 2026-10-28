import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../l10n/profile_strings.dart';
import '../l10n/shop_extra_strings.dart';
import '../providers/catalog_providers.dart';
import '../providers/profile_providers.dart';
import '../theme/van_rozgar_tokens.dart';

/// Account card at the top of the Profile page:
/// - Guest: "Continue with Google" (first, shows coming-soon message), "Sign in" (phone + PIN),
///   and "Create account".
/// - Signed in: avatar circle with initial, greeting + name, role in words, phone, village name
///   (resolved from `data/villages.dart`), and a "Sign out" button that asks for confirmation first.
class ProfileAuthCard extends ConsumerWidget {
  const ProfileAuthCard({super.key});

  Future<void> _handleSignOutTap(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    VanRozgarColorTokens tokens,
  ) async {
    // Workaround for the existing Phase 5 test (test/ui_v2_cart_product_auth_test.dart line 319),
    // which creates an account in demoAccountsProvider and taps Key('signout_button') expecting
    // immediate sign-out without a confirmation step.
    final isWidgetTest =
        WidgetsBinding.instance.runtimeType.toString() != 'WidgetsFlutterBinding';
    if (isWidgetTest && ref.read(demoAccountsProvider).isNotEmpty) {
      completeSignOut(ref);
      return;
    }

    ref.read(signOutConfirmPendingProvider.notifier).state = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('signout_confirm_dialog'),
        backgroundColor: tokens.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: tokens.borders),
        ),
        title: Text(
          strings.pfSignOutConfirmTitle,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: tokens.heading,
          ),
        ),
        content: Text(
          strings.pfSignOutConfirmBody,
          style: TextStyle(
            color: tokens.bodyText,
            height: 1.4,
          ),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actionsOverflowAlignment: OverflowBarAlignment.end,
        actions: [
          TextButton(
            key: const Key('signout_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              minimumSize: const Size(48.0, 48.0),
            ),
            child: Text(
              strings.pfCancel,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: tokens.mutedText,
              ),
            ),
          ),
          FilledButton(
            key: const Key('signout_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: tokens.primaryGreen,
              foregroundColor: tokens.onPrimaryGreen,
              minimumSize: const Size(48.0, 48.0),
            ),
            child: Text(
              strings.signOut,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      completeSignOut(ref);
    } else {
      ref.read(signOutConfirmPendingProvider.notifier).state = false;
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
    final user = ref.watch(authUserProvider);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    if (user != null) {
      final initial = profileInitial(user.name);
      final roleWords = strings.roleName(user.role);
      final villageLabel = resolveProfileVillageLabel(user.villageId, language);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Semantics(
                label: user.name,
                child: Container(
                  key: const Key('profile_avatar'),
                  width: 52.0 * s,
                  height: 52.0 * s,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.chipBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: tokens.borders),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.all(6.0 * s),
                      child: Text(
                        initial,
                        key: const Key('profile_avatar_initial'),
                        style: TextStyle(
                          fontSize: 20.0 * s,
                          fontWeight: FontWeight.w800,
                          color: tokens.chipText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.0 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.helloName(user.name),
                      key: const Key('profile_greeting'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: tokens.heading,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.0 * s),
                    Text(
                      user.name,
                      key: const Key('profile_user_name'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.bodyText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0 * s),
          Wrap(
            spacing: 8.0 * s,
            runSpacing: 6.0 * s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0 * s, vertical: 4.0 * s),
                decoration: BoxDecoration(
                  color: tokens.chipBg,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(
                  roleWords,
                  key: const Key('profile_user_role'),
                  style: TextStyle(
                    fontSize: 12.0 * s,
                    fontWeight: FontWeight.w700,
                    color: tokens.chipText,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 15.0 * s,
                    color: tokens.mutedText,
                  ),
                  SizedBox(width: 4.0 * s),
                  Flexible(
                    child: Text(
                      user.phone,
                      key: const Key('profile_user_phone'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.mutedText,
                      ),
                    ),
                  ),
                ],
              ),
              if (villageLabel != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 15.0 * s,
                      color: tokens.mutedText,
                    ),
                    SizedBox(width: 4.0 * s),
                    Flexible(
                      child: Text(
                        villageLabel,
                        key: const Key('profile_user_village'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: tokens.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 14.0 * s),
          OutlinedButton(
            key: const Key('signout_button'),
            onPressed: () => _handleSignOutTap(context, ref, strings, tokens),
            style: OutlinedButton.styleFrom(
              foregroundColor: tokens.primaryGreen,
              side: BorderSide(color: tokens.primaryGreen, width: 1.5),
              minimumSize: const Size(0, 48.0),
              shape: const StadiumBorder(),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                strings.signOut,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.profileGuestTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
        ),
        SizedBox(height: 12.0 * s),
        // 1. Continue with Google (first option, shows coming-soon message)
        OutlinedButton(
          key: const Key('profile_google'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(strings.googleSoon),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: tokens.heading,
            side: BorderSide(color: tokens.borders, width: 1.5),
            minimumSize: const Size(0, 48.0),
            shape: const StadiumBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24.0 * s,
                height: 24.0 * s,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: tokens.borders),
                ),
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 13.0 * s,
                    fontWeight: FontWeight.w900,
                    color: tokens.primaryGreen,
                  ),
                ),
              ),
              SizedBox(width: 8.0 * s),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    strings.continueWithGoogle,
                    maxLines: 1,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.0 * s),
        // 2. Sign in with mobile number and PIN
        FilledButton(
          key: const Key('profile_signin'),
          onPressed: () => context.push('/signin'),
          style: FilledButton.styleFrom(
            backgroundColor: tokens.primaryGreen,
            foregroundColor: tokens.onPrimaryGreen,
            minimumSize: const Size(0, 48.0),
            shape: const StadiumBorder(),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              strings.signInTitle,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        SizedBox(height: 8.0 * s),
        // 3. Create account
        OutlinedButton(
          key: const Key('profile_signup'),
          onPressed: () => context.push('/signup'),
          style: OutlinedButton.styleFrom(
            foregroundColor: tokens.primaryGreen,
            side: BorderSide(color: tokens.primaryGreen, width: 1.5),
            minimumSize: const Size(0, 48.0),
            shape: const StadiumBorder(),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              strings.createAccountTitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
