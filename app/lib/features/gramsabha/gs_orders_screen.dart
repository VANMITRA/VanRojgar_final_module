import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/underline_tabs.dart';
import '../../shared/widgets/order_card.dart';
import '../../shared/widgets/async_value_view.dart';
import '../../shared/widgets/breadcrumb.dart';
import '../trade/trade_providers.dart';
import '../auth/auth_providers.dart';

class GsOrdersScreen extends ConsumerStatefulWidget {
  const GsOrdersScreen({super.key});

  @override
  ConsumerState<GsOrdersScreen> createState() => _GsOrdersScreenState();
}

class _GsOrdersScreenState extends ConsumerState<GsOrdersScreen> {
  int _selectedTab = 0; // 0 = Active, 1 = Past

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authControllerProvider).asData?.value;
    final isSeller = currentUser?.role == 'gramsabha';
    final scope = isSeller ? 'selling' : 'buying';
    final ordersAsync = ref.watch(ordersProvider(scope));

    return Scaffold(
      appBar: AppBar(title: VrText(isSeller ? 'विक्री ऑर्डर्स • Sales Orders' : 'माझ्या ऑर्डर्स • My Orders')),
      body: SafeArea(
        child: Column(
          children: [
            Breadcrumb(segments: [
              'मुख्यपृष्ठ • Home',
              isSeller ? 'विक्री ऑर्डर्स • Orders' : 'माझ्या ऑर्डर्स • Orders',
            ]),
            UnderlineTabs(
              tabs: const ['सक्रिय (Active)', 'पूर्ण / मागील (Completed)'],
              selectedIndex: _selectedTab,
              onTabSelected: (idx) => setState(() => _selectedTab = idx),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(ordersProvider(scope)),
                child: AsyncValueView(
                  value: ordersAsync,
                  emptyMessage: 'कोणतीही ऑर्डर नाही (No orders found)',
                  data: (orders) {
                    final filtered = _selectedTab == 0
                        ? orders.where((o) => o.orderStatus != 'delivered' && o.orderStatus != 'closed' && o.orderStatus != 'cancelled').toList()
                        : orders.where((o) => o.orderStatus == 'delivered' || o.orderStatus == 'closed' || o.orderStatus == 'cancelled').toList();

                    if (filtered.isEmpty) {
                      return const Center(child: VrText('या विभागात ऑर्डर्स नाहीत. • No orders in this section.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final order = filtered[i];
                        return OrderCard(
                          order: order,
                          onTap: () => context.push('/orders/${order.id}'),
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
