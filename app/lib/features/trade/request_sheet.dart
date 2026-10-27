import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_input_hints.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/idempotency.dart';
import '../../core/network/app_exception.dart';
import '../../shared/models/listing.dart';
import '../trade/trade_providers.dart';
import '../auth/auth_providers.dart';

class RequestSheet extends ConsumerStatefulWidget {
  final ListingModel listing;

  const RequestSheet({super.key, required this.listing});

  @override
  ConsumerState<RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends ConsumerState<RequestSheet> {
  final _qtyController = TextEditingController(text: '10');
  final _villageController = TextEditingController();
  final _reasonController = TextEditingController();
  String _deliveryPref = 'pickup'; // 'pickup' | 'delivery'
  String _paymentMethod = 'cod'; // 'cod' | 'upi'
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).asData?.value;
    if (user?.village != null) {
      _villageController.text = user!.village!;
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _villageController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool get _isBulk {
    final qty = double.tryParse(_qtyController.text) ?? 0;
    return qty >= 50;
  }

  Future<void> _submitRequest() async {
    final qty = double.tryParse(_qtyController.text.trim());
    if (qty == null || qty <= 0) {
      setState(() => _errorMessage = 'कृपया वैध प्रमाण प्रविष्ट करा.');
      return;
    }

    if (qty > widget.listing.quantityAvailable) {
      setState(() => _errorMessage = 'प्रमाण उपलब्ध साठ्यापेक्षा जास्त असू शकत नाही.');
      return;
    }

    if (_isBulk && _reasonController.text.trim().length < 5) {
      setState(() => _errorMessage = '५० एकक किंवा त्याहून अधिक खरेदीसाठी वनसंवर्धन वापर कारण अनिवार्य आहे.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final idempKey = generateIdempotencyKey();

      await api.post('/requests', data: {
        'listingId': widget.listing.id,
        'quantity': qty,
        'deliveryPref': _deliveryPref,
        'paymentMethod': _paymentMethod,
        'dropVillage': _villageController.text.trim(),
        'reason': _reasonController.text.trim(),
      }, headers: {
        'Idempotency-Key': idempKey
      });

      ref.invalidate(requestsProvider('mine'));
      ref.invalidate(requestsProvider('incoming'));

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: VrText('खरेदी विनंती पाठवली! (Purchase request submitted)')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is AppException ? e.localizedMessage : e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final upiOffered = ref.watch(paymentOptionsProvider).asData?.value.upi ?? false;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                VrText(
                  'खरेदी विनंती • Purchase Request',
                  style: TextStyle(color: tokens.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tokens.chipErrorBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: VrText(
                  _errorMessage!,
                  style: TextStyle(color: tokens.error, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
            ],
            VrText(
              'प्रमाण (Quantity in ${widget.listing.unit})',
              style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'कमाल उपलब्ध: ${widget.listing.quantityAvailable} ${widget.listing.unit}',
                suffixText: widget.listing.unit,
                filled: true,
                fillColor: tokens.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            VrText(
              'प्राप्ती पद्धत (Fulfillment)',
              style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'pickup', label: VrText('गावातून स्वतः घेणे (Self Pickup)')),
                ButtonSegment(value: 'delivery', label: VrText('डिलिव्हरी (Delivery)')),
              ],
              selected: {_deliveryPref},
              onSelectionChanged: (set) => setState(() => _deliveryPref = set.first),
            ),
            const SizedBox(height: 14),
            VrText(
              'पेमेंट पद्धत (Payment)',
              style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              segments: [
                const ButtonSegment(value: 'cod', label: VrText('रोख (Cash on delivery)')),
                if (upiOffered) const ButtonSegment(value: 'upi', label: VrText('UPI')),
              ],
              selected: {upiOffered ? _paymentMethod : 'cod'},
              onSelectionChanged: (set) => setState(() => _paymentMethod = set.first),
            ),
            const SizedBox(height: 4),
            VrText(
              _paymentMethod == 'upi' && upiOffered
                  ? 'विनंती मंजूर झाल्यावर तुम्ही UPI ने पैसे द्याल; विक्रेता पैसे आल्याची पुष्टी करतो. (After approval you pay with UPI; the seller confirms the money arrived.)'
                  : 'माल मिळताना रोख द्या. (Pay in cash when the goods arrive.)',
              style: TextStyle(color: tokens.textMuted, fontSize: 11),
            ),
            if (_deliveryPref == 'delivery') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _villageController,
                decoration: InputDecoration(
                  labelText: 'डिलिव्हरीचे ठिकाण / गाव (Drop Village)',
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
            if (_isBulk) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tokens.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 18, color: tokens.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VrText(
                        '५० एकक किंवा जास्त मागणीसाठी वनसंवर्धनाचे कारण आवश्यक आहे.',
                        style: TextStyle(color: tokens.info, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'वापर व संवर्धन कारण (Purpose / Reason) *',
                  hintText: AppInputHints.requestPurpose(context),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.actionPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const VrText('विनंती पाठवा • Submit Request', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
