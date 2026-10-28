import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/villages.dart';
import '../l10n/app_strings.dart';
import '../l10n/shop_extra_strings.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import '../widgets/app_background.dart';
import '../widgets/brand_logo.dart';

/// Where to go after signing in or creating an account. A page that sends a guest here (for example the
/// Product page after "Buy now") passes `?redirect=/product/<code>`; without it the user lands on Profile.
String _afterAuthTarget(BuildContext context) {
  final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
  if (redirect != null && redirect.startsWith('/') && !redirect.startsWith('//')) return redirect;
  return '/profile';
}

/// [path] with the current `redirect` carried over, so switching between sign in and create account keeps it.
String _withRedirect(BuildContext context, String path) {
  final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
  if (redirect == null) return path;
  return '$path?redirect=${Uri.encodeQueryComponent(redirect)}';
}

/// Shared frame of the sign-in and create-account pages: background, back arrow, language chips,
/// round brand logo header, scrollable body, and optional sticky bottom bar.
class _AuthFrame extends ConsumerWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? stickyBottom;

  const _AuthFrame({
    required this.title,
    required this.subtitle,
    required this.children,
    this.stickyBottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
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
            // Top bar: back button + language chips
            Padding(
              padding: EdgeInsets.fromLTRB(4.0 * s, 4.0 * s, 12.0 * s, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: strings.backLabel,
                    onPressed: goBack,
                    icon: Icon(Icons.arrow_back, color: tokens.heading),
                  ),
                  const Spacer(),
                  for (final lang in AppLanguage.values)
                    Semantics(
                      button: true,
                      selected: lang == language,
                      label: lang.nativeLabel,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: () => ref.read(uiV2LanguageProvider.notifier).state = lang,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 44.0, minHeight: 48.0),
                          padding: EdgeInsets.symmetric(horizontal: 6.0 * s),
                          alignment: Alignment.center,
                          child: Text(
                            AppStrings.shortLanguageLabel(lang),
                            style: TextStyle(
                              fontSize: 13.0 * s,
                              fontWeight: FontWeight.w700,
                              color: lang == language ? tokens.primaryGreen : tokens.mutedText,
                              decoration:
                                  lang == language ? TextDecoration.underline : TextDecoration.none,
                              decorationColor: tokens.primaryGreen,
                              decorationThickness: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Scrollable form content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.0 * s, 6.0 * s, 18.0 * s, 20.0 * s),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Friendly Brand Header (round logo + app name + short friendly line)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 60.0 * s,
                                height: 60.0 * s,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: tokens.chipBg,
                                  border: Border.all(color: tokens.borders, width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: BrandLogo(size: 38.0 * s),
                              ),
                              SizedBox(height: 8.0 * s),
                              Text(
                                strings.appNameNative,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18.0 * s,
                                  fontWeight: FontWeight.w800,
                                  color: tokens.heading,
                                ),
                              ),
                              SizedBox(height: 2.0 * s),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.0 * s,
                                  fontWeight: FontWeight.w500,
                                  color: tokens.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14.0 * s),

                        // Main Form Card
                        Container(
                          padding: EdgeInsets.all(20.0 * s),
                          decoration: BoxDecoration(
                            color: tokens.card,
                            borderRadius: BorderRadius.circular(22.0 * s),
                            border: Border.all(color: tokens.borders),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 24.0 * s,
                                  fontWeight: FontWeight.w800,
                                  color: tokens.heading,
                                ),
                              ),
                              SizedBox(height: 16.0 * s),
                              ...children,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (stickyBottom != null) stickyBottom!,
          ],
        ),
      ),
    );
  }
}

InputDecoration _decoration(
  String label,
  VanRozgarColorTokens tokens, {
  String? error,
  String? prefix,
  IconData? icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    errorText: error,
    errorMaxLines: 2,
    prefixText: prefix,
    prefixIcon: icon != null ? Icon(icon, color: tokens.primaryGreen, size: 20.0) : null,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: tokens.page.withValues(alpha: 0.6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: BorderSide(color: tokens.borders),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: BorderSide(color: tokens.borders),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: BorderSide(color: tokens.primaryGreen, width: 1.5),
    ),
  );
}

Widget _buildGoogleButton({
  required BuildContext context,
  required AppStrings strings,
  required VanRozgarColorTokens tokens,
  required double s,
}) {
  return OutlinedButton(
    key: const Key('google_button'),
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
      backgroundColor: tokens.page.withValues(alpha: 0.35),
      side: BorderSide(color: tokens.borders, width: 1.5),
      minimumSize: Size(0, 52.0 * s),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0 * s)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 26.0 * s,
          height: 26.0 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: tokens.borders),
          ),
          child: Text(
            'G',
            style: TextStyle(
              fontSize: 15.0 * s,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4285F4),
            ),
          ),
        ),
        SizedBox(width: 10.0 * s),
        Flexible(
          child: Text(
            strings.continueWithGoogle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

final RegExp _phoneRe = RegExp(r'^[6-9]\d{9}$');
final RegExp _pinRe = RegExp(r'^\d{6}$');

/// Sign in: Google first, then mobile number + 6-digit PIN.
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _phone = TextEditingController();
  final _pin = TextEditingController();
  bool _obscurePin = true;
  String? _phoneError;
  String? _pinError;

  @override
  void dispose() {
    _phone.dispose();
    _pin.dispose();
    super.dispose();
  }

  void _submit(AppStrings strings) {
    final phone = _phone.text.trim();
    final pin = _pin.text.trim();
    setState(() {
      _phoneError = _phoneRe.hasMatch(phone) ? null : strings.errPhone;
      _pinError = _pinRe.hasMatch(pin) ? null : strings.errPin;
    });
    if (_phoneError != null || _pinError != null) return;

    final account = ref.read(demoAccountsProvider)[phone];
    if (account == null) {
      setState(() => _phoneError = strings.errNoAccount);
      return;
    }
    if (account.pin != pin) {
      setState(() => _pinError = strings.errWrongPin);
      return;
    }
    ref.read(authUserProvider.notifier).state = account.user;
    context.go(_afterAuthTarget(context));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    return _AuthFrame(
      title: strings.signInTitle,
      subtitle: strings.signInSubtitle,
      children: [
        _buildGoogleButton(
          context: context,
          strings: strings,
          tokens: tokens,
          s: s,
        ),
        SizedBox(height: 16.0 * s),
        Row(
          children: [
            Expanded(child: Divider(color: tokens.borders)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0 * s),
              child: Text(strings.orDivider, style: TextStyle(color: tokens.mutedText)),
            ),
            Expanded(child: Divider(color: tokens.borders)),
          ],
        ),
        SizedBox(height: 16.0 * s),
        TextField(
          key: const Key('signin_phone'),
          controller: _phone,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _decoration(
            strings.phoneLabel,
            tokens,
            error: _phoneError,
            prefix: '+91 ',
            icon: Icons.phone_android_rounded,
          ).copyWith(counterText: ''),
        ),
        SizedBox(height: 14.0 * s),
        TextField(
          key: const Key('signin_pin'),
          controller: _pin,
          keyboardType: TextInputType.number,
          obscureText: _obscurePin,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _decoration(
            strings.pinLabel,
            tokens,
            error: _pinError,
            icon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              key: const Key('signin_pin_toggle'),
              onPressed: () => setState(() => _obscurePin = !_obscurePin),
              icon: Icon(
                _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: tokens.mutedText,
              ),
            ),
          ).copyWith(counterText: ''),
        ),
        SizedBox(height: 20.0 * s),
        FilledButton(
          key: const Key('signin_submit'),
          onPressed: () => _submit(strings),
          style: FilledButton.styleFrom(
            backgroundColor: tokens.primaryGreen,
            foregroundColor: tokens.onPrimaryGreen,
            minimumSize: Size(0, 52.0 * s),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0 * s)),
          ),
          child: Text(
            strings.signInTitle,
            style: TextStyle(fontSize: 16.0 * s, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(height: 10.0 * s),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(strings.noAccount, style: TextStyle(color: tokens.mutedText, fontSize: 13.0 * s)),
            TextButton(
              key: const Key('go_signup'),
              onPressed: () => context.pushReplacement(_withRedirect(context, '/signup')),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: Text(
                strings.createAccountLink,
                style: TextStyle(
                  color: tokens.primaryGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.0 * s,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Create account: Google first, 3 role cards, name, mobile number, PIN with show/hide,
/// searchable village bottom sheet (for Gram Sabha and CFR holder), and sticky bottom submit button.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pin = TextEditingController();
  bool _obscurePin = true;
  String _role = 'buyer';
  String? _villageId;
  String? _nameError;
  String? _phoneError;
  String? _pinError;
  String? _villageError;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _openVillageSheet(AppLanguage language, AppStrings strings, VanRozgarColorTokens tokens) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: tokens.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (sheetContext) {
        return _SearchableVillageSheet(
          language: language,
          strings: strings,
          tokens: tokens,
          selectedVillageId: _villageId,
        );
      },
    );
    if (selected != null && mounted) {
      setState(() {
        _villageId = selected;
        _villageError = null;
      });
    }
  }

  void _submit(AppStrings strings) {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final pin = _pin.text.trim();
    final needsVillage = _role != 'buyer';
    setState(() {
      _nameError = name.length >= 2 ? null : strings.errName;
      _phoneError = _phoneRe.hasMatch(phone) ? null : strings.errPhone;
      _pinError = _pinRe.hasMatch(pin) ? null : strings.errPin;
      _villageError = (!needsVillage || _villageId != null) ? null : strings.errVillage;
    });
    if (_nameError != null || _phoneError != null || _pinError != null || _villageError != null) return;

    final user = AuthUser(
      name: name,
      role: _role,
      phone: '+91$phone',
      villageId: needsVillage ? _villageId : null,
    );
    ref.read(demoAccountsProvider.notifier).state = {
      ...ref.read(demoAccountsProvider),
      phone: DemoAccount(pin, user),
    };
    ref.read(authUserProvider.notifier).state = user;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.accountCreated),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go(_afterAuthTarget(context));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);
    final needsVillage = _role != 'buyer';
    final selectedVillage = _villageId == null
        ? null
        : pilotVillages.where((v) => v.id == _villageId).firstOrNull;

    IconData roleIcon(String role) => switch (role) {
          'gramsabha' => Icons.groups_2_outlined,
          'cfrholder' => Icons.park_outlined,
          _ => Icons.shopping_bag_outlined,
        };

    String roleDescription(String role) => switch (role) {
          'gramsabha' => strings.landingSlide3Subtitle,
          'cfrholder' => strings.heroSubtitle2,
          _ => strings.heroTitle1,
        };

    Widget buildRoleCard(String role) {
      final selected = _role == role;
      return Semantics(
        button: true,
        selected: selected,
        label: strings.roleName(role),
        child: InkWell(
          key: Key('role_$role'),
          borderRadius: BorderRadius.circular(14.0 * s),
          onTap: () => setState(() {
            _role = role;
            _villageError = null;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.all(12.0 * s),
            decoration: BoxDecoration(
              color: selected ? tokens.chipBg.withValues(alpha: 0.7) : tokens.page.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14.0 * s),
              border: Border.all(
                color: selected ? tokens.primaryGreen : tokens.borders,
                width: selected ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42.0 * s,
                  height: 42.0 * s,
                  decoration: BoxDecoration(
                    color: selected ? tokens.primaryGreen : tokens.chipBg,
                    borderRadius: BorderRadius.circular(12.0 * s),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    roleIcon(role),
                    size: 22.0 * s,
                    color: selected ? tokens.onPrimaryGreen : tokens.chipText,
                  ),
                ),
                SizedBox(width: 12.0 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.roleName(role),
                        style: TextStyle(
                          fontSize: 15.0 * s,
                          fontWeight: FontWeight.w800,
                          color: tokens.heading,
                        ),
                      ),
                      SizedBox(height: 2.0 * s),
                      Text(
                        roleDescription(role),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.0 * s,
                          color: tokens.mutedText,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.0 * s),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: selected ? tokens.primaryGreen : tokens.mutedText,
                  size: 22.0 * s,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _AuthFrame(
      title: strings.createAccountTitle,
      subtitle: strings.browseSubtitle,
      stickyBottom: Container(
        decoration: BoxDecoration(
          color: tokens.card,
          border: Border(top: BorderSide(color: tokens.borders)),
        ),
        padding: EdgeInsets.fromLTRB(20.0 * s, 10.0 * s, 20.0 * s, 12.0 * s),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  key: const Key('signup_submit'),
                  onPressed: () => _submit(strings),
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.primaryGreen,
                    foregroundColor: tokens.onPrimaryGreen,
                    minimumSize: Size(0, 52.0 * s),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0 * s)),
                  ),
                  child: Text(
                    strings.createAccountTitle,
                    style: TextStyle(fontSize: 16.0 * s, fontWeight: FontWeight.w800),
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(strings.haveAccount, style: TextStyle(color: tokens.mutedText, fontSize: 13.0 * s)),
                    TextButton(
                      key: const Key('go_signin'),
                      onPressed: () => context.pushReplacement(_withRedirect(context, '/signin')),
                      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                      child: Text(
                        strings.signInTitle,
                        style: TextStyle(
                          color: tokens.primaryGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.0 * s,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      children: [
        _buildGoogleButton(
          context: context,
          strings: strings,
          tokens: tokens,
          s: s,
        ),
        SizedBox(height: 14.0 * s),
        Row(
          children: [
            Expanded(child: Divider(color: tokens.borders)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0 * s),
              child: Text(strings.orDivider, style: TextStyle(color: tokens.mutedText)),
            ),
            Expanded(child: Divider(color: tokens.borders)),
          ],
        ),
        SizedBox(height: 14.0 * s),
        Text(
          strings.roleLabel,
          style: TextStyle(
            fontSize: 13.0 * s,
            fontWeight: FontWeight.w700,
            color: tokens.mutedText,
          ),
        ),
        SizedBox(height: 8.0 * s),
        buildRoleCard('buyer'),
        SizedBox(height: 8.0 * s),
        buildRoleCard('gramsabha'),
        SizedBox(height: 8.0 * s),
        buildRoleCard('cfrholder'),
        SizedBox(height: 16.0 * s),
        TextField(
          key: const Key('signup_name'),
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: _decoration(
            strings.nameLabel,
            tokens,
            error: _nameError,
            icon: Icons.person_outline_rounded,
          ),
        ),
        SizedBox(height: 14.0 * s),
        TextField(
          key: const Key('signup_phone'),
          controller: _phone,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _decoration(
            strings.phoneLabel,
            tokens,
            error: _phoneError,
            prefix: '+91 ',
            icon: Icons.phone_android_rounded,
          ).copyWith(counterText: ''),
        ),
        SizedBox(height: 14.0 * s),
        TextField(
          key: const Key('signup_pin'),
          controller: _pin,
          keyboardType: TextInputType.number,
          obscureText: _obscurePin,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _decoration(
            strings.pinLabel,
            tokens,
            error: _pinError,
            icon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              key: const Key('signup_pin_toggle'),
              onPressed: () => setState(() => _obscurePin = !_obscurePin),
              icon: Icon(
                _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: tokens.mutedText,
              ),
            ),
          ).copyWith(counterText: ''),
        ),
        if (needsVillage) ...[
          SizedBox(height: 14.0 * s),
          Semantics(
            button: true,
            label: strings.villageLabel,
            child: InkWell(
              key: const Key('signup_village'),
              borderRadius: BorderRadius.circular(14.0),
              onTap: () => _openVillageSheet(language, strings, tokens),
              child: InputDecorator(
                decoration: _decoration(
                  strings.villageLabel,
                  tokens,
                  error: _villageError,
                  icon: Icons.location_on_outlined,
                  suffixIcon: Icon(Icons.expand_more_rounded, color: tokens.mutedText),
                ),
                child: Text(
                  selectedVillage != null
                      ? '${selectedVillage.label(language)}, ${selectedVillage.taluka}'
                      : strings.chooseVillage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.0 * s,
                    color: selectedVillage != null ? tokens.heading : tokens.mutedText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchableVillageSheet extends StatefulWidget {
  final AppLanguage language;
  final AppStrings strings;
  final VanRozgarColorTokens tokens;
  final String? selectedVillageId;

  const _SearchableVillageSheet({
    required this.language,
    required this.strings,
    required this.tokens,
    required this.selectedVillageId,
  });

  @override
  State<_SearchableVillageSheet> createState() => _SearchableVillageSheetState();
}

class _SearchableVillageSheetState extends State<_SearchableVillageSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.75;
    final q = _query.trim().toLowerCase();
    final filtered = pilotVillages.where((v) {
      if (q.isEmpty) return true;
      return v.nameEn.toLowerCase().contains(q) ||
          v.nameMr.toLowerCase().contains(q) ||
          v.taluka.toLowerCase().contains(q);
    }).toList();

    return SizedBox(
      key: const Key('village_picker_sheet'),
      height: sheetHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16.0 * s,
          12.0 * s,
          16.0 * s,
          MediaQuery.viewInsetsOf(context).bottom + 12.0 * s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: widget.tokens.borders,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            SizedBox(height: 12.0 * s),
            Text(
              widget.strings.chooseVillage,
              style: TextStyle(
                fontSize: 18.0 * s,
                fontWeight: FontWeight.w800,
                color: widget.tokens.heading,
              ),
            ),
            SizedBox(height: 10.0 * s),
            TextField(
              key: const Key('village_search_field'),
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: _decoration(
                widget.strings.chooseVillage,
                widget.tokens,
                icon: Icons.search_rounded,
              ),
            ),
            SizedBox(height: 10.0 * s),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        widget.strings.nothingFound,
                        style: TextStyle(color: widget.tokens.mutedText, fontSize: 14.0 * s),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final v in filtered)
                            InkWell(
                              key: Key('village_option_${v.id}'),
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () => Navigator.of(context).pop(v.id),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 48.0),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0 * s,
                                  vertical: 10.0 * s,
                                ),
                                decoration: BoxDecoration(
                                  color: v.id == widget.selectedVillageId
                                      ? widget.tokens.chipBg.withValues(alpha: 0.6)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 20.0 * s,
                                      color: widget.tokens.primaryGreen,
                                    ),
                                    SizedBox(width: 10.0 * s),
                                    Expanded(
                                      child: Text(
                                        '${v.label(widget.language)}, ${v.taluka}',
                                        style: TextStyle(
                                          fontSize: 15.0 * s,
                                          fontWeight: v.id == widget.selectedVillageId
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: widget.tokens.heading,
                                        ),
                                      ),
                                    ),
                                    if (v.id == widget.selectedVillageId)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 20.0 * s,
                                        color: widget.tokens.primaryGreen,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
