import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/geo/talukas.dart';
import '../../core/localization/app_input_hints.dart';
import '../../core/theme/tokens.dart';
import '../../core/network/app_exception.dart';
import '../auth/auth_providers.dart';

class DeliveryApplyScreen extends ConsumerStatefulWidget {
  const DeliveryApplyScreen({super.key});

  @override
  ConsumerState<DeliveryApplyScreen> createState() => _DeliveryApplyScreenState();
}

class _DeliveryApplyScreenState extends ConsumerState<DeliveryApplyScreen> {
  final _vehNumController = TextEditingController();
  final _capacityController = TextEditingController();
  final _licenceController = TextEditingController();

  String _vehicleType = 'bike';
  final Set<String> _selectedTalukas = {nashikTalukas.first.value};
  bool _isLoading = false;
  bool _isChecking = true;
  Map<String, dynamic>? _existingPartner;
  String? _errorMessage;

  final List<String> _talukas = [for (final t in nashikTalukas) t.value];

  @override
  void initState() {
    super.initState();
    _checkExistingApplication();
  }

  Future<void> _checkExistingApplication() async {
    try {
      final api = ref.read(apiClientProvider);
      final profile = await api.get('/delivery-partners/me');
      if (mounted) {
        setState(() {
          _existingPartner = profile is Map<String, dynamic> ? profile : null;
          _isChecking = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _vehNumController.dispose();
    _capacityController.dispose();
    _licenceController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (_vehNumController.text.trim().isEmpty ||
        _capacityController.text.trim().isEmpty ||
        _licenceController.text.trim().isEmpty ||
        _selectedTalukas.isEmpty) {
      setState(() => _errorMessage = 'कृपया सर्व माहिती भरा.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final res = await api.post('/delivery-partners/applications', data: {
        'vehicleType': _vehicleType,
        'vehicleNumber': _vehNumController.text.trim(),
        'capacityKg': double.tryParse(_capacityController.text.trim()) ?? 20,
        'licenceNumber': _licenceController.text.trim(),
        'serviceTalukas': _selectedTalukas.toList(),
      });

      if (!mounted) return;
      setState(() {
        _existingPartner = res is Map<String, dynamic> ? res : null;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: VrText('अर्ज यशस्वीरीत्या सादर केला! पडताळणी प्रलंबित आहे. • Application submitted! Verification pending.')),
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

    if (_isChecking) {
      return Scaffold(
        appBar: AppBar(title: const VrText('डिलिव्हरी अर्ज • Partner Application')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_existingPartner != null) {
      final status = _existingPartner!['approvalStatus'] ?? 'pending';
      final vehicle = _existingPartner!['vehicle'] as Map<String, dynamic>? ?? {};
      final talukas = (_existingPartner!['serviceTalukas'] as List?)?.join(', ') ?? '-';
      final isApproved = status == 'approved';

      return Scaffold(
        appBar: AppBar(title: const VrText('अर्जाची स्थिती • Application Status')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isApproved ? tokens.chipSuccessBg : tokens.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isApproved ? tokens.success : tokens.outline),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isApproved ? Icons.verified : Icons.hourglass_top,
                        size: 56,
                        color: isApproved ? tokens.success : tokens.brandSecondary,
                      ),
                      const SizedBox(height: 12),
                      VrText(
                        isApproved
                            ? 'डिलिव्हरी पार्टनर म्हणून मंजूर! (Approved)'
                            : 'अर्ज पुनरावलोकनाधीन (Under Review)',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      VrText(
                        isApproved
                            ? 'तुम्ही आता सक्रिय डिलिव्हरी भागीदार आहात. उपलब्ध कामांमधून कामे स्वीकारा.'
                            : 'तुमचा अर्ज ग्रामसभा / ॲडमिन पडताळणीसाठी प्रलंबित आहे. लवकरच मंजुरी मिळेल.',
                        style: TextStyle(color: tokens.textMuted, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          VrText('वाहन प्रकार (Vehicle):', style: TextStyle(color: tokens.textMuted, fontSize: 13)),
                          VrText('${vehicle['type'] ?? 'दोनचाकी'} (${vehicle['number'] ?? '-'})', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          VrText('क्षमता (Capacity):', style: TextStyle(color: tokens.textMuted, fontSize: 13)),
                          VrText('${vehicle['capacityKg'] ?? 20} kg', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          VrText('तालुके (Talukas):', style: TextStyle(color: tokens.textMuted, fontSize: 13)),
                          VrText(talukas, style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (isApproved) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.local_shipping),
                    onPressed: () => context.push('/delivery/jobs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.actionPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    label: const VrText('उपलब्ध कामे पहा • View Delivery Jobs', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ] else ...[
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const VrText('परत जा • Go Back'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const VrText('डिलिव्हरी अर्ज • Partner Application')),
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
              VrText('वाहन प्रकार (Vehicle Type)', style: TextStyle(fontWeight: FontWeight.w700, color: tokens.textPrimary)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'bike', label: VrText('दोनचाकी (Bike)')),
                  ButtonSegment(value: 'tempo', label: VrText('टेम्पो (Tempo)')),
                  ButtonSegment(value: 'pickup', label: VrText('पिकअप • Pickup')),
                ],
                selected: {_vehicleType},
                onSelectionChanged: (set) => setState(() => _vehicleType = set.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _vehNumController,
                decoration: InputDecoration(
                  labelText: 'वाहन क्रमांक (Vehicle No.) *',
                  hintText: AppInputHints.deliveryVehicle(context),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'क्षमता (Capacity in kg) *',
                  hintText: AppInputHints.deliveryPayload(context),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _licenceController,
                decoration: InputDecoration(
                  labelText: 'ड्रायव्हिंग लायसन्स क्रमांक *',
                  hintText: AppInputHints.deliveryLicense(context),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              const SizedBox(height: 16),
              VrText('सेवा तालुके निवडा (Service Talukas):', style: TextStyle(fontWeight: FontWeight.w700, color: tokens.textPrimary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _talukas.map((t) {
                  final isSel = _selectedTalukas.contains(t);
                  return FilterChip(
                    label: VrText(talukaLabel(t)),
                    selected: isSel,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedTalukas.add(t);
                        } else if (_selectedTalukas.length > 1) {
                          _selectedTalukas.remove(t);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.actionPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const VrText('अर्ज सादर करा • Submit Application', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
