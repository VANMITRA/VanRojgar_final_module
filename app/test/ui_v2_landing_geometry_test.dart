import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/shell/landing_geometry.dart';
import 'package:vanrozgar/ui_v2/shell/landing_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

Widget _buildLandingApp({
  required AppLanguage language,
  required ThemeMode themeMode,
  double textScale = 1.0,
}) {
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => language),
      uiV2ThemeModeProvider.overrideWith((ref) => themeMode),
    ],
    child: MaterialApp(
      theme: VanRozgarTheme.lightTheme,
      darkTheme: VanRozgarTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: const LandingPage(),
    ),
  );
}

void main() {
  group('LandingGeometry Unit Tests', () {
    test('Reference Card 1 points match specifications', () {
      const card1 = LandingGeometry.card1Reference;
      expect(card1.topLeft, const Offset(0.436, 0.159));
      expect(card1.topRight, const Offset(0.969, 0.193));
      expect(card1.bottomRight, const Offset(0.998, 0.486));
      expect(card1.bottomLeft, const Offset(0.512, 0.526));
    });

    test('Reference Card 2 points match specifications', () {
      const card2 = LandingGeometry.card2Reference;
      expect(card2.topLeft, const Offset(0.488, 0.568));
      expect(card2.topRight, const Offset(0.990, 0.493));
      expect(card2.bottomRight, const Offset(0.988, 0.828));
      expect(card2.bottomLeft, const Offset(0.565, 0.855));
    });

    test('Thin gap between Card 1 bottom and Card 2 top at right edge is ~0.007 H', () {
      final gap = LandingGeometry.card2Reference.topRight.dy -
          LandingGeometry.card1Reference.bottomRight.dy;
      expect(gap, closeTo(0.007, 0.001));
    });

    test('Mirror function maps u to 1 - u', () {
      const card1 = LandingGeometry.card1Reference;
      final mirrored = card1.mirrored();

      // Card 1 right edge was at ~0.998, mirrored left edge should be at ~0.002
      expect(mirrored.bottomLeft.dx, closeTo(1.0 - card1.bottomRight.dx, 0.0001));
      expect(mirrored.topLeft.dx, closeTo(1.0 - card1.topRight.dx, 0.0001));
      expect(mirrored.topRight.dx, closeTo(1.0 - card1.topLeft.dx, 0.0001));
      expect(mirrored.bottomRight.dx, closeTo(1.0 - card1.bottomLeft.dx, 0.0001));

      // Y coordinates remain unchanged
      expect(mirrored.topLeft.dy, card1.topRight.dy);
      expect(mirrored.topRight.dy, card1.topLeft.dy);
      expect(mirrored.bottomRight.dy, card1.bottomLeft.dy);
      expect(mirrored.bottomLeft.dy, card1.bottomRight.dy);
    });

    test('Card 1 right edge touches right screen edge on reference and left edge on mirror', () {
      const ref = LandingGeometry.card1Reference;
      expect(ref.bounds.right, closeTo(0.998, 0.001));

      final mirrored = LandingGeometry.getCard1(mirrored: true);
      expect(mirrored.bounds.left, closeTo(0.002, 0.001));
    });

    test('Rounded polygon path bounds lie strictly inside polygon bounds', () {
      const double width = 360.0;
      const double height = 800.0;
      const double d = 360.0; // min(360, 800/2.2)
      const double r = 0.058 * d;

      for (final mirrored in [false, true]) {
        for (final isCard1 in [true, false]) {
          final poly = isCard1
              ? LandingGeometry.getCard1(mirrored: mirrored)
              : LandingGeometry.getCard2(mirrored: mirrored);

          final absPoints = poly.toAbsolute(width, height);
          final path = LandingGeometry.roundPolygon(absPoints, r);
          final pathBounds = path.getBounds();
          final polyBounds = poly.absoluteBounds(width, height);

          // Path bounds must lie within polygon bounds (with floating point tolerance)
          expect(pathBounds.left, greaterThanOrEqualTo(polyBounds.left - 0.5));
          expect(pathBounds.top, greaterThanOrEqualTo(polyBounds.top - 0.5));
          expect(pathBounds.right, lessThanOrEqualTo(polyBounds.right + 0.5));
          expect(pathBounds.bottom, lessThanOrEqualTo(polyBounds.bottom + 0.5));
        }
      }
    });

    test('Blob A and Blob B translations match specifications', () {
      final blobA = LandingGeometry.blobAReference;
      const card1 = LandingGeometry.card1Reference;
      expect(blobA.topLeft.dx - card1.topLeft.dx, closeTo(0.015, 0.0001));
      expect(blobA.topLeft.dy - card1.topLeft.dy, closeTo(-0.045, 0.0001));

      final blobB = LandingGeometry.blobBReference;
      const card2 = LandingGeometry.card2Reference;
      expect(blobB.topLeft.dx - card2.topLeft.dx, closeTo(-0.06, 0.0001));
      expect(blobB.topLeft.dy - card2.topLeft.dy, closeTo(0.035, 0.0001));
    });
  });

  group('Task 2: Landing Slides 1 and 3 Pulled Headline Geometry Tests', () {
    const sizes = <Size>[
      Size(320.0, 568.0),
      Size(360.0, 800.0),
      Size(430.0, 932.0),
    ];

    Map<int, List<int>> pulledIndicesForSlide1(AppLanguage lang) => switch (lang) {
          AppLanguage.en => const {1: [1, 3]}, // "from the", "forest"
          AppLanguage.hi => const {1: [1, 2]}, // "गाँव के", "जंगल"
          AppLanguage.mr => const {1: [1, 2]}, // "गावच्या", "जंगलातून"
        };

    Map<int, List<int>> pulledIndicesForSlide3(AppLanguage lang) => switch (lang) {
          AppLanguage.en => const {3: [1, 3]}, // "that stays", "village"
          AppLanguage.hi => const {3: [0, 1]}, // "रोज़गार", "जो गाँव"
          AppLanguage.mr => const {3: [0, 2]}, // "रोजगार", "गावातच"
        };

    testWidgets(
      'Slides 1 and 3 pulled headline lines overlap picture card by <= 0.08 * W, '
      'stay on screen, and subtitle/note do not touch pictures at 320x568, 360x800, 430x932 '
      'in EN, HI, MR, light & dark, textScaler 1.5',
      (WidgetTester tester) async {
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final size in sizes) {
          final W = size.width;
          final H = size.height;
          final card1Poly = LandingGeometry.getCard1(mirrored: true);

          for (final lang in AppLanguage.values) {
            final strings = AppStrings.of(lang);
            for (final mode in [ThemeMode.light, ThemeMode.dark]) {
              tester.view.physicalSize = Size(W * 2.0, H * 2.0);
              tester.view.devicePixelRatio = 2.0;

              await tester.pumpWidget(const SizedBox());
              await tester.pumpWidget(
                _buildLandingApp(
                  language: lang,
                  themeMode: mode,
                  textScale: 1.5,
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);

              void verifyMirroredSlide({
                required int slideNumber,
                required List<String> lines,
                required List<int> pulledIndices,
              }) {
                final card1Rect = tester.getRect(find.byKey(const Key('landing_card_top')));
                final card2Rect = tester.getRect(find.byKey(const Key('landing_card_bottom')));
                final subtitleRect = tester.getRect(find.byKey(const Key('landing_subtitle')));
                final noteRect = tester.getRect(find.byKey(const Key('landing_note')));

                for (int i = 0; i < lines.length; i++) {
                  final lineRect =
                      tester.getRect(find.byKey(Key('landing_headline_line_$i')));
                  // Must stay inside screen bounds
                  expect(
                    lineRect.left,
                    greaterThanOrEqualTo(0.0),
                    reason: 'Slide $slideNumber ($lang, $size, $mode) line $i went off left edge',
                  );
                  expect(
                    lineRect.right,
                    lessThanOrEqualTo(W + 0.5),
                    reason: 'Slide $slideNumber ($lang, $size, $mode) line $i went off right edge',
                  );

                  final edgeX = LandingGeometry.innerEdgeU(
                        card1Poly,
                        lineRect.center.dy / H,
                        mirrored: true,
                      ) *
                      W;
                  final rectOverlap = card1Rect.right - lineRect.left;
                  final edgeOverlap = edgeX - lineRect.left;

                  if (pulledIndices.contains(i)) {
                    // Pulled line must actually overlap the picture card (both polygon edge and card rect)
                    expect(
                      rectOverlap,
                      greaterThan(0.0),
                      reason:
                          'Slide $slideNumber ($lang, $size, $mode) pulled line $i ("${lines[i]}") did not overlap card1Rect',
                    );
                    expect(
                      edgeOverlap,
                      greaterThan(0.0),
                      reason:
                          'Slide $slideNumber ($lang, $size, $mode) pulled line $i ("${lines[i]}") did not overlap polygon edge',
                    );
                    // Overlap must be at most 0.08 * W
                    expect(
                      rectOverlap,
                      lessThanOrEqualTo(0.08 * W + 0.5),
                      reason:
                          'Slide $slideNumber ($lang, $size, $mode) pulled line $i ("${lines[i]}") overlapped card1Rect by more than 0.08 * W',
                    );
                    expect(
                      edgeOverlap,
                      lessThanOrEqualTo(0.08 * W + 0.5),
                      reason:
                          'Slide $slideNumber ($lang, $size, $mode) pulled line $i ("${lines[i]}") overlapped polygon edge by more than 0.08 * W',
                    );
                  } else {
                    // Non-pulled line must NOT touch the picture card
                    expect(
                      edgeOverlap,
                      lessThanOrEqualTo(0.0),
                      reason:
                          'Slide $slideNumber ($lang, $size, $mode) non-pulled line $i ("${lines[i]}") touched picture polygon',
                    );
                  }
                }

                // Subtitle and note must not touch the pictures
                expect(subtitleRect.overlaps(card2Rect), isFalse);
                expect(noteRect.overlaps(card1Rect), isFalse);
                expect(noteRect.overlaps(card2Rect), isFalse);
              }

              // Check Slide 1
              verifyMirroredSlide(
                slideNumber: 1,
                lines: strings.landingSlide1HeadlineLines,
                pulledIndices: pulledIndicesForSlide1(lang)[1]!,
              );

              // Advance to Slide 2 -> Slide 3
              await tester.tap(find.text(strings.landingNext));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);

              await tester.tap(find.text(strings.landingNext));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);

              // Check Slide 3
              verifyMirroredSlide(
                slideNumber: 3,
                lines: strings.landingSlide3HeadlineLines,
                pulledIndices: pulledIndicesForSlide3(lang)[3]!,
              );
            }
          }
        }
      },
    );
  });
}
