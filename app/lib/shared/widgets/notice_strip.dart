import '../../features/auth/auth_providers.dart';
import 'vr_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/tokens.dart';

class NoticeItem {
  final String id;
  final String text;

  const NoticeItem({required this.id, required this.text});
}

final metaNoticesProvider = FutureProvider<List<NoticeItem>>((ref) async {
  try {
    final api = ref.watch(apiClientProvider);
    final res = await api.get('/meta');
    final raw = res['notices'] as List? ?? [];
    return raw
        .where((n) => n['active'] != false)
        .map((n) => NoticeItem(
              id: (n['id'] ?? '').toString(),
              text: (n['text'] ?? '').toString(),
            ))
        .toList();
  } catch (_) {
    return [];
  }
});

class NoticeStrip extends ConsumerStatefulWidget {
  final List<String>? notices;

  const NoticeStrip({
    super.key,
    this.notices,
  });

  @override
  ConsumerState<NoticeStrip> createState() => _NoticeStripState();
}

class _NoticeStripState extends ConsumerState<NoticeStrip> {
  int _currentIndex = 0;
  final Set<String> _dismissedIds = {};
  bool _loadedPrefs = false;

  @override
  void initState() {
    super.initState();
    _loadDismissedIds();
  }

  Future<void> _loadDismissedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('notice_dismissed_'));
      setState(() {
        _dismissedIds.addAll(keys.map((k) => k.replaceFirst('notice_dismissed_', '')));
        _loadedPrefs = true;
      });
    } catch (_) {
      setState(() => _loadedPrefs = true);
    }
  }

  Future<void> _dismissNotice(String id) async {
    setState(() {
      _dismissedIds.add(id);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notice_dismissed_$id', true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedPrefs) return const SizedBox.shrink();

    final tokens = context.vr;
    final metaAsync = ref.watch(metaNoticesProvider);

    List<NoticeItem> activeNotices = [];
    if (metaAsync.asData != null && metaAsync.asData!.value.isNotEmpty) {
      activeNotices = metaAsync.asData!.value.where((n) => !_dismissedIds.contains(n.id)).toList();
    } else if (widget.notices != null && widget.notices!.isNotEmpty) {
      activeNotices = widget.notices!
          .asMap()
          .entries
          .map((e) => NoticeItem(id: 'local_${e.key}', text: e.value))
          .where((n) => !_dismissedIds.contains(n.id))
          .toList();
    }

    if (activeNotices.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_currentIndex >= activeNotices.length) {
      _currentIndex = 0;
    }

    final currentNotice = activeNotices[_currentIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.info.withValues(alpha: 0.10),
        border: Border(
          bottom: BorderSide(
            color: tokens.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.campaign,
            color: tokens.info,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: VrText(
              currentNotice.text,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (activeNotices.length > 1) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: () {
                setState(() {
                  _currentIndex = (_currentIndex + 1) % activeNotices.length;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tokens.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: VrText(
                  '${_currentIndex + 1}/${activeNotices.length}',
                  style: TextStyle(
                    color: tokens.info,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _dismissNotice(currentNotice.id),
            child: Icon(Icons.close, color: tokens.textMuted, size: 16),
          ),
        ],
      ),
    );
  }
}
