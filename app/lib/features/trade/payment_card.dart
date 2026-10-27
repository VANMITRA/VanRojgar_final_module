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

/// Payment of one order: UPI (the buyer pays in their own UPI app and reports the reference; the SELLER confirms the
/// money arrived) or cash on delivery (the delivery partner, or the seller for a pickup, marks the cash received).
/// The app cannot see a bank, so it never says "verified" before a person has confirmed.
class PaymentCard extends ConsumerStatefulWidget {
  final OrderModel order;
  final bool isBuyer;
  final bool isSeller;

  const PaymentCard({super.key, required this.order, required this.isBuyer, required this.isSeller});

  @override
  ConsumerState<PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends ConsumerState<PaymentCard> {
  final _reference = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _upiId; // shown so the buyer can pay by hand if no UPI app opens

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      ref.invalidate(orderDetailProvider(widget.order.id));
      ref.invalidate(ordersProvider('buying'));
      ref.invalidate(ordersProvider('selling'));
    } catch (e) {
      if (mounted) setState(() => _error = e is AppException ? e.localizedMessage : e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openUpi() => _run(() async {
        final res = await ref.read(apiClientProvider).get('/orders/${widget.order.id}/payment/upi-link');
        final link = res['link'] as String;
        if (mounted) setState(() => _upiId = res['upiId'] as String?);
        final opened = await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication).catchError((_) => false);
        if (!opened && mounted) {
          setState(() => _error = 'UPI अॅप उघडले नाही. वरील UPI ID वर हाताने पैसे द्या. • No UPI app opened. Pay to the UPI ID shown above by hand.');
        }
      });

  Future<void> _report() async {
    final ref0 = _reference.text.trim();
    if (!RegExp(r'^[A-Za-z0-9]{8,30}$').hasMatch(ref0)) {
      setState(() => _error = 'UPI अॅपमधील पेमेंट संदर्भ क्रमांक टाका (८ ते ३०). • Enter the payment reference from your UPI app (8 to 30 letters or digits).');
      return;
    }
    await _run(() => ref.read(apiClientProvider).post('/orders/${widget.order.id}/payment/report', data: {'reference': ref0}));
  }

  Future<void> _post(String path) => _run(() => ref.read(apiClientProvider).post('/orders/${widget.order.id}/payment/$path'));

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final o = widget.order;
    final amount = formatInr(o.line.totalPaise);
    final (title, lines, actions) = _content(tokens, o, amount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.payment, size: 18, color: tokens.brandSecondary),
            const SizedBox(width: 8),
            Expanded(child: VrText(title, style: TextStyle(color: tokens.textPrimary, fontSize: 14, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 8),
          for (final l in lines) Padding(padding: const EdgeInsets.only(bottom: 4), child: VrText(l, style: TextStyle(color: tokens.textMuted, fontSize: 12))),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: VrText(_error!, style: TextStyle(color: tokens.error, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          if (actions.isNotEmpty) const SizedBox(height: 10),
          ...actions,
        ],
      ),
    );
  }

  Widget _button(String label, VoidCallback onTap, {Color? color}) {
    final tokens = context.vr;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _busy ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? tokens.actionPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: VrText(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }

  (String, List<String>, List<Widget>) _content(VrTokens tokens, OrderModel o, String amount) {
    final cancelled = o.orderStatus == 'cancelled';
    switch (o.paymentStatus) {
      case 'awaiting_payment':
        if (cancelled) return ('UPI पेमेंट • UPI payment', ['ऑर्डर रद्द झाली. • The order was cancelled.'], const []);
        if (!widget.isBuyer) {
          return ('UPI पेमेंट • UPI payment', ['खरेदीदाराच्या पेमेंटची वाट पाहत आहोत. • Waiting for the buyer to pay $amount.'], const []);
        }
        return (
          'UPI ने $amount द्या • Pay $amount by UPI',
          [
            if (_upiId != null) 'UPI ID: $_upiId',
            'पैसे दिल्यावर संदर्भ क्रमांक खाली टाका. पैसे आल्याची पुष्टी विक्रेता करतो; हे अॅप तुमचे बँक खाते पाहू शकत नाही. • After paying, enter the reference below. The seller confirms that the money arrived; this app cannot see your bank.',
          ],
          [
            _button('UPI अॅप उघडा • Open UPI app', _openUpi),
            const SizedBox(height: 10),
            TextField(
              controller: _reference,
              enabled: !_busy,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'पेमेंट संदर्भ क्रमांक • Payment reference',
                filled: true,
                fillColor: tokens.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            _button('मी पैसे दिले • I have paid', _report, color: tokens.success),
          ],
        );
      case 'payment_reported':
        return (
          'पेमेंट सांगितले, पुष्टी बाकी • Payment reported, not yet confirmed',
          [
            'खरेदीदार म्हणतो पैसे दिले. संदर्भ: ${o.paymentReference ?? '-'}. • The buyer says $amount was paid. Reference: ${o.paymentReference ?? '-'}.',
            if (!widget.isSeller) 'विक्रेता पैसे आल्याची पुष्टी करेल. • The seller will confirm that the money arrived.',
          ],
          [
            if (widget.isSeller)
              _button('पैसे आले, पुष्टी करा • Money arrived, confirm', () => _post('confirm'), color: tokens.success),
          ],
        );
      case 'payment_confirmed':
        return ('UPI पेमेंट: विक्रेत्याने पुष्टी केली • UPI payment: confirmed by the seller', ['$amount (संदर्भ • reference ${o.paymentReference ?? '-'})'], const []);
      case 'cod_pending':
        final byPartner = o.fulfilmentMethod == 'delivery';
        return (
          'डिलिव्हरीवर रोख • Cash on delivery',
          [
            byPartner
                ? 'डिलिव्हरी करणारी व्यक्ती $amount रोख घेईल. • The delivery partner collects $amount in cash.'
                : 'गावातून माल घेताना $amount रोख द्या. • Pay $amount in cash when you collect the goods.',
          ],
          [
            if (!byPartner && widget.isSeller && !cancelled) _button('रोख मिळाली • Cash received', () => _post('cash-received'), color: tokens.success),
          ],
        );
      case 'cash_received':
        return ('रोख मिळाली • Cash received', ['$amount रोख मिळाल्याची नोंद झाली. • $amount was marked as received in cash.'], const []);
      case 'not_required':
        return ('पेमेंट नाही (अदलाबदल) • No payment (barter)', const [], const []);
      default:
        return ('पेमेंट: प्रत्यक्ष व्यवहार • Payment: settled offline', ['जुनी ऑर्डर; अॅपमध्ये पेमेंट नाही. • An older order; no payment inside the app.'], const []);
    }
  }
}
