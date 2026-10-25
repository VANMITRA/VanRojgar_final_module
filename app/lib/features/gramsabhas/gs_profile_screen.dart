import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/geo/talukas.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/badges.dart';
import '../auth/auth_providers.dart';

final gsDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/gramsabhas/$id');
  return Map<String, dynamic>.from(res as Map);
});

/// A Gram Sabha of the dataset (the 14 CFR villages of the Raah Foundation report): who it is and the restoration
/// figures of its community forest. Everything shown comes from the server; a missing value is shown as
/// "not available", never filled in.
class GsProfileScreen extends ConsumerWidget {
  final String gramSabhaId;

  const GsProfileScreen({super.key, required this.gramSabhaId});

  static const _na = 'उपलब्ध नाही • not available';

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
            final restoration = gs['restoration'] as Map<String, dynamic>?;
            final status = (gs['verificationStatus'] as String?) ?? 'pending';
            final isDemo = status == 'verified_seed' || gs['isDemoData'] == true;
            final claimStatus = (gs['claim'] as Map?)?['status'] as String?;

            return RefreshIndicator(
              onRefresh: () async => ref.refresh(gsDetailProvider(gramSabhaId).future),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _hero(tokens, gs, status, isDemo, claimStatus),
                  const SizedBox(height: 12),
                  _sourceNote(tokens, isDemo),
                  const SizedBox(height: 16),
                  ..._restorationCards(tokens, restoration),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const VrText('माहिती मिळाली नाही • Could not load this profile'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(gsDetailProvider(gramSabhaId)),
                    child: const VrText('पुन्हा प्रयत्न करा • Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(num v) => v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  Widget _hero(VrTokens tokens, Map<String, dynamic> gs, String status, bool isDemo, String? claimStatus) {
    final String chip;
    if (isDemo) {
      chip = 'डेमो लॉगिन • Demo login';
    } else if (claimStatus == 'pending') {
      chip = 'दावा तपासणीत • Claim under review';
    } else if (status == 'verified') {
      chip = 'सत्यापित • Verified';
    } else {
      chip = 'Raah Foundation अहवाल • Report';
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: tokens.brandPrimary, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TrustTag(status: status),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isDemo ? Colors.amber : Colors.white).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDemo ? Colors.amberAccent : Colors.white54),
                  ),
                  child: VrText(
                    chip,
                    style: TextStyle(
                      color: isDemo ? Colors.amberAccent : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          VrText(
            (gs['name'] as Map?)?['mr'] ?? 'ग्रामसभा',
            style: TextStyle(color: tokens.onBrand, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          VrText(
            '${talukaLabel('${gs['taluka'] ?? ''}')} • जिल्हा ${gs['district'] ?? 'Nashik'}',
            style: TextStyle(color: tokens.onBrand.withValues(alpha: 0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _sourceNote(VrTokens tokens, bool isDemo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDemo ? Colors.amber : tokens.outline).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: isDemo ? Colors.amber : tokens.brandSecondary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: VrText(
              isDemo
                  ? 'टीप: या गावाचे लॉगिन प्रात्यक्षिकासाठी आहे; गावाची आकडेवारी Raah Foundation अहवालातील आहे. (The login on this village is a demo; the figures are from the Raah Foundation report.)'
                  : 'स्रोत: Raah Foundation अहवाल, 1 ऑक्टोबर 2026. (Source: Raah Foundation report, 1 October 2026.)',
              style: TextStyle(color: tokens.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(VrTokens tokens,
      {required IconData icon, required Color iconColor, required String title, required List<Widget> children}) {
    return Container(
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
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: VrText(title, style: TextStyle(color: tokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _fact(VrTokens tokens, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 3, child: VrText(label, style: TextStyle(color: tokens.textMuted, fontSize: 13))),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: VrText(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  List<Widget> _restorationCards(VrTokens tokens, Map<String, dynamic>? r) {
    if (r == null) {
      return [
        _card(
          tokens,
          icon: Icons.park_outlined,
          iconColor: tokens.brandPrimary,
          title: 'वन पुनरुज्जीवन (Forest restoration)',
          children: [VrText(_na, style: TextStyle(color: tokens.textMuted, fontSize: 13))],
        ),
      ];
    }
    String n(Object? v, [String unit = '']) => v == null ? _na : '${_group(v as num)}$unit';
    final species = (r['species'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return [
      _card(
        tokens,
        icon: Icons.park_outlined,
        iconColor: tokens.brandPrimary,
        title: 'वन पुनरुज्जीवन (Forest restoration)',
        children: [
          _fact(tokens, 'CFR क्षेत्र • CFR area', n(r['cfrAreaHa'], ' ha')),
          _fact(tokens, 'लावलेली रोपे • Saplings planted and nurtured', n(r['saplings'])),
          _fact(tokens, 'वन तळी • Forest ponds', n(r['forestPonds'])),
          _fact(tokens, 'पाणी साठवण क्षमता • Water storage', n(r['waterCapacityLitres'], ' litres')),
          _fact(tokens, 'दगडी बंधारे (LBS) • Loose boulder structures', n(r['looseBoulderStructures'])),
          _fact(tokens, 'रोजगार दिवस • Labour days', n(r['labourDays'])),
          _fact(tokens, 'CFRMC बैठका • CFRMC meetings', n(r['cfrmcMeetings'])),
          _fact(tokens, 'वन्यजीव जागृती सत्रे • Wildlife awareness sessions', n(r['wildlifeSessions'])),
        ],
      ),
      const SizedBox(height: 16),
      _card(
        tokens,
        icon: Icons.nature_outlined,
        iconColor: tokens.brandSecondary,
        title: 'लागवडीच्या प्रजाती (Plantation species)',
        children: species.isEmpty
            ? [
                VrText(
                  'अहवालात या गावाची प्रजाती यादी नाही (The report has no species list for this village).',
                  style: TextStyle(color: tokens.textMuted, fontSize: 13),
                ),
              ]
            : [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final sp in species)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: VrText(
                          sp['count'] == null ? '${sp['name']}' : '${sp['name']} • ${_group(sp['count'] as num)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
      ),
      const SizedBox(height: 8),
      VrText(
        'स्रोत: ${r['source'] ?? 'Raah Foundation report'}. आकडे अहवालात छापल्याप्रमाणे. (Figures as printed in the report.)',
        style: TextStyle(color: tokens.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
      ),
    ];
  }

  /// Thousands grouping: 217708 -> 217,708.
  String _group(num v) {
    final digits = _fmt(v);
    final dot = digits.indexOf('.');
    final whole = dot < 0 ? digits : digits.substring(0, dot);
    final grouped = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return dot < 0 ? grouped : grouped + digits.substring(dot);
  }
}
