import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format_inr.dart';
import '../../core/utils/idempotency.dart';
import '../../core/network/app_exception.dart';
import '../../shared/widgets/async_value_view.dart';
import '../auth/auth_providers.dart';

final deliveryJobsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/deliveries/jobs');
  return res as List? ?? [];
});

class DeliveryJobsScreen extends ConsumerStatefulWidget {
  const DeliveryJobsScreen({super.key});

  @override
  ConsumerState<DeliveryJobsScreen> createState() => _DeliveryJobsScreenState();
}

class _DeliveryJobsScreenState extends ConsumerState<DeliveryJobsScreen> {
  bool _available = true;

  Future<void> _claimJob(String deliveryId) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/deliveries/jobs/$deliveryId/accept', headers: {
        'Idempotency-Key': generateIdempotencyKey(),
      });
      ref.invalidate(deliveryJobsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: VrText('डिलिव्हरी काम स्वीकारले! (Delivery job accepted)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: VrText(e is AppException ? e.localizedMessage : 'स्वीकारता आले नाही.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final jobsAsync = ref.watch(deliveryJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const VrText('डिलिव्हरी कामे • Delivery Jobs'),
        actions: [
          Switch(
            value: _available,
            activeTrackColor: tokens.actionPrimary,
            activeThumbColor: Colors.white,
            onChanged: (val) {
              setState(() => _available = val);
              ref.read(apiClientProvider).patch('/delivery-partners/me/availability', data: {'available': val});
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(deliveryJobsProvider),
          child: AsyncValueView(
            value: jobsAsync,
            emptyMessage: 'सध्या नवीन डिलिव्हरी कामे उपलब्ध नाहीत (No open delivery jobs)',
            onRetry: () => ref.invalidate(deliveryJobsProvider),
            data: (jobs) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jobs.length,
                itemBuilder: (ctx, i) {
                  final job = jobs[i] as Map<String, dynamic>;
                  final pickup = job['pickup'] as Map<String, dynamic>? ?? {};
                  final drop = job['drop'] as Map<String, dynamic>? ?? {};
                  final status = job['status'] as String? ?? 'requested';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: tokens.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            VrText(
                              job['goodsSummary'] ?? 'वनउत्पादन',
                              style: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            VrText(
                              formatInr(job['feePaise'] ?? 12000),
                              style: TextStyle(color: tokens.actionPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.trip_origin, size: 14, color: tokens.brandSecondary),
                            const SizedBox(width: 6),
                            VrText('${pickup['village']}, ${pickup['taluka']}', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: tokens.actionPrimary),
                            const SizedBox(width: 6),
                            VrText('${drop['village']}, ${drop['taluka']}', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (status == 'requested') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _claimJob(job['_id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tokens.brandSecondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const VrText('हे काम स्वीकारा • Accept Job'),
                            ),
                          ),
                        ] else if (status == 'assigned') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.local_shipping, size: 18),
                              onPressed: () async {
                                try {
                                  await ref.read(apiClientProvider).patch('/deliveries/${job['_id']}/status', data: {'status': 'in_transit'});
                                  ref.invalidate(deliveryJobsProvider);
                                } catch (_) {}
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tokens.actionPrimary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              label: const VrText('माल ताब्यात घेतला • Picked Up'),
                            ),
                          ),
                        ] else if (status == 'in_transit') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle, size: 18),
                              onPressed: () async {
                                try {
                                  await ref.read(apiClientProvider).patch('/deliveries/${job['_id']}/status', data: {'status': 'delivered'});
                                  ref.invalidate(deliveryJobsProvider);
                                } catch (_) {}
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tokens.success,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              label: const VrText('माल पोहोचवला • Mark Delivered'),
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: tokens.chipSuccessBg, borderRadius: BorderRadius.circular(8)),
                            child: VrText('पूर्ण झाले • Delivered', style: TextStyle(color: tokens.success, fontWeight: FontWeight.bold, fontSize: 12)),
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
    );
  }
}
