import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/community_models.dart';
import 'community_test_helpers.dart';

const _places = {'Asha Patil', 'Rice', 'Bamboo basket', 'तांदूळ', 'बांबू टोपली', 'आशा पाटील'};

void main() {
  group('Barter list: states & segments', () {
    testWidgets('guest sees sign-in and create account options', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(barter: FakeBarter()), '/barter');
      expect(find.byKey(const Key('community_guest_signin')), findsOneWidget);
      expect(find.byKey(const Key('community_guest_signup')), findsOneWidget);
      expect(find.byKey(const Key('barter_seg_incoming')), findsNothing);
    });

    testWidgets('signed-in user sees empty state on both segments when empty', (tester) async {
      tall(tester);
      final fake = FakeBarter(incoming: [], outgoing: []);
      await openPath(tester, communityApp(user: buyerUser, barter: fake), '/barter');

      expect(find.byKey(const Key('barter_seg_incoming')), findsOneWidget);
      expect(find.byKey(const Key('barter_seg_outgoing')), findsOneWidget);
      expect(find.byKey(const Key('barter_empty_incoming')), findsOneWidget);

      await tester.tap(find.byKey(const Key('barter_seg_outgoing')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('barter_empty_outgoing')), findsOneWidget);
    });

    testWidgets('shows incoming and outgoing cards with status chips and taps into detail', (tester) async {
      tall(tester);
      final inOffer = barterOffer('b1', incoming: true, status: 'pending');
      final outOffer = barterOffer('b2', incoming: false, status: 'countered');
      final fake = FakeBarter(incoming: [inOffer], outgoing: [outOffer]);

      await openPath(tester, communityApp(user: buyerUser, barter: fake), '/barter');
      expect(find.byKey(const Key('barter_card_b1')), findsOneWidget);
      expect(find.byKey(const Key('barter_status_b1')), findsOneWidget);

      await tester.tap(find.byKey(const Key('barter_seg_outgoing')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('barter_card_b2')), findsOneWidget);
      expect(find.byKey(const Key('barter_status_b2')), findsOneWidget);

      await tester.tap(find.byKey(const Key('barter_card_b2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('barter_detail_offered')), findsOneWidget);
    });
  });

  group('Barter detail: incoming actions (Accept, Reject, Counter)', () {
    testWidgets('incoming pending offer has Accept, Reject, Counter with confirmation dialogs', (tester) async {
      tall(tester);
      final offer = barterOffer('b1', incoming: true, status: 'pending');
      final fake = FakeBarter(incoming: [offer]);

      await openPath(tester, communityApp(user: buyerUser, barter: fake), '/barter/b1');
      expect(find.byKey(const Key('barter_detail_offered')), findsOneWidget);
      expect(find.byKey(const Key('barter_detail_wanted')), findsOneWidget);
      expect(find.byKey(const Key('barter_version_1')), findsOneWidget);
      expect(find.byKey(const Key('barter_version_2')), findsOneWidget);

      // 1. Accept with confirmation
      expect(find.byKey(const Key('barter_action_accept')), findsOneWidget);
      await tester.tap(find.byKey(const Key('barter_action_accept')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('community_confirm_ok')), findsOneWidget);
      await tester.tap(find.byKey(const Key('community_confirm_ok')));
      await tester.pumpAndSettle();
      expect(fake.calls, contains(startsWith('accept:b1')));

      // 2. Reject with confirmation
      fake.incoming = [barterOffer('b1', incoming: true, status: 'pending')];
      await openPath(tester, communityApp(user: buyerUser, barter: fake), '/barter/b1');
      expect(find.byKey(const Key('barter_action_reject')), findsOneWidget);
      await tester.tap(find.byKey(const Key('barter_action_reject')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('community_confirm_ok')), findsOneWidget);
      await tester.tap(find.byKey(const Key('community_confirm_ok')));
      await tester.pumpAndSettle();
      expect(fake.calls, contains(startsWith('reject:b1')));

      // 3. Counter opens sheet, validates inputs > 0, and submits
      fake.incoming = [barterOffer('b1', incoming: true, status: 'pending')];
      await openPath(tester, communityApp(user: buyerUser, barter: fake), '/barter/b1');
      expect(find.byKey(const Key('barter_action_counter')), findsOneWidget);
      await tester.tap(find.byKey(const Key('barter_action_counter')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('barter_counter_title')), findsOneWidget);
      expect(find.byKey(const Key('barter_counter_offered_qty')), findsOneWidget);
      expect(find.byKey(const Key('barter_counter_wanted_qty')), findsOneWidget);

      // Trigger error on offered qty = 0
      await tester.enterText(find.byKey(const Key('barter_counter_offered_qty')), '0');
      await tester.tap(find.byKey(const Key('barter_counter_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a whole number above 0.'), findsOneWidget);

      // Enter valid quantities
      await tester.enterText(find.byKey(const Key('barter_counter_offered_qty')), '30');
      await tester.enterText(find.byKey(const Key('barter_counter_wanted_qty')), '15');
      await tester.tap(find.byKey(const Key('barter_counter_submit')));
      await tester.pumpAndSettle();

      expect(fake.calls, contains('counter:b1:Rice:30:15:'));
    });

    testWidgets('outgoing countered offer allows Accept and Reject', (tester) async {
      tall(tester);
      final offer = barterOffer('b2', incoming: false, status: 'countered');
      final fake = FakeBarter(outgoing: [offer]);

      await openPath(tester, communityApp(user: buyerUser, barter: fake), '/barter/b2');
      expect(find.byKey(const Key('barter_action_accept')), findsOneWidget);
      expect(find.byKey(const Key('barter_action_reject')), findsOneWidget);
      expect(find.byKey(const Key('barter_action_counter')), findsNothing);
    });

    testWidgets('missing barter offer shows not found message', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(user: buyerUser, barter: FakeBarter()), '/barter/missing');
      expect(find.byKey(const Key('barter_not_found')), findsOneWidget);
    });
  });

  group('Barter new: form and validations', () {
    testWidgets('missing listing parameter shows friendly error with back button', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(user: buyerUser, barter: FakeBarter()), '/barter/new');
      expect(find.byKey(const Key('barter_new_missing_listing')), findsOneWidget);
      expect(find.byKey(const Key('barter_new_back_btn')), findsOneWidget);
    });

    testWidgets('valid listing shows form, validates fields, and creates offer', (tester) async {
      tall(tester);
      final fake = FakeBarter();
      await openPath(
        tester,
        communityApp(user: buyerUser, barter: fake),
        '/barter/new?listing=L101&title=Wild%20Honey&unit=jar',
      );

      expect(find.byKey(const Key('barter_new_target_title')), findsOneWidget);
      expect(find.text('For: Wild Honey'), findsOneWidget);

      // Submit with empty item title produces error
      await tester.tap(find.byKey(const Key('barter_new_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Enter at least 2 characters.'), findsOneWidget);

      // Fill in valid details
      await tester.enterText(find.byKey(const Key('barter_new_offered_title')), 'Pure Ghee');
      await tester.enterText(find.byKey(const Key('barter_new_offered_qty')), '2');
      await tester.enterText(find.byKey(const Key('barter_new_offered_unit')), 'kg');
      await tester.enterText(find.byKey(const Key('barter_new_wanted_qty')), '3');
      await tester.enterText(find.byKey(const Key('barter_new_note')), 'Organic homemade');

      await tester.tap(find.byKey(const Key('barter_new_submit')));
      await tester.pumpAndSettle();

      expect(fake.created, isNotNull);
      expect(fake.created!.wantedListingId, 'L101');
      expect(fake.created!.offeredTitle, 'Pure Ghee');
      expect(fake.created!.offeredQuantity, 2);
      expect(fake.created!.offeredUnit, 'kg');
      expect(fake.created!.wantedQuantity, 3);
      expect(fake.created!.note, 'Organic homemade');
    });
  });

  group('Barter: language purity', () {
    testWidgets('Marathi mode has no English words except allowed', (tester) async {
      tall(tester);
      final offer = BarterOffer(
        id: 'b1',
        status: 'pending',
        wantedListingId: 'L1',
        wantedTitle: 'बांबू टोपली',
        wantedUnit: 'नग',
        offeredTitle: 'तांदूळ',
        offeredQuantity: 10,
        offeredUnit: 'किलो',
        wantedQuantity: 5,
        note: 'उत्कृष्ट दर्जा',
        isIncoming: true,
        otherPartyName: 'आशा पाटील',
        versions: [],
        createdAt: DateTime(2026, 10, 20),
      );
      final fake = FakeBarter(incoming: [offer]);

      await openPath(tester, communityApp(user: buyerUser, barter: fake, language: AppLanguage.mr), '/barter');
      final listLeaks = englishTexts(tester, allowed: _places);
      expect(listLeaks, isEmpty, reason: 'English found on Marathi list: $listLeaks');

      await openPath(tester, communityApp(user: buyerUser, barter: fake, language: AppLanguage.mr), '/barter/b1');
      final detailLeaks = englishTexts(tester, allowed: _places);
      expect(detailLeaks, isEmpty, reason: 'English found on Marathi detail: $detailLeaks');
    });
  });

  group('Barter: overflow and scaling', () {
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

            final offer = barterOffer('b1', incoming: true, status: 'countered');
            final fake = FakeBarter(incoming: [offer]);

            await openPath(
              tester,
              communityApp(
                user: buyerUser,
                barter: fake,
                language: lang,
                mode: mode,
                textScale: 1.5,
              ),
              '/barter',
            );
            expect(tester.takeException(), isNull);

            await openPath(
              tester,
              communityApp(
                user: buyerUser,
                barter: fake,
                language: lang,
                mode: mode,
                textScale: 1.5,
              ),
              '/barter/b1',
            );
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });

  group('Barter: forbidden text', () {
    testWidgets('no screen contains Sample, Demo, or Opens in the full app', (tester) async {
      tall(tester);
      final offer = barterOffer('b1');
      final fake = FakeBarter(incoming: [offer]);

      await openPath(tester, communityApp(user: buyerUser, barter: fake), '/barter');
      expect(find.textContaining('Sample'), findsNothing);
      expect(find.textContaining('Demo'), findsNothing);
      expect(find.textContaining('Opens in the full app'), findsNothing);

      await openPath(tester, communityApp(user: buyerUser, barter: fake), '/barter/b1');
      expect(find.textContaining('Sample'), findsNothing);
      expect(find.textContaining('Demo'), findsNothing);
      expect(find.textContaining('Opens in the full app'), findsNothing);

      await openPath(tester, communityApp(user: buyerUser, barter: fake), '/barter/new?listing=L1');
      expect(find.textContaining('Sample'), findsNothing);
      expect(find.textContaining('Demo'), findsNothing);
      expect(find.textContaining('Opens in the full app'), findsNothing);
    });
  });
}

