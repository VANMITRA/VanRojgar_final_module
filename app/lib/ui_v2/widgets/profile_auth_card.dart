import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../l10n/shop_extra_strings.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';

/// Top of the Profile page: sign-in / create-account buttons for a guest, or the user and "Sign out".
class ProfileAuthCard extends ConsumerWidget {
  const ProfileAuthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final user = ref.watch(authUserProvider);

    if (user != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.helloName(user.name),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: tokens.heading,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            '${strings.roleName(user.role)}  ·  ${user.phone}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
          ),
          const SizedBox(height: 12.0),
          OutlinedButton(
            key: const Key('signout_button'),
            onPressed: () => ref.read(authUserProvider.notifier).state = null,
            style: OutlinedButton.styleFrom(
              foregroundColor: tokens.primaryGreen,
              side: BorderSide(color: tokens.primaryGreen, width: 1.5),
              minimumSize: const Size(0, 48),
              shape: const StadiumBorder(),
            ),
            child: Text(strings.signOut, style: const TextStyle(fontWeight: FontWeight.w700)),
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
        const SizedBox(height: 12.0),
        FilledButton(
          key: const Key('profile_signin'),
          onPressed: () => context.push('/signin'),
          style: FilledButton.styleFrom(
            backgroundColor: tokens.primaryGreen,
            foregroundColor: tokens.onPrimaryGreen,
            minimumSize: const Size(0, 48),
            shape: const StadiumBorder(),
          ),
          child: Text(strings.signInTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 8.0),
        OutlinedButton(
          key: const Key('profile_signup'),
          onPressed: () => context.push('/signup'),
          style: OutlinedButton.styleFrom(
            foregroundColor: tokens.primaryGreen,
            side: BorderSide(color: tokens.primaryGreen, width: 1.5),
            minimumSize: const Size(0, 48),
            shape: const StadiumBorder(),
          ),
          child: Text(strings.createAccountTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
