import 'package:flutter/material.dart';
import '../utils/product_image.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/dates.dart';
import '../models/trade_request.dart';

class RequestCard extends StatelessWidget {
  final TradeRequestModel request;
  final bool isSeller;
  final VoidCallback? onApprove;
  final VoidCallback? onCounter;
  final VoidCallback? onReject;
  final VoidCallback? onAcceptCounter;
  final VoidCallback? onDeclineCounter;
  final VoidCallback? onCancel;
  final VoidCallback? onViewOrder;

  const RequestCard({
    super.key,
    required this.request,
    required this.isSeller,
    this.onApprove,
    this.onCounter,
    this.onReject,
    this.onAcceptCounter,
    this.onDeclineCounter,
    this.onCancel,
    this.onViewOrder,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    Color statusColor;
    if (request.status == 'approved') {
      statusColor = tokens.success;
    } else if (request.status == 'rejected' || request.status == 'cancelled') {
      statusColor = tokens.error;
    } else if (request.status == 'countered') {
      statusColor = tokens.actionPrimary;
    } else {
      statusColor = tokens.warning;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
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
              Text(
                isSeller
                  ? (request.requesterName ?? 'Buyer')
                  : 'Requested from GS',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.status.toUpperCase(),
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
                    request.listing?.displayImageUrl ?? 'assets/products/forest.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.forest, color: tokens.brandSecondary, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.listing?.localizedTitle(Localizations.localeOf(context).languageCode) ?? 'Forest Produce',
                      style: TextStyle(
                        color: tokens.brandPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Quantity: ${request.quantity} ${request.unit} (${request.deliveryPref})',
                      style: TextStyle(color: tokens.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (request.reason != null && request.reason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tokens.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Purpose: ${request.reason}',
                style: TextStyle(color: tokens.info, fontSize: 12),
              ),
            ),
          ],
          if (request.status == 'rejected' && request.decisionNote != null && request.decisionNote!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tokens.chipErrorBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tokens.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel_outlined, size: 14, color: tokens.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'कारण • Reason: ${request.decisionNote}',
                      style: TextStyle(color: tokens.error, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (request.status == 'countered' && request.counter != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tokens.actionPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tokens.actionPrimary.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Counter-Offer: ${request.counter!['quantity']} ${request.unit} @ ₹${((request.counter!['pricePerUnitPaise'] ?? 0) / 100).toStringAsFixed(2)}',
                style: TextStyle(color: tokens.actionPrimary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDate(request.createdAt),
                style: TextStyle(color: tokens.textMuted, fontSize: 11),
              ),
              // Action Buttons
              if (isSeller && request.status == 'pending') ...[
                Row(
                  children: [
                    TextButton(
                      onPressed: onReject,
                      child: Text('Reject', style: TextStyle(color: tokens.error, fontSize: 13)),
                    ),
                    const SizedBox(width: 4),
                    OutlinedButton(
                      onPressed: onCounter,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: tokens.actionPrimary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text('Counter', style: TextStyle(color: tokens.actionPrimary, fontSize: 13)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.actionPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                      child: const Text('Approve', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
              if (!isSeller && request.status == 'pending') ...[
                TextButton.icon(
                  icon: Icon(Icons.cancel_outlined, size: 16, color: tokens.error),
                  onPressed: onCancel,
                  label: Text('रद्द करा (Cancel)', style: TextStyle(color: tokens.error, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
              if (!isSeller && request.status == 'countered') ...[
                Row(
                  children: [
                    TextButton(
                      onPressed: onDeclineCounter,
                      child: Text('Decline', style: TextStyle(color: tokens.error, fontSize: 13)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: onAcceptCounter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.actionPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Accept Counter', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
              if (onViewOrder != null) ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text('ऑर्डर पहा • View Order', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.brandSecondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: onViewOrder,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
