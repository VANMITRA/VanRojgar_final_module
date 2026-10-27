import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import '../../core/theme/tokens.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    return Scaffold(
      appBar: AppBar(title: const VrText('मदत व संकेतशब्द पुनर्संचयित • Help & password recovery')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Icon(Icons.support_agent, size: 70, color: tokens.brandSecondary),
              const SizedBox(height: 20),
              VrText(
                'पासवर्ड विसरलात?',
                style: TextStyle(color: tokens.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              VrText(
                'नाशिक पायलट आवृत्तीमध्ये सुरक्षिततेसाठी थेट एसएमएस ओटीपीऐवजी ग्रामसभा सचिव किंवा वनरोजगार समन्वयकाकडून पडताळणी केली जाते.',
                style: TextStyle(color: tokens.textMuted, fontSize: 14, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: tokens.outline),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone, color: tokens.brandPrimary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: VrText(
                            'मदतीसाठी तुमच्या ग्रामसभेशी किंवा VanRozgar टीमशी संपर्क साधा • Contact your Gram Sabha or the VanRozgar team',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(Icons.email, color: tokens.brandPrimary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: VrText(
                            'सहाय्य ईमेल:\nsupport@vanrozgar.org',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
