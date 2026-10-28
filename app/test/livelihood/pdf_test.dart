import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/livelihood/data/livelihood_repository.dart';
import 'package:vanrozgar/features/livelihood/data/profile_repository.dart';
import 'package:vanrozgar/features/livelihood/livelihood_strings.dart';
import 'package:vanrozgar/features/livelihood/models/report.dart';
import 'package:vanrozgar/features/livelihood/pdf/report_pdf.dart';
import 'package:vanrozgar/features/livelihood/providers/livelihood_providers.dart';
import 'package:vanrozgar/features/livelihood/providers/profile_providers.dart';
import 'package:vanrozgar/features/livelihood/screens/report_screen.dart';

Report _sample() => Report.fromJson(
      jsonDecode(File('assets/livelihood/sample_report.json').readAsStringSync()) as Map<String, dynamic>,
    );

class _Repo implements LivelihoodRepository {
  @override
  Future<ReportResult> report({int? radiusM}) async => ReportResult(_sample());
}

// A 1x1 transparent PNG, enough to test the page assembly on its own.
final Uint8List _tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

/// Frames only move when a test pumps them, and the picture is made asynchronously: pump while it finishes.
Future<T> _drive<T>(WidgetTester tester, Future<T> future) async {
  var done = false;
  late T result;
  Object? error;
  future.then((v) {
    done = true;
    result = v;
  }, onError: (Object e) {
    done = true;
    error = e;
  });
  for (var i = 0; i < 300 && !done; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 15)));
  }
  expect(done, isTrue, reason: 'the PDF was not finished');
  if (error != null) throw error!;
  return result;
}

Future<BuildContext> _pumpReport(
  WidgetTester tester, {
  String lang = 'en',
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = const Size(800, 6000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        livelihoodRepositoryProvider.overrideWithValue(_Repo()),
        profileRepositoryProvider.overrideWithValue(MemoryProfileRepository()),
        ...extra,
      ],
      child: MaterialApp(
        locale: Locale(lang),
        theme: ThemeData(fontFamily: 'NotoSansDevanagari'),
        supportedLocales: const [Locale('en'), Locale('mr'), Locale('hi')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const ReportScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester.element(find.byType(ReportScreen));
}

void main() {
  test('the page assembly makes a valid PDF with one image per block and a Latin-only footer', () async {
    final bytes = await assemblePdf([_tinyPng, _tinyPng, _tinyPng]);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    final text = latin1.decode(bytes, allowInvalid: true);
    expect(RegExp(r'/Subtype\s*/Image').allMatches(text).length, greaterThanOrEqualTo(1));
    expect(text, contains('%%EOF'));
  });

  testWidgets('the blocks cover the title, every idea, every resource and every held-back idea', (tester) async {
    final context = await _pumpReport(tester);
    final report = _sample();
    final blocks = reportBlocks(report, LivelihoodStrings.of(context));
    // title + 2 headings + ideas + resources, plus the held-back heading and rows when there are any
    final expected = 1 + 2 + report.ideas.length + report.resources.length +
        (report.removed.isEmpty ? 0 : 1 + report.removed.length);
    expect(blocks.length, expected);
  });

  for (final lang in ['en', 'mr', 'hi']) {
    testWidgets('the Save as PDF button makes a PDF in $lang and passes it to the share sheet', (tester) async {
      final saved = <(Uint8List, String)>[];
      await _pumpReport(
        tester,
        lang: lang,
        extra: [pdfSaverProvider.overrideWithValue((bytes, name) async => saved.add((bytes, name)))],
      );
      expect(find.byKey(const ValueKey('pdf_button')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('pdf_button')));
      // the work starts on the tap; keep the frames moving until it has finished
      for (var i = 0; i < 400 && saved.isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 15)));
      }
      expect(saved, hasLength(1), reason: 'no PDF reached the share sheet');
      final (bytes, name) = saved.single;
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(name, startsWith('VanMitra-livelihood-report-'));
      expect(name, endsWith('-$lang.pdf'));
      expect(bytes.length, greaterThan(5000), reason: 'a real report is more than a few KB');
    });
  }

  testWidgets('Marathi and Hindi pictures are made and written out so a person can read them', (tester) async {
    // the test environment draws boxes unless the bundled font is loaded, exactly as the app loads it
    await tester.runAsync(() async {
      final loader = FontLoader('NotoSansDevanagari')
        ..addFont(rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/NotoSansDevanagari-Bold.ttf'));
      await loader.load();
    });
    for (final lang in ['mr', 'hi']) {
      final context = await _pumpReport(tester, lang: lang);
      final pngs = await _drive(
        tester,
        captureBlocks(context, reportBlocks(_sample(), LivelihoodStrings.of(context))),
      );
      expect(pngs, isNotEmpty);
      for (final png in pngs) {
        expect(png.take(4).toList(), [0x89, 0x50, 0x4E, 0x47], reason: 'not a PNG');
        expect(png.length, greaterThan(300));
      }
      final dir = Platform.environment['PDF_DEBUG_DIR'];
      if (dir != null) {
        // real file IO must run outside the test's fake time
        await tester.runAsync(() async {
          await Directory(dir).create(recursive: true);
          for (var i = 0; i < pngs.length && i < 6; i++) {
            await File('$dir/$lang-$i.png').writeAsBytes(pngs[i]);
          }
        });
      }
    }
  });
}
