import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import 'auth_providers.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(activeLocaleProvider);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0E1B15) : tokens.background;
    final surfaceColor = isDark ? const Color(0xFF142920) : tokens.surface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Brand Header (video 01:14)
              Center(
                child: VrText(
                  'वनरोजगार | VanRozgar',
                  style: TextStyle(
                    color: tokens.brandSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title & Subtitle
              VrText(
                _getTitle(),
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              VrText(
                _getSubtitle(),
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 2x2 Language Grid (video 01:14)
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildLangCard(
                      code: 'en',
                      iconWidget: _buildFlagBadge('🇬🇧'),
                      name: 'English',
                      subName: 'English',
                      surfaceColor: surfaceColor,
                      tokens: tokens,
                    ),
                    _buildLangCard(
                      code: 'hi',
                      iconWidget: _buildFlagBadge('🇮🇳'),
                      name: 'हिंदी',
                      subName: 'Hindi',
                      surfaceColor: surfaceColor,
                      tokens: tokens,
                    ),
                    _buildLangCard(
                      code: 'mr',
                      iconWidget: const Icon(Icons.account_balance, size: 36, color: Color(0xFFC97B3C)),
                      name: 'मराठी',
                      subName: 'Marathi',
                      surfaceColor: surfaceColor,
                      tokens: tokens,
                    ),
                  ],
                ),
              ),

              // Continue Button
              ElevatedButton(
                onPressed: () async {
                  await ref.read(activeLocaleProvider.notifier).setLanguage(_selected);
                  if (_selected == 'en' || _selected == 'hi' || _selected == 'mr') {
                    // Save to the account so the next login keeps this language
                    ref.read(apiClientProvider).patch('/auth/profile', data: {'language': _selected}).catchError((_) => null);
                  }
                  if (context.mounted) {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/login');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.actionPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: VrText(
                  _getButtonLabel(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlagBadge(String emoji) {
    return VrText(emoji, style: const TextStyle(fontSize: 38));
  }

  Widget _buildLangCard({
    required String code,
    required Widget iconWidget,
    required String name,
    required String subName,
    required Color surfaceColor,
    required VrTokens tokens,
  }) {
    final isSelected = _selected == code;

    return GestureDetector(
      onTap: () => setState(() => _selected = code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? tokens.actionPrimary : tokens.outline,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tokens.actionPrimary.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconWidget,
                  const SizedBox(height: 12),
                  VrText(
                    name,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  VrText(
                    subName,
                    style: TextStyle(
                      color: tokens.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tokens.actionPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: VrText(
                      '✔ Selected',
                      style: TextStyle(
                        color: tokens.actionPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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

  String _getTitle() {
    switch (_selected) {
      case 'hi': return 'भाषा चुनें';
      case 'mr': return 'भाषा निवडा';
      default: return 'Choose Your Language';
    }
  }

  String _getSubtitle() {
    switch (_selected) {
      case 'hi': return 'अपनी पसंदीदा भाषा चुनें';
      case 'mr': return 'आपली पसंतीची भाषा निवडा';
      default: return 'Select your preferred language';
    }
  }

  String _getButtonLabel() {
    switch (_selected) {
      case 'hi': return 'आगे बढ़ें →';
      case 'mr': return 'पुढे जा →';
      default: return 'Continue →';
    }
  }
}
