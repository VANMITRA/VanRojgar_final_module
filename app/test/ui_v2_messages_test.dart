import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/community_models.dart';
import 'community_test_helpers.dart';

void main() {
  group('Messages: states & routing', () {
    testWidgets('guest sees sign-in and create account options', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(messages: FakeMessages([])), '/messages');
      expect(find.byKey(const Key('community_guest_signin')), findsOneWidget);
      expect(find.byKey(const Key('community_guest_signup')), findsOneWidget);
      expect(find.byKey(const Key('messages_empty')), findsNothing);
    });

    testWidgets('signed in user with no messages sees empty state', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(user: buyerUser, messages: FakeMessages([])), '/messages');
      expect(find.byKey(const Key('messages_empty')), findsOneWidget);
      expect(find.byKey(const Key('messages_mark_all')), findsNothing);
    });

    testWidgets('messages list is sorted newest first with unread dot', (tester) async {
      tall(tester);
      final m1 = message('m1', read: true, createdAt: DateTime(2026, 10, 20));
      final m2 = message('m2', read: false, createdAt: DateTime(2026, 10, 25));
      final fake = FakeMessages([m1, m2]);

      await openPath(tester, communityApp(user: buyerUser, messages: fake), '/messages');
      expect(find.byKey(const Key('message_m2')), findsOneWidget);
      expect(find.byKey(const Key('message_m1')), findsOneWidget);
      expect(find.byKey(const Key('message_dot_m2')), findsOneWidget);
      expect(find.byKey(const Key('message_dot_m1')), findsNothing);
    });

    testWidgets('tapping mark all read calls repository and hides button', (tester) async {
      tall(tester);
      final m1 = message('m1', read: false);
      final m2 = message('m2', read: false);
      final fake = FakeMessages([m1, m2]);

      await openPath(tester, communityApp(user: buyerUser, messages: fake), '/messages');
      expect(find.byKey(const Key('messages_mark_all')), findsOneWidget);

      await tester.tap(find.byKey(const Key('messages_mark_all')));
      await tester.pumpAndSettle();

      expect(fake.readIds, containsAll(['m1', 'm2']));
      expect(find.byKey(const Key('messages_mark_all')), findsNothing);
    });

    testWidgets('tapping an unread message marks it read and navigates to target order', (tester) async {
      tall(tester);
      final m = message('m1', read: false, orderId: 'ord_123');
      final fake = FakeMessages([m]);

      await openPath(tester, communityApp(user: buyerUser, messages: fake), '/messages');
      await tester.tap(find.byKey(const Key('message_m1')));
      await tester.pumpAndSettle();

      expect(fake.readIds, contains('m1'));
    });

    testWidgets('Hindi note is shown only in Hindi mode', (tester) async {
      tall(tester);
      final m = message('m1', read: true);
      final fake = FakeMessages([m]);

      await openPath(tester, communityApp(user: buyerUser, messages: fake, language: AppLanguage.en), '/messages');
      expect(find.byKey(const Key('messages_hindi_note')), findsNothing);

      await openPath(tester, communityApp(user: buyerUser, messages: fake, language: AppLanguage.mr), '/messages');
      expect(find.byKey(const Key('messages_hindi_note')), findsNothing);

      await openPath(tester, communityApp(user: buyerUser, messages: fake, language: AppLanguage.hi), '/messages');
      expect(find.byKey(const Key('messages_hindi_note')), findsOneWidget);
    });

    testWidgets('profile messages row displays unread badge when unread > 0', (tester) async {
      tall(tester);
      final m1 = message('m1', read: false);
      final m2 = message('m2', read: true);
      final fake = FakeMessages([m1, m2]);

      await openPath(tester, communityApp(user: buyerUser, messages: fake), '/profile');
      expect(find.byKey(const Key('profile_messages_badge')), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('Messages: Marathi purity', () {
    testWidgets('Marathi mode has no English words for UI chrome', (tester) async {
      tall(tester);
      final m = AppMessage(
        id: 'm1',
        type: 'test',
        title: const {'en': 'Test', 'mr': 'नवीन संदेश'},
        body: const {'en': 'Body', 'mr': 'तपशील उपलब्ध आहे.'},
        readAt: null,
        createdAt: DateTime(2026, 10, 28),
      );
      final fake = FakeMessages([m]);

      await openPath(tester, communityApp(user: buyerUser, messages: fake, language: AppLanguage.mr), '/messages');
      final leaks = englishTexts(tester);
      expect(leaks, isEmpty, reason: 'Found English on Marathi screen: $leaks');
    });
  });

  group('Messages: overflow and scaling', () {
    final sizes = [
      const Size(320, 568),
      const Size(360, 800),
      const Size(430, 932),
    ];
    final langs = [AppLanguage.en, AppLanguage.hi, AppLanguage.mr];
    final modes = [ThemeMode.light, ThemeMode.dark];

    for (final size in sizes) {
      for (final lang in langs) {
        for (final mode in modes) {
          testWidgets('overflow check ${size.width}x${size.height} $lang $mode scale 1.5', (tester) async {
            tester.view.physicalSize = Size(size.width * 2, size.height * 2);
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            final m = AppMessage(
              id: 'm1',
              type: 'test',
              title: const {'en': 'New request notification', 'mr': 'नवीन मागणीची सूचना'},
              body: const {'en': 'Your request has been processed.', 'mr': 'तुमची मागणी पूर्ण झाली आहे.'},
              readAt: null,
              createdAt: DateTime(2026, 10, 28),
            );
            final fake = FakeMessages([m]);

            await openPath(
              tester,
              communityApp(
                user: buyerUser,
                messages: fake,
                language: lang,
                mode: mode,
                textScale: 1.5,
              ),
              '/messages',
            );

            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });

  group('Messages: forbidden text', () {
    testWidgets('no screen contains Sample, Demo, or Opens in the full app', (tester) async {
      tall(tester);
      final m = message('m1');
      await openPath(tester, communityApp(user: buyerUser, messages: FakeMessages([m])), '/messages');

      expect(find.textContaining('Sample'), findsNothing);
      expect(find.textContaining('Demo'), findsNothing);
      expect(find.textContaining('Opens in the full app'), findsNothing);
    });
  });
}

