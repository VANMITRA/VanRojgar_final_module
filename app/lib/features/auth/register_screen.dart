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
import '../../shared/widgets/vr_text.dart';
import 'village_providers.dart';
import '../../shared/utils/roles.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String portal; // 'gramsabha' | 'villager' (farmer) | 'cfrholder' | 'buyer'

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
            ref.watch(activeLocaleProvider) == 'en' && (v.villageEn ?? '').isNotEmpty
                ? v.villageEn!
                : (v.villageEn != null && v.villageEn!.isNotEmpty && v.villageEn != v.villageMr
                    ? '${v.villageMr} (${v.villageEn})'
                    : v.villageMr),
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
      setState(() => _errorMessage = tr3(ref.read(activeLocaleProvider),
          en: 'Please fill in all required fields.',
          hi: 'कृपया सभी आवश्यक जानकारी भरें।',
          mr: 'कृपया सर्व आवश्यक माहिती भरा.'));
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(password)) {
      setState(() => _errorMessage = AppLocalizations.of(context)?.pinInvalid ?? 'The PIN must be exactly 6 digits.');
      return;
    }

    final taluka = _selectedTaluka ?? _talukaController.text.trim();
    final village = _selectedVillage ?? _villageController.text.trim();

    if (isVillageRole(widget.portal) && village.isEmpty) {
      setState(() => _errorMessage = tr3(ref.read(activeLocaleProvider),
          en: 'Please select your village.',
          hi: 'कृपया अपना गाँव चुनें।',
          mr: 'कृपया गाव निवडा.'));
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
    } else if (widget.portal == roleFarmer || widget.portal == roleCfrHolder) {
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

      context.go(homeRouteFor(user.role));
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
    final lang = ref.watch(activeLocaleProvider);

    String portalTitle = tr3(lang, en: 'Register', hi: 'पंजीकरण करें', mr: 'नोंदणी करा');
    if (widget.portal == 'gramsabha') portalTitle = tr3(lang, en: 'Gram Sabha registration', hi: 'ग्राम सभा पंजीकरण', mr: 'ग्रामसभा नोंदणी');
    if (widget.portal == roleFarmer) portalTitle = tr3(lang, en: 'Farmer registration', hi: 'किसान पंजीकरण', mr: 'शेतकरी नोंदणी');
    if (widget.portal == roleCfrHolder) portalTitle = tr3(lang, en: 'CFR holder registration', hi: 'सीएफआर धारक पंजीकरण', mr: 'सीएफआर धारक नोंदणी');
    if (widget.portal == 'buyer') portalTitle = tr3(lang, en: 'Buyer registration', hi: 'खरीदार पंजीकरण', mr: 'व्यापारी नोंदणी');

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
              Text(tr3(lang, en: 'Full name / organisation name *', hi: 'पूरा नाम / संस्था का नाम *', mr: 'पूर्ण नाव / संस्था नाव *'), style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
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
              Text(tr3(lang, en: 'Mobile number *', hi: 'मोबाइल नंबर *', mr: 'मोबाईल क्रमांक *'), style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
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
              if (isVillageRole(widget.portal)) ...[
                Text(tr3(lang, en: 'Taluka *', hi: 'तालुका *', mr: 'तालुका *'), style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
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
                      _villageController.clear();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(tr3(lang, en: 'Village *', hi: 'गाँव *', mr: 'गाव *'), style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
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
                  items: _villageItems(),
                  onChanged: (val) {
                    setState(() {
                      _selectedVillage = val;
                      _villageController.text = val ?? '';
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (widget.portal == 'gramsabha') ...[
                Text(tr3(lang, en: 'Contact person (secretary / chair)', hi: 'संपर्क व्यक्ति (सचिव / अध्यक्ष)', mr: 'संपर्क व्यक्ती (सचिव / अध्यक्ष)'), style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
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
                Text(tr3(lang, en: 'Company / brand name', hi: 'कंपनी / ब्रांड का नाम', mr: 'कंपनी / ब्रँड नाव'), style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
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
                Text(tr3(lang, en: 'City', hi: 'शहर', mr: 'शहर'), style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
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
                  : Text(tr3(lang, en: 'Complete registration', hi: 'पंजीकरण पूरा करें', mr: 'नोंदणी पूर्ण करा'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
