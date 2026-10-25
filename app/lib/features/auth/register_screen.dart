import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/localization/app_input_hints.dart';
import '../../core/network/app_exception.dart';
import '../../core/geo/talukas.dart';
import '../../shared/models/gram_sabha.dart';
import 'auth_providers.dart';
import 'village_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String portal; // 'gramsabha' | 'villager' | 'buyer'

  const RegisterScreen({super.key, required this.portal});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _villageController = TextEditingController();
  final _talukaController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _businessController = TextEditingController();
  final _cityController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedTaluka;
  String? _selectedVillage;
  bool _isOtherVillage = false;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _contactPersonController.dispose();
    _businessController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// The villages of the chosen taluka, loaded from the server. Empty until a taluka is chosen.
  List<DropdownMenuItem<String>> _villageItems() {
    final taluka = _selectedTaluka;
    if (taluka == null) return const [];
    final List<GramSabhaModel> villages = ref.watch(talukaVillagesProvider(taluka)).asData?.value ?? const [];
    return [
      for (final v in villages)
        DropdownMenuItem(
          value: v.villageMr,
          child: Text(
            v.villageEn != null && v.villageEn!.isNotEmpty && v.villageEn != v.villageMr
                ? '${v.villageMr} (${v.villageEn})'
                : v.villageMr,
            style: const TextStyle(fontSize: 13.5),
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ];
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'कृपया सर्व आवश्यक माहिती भरा (Please fill required fields).');
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(password)) {
      setState(() => _errorMessage = AppLocalizations.of(context)?.pinInvalid ?? 'The PIN must be exactly 6 digits.');
      return;
    }

    final taluka = _selectedTaluka ?? _talukaController.text.trim();
    final village = _isOtherVillage
        ? _villageController.text.trim()
        : (_selectedVillage ?? _villageController.text.trim());

    if ((widget.portal == 'gramsabha' || widget.portal == 'villager') && village.isEmpty) {
      setState(() => _errorMessage = 'कृपया गाव निवडा (Please select village).');
      return;
    }

    final data = <String, dynamic>{
      'role': widget.portal,
      'name': name,
      'phone': phone,
      'password': password,
      'district': 'Nashik',
    };

    if (widget.portal == 'gramsabha') {
      data['village'] = village;
      data['taluka'] = taluka;
      data['contactPerson'] = _contactPersonController.text.trim();
    } else if (widget.portal == 'villager') {
      data['village'] = village;
      data['taluka'] = taluka;
    } else {
      data['businessName'] = _businessController.text.trim();
      data['city'] = _cityController.text.trim();
      data['email'] = _emailController.text.trim();
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await ref.read(authControllerProvider.notifier).register(data);
      if (!mounted) return;

      if (user.role == 'gramsabha') {
        context.go('/gs');
      } else if (user.role == 'buyer') {
        context.go('/b');
      } else {
        context.go('/v');
      }
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

    String portalTitle = 'नोंदणी करा';
    if (widget.portal == 'gramsabha') portalTitle = 'ग्रामसभा नोंदणी (Gram Sabha)';
    if (widget.portal == 'villager') portalTitle = 'ग्रामस्थ नोंदणी (Villager)';
    if (widget.portal == 'buyer') portalTitle = 'व्यापारी नोंदणी (General Buyer)';

    return Scaffold(
      appBar: AppBar(title: Text(portalTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tokens.chipErrorBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: tokens.error, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text('पूर्ण नाव / संस्था नाव *', style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: AppInputHints.fullName(context, isGs: widget.portal == 'gramsabha'),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              Text('मोबाईल क्रमांक *', style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixText: '+91 ',
                  hintText: '98220XXXXX',
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.portal == 'gramsabha' || widget.portal == 'villager') ...[
                Text('तालुका (Taluka) *', style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTaluka,
                  decoration: InputDecoration(
                    hintText: AppInputHints.selectTaluka(context),
                    filled: true,
                    fillColor: tokens.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: nashikTalukas.map((t) => DropdownMenuItem(
                    value: t.value,
                    child: Text(t.label, style: const TextStyle(fontSize: 13.5)),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedTaluka = val;
                      _talukaController.text = val ?? '';
                      _selectedVillage = null;
                      _isOtherVillage = false;
                      _villageController.clear();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text('गाव (Village) *', style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  key: ValueKey('village-$_selectedTaluka'),
                  isExpanded: true,
                  initialValue: _selectedVillage,
                  decoration: InputDecoration(
                    hintText: AppInputHints.selectVillage(context, _selectedTaluka != null),
                    filled: true,
                    fillColor: tokens.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: [
                    ..._villageItems(),
                    const DropdownMenuItem(
                      value: '__other__',
                      child: Text('इतर गाव • Other Village...', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedVillage = val;
                      if (val == '__other__') {
                        _isOtherVillage = true;
                        _villageController.clear();
                      } else {
                        _isOtherVillage = false;
                        _villageController.text = val ?? '';
                      }
                    });
                  },
                ),
                if (_isOtherVillage) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _villageController,
                    decoration: InputDecoration(
                      hintText: AppInputHints.typeVillage(context),
                      filled: true,
                      fillColor: tokens.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
              if (widget.portal == 'gramsabha') ...[
                Text('संपर्क व्यक्ती (सचिव / अध्यक्ष)', style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _contactPersonController,
                  decoration: InputDecoration(
                    hintText: AppInputHints.representative(context),
                    filled: true,
                    fillColor: tokens.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (widget.portal == 'buyer') ...[
                Text('कंपनी / ब्रँड नाव', style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _businessController,
                  decoration: InputDecoration(
                    hintText: AppInputHints.organization(context),
                    filled: true,
                    fillColor: tokens.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('शहर (City)', style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: AppInputHints.city(context),
                    filled: true,
                    fillColor: tokens.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Text(AppLocalizations.of(context)?.pinLabel ?? 'PIN (6 digits) *', style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: AppLocalizations.of(context)?.pinHint ?? '6-digit PIN',
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.actionPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('नोंदणी पूर्ण करा • Complete Registration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
