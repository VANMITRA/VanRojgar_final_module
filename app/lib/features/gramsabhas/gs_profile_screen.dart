import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/badges.dart';
import '../auth/auth_providers.dart';

final gsDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/gramsabhas/$id');
  return Map<String, dynamic>.from(res as Map);
});

class GsProfileScreen extends ConsumerWidget {
  final String gramSabhaId;

  const GsProfileScreen({super.key, required this.gramSabhaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.vr;
    final gsAsync = ref.watch(gsDetailProvider(gramSabhaId));

    return Scaffold(
      appBar: AppBar(title: const VrText('ग्रामसभा प्रोफाइल • Profile')),
      body: SafeArea(
        child: gsAsync.when(
          data: (data) {
            final gs = data['gramSabha'] as Map<String, dynamic>? ?? {};
            final villageProfile = data['villageProfile'] as Map<String, dynamic>?;
            final cfr = gs['cfr'] as Map<String, dynamic>? ?? {};
            final rights = (cfr['rights'] as List? ?? ['3(1)(c)', '3(1)(d)', '3(1)(i)']).cast<String>();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: tokens.brandPrimary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TrustTag(status: gs['verificationStatus'] ?? 'verified_seed'),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amberAccent),
                              ),
                              child: const VrText(
                                '⚠️ डेमो डेटा (Demo)',
                                style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        VrText(
                          gs['name']?['mr'] ?? 'ग्रामसभा',
                          style: TextStyle(color: tokens.onBrand, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        VrText(
                          '${gs['taluka']} • जिल्हा नाशिक (नाशिक पायलट)',
                          style: TextStyle(color: tokens.onBrand.withValues(alpha: 0.8), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Demo Data Notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: VrText(
                            'टीप: १६ गावांचे वनहक्क व MRSAC क्षेत्र प्रात्यक्षिक स्वरूपात (Demo Placeholders) दर्शविले आहे. प्रत्यक्ष डेटा दुसऱ्या टप्प्यात आयात केला जाईल.',
                            style: TextStyle(color: tokens.textMuted, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CFR Rights Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: tokens.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.gavel, color: tokens.brandSecondary, size: 20),
                            const SizedBox(width: 8),
                            VrText(
                              'सामूहिक वनहक्क (CFR Rights)',
                              style: TextStyle(color: tokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: rights.map((r) => RightsBadge(clause: r)).toList(),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            VrText('मान्य CFR वनक्षेत्र:', style: TextStyle(color: tokens.textMuted, fontSize: 13)),
                            VrText(
                              '${cfr['approvedAreaHa'] ?? "45.5"} हेक्टर (ha)',
                              style: TextStyle(color: tokens.brandSecondary, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // MRSAC Village Resources Profile
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: tokens.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.landscape, color: tokens.brandPrimary, size: 20),
                            const SizedBox(width: 8),
                            VrText(
                              'गावातील नैसर्गिक संसाधने (MRSAC Facts)',
                              style: TextStyle(color: tokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildFactRow('वन आच्छादन (Forest Area)', '${villageProfile?['forestHa'] ?? "124"} हेक्टर'),
                        _buildFactRow('जलस्रोत व तलाव (Water Bodies)', '${villageProfile?['waterBodiesCount'] ?? "4"}'),
                        _buildFactRow('विहिरींची संख्या (Wells)', '${villageProfile?['wellsTotal'] ?? "28"}'),
                        _buildFactRow('मृदा प्रकार (Soil)', villageProfile?['soilType'] ?? 'काळी कसदार आणि डोंगराळ'),
                        const SizedBox(height: 8),
                        VrText(
                          'स्रोत: MRSAC जिओपोर्टल • प्रायोगिक डेमो डेटा (Placeholder Data)',
                          style: TextStyle(color: tokens.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: VrText('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildFactRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          VrText(label, style: const TextStyle(fontSize: 13)),
          VrText(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
