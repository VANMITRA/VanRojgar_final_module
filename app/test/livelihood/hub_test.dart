import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/livelihood/data/profile_repository.dart';
import 'package:vanrozgar/features/livelihood/livelihood_routes.dart';
import 'package:vanrozgar/features/livelihood/providers/host_hooks.dart';
import 'package:vanrozgar/features/livelihood/providers/profile_providers.dart';
import 'package:vanrozgar/features/livelihood/screens/livelihood_home_screen.dart';

Future<void> _pumpHub(
  WidgetTester tester, {
  String lang = 'en',
  List<Override> extra = const [],
  Widget? nav,
}) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(MemoryProfileRepository()),
        ...extra,
      ],
      child: MaterialApp(
        locale: Locale(lang),
        theme: ThemeData(fontFamily: 'NotoSansDevanagari'),
        supportedLocales: const [Locale('en'), Locale('mr')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: livelihoodRoutes,
        home: LivelihoodHomeScreen(bottomNavigationBar: nav),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the hub offers the report, resources, schemes and policy, and no Ask',
      (tester) async {
    await _pumpHub(tester);
    expect(find.text('Add your details'), findsOneWidget);
    expect(find.text('Ask AI'), findsNothing);
    expect(find.byTooltip('Ask AI'), findsNothing);
    expect(find.text('Show my report'), findsOneWidget);
    expect(find.text('Resources near me'), findsOneWidget);
    expect(find.text('Government schemes'), findsOneWidget);
    expect(find.text('Wildlife policy'), findsOneWidget);
    // nothing to change or delete until details are saved
    expect(find.text('Change my details'), findsNothing);
    expect(find.text('Delete my answers'), findsNothing);
  });




  testWidgets('inside the host: its frame, its bottom bar and its hero are used',
      (tester) async {
    await _pumpHub(
      tester,
      nav: const Text('HOST-NAV'),
      extra: [
        hostFrameBuilderProvider.overrideWithValue(
          (context, spec) => Column(
            children: [
              Text('HOST-FRAME ${spec.title}'),
              Expanded(child: spec.body),
              if (spec.bottomNavigationBar != null) spec.bottomNavigationBar!,
            ],
          ),
        ),
        hostHeroBuilderProvider.overrideWithValue(
          (context, ref, {required badge, required child}) => Column(
            children: [Text('HOST-HERO $badge'), child],
          ),
        ),
      ],
    );
    expect(find.text('HOST-FRAME My livelihood'), findsOneWidget);
    expect(find.text('HOST-HERO Livelihood'), findsOneWidget);
    expect(find.text('HOST-NAV'), findsOneWidget);
  });
}
