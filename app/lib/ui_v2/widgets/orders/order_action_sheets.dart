import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/orders_strings.dart';
import '../../l10n/shop_extra_strings.dart';
import '../../models/catalog_models.dart';
import '../../models/order_models.dart';
import '../../providers/orders_providers.dart';
import '../../theme/van_rozgar_tokens.dart';

InputDecoration _sheetInputDecoration(
  String label,
  VanRozgarColorTokens tokens, {
  String? hint,
  String? error,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    errorText: error,
    errorMaxLines: 3,
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
  );
}

/// Asks the buyer to confirm cancelling a pending request.
Future<bool?> showCancelOrderSheet(
  BuildContext context, {
  required AppLanguage language,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _CancelOrderSheet(language: language),
  );
}

class _CancelOrderSheet extends StatelessWidget {
  final AppLanguage language;

  const _CancelOrderSheet({required this.language});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    return SafeArea(
      top: false,
      child: Material(
        key: const Key('cancel_order_sheet'),
        color: tokens.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0 * s)),
          side: BorderSide(color: tokens.borders),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0 * s, 12.0 * s, 20.0 * s, 20.0 * s),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.0 * s,
                    height: 4.0 * s,
                    decoration: BoxDecoration(
                      color: tokens.borders,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                SizedBox(height: 14.0 * s),
                Text(
                  strings.odCancelConfirmTitle,
                  style: TextStyle(
                    fontSize: 18.0 * s,
                    fontWeight: FontWeight.w800,
                    color: tokens.heading,
                  ),
                ),
                SizedBox(height: 8.0 * s),
                Text(
                  strings.odCancelConfirmBody,
                  style: TextStyle(
                    fontSize: 13.5 * s,
                    color: tokens.bodyText,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 18.0 * s),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('cancel_order_keep'),
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tokens.primaryGreen,
                          side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                          minimumSize: Size(0, 48.0 * s),
                          shape: const StadiumBorder(),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            strings.odCancelKeepBtn,
                            maxLines: 1,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.0 * s),
                    Expanded(
                      child: FilledButton(
                        key: const Key('cancel_order_confirm'),
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: tokens.primaryGreen,
                          foregroundColor: tokens.onPrimaryGreen,
                          minimumSize: Size(0, 48.0 * s),
                          shape: const StadiumBorder(),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            strings.odCancelConfirmBtn,
                            maxLines: 1,
                            style: const TextStyle(fontWeight: FontWeight.w800),
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
      ),
    );
  }
}

/// Sheet for the buyer to report a UPI payment reference (6 to 30 characters).
/// Never displays a UPI ID, QR code, or payment link.
Future<String?> showPaymentReferenceSheet(
  BuildContext context, {
  required AppLanguage language,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _PaymentReferenceSheet(language: language),
  );
}

class _PaymentReferenceSheet extends StatefulWidget {
  final AppLanguage language;

  const _PaymentReferenceSheet({required this.language});

  @override
  State<_PaymentReferenceSheet> createState() => _PaymentReferenceSheetState();
}

class _PaymentReferenceSheetState extends State<_PaymentReferenceSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(AppStrings strings) {
    final text = _controller.text.trim();
    if (!isValidPaymentReference(text)) {
      setState(() => _error = strings.odPaidRefError);
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(widget.language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Material(
          key: const Key('paid_reference_sheet'),
          color: tokens.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0 * s)),
            side: BorderSide(color: tokens.borders),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.0 * s, 12.0 * s, 20.0 * s, 20.0 * s),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.0 * s,
                      height: 4.0 * s,
                      decoration: BoxDecoration(
                        color: tokens.borders,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.0 * s),
                  Text(
                    strings.odPaidSheetTitle,
                    style: TextStyle(
                      fontSize: 18.0 * s,
                      fontWeight: FontWeight.w800,
                      color: tokens.heading,
                    ),
                  ),
                  SizedBox(height: 6.0 * s),
                  Text(
                    strings.odPaidSheetSubtitle,
                    style: TextStyle(
                      fontSize: 13.0 * s,
                      color: tokens.mutedText,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 14.0 * s),
                  TextField(
                    key: const Key('paid_reference_input'),
                    controller: _controller,
                    maxLength: 30,
                    decoration: _sheetInputDecoration(
                      strings.odPaymentRefLabel,
                      tokens,
                      hint: strings.odPaidRefHint,
                      error: _error,
                    ).copyWith(counterText: ''),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  SizedBox(height: 16.0 * s),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('paid_reference_cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: tokens.primaryGreen,
                            side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                            minimumSize: Size(0, 48.0 * s),
                            shape: const StadiumBorder(),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              strings.notNow,
                              maxLines: 1,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.0 * s),
                      Expanded(
                        child: FilledButton(
                          key: const Key('paid_reference_submit'),
                          onPressed: () => _submit(strings),
                          style: FilledButton.styleFrom(
                            backgroundColor: tokens.primaryGreen,
                            foregroundColor: tokens.onPrimaryGreen,
                            minimumSize: Size(0, 48.0 * s),
                            shape: const StadiumBorder(),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              strings.odPaidSubmitBtn,
                              maxLines: 1,
                              style: const TextStyle(fontWeight: FontWeight.w800),
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
        ),
      ),
    );
  }
}

/// Sheet for the seller to reject a pending request with a required reason.
Future<String?> showRejectOrderSheet(
  BuildContext context, {
  required AppLanguage language,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _RejectOrderSheet(language: language),
  );
}

class _RejectOrderSheet extends StatefulWidget {
  final AppLanguage language;

  const _RejectOrderSheet({required this.language});

  @override
  State<_RejectOrderSheet> createState() => _RejectOrderSheetState();
}

class _RejectOrderSheetState extends State<_RejectOrderSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(AppStrings strings) {
    final reason = _controller.text.trim();
    if (!isValidRejectReason(reason)) {
      setState(() => _error = strings.odRejectReasonError);
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(widget.language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Material(
          key: const Key('reject_order_sheet'),
          color: tokens.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0 * s)),
            side: BorderSide(color: tokens.borders),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.0 * s, 12.0 * s, 20.0 * s, 20.0 * s),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.0 * s,
                      height: 4.0 * s,
                      decoration: BoxDecoration(
                        color: tokens.borders,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.0 * s),
                  Text(
                    strings.odRejectSheetTitle,
                    style: TextStyle(
                      fontSize: 18.0 * s,
                      fontWeight: FontWeight.w800,
                      color: tokens.heading,
                    ),
                  ),
                  SizedBox(height: 12.0 * s),
                  TextField(
                    key: const Key('reject_reason_input'),
                    controller: _controller,
                    maxLines: 2,
                    decoration: _sheetInputDecoration(
                      strings.odRejectionReasonLabel,
                      tokens,
                      hint: strings.odRejectReasonHint,
                      error: _error,
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  SizedBox(height: 16.0 * s),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('reject_order_cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: tokens.primaryGreen,
                            side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                            minimumSize: Size(0, 48.0 * s),
                            shape: const StadiumBorder(),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              strings.notNow,
                              maxLines: 1,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.0 * s),
                      Expanded(
                        child: FilledButton(
                          key: const Key('reject_order_submit'),
                          onPressed: () => _submit(strings),
                          style: FilledButton.styleFrom(
                            backgroundColor: tokens.primaryGreen,
                            foregroundColor: tokens.onPrimaryGreen,
                            minimumSize: Size(0, 48.0 * s),
                            shape: const StadiumBorder(),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              strings.odRejectSubmitBtn,
                              maxLines: 1,
                              style: const TextStyle(fontWeight: FontWeight.w800),
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
        ),
      ),
    );
  }
}

/// Result returned from the seller counter-offer sheet.
typedef CounterSheetResult = ({int quantity, int unitPricePaise, String? note});

/// Sheet for the seller to propose a counter-offer (quantity within stock and >= minOrder,
/// price in rupees <= MRP).
Future<CounterSheetResult?> showCounterOfferSheet(
  BuildContext context, {
  required OrderLine line,
  required AppLanguage language,
}) {
  return showModalBottomSheet<CounterSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _CounterOfferSheet(line: line, language: language),
  );
}

class _CounterOfferSheet extends StatefulWidget {
  final OrderLine line;
  final AppLanguage language;

  const _CounterOfferSheet({required this.line, required this.language});

  @override
  State<_CounterOfferSheet> createState() => _CounterOfferSheetState();
}

class _CounterOfferSheetState extends State<_CounterOfferSheet> {
  late final TextEditingController _qtyController =
      TextEditingController(text: '${widget.line.quantity}');
  late final TextEditingController _priceController =
      TextEditingController(text: '${widget.line.unitPricePaise ~/ 100}');
  final TextEditingController _noteController = TextEditingController();

  String? _qtyError;
  String? _priceError;

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit(AppStrings strings, String unit) {
    final line = widget.line;
    final qty = int.tryParse(_qtyController.text.trim());
    final rupees = double.tryParse(_priceController.text.trim());
    final pricePaise = rupees != null ? (rupees * 100).round() : -1;

    String? nextQtyErr;
    String? nextPriceErr;

    if (qty == null || qty < line.minOrderQuantity || qty > line.availableStock) {
      nextQtyErr = strings.odCounterQtyError(
        line.minOrderQuantity,
        line.availableStock,
        unit,
      );
    }
    if (pricePaise <= 0 || pricePaise > line.mrpPerUnitPaise) {
      nextPriceErr = strings.odCounterPriceError(formatRupees(line.mrpPerUnitPaise));
    }

    setState(() {
      _qtyError = nextQtyErr;
      _priceError = nextPriceErr;
    });

    if (nextQtyErr != null || nextPriceErr != null || qty == null) return;

    final noteText = _noteController.text.trim();
    Navigator.of(context).pop((
      quantity: qty,
      unitPricePaise: pricePaise,
      note: noteText.isEmpty ? null : noteText,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(widget.language);
    final line = widget.line;
    final unit = line.localizedUnit(widget.language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Material(
          key: const Key('counter_offer_sheet'),
          color: tokens.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0 * s)),
            side: BorderSide(color: tokens.borders),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.0 * s, 12.0 * s, 20.0 * s, 20.0 * s),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.0 * s,
                      height: 4.0 * s,
                      decoration: BoxDecoration(
                        color: tokens.borders,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.0 * s),
                  Text(
                    strings.odCounterSheetTitle,
                    style: TextStyle(
                      fontSize: 18.0 * s,
                      fontWeight: FontWeight.w800,
                      color: tokens.heading,
                    ),
                  ),
                  SizedBox(height: 6.0 * s),
                  Text(
                    strings.odCounterRulesHint(
                      line.minOrderQuantity,
                      line.availableStock,
                      unit,
                      formatRupees(line.mrpPerUnitPaise),
                    ),
                    style: TextStyle(
                      fontSize: 12.5 * s,
                      color: tokens.mutedText,
                    ),
                  ),
                  SizedBox(height: 12.0 * s),
                  TextField(
                    key: const Key('counter_qty_input'),
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: _sheetInputDecoration(
                      strings.odCounterQtyLabel(unit),
                      tokens,
                      error: _qtyError,
                    ),
                    onChanged: (_) {
                      if (_qtyError != null) setState(() => _qtyError = null);
                    },
                  ),
                  SizedBox(height: 12.0 * s),
                  TextField(
                    key: const Key('counter_price_input'),
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: _sheetInputDecoration(
                      strings.odCounterPriceLabel(unit),
                      tokens,
                      error: _priceError,
                    ),
                    onChanged: (_) {
                      if (_priceError != null) setState(() => _priceError = null);
                    },
                  ),
                  SizedBox(height: 12.0 * s),
                  TextField(
                    key: const Key('counter_note_input'),
                    controller: _noteController,
                    decoration: _sheetInputDecoration(
                      strings.odCounterNoteLabel,
                      tokens,
                    ),
                  ),
                  SizedBox(height: 16.0 * s),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('counter_offer_cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: tokens.primaryGreen,
                            side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                            minimumSize: Size(0, 48.0 * s),
                            shape: const StadiumBorder(),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              strings.notNow,
                              maxLines: 1,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.0 * s),
                      Expanded(
                        child: FilledButton(
                          key: const Key('counter_offer_submit'),
                          onPressed: () => _submit(strings, unit),
                          style: FilledButton.styleFrom(
                            backgroundColor: tokens.primaryGreen,
                            foregroundColor: tokens.onPrimaryGreen,
                            minimumSize: Size(0, 48.0 * s),
                            shape: const StadiumBorder(),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              strings.odCounterSubmitBtn,
                              maxLines: 1,
                              style: const TextStyle(fontWeight: FontWeight.w800),
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
        ),
      ),
    );
  }
}

