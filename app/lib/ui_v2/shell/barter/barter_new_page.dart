import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/community_strings.dart';
import '../../models/community_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/community_providers.dart';
import '../../widgets/community/community_widgets.dart';

/// `/barter/new`: Create a new barter offer for a specific listing.
class BarterNewPage extends ConsumerStatefulWidget {
  final String? listingId;
  final String? title;
  final String? unit;

  const BarterNewPage({
    super.key,
    this.listingId,
    this.title,
    this.unit,
  });

  @override
  ConsumerState<BarterNewPage> createState() => _BarterNewPageState();
}

class _BarterNewPageState extends ConsumerState<BarterNewPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _offeredQtyCtrl = TextEditingController();
  final _offeredUnitCtrl = TextEditingController(text: 'kg');
  final _wantedQtyCtrl = TextEditingController(text: '1');
  final _noteCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _offeredQtyCtrl.dispose();
    _offeredUnitCtrl.dispose();
    _wantedQtyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppStrings strings) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final listingId = widget.listingId!;
    final offTitle = _titleCtrl.text.trim();
    final offQty = int.parse(_offeredQtyCtrl.text.trim());
    final offUnit = _offeredUnitCtrl.text.trim().isEmpty ? 'kg' : _offeredUnitCtrl.text.trim();
    final wantQty = int.parse(_wantedQtyCtrl.text.trim());
    final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();

    try {
      await ref.read(barterRepositoryProvider).create(
            NewBarterOffer(
              wantedListingId: listingId,
              offeredTitle: offTitle,
              offeredQuantity: offQty,
              offeredUnit: offUnit,
              wantedQuantity: wantQty,
              note: note,
            ),
          );
      ref.invalidate(outgoingBarterProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.btSent)),
        );
        context.pushReplacement('/barter');
      }
    } catch (_) {
      // In offline/test mode handled safely
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final user = ref.watch(authUserProvider);

    if (user == null) {
      return CommunityPage(
        title: strings.btNewTitle,
        body: CommunityCentered(
          child: CommunityGuestCard(
            icon: Icons.swap_horiz,
            body: strings.btGuestBody,
          ),
        ),
      );
    }

    // Friendly error when listing is missing
    if (widget.listingId == null || widget.listingId!.isEmpty) {
      return CommunityPage(
        title: strings.btNewTitle,
        body: CommunityCentered(
          child: CommunityMessageCard(
            key: const Key('barter_new_missing_listing'),
            icon: Icons.info_outline,
            body: strings.btMissingListing,
            actions: [
              CommunitySecondaryButton(
                key: const Key('barter_new_back_btn'),
                label: strings.btBackToProducts,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/categories');
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    final targetTitle = widget.title?.trim().isNotEmpty == true ? widget.title!.trim() : widget.listingId!;
    final targetUnit = widget.unit?.trim().isNotEmpty == true ? widget.unit!.trim() : '';

    return CommunityPage(
      title: strings.btNewTitle,
      body: CommunityScroll(
        scrollKey: const Key('barter_new_scroll'),
        children: [
          // Header showing target listing
          CommunityCard(
            child: Row(
              children: [
                Icon(Icons.swap_horiz, size: 28.0 * s, color: tokens.primaryGreen),
                SizedBox(width: 12.0 * s),
                Expanded(
                  child: Text(
                    strings.btForListing(targetTitle),
                    key: const Key('barter_new_target_title'),
                    style: TextStyle(fontSize: 15.5 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0 * s),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Offered item title
                Text(
                  strings.btOfferedItem,
                  style: TextStyle(fontSize: 13.5 * s, fontWeight: FontWeight.w700, color: tokens.heading),
                ),
                SizedBox(height: 4.0 * s),
                TextFormField(
                  key: const Key('barter_new_offered_title'),
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: tokens.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0 * s),
                      borderSide: BorderSide(color: tokens.borders),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 2) return strings.btErrItem;
                    return null;
                  },
                ),
                SizedBox(height: 14.0 * s),

                // Offered quantity & unit row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            strings.btOfferedQuantity,
                            style: TextStyle(fontSize: 13.5 * s, fontWeight: FontWeight.w700, color: tokens.heading),
                          ),
                          SizedBox(height: 4.0 * s),
                          TextFormField(
                            key: const Key('barter_new_offered_qty'),
                            controller: _offeredQtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: tokens.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0 * s),
                                borderSide: BorderSide(color: tokens.borders),
                              ),
                            ),
                            validator: (val) {
                              final n = int.tryParse(val?.trim() ?? '');
                              if (n == null || n <= 0) return strings.btErrQuantity;
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.0 * s),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            strings.btUnit,
                            style: TextStyle(fontSize: 13.5 * s, fontWeight: FontWeight.w700, color: tokens.heading),
                          ),
                          SizedBox(height: 4.0 * s),
                          TextFormField(
                            key: const Key('barter_new_offered_unit'),
                            controller: _offeredUnitCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: tokens.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0 * s),
                                borderSide: BorderSide(color: tokens.borders),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.0 * s),

                // Wanted quantity
                Text(
                  targetUnit.isNotEmpty ? '${strings.btWantedQuantity} ($targetUnit)' : strings.btWantedQuantity,
                  style: TextStyle(fontSize: 13.5 * s, fontWeight: FontWeight.w700, color: tokens.heading),
                ),
                SizedBox(height: 4.0 * s),
                TextFormField(
                  key: const Key('barter_new_wanted_qty'),
                  controller: _wantedQtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: tokens.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0 * s),
                      borderSide: BorderSide(color: tokens.borders),
                    ),
                  ),
                  validator: (val) {
                    final n = int.tryParse(val?.trim() ?? '');
                    if (n == null || n <= 0) return strings.btErrQuantity;
                    return null;
                  },
                ),
                SizedBox(height: 14.0 * s),

                // Note (optional)
                Text(
                  strings.btNoteOptional,
                  style: TextStyle(fontSize: 13.5 * s, fontWeight: FontWeight.w700, color: tokens.heading),
                ),
                SizedBox(height: 4.0 * s),
                TextFormField(
                  key: const Key('barter_new_note'),
                  controller: _noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: tokens.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0 * s),
                      borderSide: BorderSide(color: tokens.borders),
                    ),
                  ),
                ),
                SizedBox(height: 24.0 * s),

                // Submit button
                CommunityPrimaryButton(
                  key: const Key('barter_new_submit'),
                  label: strings.btSendOffer,
                  onPressed: _submitting ? null : () => _submit(strings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

