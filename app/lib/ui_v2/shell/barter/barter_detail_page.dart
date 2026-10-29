import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/community_strings.dart';
import '../../models/community_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/community_providers.dart';
import '../../widgets/community/community_widgets.dart';

/// `/barter/:id`: Detail view of a barter offer with version history and actions.
class BarterDetailPage extends ConsumerStatefulWidget {
  final String offerId;

  const BarterDetailPage({super.key, required this.offerId});

  @override
  ConsumerState<BarterDetailPage> createState() => _BarterDetailPageState();
}

class _BarterDetailPageState extends ConsumerState<BarterDetailPage> {
  bool _submitting = false;

  Future<void> _handleRespond(String action, {
    String? counterOfferedTitle,
    int? counterOfferedQuantity,
    int? counterWantedQuantity,
    String? note,
  }) async {
    setState(() => _submitting = true);
    try {
      await ref.read(barterRepositoryProvider).respond(
            widget.offerId,
            action,
            counterOfferedTitle: counterOfferedTitle,
            counterOfferedQuantity: counterOfferedQuantity,
            counterWantedQuantity: counterWantedQuantity,
            note: note,
          );
      ref.invalidate(incomingBarterProvider);
      ref.invalidate(outgoingBarterProvider);
      if (mounted) {
        final language = ref.read(uiV2LanguageProvider);
        final strings = AppStrings.of(language);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.btActionDone)),
        );
      }
    } catch (_) {
      // In tests or offline, error can be handled gracefully
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showCounterSheet(BuildContext context, BarterOffer offer, AppStrings strings) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CounterSheet(
        offer: offer,
        strings: strings,
        onSubmit: (title, offeredQty, wantedQty, note) {
          Navigator.of(sheetContext).pop();
          _handleRespond(
            'counter',
            counterOfferedTitle: title,
            counterOfferedQuantity: offeredQty,
            counterWantedQuantity: wantedQty,
            note: note,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);

    final incomingAsync = ref.watch(incomingBarterProvider);
    final outgoingAsync = ref.watch(outgoingBarterProvider);

    if (incomingAsync.isLoading && outgoingAsync.isLoading) {
      return CommunityPage(title: strings.btDetailTitle, body: const SizedBox.shrink());
    }

    final allOffers = [
      ...?incomingAsync.asData?.value,
      ...?outgoingAsync.asData?.value,
    ];

    BarterOffer? offer;
    for (final o in allOffers) {
      if (o.id == widget.offerId) {
        offer = o;
        break;
      }
    }

    if (offer == null) {
      return CommunityPage(
        title: strings.btDetailTitle,
        body: CommunityCentered(
          child: CommunityMessageCard(
            key: const Key('barter_not_found'),
            icon: Icons.info_outline,
            body: strings.btNotFound,
          ),
        ),
      );
    }

    final statusText = strings.btStatusLabel(offer.status);
    final partyText = offer.isIncoming
        ? strings.btFromParty(offer.otherPartyName)
        : strings.btToParty(offer.otherPartyName);
    final wantedName = offer.wantedTitle.isNotEmpty ? offer.wantedTitle : strings.btOfferedItem;

    // Determine allowed actions
    final bool canCounter = offer.isIncoming && (offer.status == 'pending' || offer.status == 'countered');
    final bool canAcceptRejectIncoming = offer.isIncoming && (offer.status == 'pending' || offer.status == 'countered');
    final bool canAcceptRejectOutgoing = !offer.isIncoming && offer.status == 'countered';

    final bool showActions = canAcceptRejectIncoming || canAcceptRejectOutgoing;

    return CommunityPage(
      title: strings.btDetailTitle,
      body: CommunityScroll(
        scrollKey: const Key('barter_detail_scroll'),
        children: [
          // 1. Overview Card
          CommunityCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        partyText,
                        style: TextStyle(
                          fontSize: 14.0 * s,
                          fontWeight: FontWeight.w700,
                          color: tokens.mutedText,
                        ),
                      ),
                    ),
                    Container(
                      key: const Key('barter_detail_status'),
                      padding: EdgeInsets.symmetric(horizontal: 9.0 * s, vertical: 4.0 * s),
                      decoration: BoxDecoration(
                        color: tokens.chipBg,
                        borderRadius: BorderRadius.circular(10.0 * s),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12.0 * s,
                          fontWeight: FontWeight.w800,
                          color: tokens.chipText,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.0 * s),
                // Offered side
                Text(
                  strings.btOffered,
                  style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2.0 * s),
                Text(
                  '${offer.offeredTitle} • ${strings.btQuantity(offer.offeredQuantity, offer.offeredUnit)}',
                  key: const Key('barter_detail_offered'),
                  style: TextStyle(fontSize: 16.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                ),
                SizedBox(height: 12.0 * s),
                // Wanted side
                Text(
                  strings.btWanted,
                  style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2.0 * s),
                Text(
                  '$wantedName • ${strings.btQuantity(offer.wantedQuantity, offer.wantedUnit)}',
                  key: const Key('barter_detail_wanted'),
                  style: TextStyle(fontSize: 15.5 * s, fontWeight: FontWeight.w700, color: tokens.heading),
                ),
                if (offer.note != null && offer.note!.isNotEmpty) ...[
                  SizedBox(height: 12.0 * s),
                  Text(
                    strings.btNoteLabel,
                    style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2.0 * s),
                  Text(
                    offer.note!,
                    key: const Key('barter_detail_note'),
                    style: TextStyle(fontSize: 13.5 * s, color: tokens.bodyText),
                  ),
                ],
                SizedBox(height: 12.0 * s),
                Text(
                  communityDate(offer.createdAt),
                  style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                ),
              ],
            ),
          ),

          // 2. Version history
          if (offer.versions.isNotEmpty) ...[
            SizedBox(height: 16.0 * s),
            Text(
              strings.btHistory,
              style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
            ),
            SizedBox(height: 8.0 * s),
            for (final v in offer.versions) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 8.0 * s),
                child: CommunityCard(
                  key: Key('barter_version_${v.version}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.0 * s,
                        runSpacing: 4.0 * s,
                        children: [
                          Text(
                            strings.btVersion(v.version),
                            style: TextStyle(fontSize: 13.5 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                          ),
                          Text(
                            communityDate(v.at),
                            style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.0 * s),
                      Text(
                        '${strings.btOffered}: ${v.offeredTitle} (${strings.btQuantity(v.offeredQuantity, v.offeredUnit)})',
                        style: TextStyle(fontSize: 13.0 * s, color: tokens.bodyText),
                      ),
                      SizedBox(height: 2.0 * s),
                      Text(
                        '${strings.btWanted}: ${strings.btQuantity(v.wantedQuantity, offer.wantedUnit)}',
                        style: TextStyle(fontSize: 13.0 * s, color: tokens.bodyText),
                      ),
                      if (v.note != null && v.note!.isNotEmpty) ...[
                        SizedBox(height: 4.0 * s),
                        Text(
                          '${strings.btNoteLabel}: ${v.note}',
                          style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],

          // 3. Actions
          if (showActions) ...[
            SizedBox(height: 20.0 * s),
            Wrap(
              spacing: 10.0 * s,
              runSpacing: 10.0 * s,
              children: [
                CommunityPrimaryButton(
                  key: const Key('barter_action_accept'),
                  label: strings.btAccept,
                  onPressed: _submitting ? null : () async {
                    final ok = await showCommunityConfirm(
                      context,
                      title: strings.btAcceptAskTitle,
                      body: strings.btAskBody,
                      confirmLabel: strings.btAccept,
                      cancelLabel: strings.dlCancel,
                    );
                    if (ok && context.mounted) {
                      await _handleRespond('accept');
                    }
                  },
                ),
                CommunitySecondaryButton(
                  key: const Key('barter_action_reject'),
                  label: strings.btReject,
                  onPressed: _submitting ? null : () async {
                    final ok = await showCommunityConfirm(
                      context,
                      title: strings.btRejectAskTitle,
                      body: strings.btAskBody,
                      confirmLabel: strings.btReject,
                      cancelLabel: strings.dlCancel,
                    );
                    if (ok && context.mounted) {
                      await _handleRespond('reject');
                    }
                  },
                ),
                if (canCounter)
                  CommunitySecondaryButton(
                    key: const Key('barter_action_counter'),
                    label: strings.btCounter,
                    onPressed: _submitting ? null : () => _showCounterSheet(context, offer!, strings),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CounterSheet extends StatefulWidget {
  final BarterOffer offer;
  final AppStrings strings;
  final void Function(String title, int offeredQty, int wantedQty, String? note) onSubmit;

  const _CounterSheet({
    required this.offer,
    required this.strings,
    required this.onSubmit,
  });

  @override
  State<_CounterSheet> createState() => _CounterSheetState();
}

class _CounterSheetState extends State<_CounterSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _offeredQtyCtrl;
  late final TextEditingController _wantedQtyCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.offer.offeredTitle);
    _offeredQtyCtrl = TextEditingController(text: widget.offer.offeredQuantity.toString());
    _wantedQtyCtrl = TextEditingController(text: widget.offer.wantedQuantity.toString());
    _noteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _offeredQtyCtrl.dispose();
    _wantedQtyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleCtrl.text.trim();
    final offQty = int.parse(_offeredQtyCtrl.text.trim());
    final wantQty = int.parse(_wantedQtyCtrl.text.trim());
    final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
    widget.onSubmit(title, offQty, wantQty, note);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final strings = widget.strings;

    return Container(
      padding: EdgeInsets.fromLTRB(16.0 * s, 16.0 * s, 16.0 * s, MediaQuery.viewInsetsOf(context).bottom + 20.0 * s),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0 * s)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16.0, offset: Offset(0, -2))],
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.btCounterTitle,
                    style: TextStyle(fontSize: 18.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                  ),
                  IconButton(
                    key: const Key('barter_counter_close'),
                    icon: Icon(Icons.close, color: tokens.heading),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 12.0 * s),
              // Offered item title
              Text(strings.btOfferedItem, style: TextStyle(fontSize: 13.0 * s, fontWeight: FontWeight.w700, color: tokens.heading)),
              SizedBox(height: 4.0 * s),
              TextFormField(
                key: const Key('barter_counter_title'),
                controller: _titleCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: tokens.chipBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0 * s), borderSide: BorderSide.none),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 2) return strings.btErrItem;
                  return null;
                },
              ),
              SizedBox(height: 12.0 * s),
              // Offered quantity
              Text(strings.btOfferedQuantity, style: TextStyle(fontSize: 13.0 * s, fontWeight: FontWeight.w700, color: tokens.heading)),
              SizedBox(height: 4.0 * s),
              TextFormField(
                key: const Key('barter_counter_offered_qty'),
                controller: _offeredQtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: tokens.chipBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0 * s), borderSide: BorderSide.none),
                ),
                validator: (val) {
                  final n = int.tryParse(val?.trim() ?? '');
                  if (n == null || n <= 0) return strings.btErrQuantity;
                  return null;
                },
              ),
              SizedBox(height: 12.0 * s),
              // Wanted quantity
              Text(strings.btWantedQuantity, style: TextStyle(fontSize: 13.0 * s, fontWeight: FontWeight.w700, color: tokens.heading)),
              SizedBox(height: 4.0 * s),
              TextFormField(
                key: const Key('barter_counter_wanted_qty'),
                controller: _wantedQtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: tokens.chipBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0 * s), borderSide: BorderSide.none),
                ),
                validator: (val) {
                  final n = int.tryParse(val?.trim() ?? '');
                  if (n == null || n <= 0) return strings.btErrQuantity;
                  return null;
                },
              ),
              SizedBox(height: 12.0 * s),
              // Note optional
              Text(strings.btNoteOptional, style: TextStyle(fontSize: 13.0 * s, fontWeight: FontWeight.w700, color: tokens.heading)),
              SizedBox(height: 4.0 * s),
              TextFormField(
                key: const Key('barter_counter_note'),
                controller: _noteCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: tokens.chipBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0 * s), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 18.0 * s),
              CommunityPrimaryButton(
                key: const Key('barter_counter_submit'),
                label: strings.btSendCounter,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

