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

/// A Gram Sabha: who it is, the community forest rights on the district CFR register, the individual claims,
/// and the village facts from the MRSAC geoportal. Everything shown comes from the server; a missing value is
/// shown as "not available", never filled in.
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
            final profile = data['villageProfile'] as Map<String, dynamic>?;
            final claims = (data['claims'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
            final cfr = gs['cfr'] as Map<String, dynamic>? ?? {};
            final rights = (cfr['rights'] as List? ?? []).cast<String>();
            final status = (gs['verificationStatus'] as String?) ?? 'pending';
            final isDemo = status == 'verified_seed' || gs['isDemoData'] == true;
            final claimStatus = (gs['claim'] as Map?)?['status'] as String?;
            final approvedCount = claims.where((c) => c['decision'] == 'approved').length;
            final approvedArea = (cfr['approvedAreaHa'] as num?)?.toDouble() ?? 0;

            return RefreshIndicator(
              onRefresh: () async => ref.refresh(gsDetailProvider(gramSabhaId).future),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _hero(tokens, gs, status, isDemo, claimStatus),
                  const SizedBox(height: 12),
                  _sourceNote(tokens, isDemo),
                  const SizedBox(height: 16),
                  _card(
                    tokens,
                    icon: Icons.gavel,
                    iconColor: tokens.brandSecondary,
                    title: 'सामूहिक वनहक्क (CFR Rights)',
                    children: [
                      if (rights.isEmpty)
                        VrText(
                          isDemo ? 'डेमो गाव: हक्क नोंदवलेले नाहीत (Demo village, no rights recorded)' : 'नोंदवही मध्ये हक्कांचा प्रकार नाही (No right type recorded)',
                          style: TextStyle(color: tokens.textMuted, fontSize: 13),
                        )
                      else
                        Wrap(spacing: 8, runSpacing: 8, children: rights.map((r) => RightsBadge(clause: r)).toList()),
                      const Divider(height: 24),
                      _fact(tokens, 'दावे • Claims on record', claims.isEmpty ? _na : '${claims.length}'),
                      _fact(tokens, 'मंजूर दावे • Approved claims', claims.isEmpty ? _na : '$approvedCount'),
                      _fact(tokens, 'मंजूर CFR क्षेत्र • Approved area', approvedCount == 0 ? _na : '${_fmt(approvedArea)} ha'),
                    ],
                  ),
                  if (claims.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _card(
                      tokens,
                      icon: Icons.assignment_outlined,
                      iconColor: tokens.brandPrimary,
                      title: 'दावे (Claims in the district register)',
                      children: [for (final c in claims) _claimRow(tokens, c)],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _card(
                    tokens,
                    icon: Icons.landscape,
                    iconColor: tokens.brandPrimary,
                    title: 'गावातील नैसर्गिक संसाधने (MRSAC Facts)',
                    children: profile == null
                        ? [
                            VrText(
                              isDemo
                                  ? 'डेमो गाव: MRSAC माहिती जोडलेली नाही (Demo village, no MRSAC profile)'
                                  : 'या गावासाठी MRSAC माहिती जुळली नाही (No MRSAC profile matched this village)',
                              style: TextStyle(color: tokens.textMuted, fontSize: 13),
                            ),
                          ]
                        : _profileRows(tokens, profile),
                  ),
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
      chip = '⚠️ डेमो डेटा (Demo)';
    } else if (claimStatus == 'pending') {
      chip = 'दावा तपासणीत • Claim under review';
    } else if (status == 'verified') {
      chip = 'सत्यापित • Verified';
    } else {
      chip = 'जिल्हा CFR नोंदवही • District CFR register';
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
                  ? 'टीप: हे गाव प्रात्यक्षिकासाठी आहे. येथील उत्पादने व खाती डेमो डेटा आहेत. (This village is for demonstration; its listings and accounts are demo data.)'
                  : 'स्रोत: जिल्हा समितीची CFR नोंदवही 2026 आणि MRSAC जिओपोर्टल. (Source: district CFR register 2026 and the MRSAC geoportal.)',
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

  Widget _claimRow(VrTokens tokens, Map<String, dynamic> c) {
    final decision = c['decision'] as String? ?? 'pending';
    final recorded = c['decisionRecorded'] != false;
    final (label, color) = switch (decision) {
      'approved' => ('मंजूर • Approved', tokens.success),
      'rejected' => ('नामंजूर • Rejected', tokens.error),
      _ => (recorded ? 'प्रलंबित • Pending' : 'निर्णय नोंद नाही • No decision recorded', tokens.warning),
    };
    final rights = (c['rights'] as List? ?? []).join(', ');
    final claimed = (c['areaClaimedHa'] as num?) ?? 0;
    final approved = (c['areaApprovedHa'] as num?) ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: VrText('दावा क्र. ${c['caseNo'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              Flexible(child: VrText(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 4),
          if (rights.isNotEmpty) VrText('हक्क: $rights', style: TextStyle(color: tokens.textMuted, fontSize: 12)),
          if ((c['compartment'] as String?)?.isNotEmpty ?? false)
            VrText('वनकक्ष / गट: ${c['compartment']}', style: TextStyle(color: tokens.textMuted, fontSize: 12)),
          VrText(
            'मागणी: ${_fmt(claimed)} ha • मंजूर: ${decision == 'approved' ? _fmt(approved) : '-'} ha',
            style: TextStyle(color: tokens.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  List<Widget> _profileRows(VrTokens tokens, Map<String, dynamic> p) {
    String n(Object? v, [String unit = '']) => v == null ? _na : '${v is num ? _fmt(v) : v}$unit';
    final raw = (p['rawDetails'] as Map?)?.map((k, v) => MapEntry('$k', '$v')) ?? <String, String>{};
    return [
      _fact(tokens, 'गावाचे क्षेत्र • Village area', n(p['villageAreaHa'], ' ha')),
      _fact(tokens, 'वन क्षेत्र • Forest area', n(p['forestHa'], ' ha')),
      _fact(tokens, 'जलस्रोत • Water bodies', n(p['waterBodiesCount'])),
      _fact(tokens, 'विहिरी • Wells', n(p['wellsTotal'])),
      _fact(tokens, 'जलसंधारण कामे • Water conservation works', n(p['waterConservationWorks'])),
      _fact(tokens, 'मृदा प्रकार • Soil', n(p['soilType'])),
      if (raw.isNotEmpty) ...[
        const Divider(height: 24),
        for (final e in raw.entries)
          Theme(
            data: ThemeData(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: VrText(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              children: [Align(alignment: Alignment.centerLeft, child: VrText(e.value, style: TextStyle(color: tokens.textMuted, fontSize: 12)))],
            ),
          ),
      ],
      const SizedBox(height: 8),
      VrText(
        'स्रोत: MRSAC जिओपोर्टल, ऑक्टोबर 2026 (Source: MRSAC geoportal, October 2026). आकडे जसे छापले तसे.',
        style: TextStyle(color: tokens.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
      ),
    ];
  }
}
