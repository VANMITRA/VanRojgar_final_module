import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/community_models.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'community_test_helpers.dart';

const _places = {'Dongargaon', 'Bhatode', 'Deola', 'Dindori', 'Trimbakeshwar', 'डोंगरगाव', 'MH15 AB 1234'};

void main() {
  group('Delivery partner: who sees what', () {
    testWidgets('a guest sees sign in and create account', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(delivery: FakeDelivery()), '/delivery');
      expect(find.byKey(const Key('community_guest_signin')), findsOneWidget);
      expect(find.byKey(const Key('community_guest_signup')), findsOneWidget);
      expect(find.byKey(const Key('delivery_apply_button')), findsNothing);
    });

    testWidgets('a buyer and a Gram Sabha see only a short explanation', (tester) async {
      tall(tester);
      for (final user in [buyerUser, gramSabhaUser]) {
        await openPath(tester, communityApp(user: user, delivery: FakeDelivery()), '/delivery');
        expect(find.byKey(const Key('delivery_not_cfr')), findsOneWidget);
        expect(find.text('Delivery partners are CFR holders'), findsOneWidget);
        expect(find.byKey(const Key('delivery_apply_button')), findsNothing);
        expect(find.byKey(const Key('delivery_available_switch')), findsNothing);
      }
    });

    testWidgets('a CFR holder who has not applied sees the intro and the Apply button', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(user: cfrUser, delivery: FakeDelivery()), '/delivery');
      expect(find.byKey(const Key('delivery_intro')), findsOneWidget);
      await tester.tap(find.byKey(const Key('delivery_apply_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('delivery_apply_submit')), findsOneWidget);
    });

    testWidgets('pending, rejected (with the note) and paused each have their own card', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(user: cfrUser, delivery: FakeDelivery(profile: partner(status: 'pending'))), '/delivery');
      expect(find.text('Waiting for approval'), findsOneWidget);

      await openPath(
        tester,
        communityApp(user: cfrUser, delivery: FakeDelivery(profile: partner(status: 'rejected', reviewNote: 'Licence photo missing'))),
        '/delivery',
      );
      expect(find.text('Application not approved'), findsOneWidget);
      expect(find.text('Licence photo missing'), findsOneWidget);

      await openPath(tester, communityApp(user: cfrUser, delivery: FakeDelivery(profile: partner(status: 'paused'))), '/delivery');
      expect(find.text('Your partner account is paused'), findsOneWidget);
      expect(find.byKey(const Key('delivery_available_switch')), findsNothing);
    });
  });

  group('Delivery partner: apply form', () {
    testWidgets('shows an inline error for each wrong field, then submits and shows Waiting for approval', (tester) async {
      tall(tester);
      final fake = FakeDelivery();
      await openPath(tester, communityApp(user: cfrUser, delivery: fake), '/delivery');
      await tester.tap(find.byKey(const Key('delivery_apply_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('delivery_vehicle_bike')), findsOneWidget);
      expect(find.byKey(const Key('delivery_vehicle_tempo')), findsOneWidget);
      expect(find.byKey(const Key('delivery_vehicle_pickup')), findsOneWidget);
      expect(find.byKey(const Key('delivery_vehicle_tractor')), findsOneWidget);

      await tester.tap(find.byKey(const Key('delivery_apply_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Enter your vehicle number.'), findsOneWidget);
      expect(find.text('Enter a whole number above 0.'), findsOneWidget);
      expect(find.text('Licence number needs at least 4 characters.'), findsOneWidget);
      expect(find.text('Choose at least one taluka.'), findsOneWidget);
      expect(fake.calls, isEmpty);

      await tester.enterText(find.byKey(const Key('delivery_vehicle_number')), 'MH15 XY 9999');
      await tester.enterText(find.byKey(const Key('delivery_capacity')), '0');
      await tester.enterText(find.byKey(const Key('delivery_licence')), 'ab1');
      await tester.tap(find.byKey(const Key('delivery_apply_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a whole number above 0.'), findsOneWidget);
      expect(find.text('Licence number needs at least 4 characters.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('delivery_vehicle_pickup')));
      await tester.enterText(find.byKey(const Key('delivery_capacity')), '600');
      await tester.enterText(find.byKey(const Key('delivery_licence')), 'MH1520230001');
      await tester.tap(find.byKey(const Key('delivery_taluka_Dindori')));
      await tester.tap(find.byKey(const Key('delivery_taluka_Deola')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('delivery_apply_submit')));
      await tester.pumpAndSettle();

      expect(fake.calls, ['apply:pickup:MH15 XY 9999:600:MH1520230001:Deola+Dindori']);
      expect(find.text('Waiting for approval'), findsOneWidget);
    });

    testWidgets('a failing submit shows a plain message and stays on the form', (tester) async {
      tall(tester);
      final fake = FakeDelivery()..failActions = true;
      await openPath(tester, communityApp(user: cfrUser, delivery: fake), '/delivery/apply');
      await tester.enterText(find.byKey(const Key('delivery_vehicle_number')), 'MH15 XY 9999');
      await tester.enterText(find.byKey(const Key('delivery_capacity')), '600');
      await tester.enterText(find.byKey(const Key('delivery_licence')), 'MH1520230001');
      await tester.tap(find.byKey(const Key('delivery_taluka_Deola')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('delivery_apply_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
      expect(find.byKey(const Key('delivery_apply_submit')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a guest or a buyer cannot use the form', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(delivery: FakeDelivery()), '/delivery/apply');
      expect(find.byKey(const Key('community_guest_signin')), findsOneWidget);
      await openPath(tester, communityApp(user: buyerUser, delivery: FakeDelivery()), '/delivery/apply');
      expect(find.byKey(const Key('delivery_apply_submit')), findsNothing);
      expect(find.text('Delivery partners are CFR holders'), findsOneWidget);
    });
  });

  group('Delivery partner: the hub, jobs and actions', () {
    FakeDelivery hubData() => FakeDelivery(
          profile: partner(),
          open: [job('o1', collectCashPaise: 250000), job('o2')],
          mine: [
            job('m1', status: 'accepted', timeline: [DeliveryStep(status: 'accepted', at: DateTime(2026, 10, 27), note: 'Taken')]),
          ],
        );

    testWidgets('shows earnings in rupees, jobs completed, the switch, and the two segments', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(user: cfrUser, delivery: hubData()), '/delivery');
      expect(find.text('₹1,250'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.byKey(const Key('delivery_available_switch')), findsOneWidget);
      expect(find.byKey(const Key('delivery_seg_open')), findsOneWidget);
      expect(find.byKey(const Key('delivery_seg_mine')), findsOneWidget);
      expect(find.byKey(const Key('delivery_job_o1')), findsOneWidget);
      expect(find.text('Collect cash: ₹2,500'), findsOneWidget);
      expect(find.textContaining('Collect cash'), findsOneWidget);
    });

    testWidgets('the availability switch calls setAvailable', (tester) async {
      tall(tester);
      final fake = hubData();
      await openPath(tester, communityApp(user: cfrUser, delivery: fake), '/delivery');
      await tester.tap(find.byKey(const Key('delivery_available_switch')));
      await tester.pumpAndSettle();
      expect(fake.calls, ['available:false']);
      expect(tester.widget<Switch>(find.byKey(const Key('delivery_available_switch'))).value, isFalse);
    });

    testWidgets('Accept job asks first; Cancel does nothing, Yes moves the job to My jobs', (tester) async {
      tall(tester);
      final fake = hubData();
      await openPath(tester, communityApp(user: cfrUser, delivery: fake), '/delivery');

      await tester.tap(find.byKey(const Key('delivery_accept_o2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('community_confirm_dialog')), findsOneWidget);
      await tester.tap(find.byKey(const Key('community_confirm_cancel')));
      await tester.pumpAndSettle();
      expect(fake.calls, isEmpty);

      await tester.tap(find.byKey(const Key('delivery_accept_o2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('community_confirm_ok')));
      await tester.pumpAndSettle();
      expect(fake.calls, ['accept:o2']);
      expect(find.byKey(const Key('delivery_job_o2')), findsNothing);

      await tester.tap(find.byKey(const Key('delivery_seg_mine')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('delivery_job_o2')), findsOneWidget);
      expect(find.byKey(const Key('delivery_job_m1')), findsOneWidget);
    });

    testWidgets('My jobs offer only the next valid step, each asking first, until Delivered', (tester) async {
      tall(tester);
      final fake = hubData();
      await openPath(tester, communityApp(user: cfrUser, delivery: fake), '/delivery');
      await tester.tap(find.byKey(const Key('delivery_seg_mine')));
      await tester.pumpAndSettle();

      Future<void> press(String label, String status) async {
        expect(find.descendant(of: find.byKey(const Key('delivery_step_m1')), matching: find.text(label)), findsOneWidget);
        await tester.tap(find.byKey(const Key('delivery_step_m1')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('community_confirm_dialog')), findsOneWidget);
        await tester.tap(find.byKey(const Key('community_confirm_ok')));
        await tester.pumpAndSettle();
        expect(fake.calls.last, 'status:m1:$status');
      }

      await press('Picked up', 'picked_up');
      await press('On the way', 'on_the_way');
      await press('Delivered', 'delivered');
      expect(find.byKey(const Key('delivery_step_m1')), findsNothing);
      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('a failing action shows a plain message, never a stack trace', (tester) async {
      tall(tester);
      final fake = hubData()..failActions = true;
      await openPath(tester, communityApp(user: cfrUser, delivery: fake), '/delivery');
      await tester.tap(find.byKey(const Key('delivery_accept_o1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('community_confirm_ok')));
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty lists show a plain empty state', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(user: cfrUser, delivery: FakeDelivery(profile: partner())), '/delivery');
      expect(find.text('There are no open jobs right now.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('delivery_seg_mine')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('delivery_jobs_empty')), findsOneWidget);
    });

    testWidgets('the job page shows both places, the cash line, the timeline and the action', (tester) async {
      tall(tester);
      final fake = FakeDelivery(
        profile: partner(),
        mine: [
          job(
            'm1',
            status: 'picked_up',
            collectCashPaise: 100000,
            timeline: [
              DeliveryStep(status: 'accepted', at: DateTime(2026, 10, 27)),
              DeliveryStep(status: 'picked_up', at: DateTime(2026, 10, 28), note: 'Loaded'),
            ],
          ),
        ],
      );
      await openPath(tester, communityApp(user: cfrUser, delivery: fake), '/delivery/jobs/m1');
      expect(find.text('Dongargaon, Deola'), findsOneWidget);
      expect(find.text('Bhatode, Dindori'), findsOneWidget);
      expect(find.text('Collect cash: ₹1,000'), findsOneWidget);
      expect(find.byKey(const Key('delivery_job_timeline')), findsOneWidget);
      expect(find.text('27-10-2026'), findsOneWidget);
      expect(find.text('Loaded'), findsOneWidget);
      await tester.tap(find.byKey(const Key('delivery_step_m1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('community_confirm_ok')));
      await tester.pumpAndSettle();
      expect(fake.calls, ['status:m1:on_the_way']);
    });

    testWidgets('an unknown job id shows a friendly message', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(user: cfrUser, delivery: FakeDelivery(profile: partner())), '/delivery/jobs/nope');
      expect(find.byKey(const Key('delivery_job_missing')), findsOneWidget);
    });
  });

  group('Delivery partner: Hindi and Marathi', () {
    testWidgets('no English words on any state', (tester) async {
      tall(tester);
      for (final lang in [AppLanguage.hi, AppLanguage.mr]) {
        final hub = FakeDelivery(
          profile: partner(),
          open: [job('o1', collectCashPaise: 100000, goods: '40 किलो बांबूच्या टोपल्या')],
          mine: [job('m1', status: 'accepted', goods: '40 किलो बांबूच्या टोपल्या')],
        );
        for (final entry in <(String, AuthUser?, FakeDelivery)>[
          ('/delivery', null, FakeDelivery()),
          ('/delivery', buyerUser, FakeDelivery()),
          ('/delivery', cfrUser, FakeDelivery()),
          ('/delivery', cfrUser, FakeDelivery(profile: partner(status: 'pending'))),
          ('/delivery', cfrUser, FakeDelivery(profile: partner(status: 'paused'))),
          ('/delivery', cfrUser, hub),
          ('/delivery/apply', cfrUser, FakeDelivery()),
          ('/delivery/jobs/o1', cfrUser, hub),
        ]) {
          await openPath(tester, communityApp(language: lang, user: entry.$2, delivery: entry.$3), entry.$1);
          expect(englishTexts(tester, allowed: _places), isEmpty, reason: '${entry.$1} $lang ${entry.$2?.role}');
        }
      }
    });
  });

  group('Delivery partner: no overflow', () {
    testWidgets('3 sizes, 3 languages, light and dark, text x1.5', (tester) async {
      const sizes = [Size(320, 568), Size(360, 800), Size(430, 932)];
      for (final size in sizes) {
        for (final lang in AppLanguage.values) {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            tall(tester, w: size.width, h: size.height);
            final fake = FakeDelivery(
              profile: partner(),
              open: [job('o1', collectCashPaise: 250000), job('o2')],
              mine: [job('m1', status: 'on_the_way', timeline: [DeliveryStep(status: 'accepted', at: DateTime(2026, 10, 27), note: 'Taken')])],
            );
            Widget app({AuthUser? user, FakeDelivery? d}) =>
                communityApp(language: lang, mode: mode, textScale: 1.5, user: user, delivery: d ?? fake);
            for (final path in ['/delivery', '/delivery/jobs/m1']) {
              await openPath(tester, app(user: cfrUser), path);
              expect(tester.takeException(), isNull, reason: '$path $size $lang $mode');
            }
            await openPath(tester, app(user: cfrUser), '/delivery');
            await tester.tap(find.byKey(const Key('delivery_seg_mine')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'mine $size $lang $mode');

            await openPath(tester, app(user: cfrUser, d: FakeDelivery()), '/delivery/apply');
            await tester.tap(find.byKey(const Key('delivery_apply_submit')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'apply $size $lang $mode');

            for (final entry in <(AuthUser?, FakeDelivery)>[
              (null, FakeDelivery()),
              (buyerUser, FakeDelivery()),
              (cfrUser, FakeDelivery()),
              (cfrUser, FakeDelivery(profile: partner(status: 'rejected', reviewNote: 'Licence photo missing'))),
            ]) {
              await openPath(tester, app(user: entry.$1, d: entry.$2), '/delivery');
              expect(tester.takeException(), isNull, reason: 'state ${entry.$1?.role} $size $lang $mode');
            }
          }
        }
      }
    });
  });
}
