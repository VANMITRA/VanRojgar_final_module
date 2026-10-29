import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/community_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../app_background.dart';

/// Colour tokens of the current theme.
VanRozgarColorTokens communityTokens(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  return theme.extension<VanRozgarColorTokens>() ??
      (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
}

/// Screen scale used by every Round 2 screen.
double communityScale(BuildContext context) =>
    (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

/// `dd-MM-yyyy` (no month names, so it reads the same in all three languages).
String communityDate(DateTime d) {
  final local = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}-${two(local.month)}-${local.year}';
}

/// Full-screen page: background, back arrow, title, a body, and an optional bottom bar above the gesture bar.
class CommunityPage extends ConsumerWidget {
  final String title;
  final Widget body;
  final Widget? bottomBar;

  const CommunityPage({super.key, required this.title, required this.body, this.bottomBar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = communityTokens(context);
    final strings = AppStrings.of(ref.watch(uiV2LanguageProvider));
    final s = communityScale(context);

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.0 * s, 4.0 * s, 16.0 * s, 4.0 * s),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: strings.backLabel,
                    child: IconButton(
                      key: const Key('community_back'),
                      tooltip: strings.backLabel,
                      constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
                      onPressed: goBack,
                      icon: Icon(Icons.arrow_back, color: tokens.heading),
                    ),
                  ),
                  SizedBox(width: 4.0 * s),
                  Expanded(
                    child: Text(
                      title,
                      key: const Key('community_title'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
            if (bottomBar != null)
              Material(
                color: tokens.card,
                child: SafeArea(
                  top: false,
                  child: Container(
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: tokens.borders))),
                    padding: EdgeInsets.fromLTRB(16.0 * s, 10.0 * s, 16.0 * s, 10.0 * s),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560.0),
                        child: bottomBar,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A scrolling list body with the usual padding and maximum width.
class CommunityScroll extends StatelessWidget {
  final List<Widget> children;
  final Key? scrollKey;

  const CommunityScroll({super.key, required this.children, this.scrollKey});

  @override
  Widget build(BuildContext context) {
    final s = communityScale(context);
    return SingleChildScrollView(
      key: scrollKey,
      padding: EdgeInsets.fromLTRB(16.0 * s, 8.0 * s, 16.0 * s, 28.0 * s),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );
  }
}

/// White card with a 1 dp border; with [onTap] it ripples (the ripple sits on a `Material`).
class CommunityCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const CommunityCard({super.key, required this.child, this.onTap, this.padding});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final content = Padding(padding: padding ?? EdgeInsets.all(14.0 * s), child: child);
    return Material(
      color: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0 * s),
        side: BorderSide(color: tokens.borders),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

/// Section heading above a group of cards.
class CommunityHeading extends StatelessWidget {
  final String text;

  const CommunityHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    return Padding(
      padding: EdgeInsets.only(left: 4.0 * s, top: 4.0 * s, bottom: 8.0 * s),
      child: Text(
        text,
        style: TextStyle(fontSize: 16.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
      ),
    );
  }
}

/// Small rounded status label.
class CommunityChip extends StatelessWidget {
  final String label;
  final bool strong;
  final bool muted;

  const CommunityChip({super.key, required this.label, this.strong = false, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final Color bg = strong ? tokens.primaryGreen : (muted ? tokens.page : tokens.chipBg);
    final Color fg = strong ? tokens.onPrimaryGreen : (muted ? tokens.mutedText : tokens.chipText);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0 * s, vertical: 4.0 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.0),
        border: muted ? Border.all(color: tokens.borders) : null,
      ),
      child: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11.5 * s, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

/// Green filled button (at least 48 dp high).
class CommunityPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const CommunityPrimaryButton({super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: tokens.primaryGreen,
        foregroundColor: tokens.onPrimaryGreen,
        minimumSize: Size(0, 48.0 * s),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18.0 * s), SizedBox(width: 8.0 * s)],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Green outlined button (at least 48 dp high).
class CommunitySecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const CommunitySecondaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: tokens.primaryGreen,
        side: BorderSide(color: tokens.primaryGreen, width: 1.5),
        minimumSize: Size(0, 48.0 * s),
        shape: const StadiumBorder(),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// Segmented switch of two or three labels.
class CommunitySegments extends StatelessWidget {
  final List<String> labels;
  final List<Key> keys;
  final int selected;
  final ValueChanged<int> onSelect;

  const CommunitySegments({
    super.key,
    required this.labels,
    required this.keys,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    return Material(
      color: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0 * s),
        side: BorderSide(color: tokens.borders),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(4.0 * s),
        child: Row(
          children: [
            for (int i = 0; i < labels.length; i++) ...[
              if (i > 0) SizedBox(width: 4.0 * s),
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == selected,
                  label: labels[i],
                  child: Material(
                    color: i == selected ? tokens.primaryGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.0 * s),
                    child: InkWell(
                      key: keys[i],
                      borderRadius: BorderRadius.circular(10.0 * s),
                      onTap: () => onSelect(i),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48.0),
                        padding: EdgeInsets.symmetric(horizontal: 8.0 * s, vertical: 6.0 * s),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            labels[i],
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 13.5 * s,
                              fontWeight: FontWeight.w800,
                              color: i == selected ? tokens.onPrimaryGreen : tokens.bodyText,
                            ),
                          ),
                        ),
                      ),
                    ),
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

/// Centered card with an icon, a title, a short text and up to two buttons. Used for guest, wrong-role,
/// empty and error states.
class CommunityMessageCard extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String body;
  final List<Widget> actions;

  const CommunityMessageCard({
    super.key,
    required this.icon,
    this.title,
    required this.body,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    return CommunityCard(
      padding: EdgeInsets.all(20.0 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56.0 * s,
              height: 56.0 * s,
              decoration: BoxDecoration(color: tokens.chipBg, shape: BoxShape.circle),
              child: Icon(icon, size: 28.0 * s, color: tokens.chipText),
            ),
          ),
          SizedBox(height: 14.0 * s),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
            ),
            SizedBox(height: 8.0 * s),
          ],
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.0 * s, color: tokens.bodyText, height: 1.4),
          ),
          for (final a in actions) ...[SizedBox(height: 10.0 * s), a],
        ],
      ),
    );
  }
}

/// Sign in / create account card for a guest.
class CommunityGuestCard extends ConsumerWidget {
  final IconData icon;
  final String body;

  const CommunityGuestCard({super.key, required this.icon, required this.body});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(ref.watch(uiV2LanguageProvider));
    return CommunityMessageCard(
      icon: icon,
      title: strings.dlGuestTitle,
      body: body,
      actions: [
        KeyedSubtree(
          key: const Key('community_guest_signin'),
          child: CommunityPrimaryButton(label: strings.signInTitle, onPressed: () => context.push('/signin')),
        ),
        KeyedSubtree(
          key: const Key('community_guest_signup'),
          child: CommunitySecondaryButton(
            label: strings.createAccountTitle,
            onPressed: () => context.push('/signup'),
          ),
        ),
      ],
    );
  }
}

/// Centers a card in a scrolling area (for single-card states).
class CommunityCentered extends StatelessWidget {
  final Widget child;

  const CommunityCentered({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final s = communityScale(context);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0 * s),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460.0), child: child),
      ),
    );
  }
}

/// Asks "Are you sure?" with a Cancel and a green confirm button. Returns true when confirmed.
Future<bool> showCommunityConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final tokens = communityTokens(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      key: const Key('community_confirm_dialog'),
      backgroundColor: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: tokens.borders),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: tokens.heading)),
      content: SingleChildScrollView(
        child: Text(body, style: TextStyle(color: tokens.bodyText, height: 1.4)),
      ),
      actionsOverflowAlignment: OverflowBarAlignment.end,
      actions: [
        TextButton(
          key: const Key('community_confirm_cancel'),
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(minimumSize: const Size(48.0, 48.0)),
          child: Text(cancelLabel, style: TextStyle(fontWeight: FontWeight.w700, color: tokens.mutedText)),
        ),
        FilledButton(
          key: const Key('community_confirm_ok'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: tokens.primaryGreen,
            foregroundColor: tokens.onPrimaryGreen,
            minimumSize: const Size(48.0, 48.0),
          ),
          child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );
  return result == true;
}

/// A plain floating message at the bottom of the screen.
void showCommunityNotice(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating),
  );
}

/// Input decoration shared by the Round 2 forms.
InputDecoration communityField(VanRozgarColorTokens tokens, String label, {String? error, IconData? icon}) {
  OutlineInputBorder border(Color c, [double w = 1.0]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    labelText: label,
    errorText: error,
    errorMaxLines: 3,
    prefixIcon: icon == null ? null : Icon(icon, color: tokens.primaryGreen, size: 20.0),
    filled: true,
    fillColor: tokens.page.withValues(alpha: 0.6),
    border: border(tokens.borders),
    enabledBorder: border(tokens.borders),
    focusedBorder: border(tokens.primaryGreen, 1.5),
  );
}

