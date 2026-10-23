import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/app_exception.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format_inr.dart';
import '../../core/utils/idempotency.dart';
import '../../shared/widgets/vr_text.dart';
import '../auth/auth_providers.dart';

/// Partner profile or null when the user has not applied yet (API answers 404).
final deliveryProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  try {
    final res = await ref.watch(apiClientProvider).get('/delivery-partners/me');
    return Map<String, dynamic>.from(res as Map);
  } on AppException catch (e) {
    if (e.code == 'NOT_FOUND') return null;
    rethrow;
  }
});

final _jobsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async =>
    (await ref.watch(apiClientProvider).get('/deliveries/jobs')) as List? ?? []);
final _mineProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async =>
    (await ref.watch(apiClientProvider).get('/deliveries/mine')) as List? ?? []);

const _next = {'accepted': 'picked_up', 'picked_up': 'on_the_way', 'on_the_way': 'delivered'};
const _nextLabel = {
  'picked_up': 'माल उचलला • Picked up',
  'on_the_way': 'वाटेत • On the way',
  'delivered': 'पोहोचवला • Delivered',
};

/// Single entry point for the delivery option: routes by the partner's state.
class DeliveryHubScreen extends ConsumerWidget {
  const DeliveryHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(deliveryProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const VrText('डिलिव्हरी • Delivery')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _Message(
          icon: Icons.cloud_off,
          text: e is AppException ? e.localizedMessage : 'त्रुटी • Error',
          action: 'पुन्हा प्रयत्न करा • Retry',
          onTap: () => ref.invalidate(deliveryProfileProvider),
        ),
        data: (p) {
          if (p == null) {
            return _Message(
              icon: Icons.two_wheeler,
              text: 'वाहन आहे? डिलिव्हरी पार्टनर व्हा आणि कमवा • Have a vehicle? Become a delivery partner',
              action: 'सुरू करा • Start',
              onTap: () => context.push('/delivery/intro'),
            );
          }
          final status = p['approvalStatus'] as String? ?? 'pending';
          if (status != 'approved') {
            final note = p['reviewNote'] as String?;
            final label = {
              'pending': 'तुमचा अर्ज तपासणीत आहे • Your application is under review',
              'rejected': 'अर्ज नाकारला • Application rejected',
              'paused': 'तुमचे खाते तात्पुरते थांबवले आहे • Your partner account is paused',
            }[status] ?? status;
            return _Message(
              icon: status == 'pending' ? Icons.hourglass_top : Icons.info_outline,
              text: note == null || note.isEmpty ? label : '$label\n$note',
              action: 'रीफ्रेश • Refresh',
              onTap: () => ref.invalidate(deliveryProfileProvider),
            );
          }
          return const _ApprovedView();
        },
      ),
    );
  }
}

class _ApprovedView extends ConsumerWidget {
  const _ApprovedView();

  Future<void> _act(BuildContext context, WidgetRef ref, Future<dynamic> Function() call) async {
    try {
      await call();
      ref.invalidate(_jobsProvider);
      ref.invalidate(_mineProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: VrText(e is AppException ? e.localizedMessage : 'अयशस्वी • Failed'),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.vr;
    final api = ref.read(apiClientProvider);
    return DefaultTabController(
      length: 2,
      child: Column(children: [
        const TabBar(tabs: [Tab(text: 'उपलब्ध • Available'), Tab(text: 'माझ्या • Mine')]),
        Expanded(
          child: TabBarView(children: [
            _List(
              provider: _jobsProvider,
              empty: 'सध्या कामे नाहीत • No open jobs',
              builder: (j) => _JobCard(
                j,
                tokens,
                button: 'काम स्वीकारा • Accept',
                onTap: () => _act(context, ref, () => api.post('/deliveries/jobs/${j['_id']}/accept',
                    headers: {'Idempotency-Key': generateIdempotencyKey()})),
              ),
            ),
            _List(
              provider: _mineProvider,
              empty: 'तुमची कामे नाहीत • No deliveries yet',
              builder: (j) {
                final n = _next[j['status']];
                return _JobCard(
                  j,
                  tokens,
                  status: j['status'] as String?,
                  button: n == null ? null : _nextLabel[n],
                  onTap: n == null
                      ? null
                      : () => _act(context, ref,
                          () => api.patch('/deliveries/jobs/${j['_id']}/status', data: {'status': n})),
                );
              },
            ),
          ]),
        ),
      ]),
    );
  }
}

class _List extends ConsumerWidget {
  final AutoDisposeFutureProvider<List<dynamic>> provider;
  final String empty;
  final Widget Function(Map<String, dynamic>) builder;
  const _List({required this.provider, required this.empty, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(provider),
      child: ref.watch(provider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ListView(children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: VrText(e is AppException ? e.localizedMessage : 'त्रुटी • Error'),
              )
            ]),
            data: (items) => items.isEmpty
                ? ListView(children: [Padding(padding: const EdgeInsets.all(40), child: Center(child: VrText(empty)))])
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    itemCount: items.length,
                    itemBuilder: (_, i) => builder(Map<String, dynamic>.from(items[i] as Map)),
                  ),
          ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> j;
  final VrTokens tokens;
  final String? button;
  final String? status;
  final VoidCallback? onTap;
  const _JobCard(this.j, this.tokens, {this.button, this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final pick = j['pickup']?['village'] ?? '-';
    final drop = j['drop']?['village'] ?? '-';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          VrText('$pick → $drop', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          VrText('${j['goodsSummary'] ?? ''} • ${j['weightKg'] ?? ''} kg • ${j['distanceKm'] ?? ''} km'),
          VrText('${formatInr(((j['feePaise'] as num?) ?? 0).toInt())} (अंदाजे • estimate)'),
          if (status != null) VrText('स्थिती • Status: $status'),
          if (button != null) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(backgroundColor: tokens.actionPrimary, foregroundColor: Colors.white),
              child: VrText(button!),
            ),
          ],
        ]),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text, action;
  final VoidCallback onTap;
  const _Message({required this.icon, required this.text, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: context.vr.brandSecondary),
            const SizedBox(height: 16),
            VrText(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(backgroundColor: context.vr.actionPrimary, foregroundColor: Colors.white),
              child: VrText(action),
            ),
          ]),
        ),
      );
}
