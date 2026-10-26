import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format_inr.dart';
import '../../core/utils/idempotency.dart';
import '../../core/network/app_exception.dart';
import '../../shared/widgets/async_value_view.dart';
import '../auth/auth_providers.dart';

/// Jobs open for this partner's talukas (server status `available`).
final deliveryJobsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/deliveries/jobs');
  return res as List? ?? [];
});

/// Jobs this partner has accepted (server statuses accepted, picked_up, on_the_way, delivered).
final myDeliveriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/deliveries/mine');
  return res as List? ?? [];
});

/// What the partner can do next for a job in [status]: (server status to send, button label), or null.
(String, String)? nextDeliveryStep(String status) => switch (status) {
      'accepted' => ('picked_up', 'माल ताब्यात घेतला • Picked Up'),
      'picked_up' => ('on_the_way', 'निघालो • On the way'),
      'on_the_way' => ('delivered', 'माल पोहोचवला • Mark Delivered'),
      _ => null,
    };

/// Cash is collected once the goods are on the way, for cash-on-delivery jobs not yet marked.
bool canMarkCash(Map<String, dynamic> job) {
  final status = job['status'] as String? ?? '';
  return ((job['collectCashPaise'] as num?) ?? 0) > 0 &&
      job['cashCollected'] != true &&
      (status == 'on_the_way' || status == 'delivered');
}

class DeliveryJobsScreen extends ConsumerStatefulWidget {
  const DeliveryJobsScreen({super.key});

  @override
  ConsumerState<DeliveryJobsScreen> createState() => _DeliveryJobsScreenState();
}

class _DeliveryJobsScreenState extends ConsumerState<DeliveryJobsScreen> {
  bool _available = true;

  void _refresh() {
    ref.invalidate(deliveryJobsProvider);
    ref.invalidate(myDeliveriesProvider);
  }

  void _say(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: VrText(message)));
  }

  Future<void> _do(Future<void> Function() action, String done) async {
    try {
      await action();
      _refresh();
      _say(done);
    } catch (e) {
      _say(e is AppException ? e.localizedMessage : 'झाले नाही. • That did not work.');
    }
  }

  Future<void> _claimJob(String deliveryId) => _do(
        () => ref.read(apiClientProvider).post('/deliveries/jobs/$deliveryId/accept', headers: {
          'Idempotency-Key': generateIdempotencyKey(),
        }),
        'डिलिव्हरी काम स्वीकारले! (Delivery job accepted)',
      );

  Future<void> _step(String deliveryId, String status) => _do(
        () => ref.read(apiClientProvider).patch('/deliveries/$deliveryId/status', data: {'status': status}),
        'नोंद झाली. • Saved.',
      );

  Future<void> _cash(String orderId) => _do(
        () => ref.read(apiClientProvider).post('/orders/$orderId/payment/cash-received'),
        'रोख मिळाल्याची नोंद झाली. • Cash marked as received.',
      );

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: const TabBar(tabs: [
            Tab(child: VrText('खुली कामे • Open')),
            Tab(child: VrText('माझी कामे • Mine')),
          ]),
        ),
        body: SafeArea(
          child: TabBarView(children: [
            _list(tokens, deliveryJobsProvider, 'सध्या नवीन डिलिव्हरी कामे उपलब्ध नाहीत (No open delivery jobs)'),
            _list(tokens, myDeliveriesProvider, 'तुम्ही अजून कोणतेही काम स्वीकारलेले नाही (You have not accepted any job yet)'),
          ]),
        ),
      ),
    );
  }

  Widget _list(VrTokens tokens, FutureProvider<List<dynamic>> provider, String emptyMessage) {
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: AsyncValueView(
        value: ref.watch(provider),
        emptyMessage: emptyMessage,
        onRetry: () => ref.invalidate(provider),
        data: (jobs) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (ctx, i) => _card(tokens, jobs[i] as Map<String, dynamic>),
        ),
      ),
    );
  }

  Widget _card(VrTokens tokens, Map<String, dynamic> job) {
    final pickup = job['pickup'] as Map<String, dynamic>? ?? {};
    final drop = job['drop'] as Map<String, dynamic>? ?? {};
    final status = job['status'] as String? ?? 'available';
    final cashPaise = ((job['collectCashPaise'] as num?) ?? 0).toInt();
    final next = nextDeliveryStep(status);

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
              Flexible(
                child: VrText(
                  job['goodsSummary'] ?? 'वनउत्पादन',
                  style: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              VrText(
                formatInr((job['feePaise'] as num?)?.toInt() ?? 0),
                style: TextStyle(color: tokens.actionPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.trip_origin, size: 14, color: tokens.brandSecondary),
            const SizedBox(width: 6),
            VrText('${pickup['village']}, ${pickup['taluka']}', style: const TextStyle(fontSize: 13)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.location_on, size: 14, color: tokens.actionPrimary),
            const SizedBox(width: 6),
            VrText('${drop['village']}, ${drop['taluka']}', style: const TextStyle(fontSize: 13)),
          ]),
          if (cashPaise > 0) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.payments_outlined, size: 14, color: tokens.info),
              const SizedBox(width: 6),
              Flexible(
                child: VrText(
                  job['cashCollected'] == true
                      ? 'रोख मिळाली • Cash received (${formatInr(cashPaise)})'
                      : 'खरेदीदाराकडून रोख घ्या • Collect cash: ${formatInr(cashPaise)}',
                  style: TextStyle(color: tokens.info, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          ],
          const SizedBox(height: 12),
          if (status == 'available')
            _wide(tokens.brandSecondary, null, 'हे काम स्वीकारा • Accept Job', () => _claimJob(job['_id'])),
          if (next != null) _wide(next.$1 == 'delivered' ? tokens.success : tokens.actionPrimary, Icons.local_shipping, next.$2, () => _step(job['_id'], next.$1)),
          if (canMarkCash(job)) ...[
            const SizedBox(height: 8),
            _wide(tokens.success, Icons.payments, 'रोख मिळाली • Cash received', () => _cash(job['orderId'] as String)),
          ],
          if (status == 'delivered' && !canMarkCash(job))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: tokens.chipSuccessBg, borderRadius: BorderRadius.circular(8)),
              child: VrText('पूर्ण झाले • Delivered', style: TextStyle(color: tokens.success, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          if (status == 'cancelled')
            VrText('रद्द • Cancelled', style: TextStyle(color: tokens.error, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _wide(Color color, IconData? icon, String label, VoidCallback onTap) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    return SizedBox(
      width: double.infinity,
      child: icon == null
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: shape),
              child: VrText(label),
            )
          : ElevatedButton.icon(
              icon: Icon(icon, size: 18),
              onPressed: onTap,
              style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: shape),
              label: VrText(label),
            ),
    );
  }
}
