import '../../shared/widgets/vr_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/storage/prefs.dart';
import '../../core/theme/tokens.dart';
import '../../core/localization/app_input_hints.dart';
import '../../core/network/app_exception.dart';
import '../../l10n/app_localizations.dart';
import 'auth_providers.dart';
import '../../shared/utils/roles.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final rawPhone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (rawPhone.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'कृपया मोबाईल क्रमांक आणि पासवर्ड प्रविष्ट करा.');
      return;
    }

    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    final String phone = digits.length == 10
        ? '+91$digits'
        : (rawPhone.startsWith('+') ? rawPhone : '+91$rawPhone');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await ref.read(authControllerProvider.notifier).login(phone, password);
      if (!mounted) return;

      context.go(homeRouteFor(user.role));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is AppException ? e.localizedMessage : e.toString();
        _isLoading = false;
      });
    }
  }

  void _fillDemo(String phone, String role) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    // Strip country code 91 so it doesn't duplicate the '+91 ' prefix in the UI
    _phoneController.text = digits.length == 12 && digits.startsWith('91')
        ? digits.substring(2)
        : (digits.length == 10 ? digits : phone);
    _passwordController.text = AppConfig.demoPin;
  }

  void _showServerDialog() async {
    final currentUrl = await Prefs.getApiBaseUrl() ?? AppConfig.apiBaseUrl;
    final controller = TextEditingController(text: currentUrl);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const VrText('सर्व्हर निवडा • Server Target'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const VrText('विकास चाचणीसाठी API सर्व्हर URL निवडा:', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await Prefs.setApiBaseUrl('http://127.0.0.1:3000/api/v1');
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: VrText('Target: 127.0.0.1:3000 (Run "adb reverse tcp:3000 tcp:3000" in PC Terminal)')),
                  );
                }
              },
              child: const VrText('USB Real Phone (adb reverse)\n127.0.0.1:3000', textAlign: TextAlign.center),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                await Prefs.setApiBaseUrl('http://10.0.2.2:3000/api/v1');
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: VrText('Target set to Android Emulator (10.0.2.2:3000)')),
                  );
                }
              },
              child: const VrText('Android Emulator\n10.0.2.2:3000', textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Custom Server URL (e.g. Wi-Fi IP)',
                hintText: 'http://192.168.1.X:3000/api/v1',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const VrText('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await Prefs.setApiBaseUrl(controller.text.trim());
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: VrText('Target updated to: ${controller.text.trim()}')),
                );
              }
            },
            child: const VrText('Save'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final l10n = AppLocalizations.of(context);
    final activeLocale = ref.watch(activeLocaleProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Brand Header (VanRozgar) with Language Switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  VrText(
                    'वनरोजगार | VanRozgar',
                    style: TextStyle(
                      color: tokens.brandSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  PopupMenuButton<String>(
                    initialValue: activeLocale,
                    onSelected: (lang) => ref.read(activeLocaleProvider.notifier).setLanguage(lang),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'mr', child: VrText('मराठी (MR)')),
                      const PopupMenuItem(value: 'en', child: VrText('English (EN)')),
                      const PopupMenuItem(value: 'hi', child: VrText('हिंदी (HI)')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: tokens.outline),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.translate, size: 14, color: tokens.brandSecondary),
                          const SizedBox(width: 4),
                          VrText(
                            activeLocale == 'en' ? 'English' : (activeLocale == 'hi' ? 'हिंदी' : 'मराठी'),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_drop_down, size: 16, color: tokens.textMuted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: tokens.brandPrimary,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.brandPrimary.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.forest, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              VrText(
                'Sign In',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              VrText(
                'Sign In to VanRozgar • वनरोजगार',
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tokens.chipErrorBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tokens.error.withValues(alpha: 0.3)),
                  ),
                  child: VrText(
                    _errorMessage!,
                    style: TextStyle(color: tokens.error, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              VrText(
                l10n?.phoneNumber != null ? '${l10n!.phoneNumber} (10 digits)' : 'Phone Number (10 digits) • मोबाईल क्रमांक',
                style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone_outlined, color: tokens.brandSecondary, size: 20),
                  prefixText: '+91 ',
                  hintText: AppInputHints.phone(context),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: tokens.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: tokens.outline),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              VrText(
                l10n?.password != null ? '${l10n!.password} (PIN)' : 'PIN (6 digits) / Password • पासवर्ड',
                style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, color: tokens.brandSecondary, size: 20),
                  hintText: AppInputHints.password(context),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: tokens.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: tokens.outline),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: tokens.textMuted),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/help/forgot-password'),
                  child: VrText(
                    'पासवर्ड विसरलात? (Help)',
                    style: TextStyle(color: tokens.brandSecondary, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.actionPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : VrText(l10n?.login ?? 'लॉगिन करा • Login', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VrText('नवीन आहात? • New here?  ', style: TextStyle(color: tokens.textMuted, fontSize: 14)),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: VrText(
                      'खाते तयार करा (Sign Up)',
                      style: TextStyle(color: tokens.actionPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              // Security & Privacy notice matching video 01:17
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: tokens.outline),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: tokens.brandSecondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: VrText(
                        'Your name, phone and village are stored on the VanRozgar server. Your PIN is stored only as a one-way hash. See About & Privacy.',
                        style: TextStyle(color: tokens.textMuted, fontSize: 11.5, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              if (AppConfig.devTools) ...[
                const SizedBox(height: 32),
                // Fast Demo Logins Section for local pilot testing
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: tokens.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VrText(
                        'Try a demo account (डेमो खाते):',
                        style: TextStyle(color: tokens.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ActionChip(
                            label: const VrText('Gram Sabha'),
                            onPressed: () => _fillDemo('+919822011001', 'gramsabha'),
                          ),
                          ActionChip(
                            label: const VrText('Farmer'),
                            onPressed: () => _fillDemo('+919822022222', 'villager'),
                          ),
                          ActionChip(
                            label: const VrText('CFR holder'),
                            onPressed: () => _fillDemo('+919822044444', 'cfrholder'),
                          ),
                          ActionChip(
                            label: const VrText('Buyer'),
                            onPressed: () => _fillDemo('+919822033333', 'buyer'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.settings_ethernet, size: 16),
                            label: const VrText('Server Target 🌐'),
                            onPressed: _showServerDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<String?>(
                        future: Prefs.getApiBaseUrl(),
                        builder: (context, snap) {
                          final url = snap.data ?? AppConfig.apiBaseUrl;
                          return VrText(
                            '📡 Target: $url',
                            style: TextStyle(color: tokens.textMuted, fontSize: 11, fontFamily: 'monospace'),
                          );
                        },
                      ),
                    ],
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
