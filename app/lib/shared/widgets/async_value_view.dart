import 'package:flutter/material.dart';
import 'vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'empty_state.dart';

class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final String emptyMessage;

  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.emptyMessage = 'No data available',
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (d) {
        if (d is List && d.isEmpty) {
          return EmptyState(
            title: emptyMessage,
            helper: 'Pull down to refresh or check back later.',
            actionText: onRetry != null ? 'Refresh' : null,
            onAction: onRetry,
          );
        }
        return data(d);
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 12),
              VrText(
                err.toString(),
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const VrText('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
