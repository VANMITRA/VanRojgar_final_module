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

/// Shared frame of the sign-in and create-account pages: background, back arrow, language chips.
class _AuthFrame extends ConsumerWidget {
  final String title;
  final List<Widget> children;

  const _AuthFrame({required this.title, required this.children});

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
                  // Language chips: English is the default
                  for (final lang in AppLanguage.values)
                    Semantics(
                      button: true,
                      selected: lang == language,
                      label: lang.nativeLabel,
                      child: InkWell(
                        onTap: () => ref.read(uiV2LanguageProvider.notifier).state = lang,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 44.0, minHeight: 48.0),
                          alignment: Alignment.center,
                          child: Text(
                            AppStrings.shortLanguageLabel(lang),
                            style: TextStyle(
                              fontSize: 13.0 * s,
                              fontWeight: FontWeight.w700,
                              color: lang == language ? tokens.primaryGreen : tokens.mutedText,
                              decoration: lang == language ? TextDecoration.underline : TextDecoration.none,
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.0 * s, 8.0 * s, 20.0 * s, 24.0 * s),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      padding: EdgeInsets.all(20.0 * s),
                      decoration: BoxDecoration(
                        color: tokens.card,
                        borderRadius: BorderRadius.circular(20.0 * s),
                        border: Border.all(color: tokens.borders),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 26.0 * s,
                              fontWeight: FontWeight.w800,
                              color: tokens.heading,
                            ),
                          ),
                          SizedBox(height: 16.0 * s),
                          ...children,
                        ],
                      ),
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

InputDecoration _decoration(String label, VanRozgarColorTokens tokens, {String? error, String? prefix}) {
  return InputDecoration(
    labelText: label,
    errorText: error,
    prefixText: prefix,
    filled: true,
    fillColor: tokens.page.withValues(alpha: 0.6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: tokens.borders),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: tokens.borders),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: tokens.primaryGreen, width: 1.5),
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
      children: [
        Text(
          strings.signInSubtitle,
          style: TextStyle(fontSize: 14.0 * s, color: tokens.mutedText),
        ),
        SizedBox(height: 16.0 * s),
        // Google sign-in is the first option (it is wired up after the demo)
        OutlinedButton(
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
            side: BorderSide(color: tokens.borders, width: 1.5),
            minimumSize: Size(0, 52.0 * s),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0 * s)),
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
        ),
        SizedBox(height: 14.0 * s),
        Row(
          children: [
            Expanded(child: Divider(color: tokens.borders)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0 * s),
              child: Text(strings.orDivider, style: TextStyle(color: tokens.mutedText)),
            ),
            Expanded(child: Divider(color: tokens.borders)),
          ],
        ),
        SizedBox(height: 14.0 * s),
        TextField(
          key: const Key('signin_phone'),
          controller: _phone,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _decoration(strings.phoneLabel, tokens, error: _phoneError, prefix: '+91 ')
              .copyWith(counterText: ''),
        ),
        SizedBox(height: 12.0 * s),
        TextField(
          key: const Key('signin_pin'),
          controller: _pin,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _decoration(strings.pinLabel, tokens, error: _pinError).copyWith(counterText: ''),
        ),
        SizedBox(height: 16.0 * s),
        FilledButton(
          key: const Key('signin_submit'),
          onPressed: () => _submit(strings),
          style: FilledButton.styleFrom(
            backgroundColor: tokens.primaryGreen,
            foregroundColor: tokens.onPrimaryGreen,
            minimumSize: Size(0, 52.0 * s),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0 * s)),
          ),
          child: Text(
            strings.signInTitle,
            style: TextStyle(fontSize: 16.0 * s, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(height: 8.0 * s),
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

/// Create account: role, name, mobile number, PIN, village (for Gram Sabha and CFR holder).
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pin = TextEditingController();
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

    Widget roleChip(String role) {
      final selected = _role == role;
      return ChoiceChip(
        key: Key('role_$role'),
        label: Text(strings.roleName(role)),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() {
          _role = role;
          _villageError = null;
        }),
        selectedColor: tokens.primaryGreen,
        backgroundColor: tokens.chipBg,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? tokens.onPrimaryGreen : tokens.chipText,
        ),
        shape: const StadiumBorder(),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      );
    }

    return _AuthFrame(
      title: strings.createAccountTitle,
      children: [
        Text(strings.roleLabel, style: TextStyle(fontSize: 13.0 * s, color: tokens.mutedText)),
        SizedBox(height: 6.0 * s),
        Wrap(
          spacing: 8.0 * s,
          runSpacing: 4.0 * s,
          children: [roleChip('buyer'), roleChip('gramsabha'), roleChip('cfrholder')],
        ),
        SizedBox(height: 14.0 * s),
        TextField(
          key: const Key('signup_name'),
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: _decoration(strings.nameLabel, tokens, error: _nameError),
        ),
        SizedBox(height: 12.0 * s),
        TextField(
          key: const Key('signup_phone'),
          controller: _phone,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _decoration(strings.phoneLabel, tokens, error: _phoneError, prefix: '+91 ')
              .copyWith(counterText: ''),
        ),
        SizedBox(height: 12.0 * s),
        TextField(
          key: const Key('signup_pin'),
          controller: _pin,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _decoration(strings.pinLabel, tokens, error: _pinError).copyWith(counterText: ''),
        ),
        if (needsVillage) ...[
          SizedBox(height: 12.0 * s),
          DropdownButtonFormField<String>(
            key: const Key('signup_village'),
            initialValue: _villageId,
            isExpanded: true,
            hint: Text(strings.chooseVillage),
            decoration: _decoration(strings.villageLabel, tokens, error: _villageError),
            items: [
              for (final v in pilotVillages)
                DropdownMenuItem<String>(
                  value: v.id,
                  child: Text(
                    '${v.label(language)}, ${v.taluka}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) => setState(() {
              _villageId = value;
              _villageError = null;
            }),
          ),
        ],
        SizedBox(height: 16.0 * s),
        FilledButton(
          key: const Key('signup_submit'),
          onPressed: () => _submit(strings),
          style: FilledButton.styleFrom(
            backgroundColor: tokens.primaryGreen,
            foregroundColor: tokens.onPrimaryGreen,
            minimumSize: Size(0, 52.0 * s),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0 * s)),
          ),
          child: Text(
            strings.createAccountTitle,
            style: TextStyle(fontSize: 16.0 * s, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(height: 8.0 * s),
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
    );
  }
}
