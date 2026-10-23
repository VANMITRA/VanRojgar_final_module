import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/async_value_view.dart';
import '../auth/auth_providers.dart';

final pendingGramSabhasProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/admin/gramsabhas');
  return res as List? ?? [];
});

final pendingPartnersProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/admin/delivery-partners');
  return res as List? ?? [];
});

class TeamToolsScreen extends ConsumerWidget {
  const TeamToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.vr;
    final pendingGsAsync = ref.watch(pendingGramSabhasProvider);
    final pendingPartnersAsync = ref.watch(pendingPartnersProvider);

    return Scaffold(
      appBar: AppBar(title: const VrText('प्रशासक साधने • Team Back Office')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VrText(
                'पडताळणी प्रलंबित ग्रामसभा (Pending Gram Sabhas)',
                style: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              AsyncValueView(
                value: pendingGsAsync,
                emptyMessage: 'कोणतीही ग्रामसभा प्रलंबित नाही',
                data: (list) {
                  return Column(
                    children: list.map((gs) {
                      final claim = gs['claim'] as Map<String, dynamic>?;
                      final claimantText = claim != null && claim['claimantName'] != null
                          ? 'दावेदार: ${claim['claimantName']} (${claim['designation'] ?? "प्रतिनिधी"}) • ${claim['claimantPhone'] ?? ""}\nठराव: ${claim['resolutionNo'] ?? "CFR/2026"}'
                          : '${gs['taluka']} • ${gs['phone'] ?? "संपर्क नाही"}';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: ListTile(
                            title: VrText(gs['name']?['mr'] ?? 'Gram Sabha', style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: VrText(claimantText, style: TextStyle(fontSize: 12, color: tokens.textMuted)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'मंजूर करा (Approve Claim)',
                                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                                  onPressed: () async {
                                    final api = ref.read(apiClientProvider);
                                    await api.patch('/admin/gramsabhas/${gs['_id']}/verification', data: {'status': 'verified'});
                                    ref.invalidate(pendingGramSabhasProvider);
                                  },
                                ),
                                IconButton(
                                  tooltip: 'नाकारा (Reject)',
                                  icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                                  onPressed: () async {
                                    final api = ref.read(apiClientProvider);
                                    await api.patch('/admin/gramsabhas/${gs['_id']}/verification', data: {'status': 'rejected'});
                                    ref.invalidate(pendingGramSabhasProvider);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              VrText(
                'पडताळणी प्रलंबित डिलिव्हरी पार्टनर (Pending Partners)',
                style: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              AsyncValueView(
                value: pendingPartnersAsync,
                emptyMessage: 'कोणताही अर्ज प्रलंबित नाही',
                data: (list) {
                  return Column(
                    children: list.map((partner) {
                      final u = partner['userId'] as Map<String, dynamic>? ?? {};
                      return Card(
                        child: ListTile(
                          title: VrText(u['name'] ?? 'Partner'),
                          subtitle: VrText('${partner['vehicle']?['number'] ?? ""} (${partner['vehicle']?['type'] ?? ""})'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  final api = ref.read(apiClientProvider);
                                  await api.patch('/admin/delivery-partners/${partner['_id']}/approval', data: {'status': 'approved'});
                                  ref.invalidate(pendingPartnersProvider);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  final api = ref.read(apiClientProvider);
                                  await api.patch('/admin/delivery-partners/${partner['_id']}/approval', data: {'status': 'rejected'});
                                  ref.invalidate(pendingPartnersProvider);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
