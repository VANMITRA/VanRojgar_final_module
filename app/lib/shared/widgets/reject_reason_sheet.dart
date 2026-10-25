import '../../features/auth/auth_providers.dart';
import 'vr_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/app_exception.dart';
import '../../core/localization/app_input_hints.dart';
import '../../core/theme/tokens.dart';
import '../../features/trade/trade_providers.dart';

Future<void> showRejectReasonSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String requestId,
  VoidCallback? onSuccess,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _RejectReasonSheet(
      requestId: requestId,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}

class _RejectReasonSheet extends StatefulWidget {
  final String requestId;
  final WidgetRef ref;
  final VoidCallback? onSuccess;

  const _RejectReasonSheet({
    required this.requestId,
    required this.ref,
    this.onSuccess,
  });

  @override
  State<_RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<_RejectReasonSheet> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final note = _controller.text.trim();
    if (note.length < 5) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final api = widget.ref.read(apiClientProvider);
      await api.patch('/requests/${widget.requestId}/status', data: {
        'action': 'reject',
        'note': note,
      });

      widget.ref.invalidate(requestsProvider('incoming'));
      widget.ref.invalidate(requestsProvider('mine'));
      widget.ref.invalidate(ordersProvider('selling'));

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          if (e is AppException && e.fields != null && e.fields!['note'] != null) {
            _errorMessage = e.fields!['note'].toString();
          } else if (e is AppException) {
            _errorMessage = e.message;
          } else {
            _errorMessage = e.toString();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final canSubmit = _controller.text.trim().length >= 5 && !_isSubmitting;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.cancel_outlined, color: tokens.error, size: 22),
              const SizedBox(width: 8),
              VrText(
                'मागणी नाकारा • Reject Request',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          VrText(
            'नाकारण्याचे कारण द्या (किमान ५ अक्षरे) • Provide reason for rejection (min 5 characters):',
            style: TextStyle(color: tokens.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLength: 300,
            minLines: 2,
            maxLines: 4,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: AppInputHints.rejectReason(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorText: _errorMessage,
            ),

          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                child: const VrText('Cancel / रद्द करा'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const VrText('Reject / नाकारा', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
