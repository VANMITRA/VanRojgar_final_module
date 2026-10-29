import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/community_strings.dart';
import '../../models/community_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/community_providers.dart';
import '../../widgets/community/community_widgets.dart';

/// `/messages`: notices the server wrote for the signed-in user, newest first. Not a chat.
class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  Future<void> _markRead(WidgetRef ref, List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      await ref.read(messagesRepositoryProvider).markRead(ids);
    } catch (_) {
      return;
    }
    ref.invalidate(messagesProvider);
    ref.invalidate(unreadMessagesProvider);
  }

  void _open(BuildContext context, AppMessage m) {
    final orderTarget = m.orderId ?? m.requestId;
    if (orderTarget != null && orderTarget.isNotEmpty) {
      context.push('/orders/$orderTarget');
    } else if (m.barterId != null && m.barterId!.isNotEmpty) {
      context.push('/barter');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final user = ref.watch(authUserProvider);

    if (user == null) {
      return CommunityPage(
        title: strings.msTitle,
        body: CommunityCentered(
          child: CommunityGuestCard(icon: Icons.notifications_none, body: strings.msGuestBody),
        ),
      );
    }

    final async = ref.watch(messagesProvider);
    final Widget body = async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => CommunityCentered(
        child: CommunityMessageCard(
          icon: Icons.cloud_off_outlined,
          body: strings.msLoadError,
          actions: [
            KeyedSubtree(
              key: const Key('messages_retry'),
              child: CommunityPrimaryButton(
                label: strings.dlRetry,
                onPressed: () => ref.invalidate(messagesProvider),
              ),
            ),
          ],
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return CommunityCentered(
            child: KeyedSubtree(
              key: const Key('messages_empty'),
              child: CommunityMessageCard(
                icon: Icons.notifications_none,
                title: strings.msEmpty,
                body: strings.msEmptyHint,
              ),
            ),
          );
        }
        final sorted = [...list]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final unreadIds = [for (final m in sorted) if (!m.isRead) m.id];
        final hindiNote = strings.msHindiNote;
        return CommunityScroll(
          scrollKey: const Key('messages_scroll'),
          children: [
            if (hindiNote.isNotEmpty) ...[
              Text(
                hindiNote,
                key: const Key('messages_hindi_note'),
                style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText, height: 1.35),
              ),
              SizedBox(height: 8.0 * s),
            ],
            if (unreadIds.isNotEmpty) ...[
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  key: const Key('messages_mark_all'),
                  onPressed: () => _markRead(ref, unreadIds),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48.0, 48.0),
                    foregroundColor: tokens.primaryGreen,
                  ),
                  child: Text(strings.msMarkAllRead, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
            for (int i = 0; i < sorted.length; i++) ...[
              if (i > 0) SizedBox(height: 10.0 * s),
              _MessageCard(
                message: sorted[i],
                language: language,
                unreadLabel: strings.msUnreadLabel,
                onTap: () async {
                  final m = sorted[i];
                  if (!m.isRead) await _markRead(ref, [m.id]);
                  if (context.mounted) _open(context, m);
                },
              ),
            ],
          ],
        );
      },
    );

    return CommunityPage(title: strings.msTitle, body: body);
  }
}

class _MessageCard extends StatelessWidget {
  final AppMessage message;
  final AppLanguage language;
  final String unreadLabel;
  final VoidCallback onTap;

  const _MessageCard({
    required this.message,
    required this.language,
    required this.unreadLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final unread = !message.isRead;
    return Semantics(
      button: true,
      label: unread ? '$unreadLabel: ${message.localizedTitle(language)}' : message.localizedTitle(language),
      child: KeyedSubtree(
        key: Key('message_${message.id}'),
        child: CommunityCard(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.0 * s, right: 10.0 * s),
                  child: unread
                      ? Container(
                          key: Key('message_dot_${message.id}'),
                          width: 10.0 * s,
                          height: 10.0 * s,
                          decoration: BoxDecoration(color: tokens.primaryGreen, shape: BoxShape.circle),
                        )
                      : SizedBox(width: 10.0 * s, height: 10.0 * s),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.localizedTitle(language),
                        style: TextStyle(
                          fontSize: 15.0 * s,
                          fontWeight: unread ? FontWeight.w800 : FontWeight.w500,
                          color: tokens.heading,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 3.0 * s),
                      Text(
                        message.localizedBody(language),
                        style: TextStyle(fontSize: 13.5 * s, color: tokens.bodyText, height: 1.35),
                      ),
                      SizedBox(height: 4.0 * s),
                      Text(
                        communityDate(message.createdAt),
                        style: TextStyle(fontSize: 12.0 * s, color: tokens.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

