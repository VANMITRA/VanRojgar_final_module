import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/orders_strings.dart';
import '../../models/catalog_models.dart';
import '../../models/order_models.dart';
import '../../theme/van_rozgar_tokens.dart';
import 'order_status_chip.dart';

/// Card summarizing one order/request on the `/orders` tab for either a buyer or a seller.
class OrderCard extends StatelessWidget {
  final OrderView order;
  final bool isSellerView;
  final AppLanguage language;
  final double scale;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.isSellerView,
    required this.language,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(language);
    final s = scale;

    final partyName = isSellerView
        ? strings.odLocalizePartyName(order.buyerName)
        : strings.odLocalizePartyName(order.sellerName);
    final productSummary = strings.odProductSummary(order.lines);
    final dateText = strings.odFormatDate(order.createdAt);
    final totalText = formatRupees(order.totalPaise);

    return Material(
      color: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0 * s),
        side: BorderSide(color: tokens.borders, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('order_card_${order.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0 * s),
        child: Padding(
          padding: EdgeInsets.all(14.0 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: status chip, Sample badge, and date
              Wrap(
                spacing: 8.0 * s,
                runSpacing: 6.0 * s,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OrderStatusChip(
                    status: order.status,
                    language: language,
                    scale: s,
                  ),
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 12.0 * s,
                      color: tokens.mutedText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0 * s),

              // Party name (seller for buyer view, buyer for seller view)
              Text(
                partyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.0 * s,
                  fontWeight: FontWeight.w800,
                  color: tokens.heading,
                ),
              ),
              SizedBox(height: 4.0 * s),

              // Product summary ("Mango x 5 kg + 2 more")
              Text(
                productSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5 * s,
                  fontWeight: FontWeight.w500,
                  color: tokens.bodyText,
                ),
              ),
              SizedBox(height: 10.0 * s),

              // Bottom row: order ID and total in orange
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.odOrderIdLabel(order.id),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0 * s,
                        color: tokens.mutedText,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0 * s),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        totalText,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 17.0 * s,
                          fontWeight: FontWeight.w800,
                          color: tokens.orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

