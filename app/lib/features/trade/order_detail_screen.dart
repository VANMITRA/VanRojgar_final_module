import 'package:flutter/material.dart';
import '../../shared/utils/product_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format_inr.dart';
import '../../shared/widgets/status_stepper.dart';
import '../../shared/widgets/async_value_view.dart';
import '../trade/trade_providers.dart';
import 'payment_card.dart';
import '../auth/auth_providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.vr;
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final currentUser = ref.watch(authControllerProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('ऑर्डर प्रगती • Order Status')),
      body: SafeArea(
        child: AsyncValueView(
          value: orderAsync,
          emptyMessage: 'Order details not found',
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
          data: (order) {
            final isSeller = currentUser?.id == order.sellerId;
            final isBuyer = currentUser?.id == order.buyerId;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: tokens.brandSecondary.withValues(alpha: 0.1),
                                border: Border.all(color: tokens.outline),
                              ),
                              child: ProductImage(
                                order.line.displayImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(Icons.forest, color: tokens.brandSecondary, size: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.line.localizedTitle(Localizations.localeOf(context).languageCode),
                                  style: TextStyle(color: tokens.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${order.line.quantity} ${order.line.unit} • Total: ${formatInr(order.line.totalPaise)}',
                                  style: TextStyle(color: tokens.actionPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  PaymentCard(order: order, isBuyer: isBuyer, isSeller: isSeller),
                  const SizedBox(height: 18),
                  // Vertical Status Stepper
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: tokens.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'प्रगती टाइमलाइन (Timeline)',
                          style: TextStyle(color: tokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        StatusStepper(currentStatus: order.orderStatus),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Contact details revealed on approval
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
                        Text(
                          'पडताळणी झालेले संपर्क (Contact Details)',
                          style: TextStyle(color: tokens.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        if (order.sellerPhone != null) ...[
                          Row(
                            children: [
                              Icon(Icons.person, size: 16, color: tokens.brandSecondary),
                              const SizedBox(width: 8),
                              Text('विक्रेता: ${order.sellerName ?? "Gram Sabha"} (${order.sellerPhone})'),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                        if (order.buyerPhone != null) ...[
                          Row(
                            children: [
                              Icon(Icons.shopping_bag, size: 16, color: tokens.brandSecondary),
                              const SizedBox(width: 8),
                              Text('खरेदीदार: ${order.buyerName ?? "Buyer"} (${order.buyerPhone})'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  if (isSeller && order.orderStatus == 'approved') ...[
                    ElevatedButton(
                      onPressed: () async {
                        final api = ref.read(apiClientProvider);
                        await api.post('/orders/${order.id}/handover');
                        ref.invalidate(orderDetailProvider(orderId));
                        ref.invalidate(ordersProvider('selling'));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.actionPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('माल सुपूर्द केला (Confirm Handover)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ],
                  if (isBuyer && (order.orderStatus == 'handed_over' || order.orderStatus == 'on_the_way')) ...[
                    ElevatedButton(
                      onPressed: () async {
                        final api = ref.read(apiClientProvider);
                        await api.post('/orders/${order.id}/confirm-received');
                        ref.invalidate(orderDetailProvider(orderId));
                        ref.invalidate(ordersProvider('buying'));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('माल मिळाला (Confirm Received)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ],
                  if (order.orderStatus == 'approved') ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        final api = ref.read(apiClientProvider);
                        await api.post('/orders/${order.id}/cancel');
                        ref.invalidate(orderDetailProvider(orderId));
                        ref.invalidate(ordersProvider('buying'));
                        ref.invalidate(ordersProvider('selling'));
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: tokens.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('ऑर्डर रद्द करा • Cancel Order', style: TextStyle(color: tokens.error, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
