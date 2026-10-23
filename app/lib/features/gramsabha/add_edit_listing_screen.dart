import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_input_hints.dart';
import '../../core/theme/tokens.dart';
import '../../core/network/app_exception.dart';
import '../listings/listing_providers.dart';
import '../auth/auth_providers.dart';

class AddEditListingScreen extends ConsumerStatefulWidget {
  final String? listingId;

  const AddEditListingScreen({super.key, this.listingId});

  @override
  ConsumerState<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends ConsumerState<AddEditListingScreen> {
  final _titleMrController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _descController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _barterWantsController = TextEditingController();
  final _sourceAreaController = TextEditingController();

  String? _selectedCategoryId;
  String _unit = 'kg';
  String _mode = 'sell'; // 'sell' | 'barter' | 'both'
  String _fulfilment = 'both';
  bool _sustainableDeclared = false;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _units = ['kg', 'g', 'quintal', 'litre', 'piece', 'bundle', 'jar', 'bag'];

  @override
  void initState() {
    super.initState();
    if (widget.listingId != null) {
      _loadExistingListing();
    }
  }

  Future<void> _loadExistingListing() async {
    setState(() => _isLoading = true);
    try {
      final listing = await ref.read(listingDetailProvider(widget.listingId!).future);
      _titleMrController.text = listing.titleMr;
      _titleEnController.text = listing.titleEn;
      _descController.text = listing.description ?? '';
      _qtyController.text = listing.quantityAvailable.toString();
      _priceController.text = (listing.pricePerUnitPaise / 100).toStringAsFixed(0);
      _barterWantsController.text = listing.barterWants ?? '';
      _sourceAreaController.text = listing.sourceForestArea ?? '';
      _selectedCategoryId = listing.categoryId;
      _unit = listing.unit;
      _mode = listing.mode;
      _fulfilment = listing.fulfilment;
      _sustainableDeclared = true;
    } catch (_) {
      // Ignored
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleMrController.dispose();
    _titleEnController.dispose();
    _descController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _barterWantsController.dispose();
    _sourceAreaController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_titleMrController.text.trim().isEmpty ||
        _titleEnController.text.trim().isEmpty ||
        _selectedCategoryId == null ||
        _qtyController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'कृपया सर्व अनिवार्य माहिती भरा (Please fill all required fields).');
      return;
    }

    final qty = double.tryParse(_qtyController.text.trim());
    if (qty == null || qty <= 0) {
      setState(() => _errorMessage = 'कृपया योग्य उपलब्ध प्रमाण प्रविष्ट करा (Valid quantity > 0 required).');
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price < 0) {
      setState(() => _errorMessage = 'कृपया योग्य दर प्रविष्ट करा (Valid price >= 0 required).');
      return;
    }

    if (!_sustainableDeclared) {
      setState(() => _errorMessage = 'वनसंवर्धन नियमांनुसार शाश्वत संकलनाची हमी देणे अनिवार्य आहे (Sustainability declaration required).');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final data = {
        'titleMr': _titleMrController.text.trim(),
        'titleEn': _titleEnController.text.trim(),
        'categoryId': _selectedCategoryId,
        'description': _descController.text.trim(),
        'quantityAvailable': qty,
        'unit': _unit,
        'pricePerUnitRupees': price,
        'mode': _mode,
        'barterWants': _barterWantsController.text.trim(),
        'sourceForestArea': _sourceAreaController.text.trim().isNotEmpty
            ? _sourceAreaController.text.trim()
            : 'CFR Nashik Boundary',
        'sustainableDeclared': _sustainableDeclared,
        'fulfilment': _fulfilment,
      };

      if (widget.listingId != null) {
        await api.patch('/listings/${widget.listingId}', data: data);
        ref.invalidate(listingDetailProvider(widget.listingId!));
      } else {
        await api.post('/listings', data: data);
      }
      ref.invalidate(myListingsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.listingId != null ? 'उत्पादन यशस्वीरित्या अद्ययावत केले! (Listing updated)' : 'उत्पादन यशस्वीरित्या जोडले गेले! (Listing created successfully)')),
      );
      context.pop();
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
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listingId != null ? 'उत्पादन संपादन • Edit Listing' : 'उत्पादन नोंदणी • Add Listing'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: tokens.chipErrorBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: tokens.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: tokens.error),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: tokens.error, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Category Section
              Text('१. श्रेणी निवडा (Select Category) *', style: TextStyle(color: tokens.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (cats) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cats.map((cat) {
                    final isSel = _selectedCategoryId == cat.id;
                    return ChoiceChip(
                      label: Text(cat.localizedName(Localizations.localeOf(context).languageCode)),
                      selected: isSel,
                      selectedColor: tokens.actionPrimary.withValues(alpha: 0.2),
                      side: BorderSide(color: isSel ? tokens.actionPrimary : tokens.outline),
                      labelStyle: TextStyle(
                        color: isSel ? tokens.actionPrimary : tokens.textPrimary,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategoryId = cat.id);
                      },
                    );
                  }).toList(),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading categories'),
              ),
              const SizedBox(height: 20),

              // 2. Titles & Description
              Text('२. उत्पादनाचे नाव (Resource Name) *', style: TextStyle(color: tokens.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleMrController,
                decoration: InputDecoration(
                  labelText: AppInputHints.listingTitleMr(context),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleEnController,
                decoration: InputDecoration(
                  labelText: AppInputHints.listingTitleEn(context),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'वर्णन (Description)',
                  hintText: AppInputHints.listingDescription(context),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Stock & Price
              Text('३. प्रमाण आणि दर (Quantity & Price) *', style: TextStyle(color: tokens.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'उपलब्ध प्रमाण',
                        hintText: AppInputHints.quantityHint(context),
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
                      initialValue: _unit,
                      decoration: InputDecoration(
                        labelText: 'एकक (Unit)',
                        filled: true,
                        fillColor: tokens.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _unit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'दर प्रति एकक (Price in ₹)',
                  prefixText: '₹ ',
                  hintText: AppInputHints.priceHint(context),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Trade Mode
              Text('४. व्यवहार पद्धत (Mode)', style: TextStyle(color: tokens.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'sell', label: Text('फक्त विक्री (Sell)')),
                  ButtonSegment(value: 'barter', label: Text('वस्तुविनिमय')),
                  ButtonSegment(value: 'both', label: Text('दोन्ही (Both)')),
                ],
                selected: {_mode},
                onSelectionChanged: (set) => setState(() => _mode = set.first),
              ),
              if (_mode == 'barter' || _mode == 'both') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _barterWantsController,
                  decoration: InputDecoration(
                    labelText: 'बदल्यात काय हवे आहे? (Barter wishlist)',
                    hintText: AppInputHints.barterWants(context),
                    filled: true,
                    fillColor: tokens.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // 5. Source & Sustainability
              Text('५. वनक्षेत्र आणि शाश्वतता हमी *', style: TextStyle(color: tokens.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _sourceAreaController,
                decoration: InputDecoration(
                  labelText: 'वनक्षेत्र / कंपार्टमेंट (Forest Area)',
                  hintText: AppInputHints.sourceForest(context),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              const SizedBox(height: 8),
              CheckboxListTile(
                value: _sustainableDeclared,
                onChanged: (val) => setState(() => _sustainableDeclared = val ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  'आम्ही खात्री देतो की हे उत्पादन वनसंवर्धनाच्या नियमांनुसार आणि शाश्वत पद्धतीने गोळा केले आहे. (We confirm this was harvested sustainably)',
                  style: TextStyle(color: tokens.textPrimary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.actionPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 2,
                ),
                child: _isLoading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('उत्पादन प्रकाशित करा • Publish Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
