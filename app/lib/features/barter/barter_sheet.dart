import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/network/app_exception.dart';
import '../auth/auth_providers.dart';

class BarterSheetScreen extends ConsumerStatefulWidget {
  final String listingId;

  const BarterSheetScreen({super.key, required this.listingId});

  @override
  ConsumerState<BarterSheetScreen> createState() => _BarterSheetScreenState();
}

class _BarterSheetScreenState extends ConsumerState<BarterSheetScreen> {
  final _offeredTitleController = TextEditingController();
  final _offeredQtyController = TextEditingController();
  final _wantedQtyController = TextEditingController();
  final _noteController = TextEditingController();
  String _offeredUnit = 'kg';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _offeredTitleController.dispose();
    _offeredQtyController.dispose();
    _wantedQtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitBarter() async {
    if (_offeredTitleController.text.trim().isEmpty ||
        _offeredQtyController.text.trim().isEmpty ||
        _wantedQtyController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'कृपया वस्तुविनिमयाची संपूर्ण माहिती भरा.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      await api.post('/barter-requests', data: {
        'toListId': widget.listingId,
        'offeredTitle': _offeredTitleController.text.trim(),
        'offeredQuantity': double.tryParse(_offeredQtyController.text.trim()) ?? 1,
        'offeredUnit': _offeredUnit,
        'wantedQuantity': double.tryParse(_wantedQtyController.text.trim()) ?? 1,
        'note': _noteController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: VrText('वस्तुविनिमय ऑफर पाठवली! (Barter offer sent)')),
      );
      context.pushReplacement('/barter/offers');
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

    return Scaffold(
      appBar: AppBar(title: const VrText('वस्तुविनिमय ऑफर • Barter Offer')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: tokens.chipErrorBg, borderRadius: BorderRadius.circular(12)),
                  child: VrText(_errorMessage!, style: TextStyle(color: tokens.error)),
                ),
                const SizedBox(height: 16),
              ],
              VrText(
                'आपण काय देणार आहात? (What you offer) *',
                style: TextStyle(fontWeight: FontWeight.w700, color: tokens.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _offeredTitleController,
                decoration: InputDecoration(
                  labelText: 'आपल्या उत्पादनाचे नाव (उदा. बांबू टोपल्या, नाचणी)',
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _offeredQtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'प्रमाण (Quantity)',
                        filled: true,
                        fillColor: tokens.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _offeredUnit,
                      decoration: InputDecoration(
                        labelText: 'एकक',
                        filled: true,
                        fillColor: tokens.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: ['kg', 'piece', 'bundle', 'bag'].map((u) => DropdownMenuItem(value: u, child: VrText(u))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _offeredUnit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              VrText(
                'बदल्यात किती प्रमाण हवे आहे? (Wanted Quantity) *',
                style: TextStyle(fontWeight: FontWeight.w700, color: tokens.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _wantedQtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'हवे असलेले प्रमाण',
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'टिप / अटी (Note)',
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitBarter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.actionPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const VrText('ऑफर पाठवा • Send Barter Offer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
