import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/dates.dart';
import '../../shared/widgets/async_value_view.dart';
import '../trade/trade_providers.dart';
import '../auth/auth_providers.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(apiClientProvider).post('/messages/read');
        ref.invalidate(unreadCountProvider);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final messagesAsync = ref.watch(messagesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('सूचना व संदेश • Messages')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(messagesProvider),
          child: AsyncValueView(
            value: messagesAsync,
            emptyMessage: 'अद्याप कोणतेही संदेश नाहीत (No messages)',
            onRetry: () => ref.invalidate(messagesProvider),
            data: (messages) {
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final msg = messages[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: msg.readAt == null ? tokens.actionPrimary.withValues(alpha: 0.05) : tokens.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: tokens.brandSecondary.withValues(alpha: 0.15),
                        child: Icon(Icons.notifications_active, color: tokens.brandSecondary, size: 20),
                      ),
                      title: Text(
                        msg.localizedTitle(Localizations.localeOf(context).languageCode),
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontWeight: msg.readAt == null ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            msg.bodyMr ?? msg.bodyEn ?? '',
                            style: TextStyle(color: tokens.textMuted, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(msg.createdAt),
                            style: TextStyle(color: tokens.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
