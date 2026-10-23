import 'package:flutter/material.dart';
import '../utils/product_image.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format_inr.dart';
import '../../core/utils/dates.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    Color statusColor;
    if (order.orderStatus == 'delivered' || order.orderStatus == 'closed') {
      statusColor = tokens.success;
    } else if (order.orderStatus == 'cancelled') {
      statusColor = tokens.error;
    } else {
      statusColor = tokens.actionPrimary;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.outline),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0).toUpperCase()}',
                      style: TextStyle(
                        color: tokens.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.orderStatus.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: tokens.brandSecondary.withValues(alpha: 0.1),
                          border: Border.all(color: tokens.outline.withValues(alpha: 0.5)),
                        ),
                        child: ProductImage(
                          order.line.displayImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.inventory_2_outlined, color: tokens.brandSecondary, size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.line.localizedTitle(Localizations.localeOf(context).languageCode),
                            style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${order.line.quantity} ${order.line.unit} • Total: ${formatInr(order.line.totalPaise)}',
                            style: TextStyle(
                              color: tokens.actionPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDate(order.createdAt),
                      style: TextStyle(color: tokens.textMuted, fontSize: 11),
                    ),
                    Row(
                      children: [
                        Text('Details', style: TextStyle(color: tokens.brandSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        Icon(Icons.chevron_right, size: 16, color: tokens.brandSecondary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
