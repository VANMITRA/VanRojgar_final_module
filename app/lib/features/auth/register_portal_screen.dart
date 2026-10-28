import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import 'auth_providers.dart';

class RegisterPortalScreen extends ConsumerWidget {
  const RegisterPortalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.vr;
    final lang = ref.watch(activeLocaleProvider);

    Widget buildPortalCard({
      required String role,
      required String title,
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
                    Text(
                      title,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
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
        title: Text(tr3(lang, en: 'Choose Portal', hi: 'पोर्टल चुनें', mr: 'पोर्टल निवडा')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                tr3(lang, en: 'Choose your role', hi: 'अपनी भूमिका चुनें', mr: 'आपली भूमिका निवडा'),
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr3(lang,
                    en: 'Select your role in the VanMitra CFR marketplace.',
                    hi: 'वनरोज़गार सीएफआर बाज़ार में अपनी भूमिका चुनें।',
                    mr: 'वनमित्र सीएफआर बाजारातील तुमची भूमिका निवडा.'),
                style: TextStyle(color: tokens.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              buildPortalCard(
                role: 'gramsabha',
                title: tr3(lang, en: 'Gram Sabha', hi: 'ग्राम सभा', mr: 'ग्रामसभा'),
                description: tr3(lang,
                    en: "Representative of a village with community forest rights (CFR). Lists and manages the village's forest produce.",
                    hi: 'सामुदायिक वन अधिकार (CFR) वाले गाँव का प्रतिनिधि। गाँव की वनोपज की बिक्री और प्रबंधन।',
                    mr: 'सामूहिक वनहक्क (CFR) धारक गाव प्रतिनिधी. गावाच्या वनोपजांची विक्री व व्यवस्थापन.'),
                icon: Icons.account_balance,
                color: tokens.brandSecondary,
              ),
              buildPortalCard(
                role: 'villager',
                title: tr3(lang, en: 'Farmer', hi: 'किसान', mr: 'शेतकरी'),
                description: tr3(lang,
                    en: 'Resident of a CFR village. Buy produce, barter, and earn through delivery if you have a vehicle.',
                    hi: 'CFR गाँव के निवासी। वनोपज खरीदें, वस्तु-विनिमय करें, और वाहन हो तो डिलीवरी से रोज़गार पाएँ।',
                    mr: 'CFR गावातील रहिवासी. वनोपज खरेदी, वस्तुविनिमय आणि वाहन असल्यास डिलिव्हरीद्वारे रोजगार.'),
                icon: Icons.person_pin,
                color: tokens.actionPrimary,
              ),
              buildPortalCard(
                role: 'cfrholder',
                title: tr3(lang, en: 'CFR holder', hi: 'सीएफआर धारक', mr: 'सीएफआर धारक'),
                description: tr3(lang,
                    en: 'Farmer with community forest rights. Everything a farmer gets, plus the livelihood report.',
                    hi: 'सामुदायिक वन अधिकार वाले किसान। किसान की सभी सुविधाएँ, साथ में आजीविका रिपोर्ट (Livelihood)।',
                    mr: 'सामूहिक वनहक्क असलेला शेतकरी. शेतकऱ्याचे सर्व काही, तसेच उपजीविका अहवाल (Livelihood).'),
                icon: Icons.forest,
                color: tokens.brandPrimary,
              ),
              buildPortalCard(
                role: 'buyer',
                title: tr3(lang, en: 'General Buyer', hi: 'आम खरीदार', mr: 'व्यापारी / खरेदीदार'),
                description: tr3(lang,
                    en: 'A company, Ayurvedic brand or outside buyer. Buy pure forest produce directly from Gram Sabhas.',
                    hi: 'कंपनी, आयुर्वेदिक ब्रांड या बाहरी खरीदार। ग्राम सभाओं से सीधे शुद्ध वनोपज खरीदें।',
                    mr: 'कंपनी, आयुर्वेदिक ब्रँड किंवा बाहेरील खरेदीदार. थेट ग्रामसभेकडून शुद्ध वनोपज खरेदी.'),
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
