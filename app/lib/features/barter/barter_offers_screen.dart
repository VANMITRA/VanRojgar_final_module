import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/tokens.dart';
import '../../core/network/app_exception.dart';
import '../../shared/widgets/async_value_view.dart';
import '../../shared/widgets/underline_tabs.dart';
import '../auth/auth_providers.dart';

final barterOffersProvider = FutureProvider.family<List<dynamic>, String>((ref, scope) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/barter-requests?scope=$scope');
  return res as List? ?? [];
});

class BarterOffersScreen extends ConsumerStatefulWidget {
  const BarterOffersScreen({super.key});

  @override
  ConsumerState<BarterOffersScreen> createState() => _BarterOffersScreenState();
}

class _BarterOffersScreenState extends ConsumerState<BarterOffersScreen> {
  int _selectedTab = 0; // 0 = Incoming, 1 = Sent

  void _showCounterDialog(Map<String, dynamic> barter) {
    final versions = barter['versions'] as List? ?? [];
    final latestVersion = versions.isNotEmpty ? versions.last as Map<String, dynamic> : {};
    final offered = latestVersion['offered'] as Map<String, dynamic>? ?? {};
    final wanted = latestVersion['wanted'] as Map<String, dynamic>? ?? {};

    final titleController = TextEditingController(text: offered['title'] ?? '');
    final offeredQtyController = TextEditingController(text: '${offered['quantity'] ?? 1}');
    final wantedQtyController = TextEditingController(text: '${wanted['quantity'] ?? 1}');
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const VrText('प्रति-ऑफर द्या (Counter Offer)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VrText(
                'बदल्यात द्यावयाचे उत्पादन व प्रमाण बदला:',
                style: TextStyle(color: context.vr.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'बदल्यात देण्याचे उत्पादन (Offered Item)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: offeredQtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'देण्याचे प्रमाण (Offered Quantity)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: wantedQtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'हवे असलेले प्रमाण (Wanted Quantity)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'टिप / कारण (Note)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const VrText('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final api = ref.read(apiClientProvider);
                await api.post('/barter-requests/${barter['_id']}/respond', data: {
                  'action': 'counter',
                  'counterOfferedTitle': titleController.text.trim(),
                  'counterOfferedQuantity': double.tryParse(offeredQtyController.text.trim()) ?? 1,
                  'counterWantedQuantity': double.tryParse(wantedQtyController.text.trim()) ?? 1,
                  'note': noteController.text.trim(),
                });
                ref.invalidate(barterOffersProvider('incoming'));
                ref.invalidate(barterOffersProvider('mine'));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: VrText('प्रति-ऑफर पाठवली! (Counter offer sent)')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: VrText(e is AppException ? e.localizedMessage : 'अयशस्वी.')),
                  );
                }
              }
            },
            child: const VrText('Send Counter'),
          ),
        ],
      ),
    );
  }

  Future<void> _respondBarter(String barterId, String action) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/barter-requests/$barterId/respond', data: {'action': action});
      ref.invalidate(barterOffersProvider('incoming'));
      ref.invalidate(barterOffersProvider('mine'));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: VrText(action == 'accept'
              ? 'वस्तुविनिमय करार मंजूर झाला! (Barter agreement accepted)'
              : 'ऑफर नाकारली. (Barter offer declined)'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: VrText(e is AppException ? e.localizedMessage : 'कृती अयशस्वी.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final scope = _selectedTab == 0 ? 'incoming' : 'mine';
    final offersAsync = ref.watch(barterOffersProvider(scope));

    return Scaffold(
      appBar: AppBar(
        title: const VrText('वस्तुविनिमय ऑफर्स • Barter Offers'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            UnderlineTabs(
              tabs: const ['येणाऱ्या ऑफर्स (Incoming)', 'माझ्या ऑफर्स (Sent)'],
              selectedIndex: _selectedTab,
              onTabSelected: (idx) => setState(() => _selectedTab = idx),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(barterOffersProvider(scope)),
                child: AsyncValueView(
                  value: offersAsync,
                  emptyMessage: _selectedTab == 0
                      ? 'सध्या कोणतीही येणारी वस्तुविनिमय ऑफर नाही.\n(No incoming barter offers)'
                      : 'तुम्ही पाठवलेली कोणतीही ऑफर नाही.\n(No sent barter offers)',
                  onRetry: () => ref.invalidate(barterOffersProvider(scope)),
                  data: (offers) {
                    if (offers.isEmpty) {
                      return const Center(child: VrText('कोणतीही वस्तुविनिमय ऑफर उपलब्ध नाही. • No barter offers available.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: offers.length,
                      itemBuilder: (ctx, i) {
                        final barter = offers[i] as Map<String, dynamic>;
                        final targetListing = barter['toListId'] as Map<String, dynamic>? ?? {};
                        final targetTitle = targetListing['title'] is Map
                            ? (targetListing['title']['mr'] ?? targetListing['title']['en'] ?? 'उत्पादन')
                            : (targetListing['title'] ?? 'उत्पादन');

                        final fromUser = barter['fromUserId'] as Map<String, dynamic>? ?? {};
                        final toUser = barter['toOwnerId'] as Map<String, dynamic>? ?? {};
                        final status = barter['status'] as String? ?? 'pending';

                        final versions = barter['versions'] as List? ?? [];
                        final latestVersion = versions.isNotEmpty
                            ? versions.last as Map<String, dynamic>
                            : {};
                        final offered = latestVersion['offered'] as Map<String, dynamic>? ?? {};
                        final wanted = latestVersion['wanted'] as Map<String, dynamic>? ?? {};

                        Color statusColor;
                        String statusLabel;
                        if (status == 'accepted') {
                          statusColor = tokens.success;
                          statusLabel = 'स्वीकारली (Accepted)';
                        } else if (status == 'rejected') {
                          statusColor = tokens.error;
                          statusLabel = 'नाकारली (Declined)';
                        } else if (status == 'countered') {
                          statusColor = tokens.actionPrimary;
                          statusLabel = 'प्रति-ऑफर (Countered)';
                        } else {
                          statusColor = tokens.warning;
                          statusLabel = 'प्रलंबित (Pending)';
                        }

                        final isIncoming = _selectedTab == 0;
                        final canRespond = (status == 'pending' && isIncoming) ||
                            (status == 'countered');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  VrText(
                                    isIncoming
                                        ? 'प्रस्तावक: ${fromUser['name'] ?? "सहकारी"} (${fromUser['village'] ?? ""})'
                                        : 'प्राप्तकर्ता: ${toUser['name'] ?? "ग्रामसभा/शेतकरी"}',
                                    style: TextStyle(
                                      color: tokens.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: VrText(
                                      statusLabel,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 18),
                              VrText(
                                'हवे असलेले उत्पादन: $targetTitle',
                                style: TextStyle(
                                  color: tokens.brandPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              VrText(
                                'प्रमाण: ${wanted['quantity'] ?? 1} ${targetListing['unit'] ?? "kg"}',
                                style: TextStyle(color: tokens.textMuted, fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: tokens.brandSecondary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: tokens.brandSecondary.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.swap_horiz, color: tokens.brandSecondary, size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          VrText(
                                            'बदल्यात ऑफर केलेले:',
                                            style: TextStyle(color: tokens.textMuted, fontSize: 11),
                                          ),
                                          VrText(
                                            '${offered['quantity'] ?? 1} ${offered['unit'] ?? "kg"} — ${offered['title'] ?? "उत्पादन"}',
                                            style: TextStyle(
                                              color: tokens.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (latestVersion['note'] != null &&
                                              (latestVersion['note'] as String).isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            VrText(
                                              'टिप: ${latestVersion['note']}',
                                              style: TextStyle(color: tokens.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (canRespond) ...[
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _respondBarter(barter['_id'], 'reject'),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: tokens.error),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: VrText('नकारा (Decline)', style: TextStyle(color: tokens.error, fontSize: 12)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _showCounterDialog(barter),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: tokens.actionPrimary),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: VrText('प्रति-ऑफर (Counter)', style: TextStyle(color: tokens.actionPrimary, fontSize: 12)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _respondBarter(barter['_id'], 'accept'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: tokens.success,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: const VrText('स्वीकारा (Accept)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
