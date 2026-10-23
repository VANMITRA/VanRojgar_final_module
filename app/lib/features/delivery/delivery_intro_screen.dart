import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';

class DeliveryIntroScreen extends StatelessWidget {
  const DeliveryIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    return Scaffold(
      appBar: AppBar(title: const VrText('डिलिव्हरी पार्टनर • Livelihood')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: tokens.brandPrimary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Icon(Icons.two_wheeler, size: 64, color: tokens.actionPrimary),
                    const SizedBox(height: 12),
                    VrText(
                      'वाहतुकीतून थेट रोजगार!',
                      style: TextStyle(color: tokens.onBrand, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    VrText(
                      'CFR गावातील वनोपज खरेदीदारांपर्यंत पोहोचवा आणि प्रति किलोमीटर सन्मानजनक मोबदला मिळवा.',
                      style: TextStyle(color: tokens.onBrand.withValues(alpha: 0.85), fontSize: 13, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              VrText(
                'पार्टनर बनण्याचे फायदे:',
                style: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildBenefitRow(Icons.currency_rupee, 'थेट उत्पन्न', 'प्रत्येक यशस्वी डिलिव्हरीनंतर थेट मोबदला जमा.'),
              _buildBenefitRow(Icons.schedule, 'लवचिक वेळ', 'आपल्या वेळेनुसार उपलब्ध/अनुपलब्ध (Available toggle) करा.'),
              _buildBenefitRow(Icons.handshake, 'गावच्या विकासात सहभाग', 'ग्रामसभेच्या वनोपज व्यापारास बळकटी.'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.push('/delivery/apply'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.actionPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const VrText('अर्ज करा • Apply Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF2D765C).withValues(alpha: 0.15),
            child: Icon(icon, size: 18, color: const Color(0xFF2D765C)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VrText(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                VrText(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
