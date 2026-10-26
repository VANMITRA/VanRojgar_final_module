import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/network/app_exception.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format_inr.dart';
import '../../shared/models/order.dart';
import '../../shared/widgets/vr_text.dart';
import '../auth/auth_providers.dart';
import 'trade_providers.dart';

/// What the payment line on an order says. Nothing here claims money arrived until a person confirmed it:
/// the app has no payment gateway and cannot see the bank.
String paymentSummary(OrderModel o) {
  switch (o.paymentStatus) {
    case 'awaiting_payment':
      return 'यूपीआयने पैसे द्यायचे आहेत • Waiting for the buyer to pay by UPI';
    case 'payment_reported':
      return 'खरेदीदार म्हणतो पैसे दिले; विक्रेत्याची पुष्टी बाकी • Buyer says paid; the seller must confirm the money arrived';
    case 'payment_confirmed':
      return 'विक्रेत्याने पैसे मिळाल्याची पुष्टी केली • Seller confirmed the UPI payment arrived';
    case 'cod_pending':
      return 'डिलिव्हरीवर रोख • Cash on delivery: pay when the goods arrive';
    case 'cash_received':
      return 'रोख रक्कम मिळाली • Cash received on delivery';
    default:
      return 'पेमेंट पद्धत निवडलेली नाही • Payment method not chosen yet';
  }
}

/// The payment steps a person can take on this order, as button ids. Used by the card and by tests.
List<String> paymentActions(OrderModel o, {required bool isBuyer, required bool isSeller}) {
  final live = o.orderStatus != 'cancelled' && o.orderStatus != 'closed';
  final handedOver = const ['picked_up', 'on_the_way', 'handed_over', 'delivered', 'closed'].contains(o.orderStatus);
  switch (o.paymentStatus) {
    case 'awaiting_payment':
      return isBuyer ? ['pay_upi', 'report'] : [];
    case 'payment_reported':
      return isSeller ? ['confirm'] : [];
    case 'cod_pending':
      // With a delivery partner the partner marks the cash (Delivery screen); for pickup the seller does.
      return isSeller && o.fulfilmentMethod == 'pickup' && handedOver ? ['cash'] : [];
    case 'payment_confirmed':
    case 'cash_received':
      return [];
    default:
      return isBuyer && live && o.paymentMethod == null ? ['choose_upi', 'choose_cod'] : [];
  }
}

class PaymentCard extends ConsumerStatefulWidget {
  final OrderModel order;
  final bool isBuyer;
  final bool isSeller;
  const PaymentCard({super.key, required this.order, required this.isBuyer, required this.isSeller});

  @override
  ConsumerState<PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends ConsumerState<PaymentCard> {
  bool _busy = false;

  void _refresh() {
    ref.invalidate(orderDetailProvider(widget.order.id));
    ref.invalidate(ordersProvider('buying'));
    ref.invalidate(ordersProvider('selling'));
  }

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: VrText(text)));
  }

  Future<void> _run(Future<void> Function() step) async {
    setState(() => _busy = true);
    try {
      await step();
      _refresh();
    } catch (e) {
      _say(e is AppException ? e.localizedMessage : 'अयशस्वी • Failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _post(String path, {Map<String, dynamic>? data}) =>
      ref.read(apiClientProvider).post('/orders/${widget.order.id}/payment/$path', data: data);

  Future<void> _payUpi() => _run(() async {
        final res = await ref.read(apiClientProvider).get('/orders/${widget.order.id}/payment/upi');
        final ok = await launchUrl(Uri.parse(res['link'] as String), mode: LaunchMode.externalApplication);
        if (!ok) {
          _say('यूपीआय अ‍ॅप सापडले नाही • No UPI app found. Choose cash on delivery or install one.');
        } else {
          _say('पैसे दिल्यावर परत या आणि संदर्भ क्रमांक द्या • After paying, come back and enter the reference number.');
        }
      });

  Future<void> _report() async {
    final controller = TextEditingController();
    final ref0 = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const VrText('यूपीआय संदर्भ क्रमांक • UPI reference'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '12-digit UTR / transaction id'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const VrText('रद्द • Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const VrText('पाठवा • Send'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (ref0 == null || ref0.isEmpty) return;
    await _run(() => _post('report', data: {'reference': ref0}));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final o = widget.order;
    final actions = paymentActions(o, isBuyer: widget.isBuyer, isSeller: widget.isSeller);

    Widget button(String label, VoidCallback onTap, {bool primary = true}) => SizedBox(
          width: double.infinity,
          child: primary
              ? ElevatedButton(
                  onPressed: _busy ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.actionPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: VrText(label),
                )
              : OutlinedButton(
                  onPressed: _busy ? null : onTap,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: VrText(label),
                ),
        );

    return Container(
      key: const Key('payment_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.payments_outlined, size: 18, color: tokens.brandSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: VrText('पेमेंट • Payment  ${formatInr(o.line.totalPaise)}',
                style: TextStyle(color: tokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 8),
        VrText(paymentSummary(o), key: const Key('payment_summary'), style: TextStyle(color: tokens.textMuted, fontSize: 13)),
        if (o.paymentReference != null && o.paymentReference!.isNotEmpty) ...[
          const SizedBox(height: 4),
          VrText('संदर्भ • Reference: ${o.paymentReference}', style: TextStyle(color: tokens.textMuted, fontSize: 12)),
        ],
        if (actions.isNotEmpty) const SizedBox(height: 12),
        for (final a in actions) ...[
          if (a == 'choose_upi')
            button('यूपीआयने पैसे द्या • Pay by UPI', () => _run(() => _post('method', data: {'method': 'upi'})))
          else if (a == 'choose_cod')
            button('डिलिव्हरीवर रोख • Cash on delivery', () => _run(() => _post('method', data: {'method': 'cod'})), primary: false)
          else if (a == 'pay_upi')
            button('यूपीआय अ‍ॅप उघडा • Open UPI app', _payUpi)
          else if (a == 'report')
            button('मी पैसे दिले • I have paid', _report, primary: false)
          else if (a == 'confirm')
            button('पैसे मिळाले • Money received', () => _run(() => _post('confirm')))
          else if (a == 'cash')
            button('रोख मिळाली • Cash received', () => _run(() => _post('cash-received'))),
          const SizedBox(height: 8),
        ],
        if (o.paymentStatus == 'awaiting_payment' || o.paymentStatus == 'payment_reported')
          VrText(
            'पैसे दिल्याची पुष्टी विक्रेता करतो; अ‍ॅपला बँक दिसत नाही • The seller confirms the money arrived; the app cannot see the bank.',
            style: TextStyle(color: tokens.textMuted, fontSize: 11),
          ),
      ]),
    );
  }
}
