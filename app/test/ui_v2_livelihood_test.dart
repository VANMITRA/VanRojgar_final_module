import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/livelihood/data/livelihood_repository.dart';
import 'package:vanrozgar/features/livelihood/data/profile_repository.dart';
import 'package:vanrozgar/features/livelihood/data/schemes_repository.dart';
import 'package:vanrozgar/features/livelihood/models/profile.dart';
import 'package:vanrozgar/features/livelihood/models/report.dart';
import 'package:vanrozgar/features/livelihood/models/scheme.dart';
import 'package:vanrozgar/features/livelihood/providers/detail_providers.dart';
import 'package:vanrozgar/features/livelihood/providers/livelihood_providers.dart';
import 'package:vanrozgar/features/livelihood/providers/market_points.dart';
import 'package:vanrozgar/features/livelihood/providers/profile_providers.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'community_test_helpers.dart';

const _allowedWords = {'Dongargaon', 'Bhatode', 'Deola', 'Dindori', 'डोंगरगाव', 'Acre', 'Guntha', 'Hectare', 'Ramesh Madavi', 'Ramesh', 'Madavi', 'Gram Sabha Survey', 'good_all_round'};

class FakeLivelihoodRepo implements LivelihoodRepository {
  ReportResult? result;
  Object? error;

  FakeLivelihoodRepo({this.result, this.error});

  @override
  Future<ReportResult> report({int? radiusM}) async {
    if (error != null) throw error!;
    return result!;
  }
}

class FakeProfileRepo implements ProfileRepository {
  LivelihoodProfile? profile;
  bool deleted = false;

  FakeProfileRepo({this.profile});

  @override
  bool get pendingSync => false;

  @override
  Future<LivelihoodProfile?> load() async => profile;

  @override
  Future<void> save(LivelihoodProfile p) async {
    profile = p;
  }

  @override
  Future<void> delete() async {
    profile = null;
    deleted = true;
  }
}

class FakeSchemesRepo implements SchemesRepository {
  SchemesResult? schemesResult;
  IdeaDetail? ideaDetail;
  Object? error;

  FakeSchemesRepo({this.schemesResult, this.ideaDetail, this.error});

  @override
  Future<SchemesResult> schemes(SchemeFilter filter) async {
    if (error != null) throw error!;
    return schemesResult!;
  }

  @override
  Future<IdeaDetail> idea(String code) async {
    if (error != null) throw error!;
    return ideaDetail!;
  }
}

Report makeTestReport({bool withDetails = true}) {
  return Report(
    id: 'rep_1',
    generatedAt: DateTime(2026, 10, 28),
    dataVersion: '1.0',
    isSampleData: false,
    newerVersionAvailable: false,
    header: const ReportHeader(
      name: 'Ramesh Madavi',
      villageMr: 'डोंगरगाव',
      villageEn: 'Dongargaon',
      level: 'plot',
      radiusM: 5000,
      centreSource: 'gps',
      trust: TrustLabel(
        source: 'Gram Sabha Survey',
        sourceDate: '2026-10-20',
        checkStatus: 'confirmed',
      ),
    ),
    resources: [
      const ResourceItem(
        id: 'res_1',
        kind: 'well',
        nameMr: 'शेततळे',
        nameEn: 'Farm pond',
        distanceM: 450,
        tag: 'near',
        label: UsefulLabel.useful,
        reason: Reason('good_all_round'),
        checkedOnGround: true,
        unknownChecks: [],
        useOnlyThroughGramSabha: false,
        trust: TrustLabel(source: 'Verified', sourceDate: '2026-10-20', checkStatus: 'confirmed'),
        lat: 19.998,
        lng: 73.790,
      ),
    ],
    counts: const Counts(total: 1, useful: 1, partlyUseful: 0, notUseful: 0),
    toldByYou: const [],
    analysis: const Analysis(
      headline: Reason('analysis.headline.farm_land'),
      strengths: [Reason('reason.good_all_round')],
      constraints: [],
      ownResources: [],
      nextSteps: [],
      notes: [],
    ),
    ideas: const [
      IdeaCard(
        rank: 1,
        code: 'dairy_small',
        nameMr: 'दुग्धव्यवसाय',
        nameEn: 'Dairy farming',
        group: 'ranked',
        fit: FitLabel.good,
        reason: Reason('good_all_round'),
        resourcesUsed: [],
        costLevel: 'low',
        bestSeason: 'year_round',
        wildlifeRisk: Wildlife.low,
        flags: [],
        draft: true,
      ),
    ],
    removed: const [],
    weather: null,
    disastersIsSample: false,
    footerKey: 'footer',
  );
}

IdeaDetail makeTestIdeaDetail() {
  return const IdeaDetail(
    card: IdeaCard(
      rank: 1,
      code: 'dairy_small',
      nameMr: 'दुग्धव्यवसाय',
      nameEn: 'Dairy farming',
      group: 'ranked',
      fit: FitLabel.good,
      reason: Reason('good_all_round'),
      resourcesUsed: [],
      costLevel: 'low',
      bestSeason: 'year_round',
      wildlifeRisk: Wildlife.low,
      flags: [],
      draft: true,
    ),
    status: 'in_report',
    needs: [],
    checks: [],
    resources: [],
    schemes: [
      Scheme(
        code: 'sch_dairy_1',
        kind: SchemeKind.government,
        nameEn: 'Dairy Support Scheme',
        nameMr: 'दुग्ध व्यवसाय विकास योजना',
        runsEn: 'Animal Husbandry Dept',
        runsMr: 'पशुसंवर्धन विभाग',
        whatEn: 'Subsidies for indigenous cattle',
        whatMr: 'स्थानिक गायींसाठी अनुदान',
        whoEn: 'Small and marginal farmers',
        whoMr: 'अल्प व अत्यल्प भूधारक शेतकरी',
        documentsEn: ['Aadhaar', 'Land 7/12'],
        documentsMr: ['आधार', '७/१२'],
        helpTypes: ['subsidy'],
        audiences: ['farmers'],
        officialUrl: 'https://ahd.maharashtra.gov.in',
        noteEn: '',
        noteMr: '',
        lastCheckedOn: '2026-10-25',
        isSample: false,
      ),
    ],
    isSampleData: false,
  );
}

SchemesResult makeTestSchemesResult() {
  return const SchemesResult(
    schemes: [
      Scheme(
        code: 'sch_1',
        kind: SchemeKind.government,
        nameEn: 'Farm Pond Subsidy',
        nameMr: 'शेततळे अनुदान योजना',
        runsEn: 'Agriculture Dept',
        runsMr: 'कृषी विभाग',
        whatEn: 'Financial assistance for farm ponds',
        whatMr: 'शेततळ्यासाठी आर्थिक साहाय्य',
        whoEn: 'Farmers with land',
        whoMr: 'जमीनधारक शेतकरी',
        documentsEn: ['Land papers'],
        documentsMr: ['जमिनीची कागदपत्रे'],
        helpTypes: ['subsidy'],
        audiences: ['farmers'],
        officialUrl: 'https://krishi.maharashtra.gov.in',
        noteEn: '',
        noteMr: '',
        lastCheckedOn: '2026-10-25',
        isSample: false,
      ),
    ],
    helpTypes: ['subsidy'],
    audiences: ['farmers'],
    isSampleData: false,
    registerEmpty: false,
  );
}

List<Override> livelihoodOverrides({
  LivelihoodRepository? livelihoodRepo,
  ProfileRepository? profileRepo,
  SchemesRepository? schemesRepo,
  Future<bool> Function(String)? urlOpener,
}) {
  return [
    mapTilesEnabledProvider.overrideWithValue(false),
    if (livelihoodRepo != null) livelihoodRepositoryProvider.overrideWithValue(livelihoodRepo),
    if (profileRepo != null) profileRepositoryProvider.overrideWithValue(profileRepo),
    if (schemesRepo != null) schemesRepositoryProvider.overrideWithValue(schemesRepo),
    if (urlOpener != null) urlOpenerProvider.overrideWithValue(urlOpener),
  ];
}

void main() {
  group('Livelihood Home: access control & states', () {
    testWidgets('guest sees sign-in / create account', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(extra: livelihoodOverrides()), '/livelihood');
      expect(find.byKey(const Key('community_guest_signin')), findsOneWidget);
      expect(find.byKey(const Key('community_guest_signup')), findsOneWidget);
      expect(find.byKey(const Key('lh_home_hero')), findsNothing);
    });

    testWidgets('non-CFR buyer sees friendly explanation card', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(user: buyerUser, extra: livelihoodOverrides()), '/livelihood');
      expect(find.byKey(const Key('lh_not_cfr')), findsOneWidget);
      expect(find.byKey(const Key('lh_home_hero')), findsNothing);
    });

    testWidgets('CFR holder with no details sees Create report button', (tester) async {
      tall(tester);
      final profRepo = FakeProfileRepo(profile: null);
      await openPath(
        tester,
        communityApp(user: cfrUser, extra: livelihoodOverrides(profileRepo: profRepo)),
        '/livelihood',
      );

      expect(find.byKey(const Key('lh_home_hero')), findsOneWidget);
      expect(find.byKey(const Key('lh_home_create_btn')), findsOneWidget);
      expect(find.byKey(const Key('lh_home_view_btn')), findsNothing);

      // Entries for hub
      expect(find.byKey(const Key('lh_home_schemes')), findsOneWidget);
      expect(find.byKey(const Key('lh_home_resources')), findsOneWidget);
      expect(find.byKey(const Key('lh_home_map')), findsOneWidget);
      expect(find.byKey(const Key('lh_home_policy')), findsOneWidget);
    });

    testWidgets('CFR holder with details sees View and Update buttons, and delete confirms', (tester) async {
      tall(tester);
      final profRepo = FakeProfileRepo(profile: const LivelihoodProfile(areaValue: 2.0));
      await openPath(
        tester,
        communityApp(user: cfrUser, extra: livelihoodOverrides(profileRepo: profRepo)),
        '/livelihood',
      );

      expect(find.byKey(const Key('lh_home_view_btn')), findsOneWidget);
      expect(find.byKey(const Key('lh_home_edit_btn')), findsOneWidget);
      expect(find.byKey(const Key('lh_home_delete_btn')), findsOneWidget);

      // Tapping delete opens confirmation dialog
      await tester.tap(find.byKey(const Key('lh_home_delete_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('community_confirm_dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('community_confirm_ok')));
      await tester.pumpAndSettle();
      expect(profRepo.deleted, isTrue);
    });
  });

  group('Livelihood Details: multi-step form flow', () {
    testWidgets('steps through land, animals, assets, work, and saves on last step', (tester) async {
      tall(tester);
      final profRepo = FakeProfileRepo();
      final lhRepo = FakeLivelihoodRepo(result: ReportResult(makeTestReport()));

      await openPath(
        tester,
        communityApp(
          user: cfrUser,
          extra: livelihoodOverrides(profileRepo: profRepo, livelihoodRepo: lhRepo),
        ),
        '/livelihood/details',
      );

      // Step 1 (Land): area input and unit
      expect(find.byKey(const Key('lh_step_title')), findsOneWidget);
      expect(find.byKey(const Key('lh_input_area')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('lh_input_area')), '3.5');

      // Next to Step 2 (Animals)
      await tester.tap(find.byKey(const Key('lh_step_next_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lh_animal_plus_cow')), findsOneWidget);
      await tester.tap(find.byKey(const Key('lh_animal_plus_cow')));
      await tester.pumpAndSettle();

      // Next to Step 3 (Assets)
      await tester.tap(find.byKey(const Key('lh_step_next_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lh_asset_pump')), findsOneWidget);
      await tester.tap(find.byKey(const Key('lh_asset_pump')));
      await tester.pumpAndSettle();

      // Next to Step 4 (Work)
      await tester.tap(find.byKey(const Key('lh_step_next_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lh_work_paddy')), findsOneWidget);
      await tester.tap(find.byKey(const Key('lh_work_paddy')));
      await tester.pumpAndSettle();

      // Next to Step 5 (Location)
      await tester.tap(find.byKey(const Key('lh_step_next_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lh_loc_village')), findsOneWidget);
      expect(find.byKey(const Key('lh_step_create_btn')), findsOneWidget);

      // Save report
      await tester.tap(find.byKey(const Key('lh_step_create_btn')));
      await tester.pumpAndSettle();
      expect(profRepo.profile, isNotNull);
      expect(profRepo.profile!.areaValue, 3.5);
    });
  });

  group('Livelihood Report & Idea Detail & Schemes', () {
    testWidgets('report shows analysis, ideas, trust label and links to idea detail', (tester) async {
      tall(tester);
      final lhRepo = FakeLivelihoodRepo(result: ReportResult(makeTestReport()));
      final schemesRepo = FakeSchemesRepo(ideaDetail: makeTestIdeaDetail(), schemesResult: makeTestSchemesResult());

      await openPath(
        tester,
        communityApp(
          user: cfrUser,
          extra: livelihoodOverrides(livelihoodRepo: lhRepo, schemesRepo: schemesRepo),
        ),
        '/livelihood/report',
      );

      expect(find.byKey(const Key('lh_report_header')), findsOneWidget);
      expect(find.byKey(const Key('lh_report_analysis')), findsOneWidget);
      expect(find.byKey(const Key('idea_card_dairy_small')), findsOneWidget);

      // Tap idea card navigates to idea detail
      await tester.tap(find.byKey(const Key('idea_card_dairy_small')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('lh_idea_header')), findsOneWidget);
      expect(find.byKey(const Key('lh_idea_reason')), findsOneWidget);
      expect(find.byKey(const Key('scheme_card_sch_dairy_1')), findsOneWidget);
    });

    testWidgets('schemes screen lists official schemes with links', (tester) async {
      tall(tester);
      String? launchedUrl;
      final schemesRepo = FakeSchemesRepo(schemesResult: makeTestSchemesResult());

      await openPath(
        tester,
        communityApp(
          user: cfrUser,
          extra: livelihoodOverrides(
            schemesRepo: schemesRepo,
            urlOpener: (url) async {
              launchedUrl = url;
              return true;
            },
          ),
        ),
        '/livelihood/schemes',
      );

      expect(find.byKey(const Key('scheme_card_sch_1')), findsOneWidget);
      await tester.tap(find.byKey(const Key('scheme_link_sch_1')));
      await tester.pumpAndSettle();

      expect(launchedUrl, 'https://krishi.maharashtra.gov.in');
    });

    testWidgets('resources screen lists nearby items', (tester) async {
      tall(tester);
      final lhRepo = FakeLivelihoodRepo(result: ReportResult(makeTestReport()));
      await openPath(
        tester,
        communityApp(user: cfrUser, extra: livelihoodOverrides(livelihoodRepo: lhRepo)),
        '/livelihood/resources',
      );
      expect(find.byKey(const Key('resource_item_res_1')), findsOneWidget);
    });

    testWidgets('policy screen explains wildlife protection and legal framework', (tester) async {
      tall(tester);
      await openPath(tester, communityApp(user: cfrUser, extra: livelihoodOverrides()), '/livelihood/policy');
      expect(find.byKey(const Key('lh_policy_card')), findsOneWidget);
    });
  });

  group('Profile integration: CFR holder activity card', () {
    testWidgets('CFR holder sees My livelihood report card on profile', (tester) async {
      tall(tester);
      final profRepo = FakeProfileRepo(profile: null);
      await openPath(
        tester,
        communityApp(user: cfrUser, extra: livelihoodOverrides(profileRepo: profRepo)),
        '/profile',
      );

      expect(find.byKey(const Key('profile_livelihood_create_btn')), findsOneWidget);
    });
  });

  group('Livelihood: language purity', () {
    testWidgets('Marathi mode has no English words except allowed', (tester) async {
      tall(tester);
      final lhRepo = FakeLivelihoodRepo(result: ReportResult(makeTestReport()));
      final schemesRepo = FakeSchemesRepo(ideaDetail: makeTestIdeaDetail(), schemesResult: makeTestSchemesResult());

      await openPath(
        tester,
        communityApp(
          user: cfrUser,
          language: AppLanguage.mr,
          extra: livelihoodOverrides(livelihoodRepo: lhRepo, schemesRepo: schemesRepo),
        ),
        '/livelihood',
      );
      final homeLeaks = englishTexts(tester, allowed: _allowedWords);
      expect(homeLeaks, isEmpty, reason: 'English found on Marathi Livelihood home: $homeLeaks');

      await openPath(
        tester,
        communityApp(
          user: cfrUser,
          language: AppLanguage.mr,
          extra: livelihoodOverrides(livelihoodRepo: lhRepo, schemesRepo: schemesRepo),
        ),
        '/livelihood/report',
      );
      final reportLeaks = englishTexts(tester, allowed: _allowedWords);
      expect(reportLeaks, isEmpty, reason: 'English found on Marathi Livelihood report: $reportLeaks');
    });
  });

  group('Livelihood: overflow and scaling', () {
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

            final lhRepo = FakeLivelihoodRepo(result: ReportResult(makeTestReport()));
            final schemesRepo = FakeSchemesRepo(ideaDetail: makeTestIdeaDetail(), schemesResult: makeTestSchemesResult());

            await openPath(
              tester,
              communityApp(
                user: cfrUser,
                language: lang,
                mode: mode,
                textScale: 1.5,
                extra: livelihoodOverrides(livelihoodRepo: lhRepo, schemesRepo: schemesRepo),
              ),
              '/livelihood',
            );
            expect(tester.takeException(), isNull);

            await openPath(
              tester,
              communityApp(
                user: cfrUser,
                language: lang,
                mode: mode,
                textScale: 1.5,
                extra: livelihoodOverrides(livelihoodRepo: lhRepo, schemesRepo: schemesRepo),
              ),
              '/livelihood/report',
            );
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });

  group('Livelihood: forbidden text', () {
    testWidgets('no screen contains Sample, Demo, or Opens in the full app', (tester) async {
      tall(tester);
      final lhRepo = FakeLivelihoodRepo(result: ReportResult(makeTestReport()));
      final schemesRepo = FakeSchemesRepo(ideaDetail: makeTestIdeaDetail(), schemesResult: makeTestSchemesResult());

      await openPath(
        tester,
        communityApp(
          user: cfrUser,
          extra: livelihoodOverrides(livelihoodRepo: lhRepo, schemesRepo: schemesRepo),
        ),
        '/livelihood',
      );
      expect(find.textContaining('Sample'), findsNothing);
      expect(find.textContaining('Demo'), findsNothing);
      expect(find.textContaining('Opens in the full app'), findsNothing);

      await openPath(
        tester,
        communityApp(
          user: cfrUser,
          extra: livelihoodOverrides(livelihoodRepo: lhRepo, schemesRepo: schemesRepo),
        ),
        '/livelihood/report',
      );
      expect(find.textContaining('Sample'), findsNothing);
      expect(find.textContaining('Demo'), findsNothing);
      expect(find.textContaining('Opens in the full app'), findsNothing);
    });
  });
}
