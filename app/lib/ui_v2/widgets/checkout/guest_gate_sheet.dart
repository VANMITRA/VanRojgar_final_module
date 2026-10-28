import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/checkout_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/van_rozgar_tokens.dart';

/// Opens the guest gate modal bottom sheet when a guest taps "Send request" on `/checkout`.
Future<void> showGuestGateSheet(BuildContext context) {
  final parentRouter = GoRouter.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _GuestGateSheet(router: parentRouter),
  );
}

class _GuestGateSheet extends ConsumerWidget {
  final GoRouter router;

  const _GuestGateSheet({required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    return Material(
      key: const Key('guest_gate_sheet'),
      color: tokens.page,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0 * s)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0 * s, 12.0 * s, 20.0 * s, 20.0 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.0 * s,
                  height: 4.0 * s,
                  decoration: BoxDecoration(
                    color: tokens.borders,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
              ),
              SizedBox(height: 14.0 * s),
              Text(
                strings.coSignInToSendTitle,
                style: TextStyle(
                  fontSize: 20.0 * s,
                  fontWeight: FontWeight.w800,
                  color: tokens.heading,
                ),
              ),
              SizedBox(height: 6.0 * s),
              Text(
                strings.coSignInToSendBody,
                style: TextStyle(
                  fontSize: 13.5 * s,
                  color: tokens.mutedText,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 18.0 * s),
              FilledButton(
                key: const Key('guest_gate_signin'),
                onPressed: () {
                  Navigator.of(context).pop();
                  router.push('/signin');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.primaryGreen,
                  foregroundColor: tokens.onPrimaryGreen,
                  minimumSize: Size(0, 50.0 * s),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0 * s),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    strings.signInTitle,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15.0 * s,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0 * s),
              OutlinedButton(
                key: const Key('guest_gate_signup'),
                onPressed: () {
                  Navigator.of(context).pop();
                  router.push('/signup');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: tokens.primaryGreen,
                  side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                  minimumSize: Size(0, 50.0 * s),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0 * s),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    strings.createAccountTitle,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15.0 * s,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.0 * s),
              TextButton(
                key: const Key('guest_gate_not_now'),
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: tokens.mutedText,
                  minimumSize: const Size(48.0, 48.0),
                ),
                child: Text(
                  strings.coNotNow,
                  style: TextStyle(
                    fontSize: 14.0 * s,
                    fontWeight: FontWeight.w700,
                    color: tokens.mutedText,
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

