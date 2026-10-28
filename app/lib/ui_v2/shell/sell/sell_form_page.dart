import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/sell_catalog.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/sell_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../models/catalog_models.dart';
import '../../models/sell_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/sell_providers.dart';
import '../../theme/van_rozgar_tokens.dart';
import '../../widgets/app_background.dart';
import '../../widgets/sell/sell_preview_card.dart';
import 'sell_page.dart';

/// Single scrolling form for `/sell/new` (`editingId == null`) and `/sell/edit/:id` (`editingId != null`).
///
/// Steps on one page:
/// 1. Choose the product (search + catalog list; fixed read-only card when editing).
/// 2. Quantity (whole number, with the product's unit).
/// 3. MRP per unit and Your price per unit in rupees (up to 2 decimal places), with a live
///    "Discount: N%" line ONLY when price < MRP and an error when price > MRP.
/// 4. Minimum order (at least 1, at most the quantity).
/// 5. How can buyers get it? (Pickup / Delivery / Both).
/// 6. Live preview card reusing `ProductCard`.
/// 7. Green "Publish listing" button.
class SellFormPage extends ConsumerStatefulWidget {
  final String? editingId;

  const SellFormPage({super.key, this.editingId});

  bool get isEditing => editingId != null;

  @override
  ConsumerState<SellFormPage> createState() => _SellFormPageState();
}

class _SellFormPageState extends ConsumerState<SellFormPage> {
  late final TextEditingController _searchController;
  late final TextEditingController _quantityController;
  late final TextEditingController _mrpController;
  late final TextEditingController _priceController;
  late final TextEditingController _minOrderController;

  String _searchQuery = '';
  String? _selectedProductCode;
  String _fulfilment = 'both';
  int _quantitySold = 0;
  bool _submitted = false;
  MyListing? _editingOriginal;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    ListingDraft initialDraft;
    if (widget.isEditing) {
      final listings = ref.read(myListingsProvider);
      MyListing? found;
      for (final item in listings) {
        if (item.id == widget.editingId) {
          found = item;
          break;
        }
      }
      _editingOriginal = found;
      _quantitySold = found?.quantitySold ?? 0;
      initialDraft = found != null ? ListingDraft.fromListing(found) : const ListingDraft();
    } else {
      initialDraft = ref.read(listingDraftProvider);
    }

    _selectedProductCode = initialDraft.productCode;
    _fulfilment = initialDraft.fulfilment;
    _quantityController = TextEditingController(text: initialDraft.quantityText);
    _mrpController = TextEditingController(text: initialDraft.mrpRupeesText);
    _priceController = TextEditingController(text: initialDraft.priceRupeesText);
    _minOrderController = TextEditingController(text: initialDraft.minOrderText);

    _quantityController.addListener(_onFormChanged);
    _mrpController.addListener(_onFormChanged);
    _priceController.addListener(_onFormChanged);
    _minOrderController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _mrpController.dispose();
    _priceController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  ListingDraft _currentDraft() {
    return ListingDraft(
      productCode: _selectedProductCode,
      quantityText: _quantityController.text,
      mrpRupeesText: _mrpController.text,
      priceRupeesText: _priceController.text,
      minOrderText: _minOrderController.text,
      fulfilment: _fulfilment,
    );
  }

  void _onFormChanged() {
    if (!widget.isEditing) {
      ref.read(listingDraftProvider.notifier).state = _currentDraft();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _selectProduct(String code) {
    setState(() {
      _selectedProductCode = code;
    });
    if (!widget.isEditing) {
      ref.read(listingDraftProvider.notifier).state = _currentDraft();
    }
  }

  void _selectFulfilment(String mode) {
    setState(() {
      _fulfilment = mode;
    });
    if (!widget.isEditing) {
      ref.read(listingDraftProvider.notifier).state = _currentDraft();
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/sell');
    }
  }

  void _publish(AppLanguage language, String unit) {
    setState(() {
      _submitted = true;
    });

    final draft = _currentDraft();
    final errors = validateListingDraft(
      draft,
      quantitySold: _quantitySold,
      language: language,
      unit: unit,
    );
    if (errors.isNotEmpty) return;

    final productCode = draft.productCode!;
    final quantityTotal = parseWholeNumber(draft.quantityText)!;
    final mrpPaise = parseRupeesToPaise(draft.mrpRupeesText)!;
    final pricePaise = parseRupeesToPaise(draft.priceRupeesText)!;
    final minOrderQuantity = parseWholeNumber(draft.minOrderText)!;

    final currentList = ref.read(myListingsProvider);
    if (widget.isEditing && _editingOriginal != null) {
      final updated = _editingOriginal!.copyWith(
        quantityTotal: quantityTotal,
        mrpPaise: mrpPaise,
        pricePaise: pricePaise,
        minOrderQuantity: minOrderQuantity,
        fulfilment: _fulfilment,
      );
      ref.read(myListingsProvider.notifier).state = updateListing(currentList, updated);
    } else {
      final newListing = MyListing(
        id: 'my-${DateTime.now().microsecondsSinceEpoch}',
        productCode: productCode,
        quantityTotal: quantityTotal,
        quantitySold: 0,
        mrpPaise: mrpPaise,
        pricePaise: pricePaise,
        minOrderQuantity: minOrderQuantity,
        fulfilment: _fulfilment,
        status: 'active',
        createdAt: DateTime.now().toUtc(),
        isSample: false,
      );
      ref.read(myListingsProvider.notifier).state = createListing(currentList, newListing);
      ref.read(listingDraftProvider.notifier).state = const ListingDraft();
    }

    _goBack();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final user = ref.watch(authUserProvider);
    final catalog = ref.watch(sellCatalogProvider).valueOrNull ?? const <ShopProduct>[];
    final byCode = <String, ShopProduct>{for (final p in catalog) p.productCode: p};

    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    final selectedProduct = _selectedProductCode != null ? byCode[_selectedProductCode!] : null;
    final unit = selectedProduct?.localizedUnit(language) ?? '';

    final draft = _currentDraft();
    final allErrors = validateListingDraft(
      draft,
      quantitySold: _quantitySold,
      language: language,
      unit: unit,
    );

    String? errorFor(ListingField field) {
      for (final e in allErrors) {
        if (e.field == field) return e.message;
      }
      return null;
    }

    final mrpPaise = parseRupeesToPaise(_mrpController.text);
    final pricePaise = parseRupeesToPaise(_priceController.text);
    final isLivePriceAboveMrp =
        mrpPaise != null && pricePaise != null && mrpPaise > 0 && pricePaise > mrpPaise;
    final discountPct = liveDiscountPercent(mrpPaise: mrpPaise, pricePaise: pricePaise);

    final productError = _submitted ? errorFor(ListingField.product) : null;
    final quantityError = _submitted ? errorFor(ListingField.quantity) : null;
    final mrpError = _submitted ? errorFor(ListingField.mrp) : null;
    final priceError = isLivePriceAboveMrp
        ? strings.slErrPriceAboveMrp
        : (_submitted ? errorFor(ListingField.price) : null);
    final minOrderError = _submitted ? errorFor(ListingField.minOrder) : null;

    final filteredCatalog = _filterCatalog(catalog, _searchQuery, strings);
    final previewProduct = selectedProduct ?? (catalog.isNotEmpty ? catalog.first : null);

    return Scaffold(
      body: AppBackground(
        categorySlug: selectedProduct?.categorySlug ?? 'forest-produce',
        useSafeArea: true,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: EdgeInsets.fromLTRB(4.0 * s, 4.0 * s, 16.0 * s, 4.0 * s),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('sell_form_back_button'),
                    tooltip: strings.backLabel,
                    onPressed: _goBack,
                    icon: Icon(Icons.arrow_back, color: tokens.heading),
                  ),
                  Expanded(
                    child: Text(
                      widget.isEditing ? strings.slEditListingTitle : strings.slAddListingButton,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !isSellerUser(user)
                  ? SellRoleGateView(
                      user: user,
                      strings: strings,
                      tokens: tokens,
                      scale: s,
                      redirectPath: widget.isEditing ? '/sell/edit/${widget.editingId}' : '/sell/new',
                    )
                  : ListView(
                      padding: EdgeInsets.fromLTRB(16.0 * s, 8.0 * s, 16.0 * s, 28.0 * s),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560.0),
                            child: Container(
                              padding: EdgeInsets.all(16.0 * s),
                              decoration: BoxDecoration(
                                color: tokens.card,
                                borderRadius: BorderRadius.circular(16.0 * s),
                                border: Border.all(color: tokens.borders),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ---- Step 1: Choose the product (or fixed product when editing) ----
                                  Text(
                                    widget.isEditing
                                        ? strings.slFixedProductHeading
                                        : strings.slStepChooseProduct,
                                    style: TextStyle(
                                      fontSize: 16.0 * s,
                                      fontWeight: FontWeight.w800,
                                      color: tokens.heading,
                                    ),
                                  ),
                                  SizedBox(height: 8.0 * s),
                                  if (widget.isEditing)
                                    _FixedProductTile(
                                      product: selectedProduct,
                                      fallbackCode: _selectedProductCode ?? '',
                                      language: language,
                                      strings: strings,
                                      tokens: tokens,
                                      scale: s,
                                    )
                                  else ...[
                                    TextField(
                                      key: const Key('sell_product_search'),
                                      controller: _searchController,
                                      onChanged: (value) => setState(() => _searchQuery = value),
                                      decoration: _fieldDecoration(
                                        label: strings.slProductSearchHint,
                                        tokens: tokens,
                                        prefixIcon: Icon(Icons.search, color: tokens.mutedText, size: 20.0 * s),
                                      ),
                                    ),
                                    SizedBox(height: 10.0 * s),
                                    if (filteredCatalog.isEmpty)
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12.0 * s),
                                        child: Text(
                                          strings.nothingFound,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 13.0 * s, color: tokens.mutedText),
                                        ),
                                      )
                                    else if (filteredCatalog.length <= 6)
                                      Column(
                                        children: [
                                          for (int i = 0; i < filteredCatalog.length; i++) ...[
                                            if (i > 0) SizedBox(height: 8.0 * s),
                                            _ProductChoiceRow(
                                              product: filteredCatalog[i],
                                              isSelected:
                                                  filteredCatalog[i].productCode == _selectedProductCode,
                                              language: language,
                                              strings: strings,
                                              tokens: tokens,
                                              scale: s,
                                              onTap: () => _selectProduct(filteredCatalog[i].productCode),
                                            ),
                                          ],
                                        ],
                                      )
                                    else
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxHeight: 240.0 * s),
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: filteredCatalog.length,
                                          separatorBuilder: (context, index) => SizedBox(height: 8.0 * s),
                                          itemBuilder: (context, index) {
                                            final p = filteredCatalog[index];
                                            return _ProductChoiceRow(
                                              product: p,
                                              isSelected: p.productCode == _selectedProductCode,
                                              language: language,
                                              strings: strings,
                                              tokens: tokens,
                                              scale: s,
                                              onTap: () => _selectProduct(p.productCode),
                                            );
                                          },
                                        ),
                                      ),
                                    if (productError != null) ...[
                                      SizedBox(height: 6.0 * s),
                                      Text(
                                        productError,
                                        key: const Key('sell_error_product'),
                                        style: TextStyle(
                                          fontSize: 12.0 * s,
                                          fontWeight: FontWeight.w600,
                                          color: tokens.orange,
                                        ),
                                      ),
                                    ],
                                  ],
                                  SizedBox(height: 8.0 * s),
                                  // Muted line explaining that the catalog photo is always used
                                  Text(
                                    strings.slCatalogPhotoNote,
                                    style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                                  ),

                                  SizedBox(height: 18.0 * s),

                                  // ---- Step 2: Quantity ----
                                  Text(
                                    strings.slStepQuantity,
                                    style: TextStyle(
                                      fontSize: 16.0 * s,
                                      fontWeight: FontWeight.w800,
                                      color: tokens.heading,
                                    ),
                                  ),
                                  SizedBox(height: 8.0 * s),
                                  TextField(
                                    key: const Key('sell_quantity_input'),
                                    controller: _quantityController,
                                    keyboardType: TextInputType.number,
                                    decoration: _fieldDecoration(
                                      label: strings.slQuantityLabel(unit),
                                      tokens: tokens,
                                      errorText: quantityError,
                                      suffixText: unit.isEmpty ? null : unit,
                                    ),
                                  ),
                                  if (widget.isEditing && _quantitySold > 0) ...[
                                    SizedBox(height: 4.0 * s),
                                    Text(
                                      strings.slAlreadySoldHint(_quantitySold, unit),
                                      style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                                    ),
                                  ],

                                  SizedBox(height: 18.0 * s),

                                  // ---- Step 3: MRP and selling price ----
                                  Text(
                                    strings.slStepPricing,
                                    style: TextStyle(
                                      fontSize: 16.0 * s,
                                      fontWeight: FontWeight.w800,
                                      color: tokens.heading,
                                    ),
                                  ),
                                  SizedBox(height: 8.0 * s),
                                  TextField(
                                    key: const Key('sell_mrp_input'),
                                    controller: _mrpController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: _fieldDecoration(
                                      label: strings.slMrpLabel(unit),
                                      tokens: tokens,
                                      errorText: mrpError,
                                      prefixText: '₹ ',
                                    ),
                                  ),
                                  SizedBox(height: 12.0 * s),
                                  TextField(
                                    key: const Key('sell_price_input'),
                                    controller: _priceController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: _fieldDecoration(
                                      label: strings.slPriceLabel(unit),
                                      tokens: tokens,
                                      errorText: priceError,
                                      prefixText: '₹ ',
                                    ),
                                  ),
                                  if (discountPct != null) ...[
                                    SizedBox(height: 6.0 * s),
                                    Text(
                                      strings.slDiscountLine(discountPct),
                                      key: const Key('sell_live_discount'),
                                      style: TextStyle(
                                        fontSize: 13.0 * s,
                                        fontWeight: FontWeight.w700,
                                        color: tokens.primaryGreen,
                                      ),
                                    ),
                                  ],

                                  SizedBox(height: 18.0 * s),

                                  // ---- Step 4: Minimum order ----
                                  Text(
                                    strings.slStepMinOrder,
                                    style: TextStyle(
                                      fontSize: 16.0 * s,
                                      fontWeight: FontWeight.w800,
                                      color: tokens.heading,
                                    ),
                                  ),
                                  SizedBox(height: 8.0 * s),
                                  TextField(
                                    key: const Key('sell_min_order_input'),
                                    controller: _minOrderController,
                                    keyboardType: TextInputType.number,
                                    decoration: _fieldDecoration(
                                      label: strings.slMinOrderLabel(unit),
                                      tokens: tokens,
                                      errorText: minOrderError,
                                      suffixText: unit.isEmpty ? null : unit,
                                    ),
                                  ),

                                  SizedBox(height: 18.0 * s),

                                  // ---- Step 5: How can buyers get it? ----
                                  Text(
                                    strings.slStepFulfilment,
                                    style: TextStyle(
                                      fontSize: 16.0 * s,
                                      fontWeight: FontWeight.w800,
                                      color: tokens.heading,
                                    ),
                                  ),
                                  SizedBox(height: 8.0 * s),
                                  _FulfilmentChoiceCard(
                                    key: const Key('sell_fulfilment_pickup'),
                                    title: strings.fulfilPickup,
                                    subtitle: strings.slFulfilPickupSub,
                                    icon: Icons.store_mall_directory_outlined,
                                    isSelected: _fulfilment == 'pickup',
                                    tokens: tokens,
                                    scale: s,
                                    onTap: () => _selectFulfilment('pickup'),
                                  ),
                                  SizedBox(height: 8.0 * s),
                                  _FulfilmentChoiceCard(
                                    key: const Key('sell_fulfilment_delivery'),
                                    title: strings.fulfilDelivery,
                                    subtitle: strings.slFulfilDeliverySub,
                                    icon: Icons.local_shipping_outlined,
                                    isSelected: _fulfilment == 'delivery',
                                    tokens: tokens,
                                    scale: s,
                                    onTap: () => _selectFulfilment('delivery'),
                                  ),
                                  SizedBox(height: 8.0 * s),
                                  _FulfilmentChoiceCard(
                                    key: const Key('sell_fulfilment_both'),
                                    title: strings.slFulfilBoth,
                                    subtitle: strings.slFulfilBothSub,
                                    icon: Icons.swap_horiz_outlined,
                                    isSelected: _fulfilment == 'both',
                                    tokens: tokens,
                                    scale: s,
                                    onTap: () => _selectFulfilment('both'),
                                  ),

                                  // ---- Step 6: Live preview card ----
                                  if (previewProduct != null) ...[
                                    SizedBox(height: 18.0 * s),
                                    Text(
                                      strings.slStepPreview,
                                      style: TextStyle(
                                        fontSize: 16.0 * s,
                                        fontWeight: FontWeight.w800,
                                        color: tokens.heading,
                                      ),
                                    ),
                                    SizedBox(height: 10.0 * s),
                                    SellPreviewCard(
                                      product: previewProduct,
                                      sellerRole: user?.role ?? 'gramsabha',
                                      sellerName: user?.name ?? strings.sellerGramSabha,
                                      quantityTotal: parseWholeNumber(_quantityController.text) ?? 50,
                                      quantitySold: _quantitySold,
                                      mrpPaise: mrpPaise ?? 10000,
                                      pricePaise: pricePaise ?? 8000,
                                      minOrderQuantity: parseWholeNumber(_minOrderController.text) ?? 1,
                                      fulfilment: _fulfilment,
                                      scale: s,
                                    ),
                                  ],

                                  SizedBox(height: 20.0 * s),

                                  // ---- Step 7: Green "Publish listing" button ----
                                  FilledButton(
                                    key: const Key('sell_publish_button'),
                                    onPressed: () => _publish(language, unit),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: tokens.primaryGreen,
                                      foregroundColor: tokens.onPrimaryGreen,
                                      minimumSize: Size(0, 52.0 * s),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0 * s),
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        strings.slPublishButton,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 16.0 * s,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

List<ShopProduct> _filterCatalog(
  List<ShopProduct> catalog,
  String query,
  AppStrings strings,
) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) return catalog;
  return catalog.where((p) {
    final en = p.title['en']?.toLowerCase() ?? '';
    final hi = p.title['hi']?.toLowerCase() ?? '';
    final mr = p.title['mr']?.toLowerCase() ?? '';
    final cat = strings.categoryLabel(p.categorySlug).toLowerCase();
    return en.contains(trimmed) ||
        hi.contains(trimmed) ||
        mr.contains(trimmed) ||
        cat.contains(trimmed);
  }).toList(growable: false);
}

InputDecoration _fieldDecoration({
  required String label,
  required VanRozgarColorTokens tokens,
  String? errorText,
  String? prefixText,
  String? suffixText,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    labelText: label,
    errorText: errorText,
    errorMaxLines: 3,
    prefixText: prefixText,
    suffixText: suffixText,
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: tokens.page.withValues(alpha: 0.6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: tokens.borders),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: tokens.borders),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: tokens.primaryGreen, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: tokens.orange, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: tokens.orange, width: 1.5),
    ),
  );
}

class _ProductChoiceRow extends StatelessWidget {
  final ShopProduct product;
  final bool isSelected;
  final AppLanguage language;
  final AppStrings strings;
  final VanRozgarColorTokens tokens;
  final double scale;
  final VoidCallback onTap;

  const _ProductChoiceRow({
    required this.product,
    required this.isSelected,
    required this.language,
    required this.strings,
    required this.tokens,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final title = product.localizedTitle(language);
    final category = strings.categoryLabel(product.categorySlug);
    final unit = product.localizedUnit(language);

    return Material(
      key: Key('sell_product_option_${product.productCode}'),
      color: isSelected ? tokens.chipBg.withValues(alpha: 0.55) : tokens.page.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0 * s),
        side: BorderSide(
          color: isSelected ? tokens.primaryGreen : tokens.borders,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52.0),
          child: Padding(
            padding: EdgeInsets.all(8.0 * s),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0 * s),
                  child: Container(
                    width: 44.0 * s,
                    height: 44.0 * s,
                    color: VanRozgarTokens.picturePanel,
                    child: Image.asset(
                      product.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.eco_outlined,
                        size: 22.0 * s,
                        color: tokens.primaryGreen.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.0 * s,
                          fontWeight: FontWeight.w700,
                          color: tokens.heading,
                        ),
                      ),
                      Text(
                        unit.isEmpty ? category : '$category · $unit',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.0 * s,
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.0 * s),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 22.0 * s,
                  color: isSelected ? tokens.primaryGreen : tokens.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FixedProductTile extends StatelessWidget {
  final ShopProduct? product;
  final String fallbackCode;
  final AppLanguage language;
  final AppStrings strings;
  final VanRozgarColorTokens tokens;
  final double scale;

  const _FixedProductTile({
    required this.product,
    required this.fallbackCode,
    required this.language,
    required this.strings,
    required this.tokens,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final title = product?.localizedTitle(language) ?? fallbackCode;
    final category = product != null ? strings.categoryLabel(product!.categorySlug) : '';
    final imageAsset = product?.imageAsset ?? 'assets/catalog/$fallbackCode.jpg';

    return Container(
      key: const Key('sell_fixed_product_tile'),
      padding: EdgeInsets.all(10.0 * s),
      decoration: BoxDecoration(
        color: tokens.page.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12.0 * s),
        border: Border.all(color: tokens.borders),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0 * s),
            child: Container(
              width: 48.0 * s,
              height: 48.0 * s,
              color: VanRozgarTokens.picturePanel,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.eco_outlined,
                  size: 24.0 * s,
                  color: tokens.primaryGreen.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.0 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.0 * s,
                    fontWeight: FontWeight.w800,
                    color: tokens.heading,
                  ),
                ),
                if (category.isNotEmpty)
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FulfilmentChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VanRozgarColorTokens tokens;
  final double scale;
  final VoidCallback onTap;

  const _FulfilmentChoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.tokens,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Material(
      color: isSelected ? tokens.chipBg.withValues(alpha: 0.55) : tokens.page.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0 * s),
        side: BorderSide(
          color: isSelected ? tokens.primaryGreen : tokens.borders,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0 * s, vertical: 10.0 * s),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22.0 * s,
                  color: isSelected ? tokens.primaryGreen : tokens.mutedText,
                ),
                SizedBox(width: 10.0 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.0 * s,
                          fontWeight: FontWeight.w700,
                          color: tokens.heading,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.0 * s,
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.0 * s),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 22.0 * s,
                  color: isSelected ? tokens.primaryGreen : tokens.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

