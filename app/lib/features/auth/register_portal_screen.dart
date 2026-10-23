import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';

class RegisterPortalScreen extends StatelessWidget {
  const RegisterPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    Widget buildPortalCard({
      required String role,
      required String titleMr,
      required String titleEn,
      required String description,
      required IconData icon,
      required Color color,
    }) {
      return GestureDetector(
        onTap: () => context.push('/register/$role'),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tokens.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VrText(
                      '$titleMr • $titleEn',
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    VrText(
                      description,
                      style: TextStyle(color: tokens.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: tokens.textMuted, size: 22),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const VrText('पोर्टल निवडा • Choose Portal'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VrText(
                'आपली भूमिका निवडा',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              VrText(
                'Select your participation role in the VanRozgar CFR marketplace.',
                style: TextStyle(color: tokens.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              buildPortalCard(
                role: 'gramsabha',
                titleMr: 'ग्रामसभा',
                titleEn: 'Gram Sabha',
                description: 'सामूहिक वनहक्क (CFR) धारक गाव प्रतिनिधी. गावाच्या वनोपजांची विक्री व व्यवस्थापन.',
                icon: Icons.account_balance,
                color: tokens.brandSecondary,
              ),
              buildPortalCard(
                role: 'villager',
                titleMr: 'ग्रामस्थ / शेतकरी',
                titleEn: 'Villager',
                description: 'CFR गावातील रहिवासी. वनोपज खरेदी, वस्तुविनिमय आणि वाहन असल्यास डिलिव्हरीद्वारे रोजगार.',
                icon: Icons.person_pin,
                color: tokens.actionPrimary,
              ),
              buildPortalCard(
                role: 'buyer',
                titleMr: 'व्यापारी / खरेदीदार',
                titleEn: 'General Buyer',
                description: 'कंपनी, आयुर्वेदिक ब्रँड किंवा बाहेरील खरेदीदार. थेट ग्रामसभेकडून शुद्ध वनोपज खरेदी.',
                icon: Icons.storefront,
                color: const Color(0xFF2F5FB3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
