import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/underline_tabs.dart';
import '../../shared/widgets/request_card.dart';
import '../../shared/widgets/async_value_view.dart';
import '../../shared/widgets/reject_reason_sheet.dart';
import '../../shared/widgets/breadcrumb.dart';
import '../trade/trade_providers.dart';
import '../auth/auth_providers.dart';

class GsRequestsScreen extends ConsumerStatefulWidget {
  const GsRequestsScreen({super.key});

  @override
  ConsumerState<GsRequestsScreen> createState() => _GsRequestsScreenState();
}

class _GsRequestsScreenState extends ConsumerState<GsRequestsScreen> with WidgetsBindingObserver {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final currentUser = ref.read(authControllerProvider).asData?.value;
      final isSeller = currentUser?.role == 'gramsabha';
      final scope = isSeller ? 'incoming' : 'mine';
      ref.invalidate(requestsProvider(scope));
      if (!isSeller) {
        ref.invalidate(ordersProvider('buying'));
      }
    }
  }

  void _showCounterDialog(String requestId) {
    final qtyController = TextEditingController();
    final priceController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const VrText('प्रति-ऑफर द्या (Counter Offer)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'सुचवलेले प्रमाण (New Quantity)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'सुचवलेला दर ₹ (New Price)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'कारण / टिप (Note)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const VrText('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final api = ref.read(apiClientProvider);
              await api.post('/requests/$requestId/counter', data: {
                if (qtyController.text.isNotEmpty) 'quantity': double.tryParse(qtyController.text),
                if (priceController.text.isNotEmpty) 'pricePerUnitRupees': double.tryParse(priceController.text),
                'note': noteController.text.trim(),
              });
              ref.invalidate(requestsProvider('incoming'));
            },
            child: const VrText('Send Counter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authControllerProvider).asData?.value;
    final isSeller = currentUser?.role == 'gramsabha';
    final scope = isSeller ? 'incoming' : 'mine';
    final requestsAsync = ref.watch(requestsProvider(scope));
    final ordersAsync = !isSeller ? ref.watch(ordersProvider('buying')) : null;

    final tabs = isSeller
        ? const ['प्रलंबित (Pending)', 'पूर्ण / इतर (Completed)']
        : const [
            'प्रलंबित (Pending)',
            'मंजूर (Approved)',
            'नाकारले (Rejected)',
            'प्रति-ऑफर (Counter)',
          ];

    return Scaffold(
      appBar: AppBar(
        title: VrText(isSeller ? 'येणाऱ्या मागण्या • Requests' : 'माझ्या मागण्या • My Requests'),
        actions: [
          IconButton(
            tooltip: 'वस्तुविनिमय ऑफर्स • Barter Offers',
            icon: const Icon(Icons.swap_horiz, size: 26),
            onPressed: () => context.push('/barter/offers'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Breadcrumb(segments: [
              'मुख्यपृष्ठ • Home',
              isSeller ? 'मागण्या • Requests' : 'माझ्या मागण्या • My Requests',
            ]),
            UnderlineTabs(
              tabs: tabs,
              selectedIndex: _selectedTab >= tabs.length ? 0 : _selectedTab,
              onTabSelected: (idx) => setState(() => _selectedTab = idx),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(requestsProvider(scope));
                  if (!isSeller) {
                    ref.invalidate(ordersProvider('buying'));
                  }
                },
                child: AsyncValueView(
                  value: requestsAsync,
                  emptyMessage: 'कोणतीही विनंती नाही (No requests found)',
                  data: (requests) {
                    List filtered;
                    if (isSeller) {
                      filtered = _selectedTab == 0
                          ? requests.where((r) => r.status == 'pending' || r.status == 'countered').toList()
                          : requests.where((r) => r.status != 'pending' && r.status != 'countered').toList();
                    } else {
                      switch (_selectedTab) {
                        case 0:
                          filtered = requests.where((r) => r.status == 'pending').toList();
                          break;
                        case 1:
                          filtered = requests.where((r) => r.status == 'approved').toList();
                          break;
                        case 2:
                          filtered = requests.where((r) => r.status == 'rejected' || r.status == 'cancelled').toList();
                          break;
                        case 3:
                          filtered = requests.where((r) => r.status == 'countered').toList();
                          break;
                        default:
                          filtered = requests;
                      }
                    }

                    if (filtered.isEmpty) {
                      return const Center(child: VrText('या विभागात विनंत्या नाहीत. • No requests in this section.'));
                    }

                    final ordersList = ordersAsync?.asData?.value ?? [];

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final req = filtered[i];
                        final matchingOrder = !isSeller
                            ? ordersList.cast().firstWhere(
                                (o) => o.requestId == req.id,
                                orElse: () => null,
                              )
                            : null;

                        return RequestCard(
                          request: req,
                          isSeller: isSeller,
                          onApprove: isSeller ? () async {
                            final api = ref.read(apiClientProvider);
                            await api.patch('/requests/${req.id}/status', data: {'action': 'approve'});
                            ref.invalidate(requestsProvider(scope));
                            ref.invalidate(ordersProvider('selling'));
                          } : null,
                          onCounter: isSeller ? () => _showCounterDialog(req.id) : null,
                          onReject: isSeller ? () {
                            showRejectReasonSheet(
                              context: context,
                              ref: ref,
                              requestId: req.id,
                            );
                          } : null,
                          onAcceptCounter: !isSeller ? () async {
                            final api = ref.read(apiClientProvider);
                            await api.post('/requests/${req.id}/counter/respond', data: {'action': 'accept'});
                            ref.invalidate(requestsProvider(scope));
                            ref.invalidate(ordersProvider('buying'));
                          } : null,
                          onDeclineCounter: !isSeller ? () async {
                            final api = ref.read(apiClientProvider);
                            await api.post('/requests/${req.id}/counter/respond', data: {'action': 'decline'});
                            ref.invalidate(requestsProvider(scope));
                          } : null,
                          onCancel: !isSeller && req.status == 'pending' ? () async {
                            final api = ref.read(apiClientProvider);
                            await api.patch('/requests/${req.id}/status', data: {'action': 'cancel'});
                            ref.invalidate(requestsProvider(scope));
                          } : null,
                          onViewOrder: matchingOrder != null
                              ? () => context.push('/orders/${matchingOrder.id}')
                              : null,
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
