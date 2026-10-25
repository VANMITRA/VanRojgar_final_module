import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../livelihood_strings.dart';
import '../models/report.dart';

/// The PDF of a report.
///
/// WHY IMAGES: the `pdf` package cannot shape Devanagari (vowel signs and conjuncts come out in the wrong place), so
/// Marathi and Hindi would be wrong. The report is therefore drawn by Flutter's own text engine (the same one that
/// draws the screens, with the bundled Noto Sans Devanagari) and each block is put into the PDF as a picture. The cost
/// is that the text in the PDF cannot be selected; the gain is that every language is correct.

/// How the finished PDF leaves the app (the share sheet: save, print, send). Tests replace it.
final pdfSaverProvider = Provider<Future<void> Function(Uint8List bytes, String filename)>(
  (ref) => (bytes, filename) => Printing.sharePdf(bytes: bytes, filename: filename),
);

const double _blockWidth = 520; // logical pixels; a block is scaled to the page width in the PDF
const _ink = Color(0xFF1B1B1B);
const _muted = Color(0xFF555555);
const _line = Color(0xFFCCCCCC);
const _forest = Color(0xFF1A4331);

TextStyle _style(double size, {bool bold = false, Color color = _ink}) => TextStyle(
      fontFamily: 'NotoSansDevanagari',
      fontSize: size,
      height: 1.35,
      color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

/// The report as a list of blocks (a heading, one idea, one resource ...). A block is never split across pages.
List<Widget> reportBlocks(Report report, LivelihoodStrings s, {DateTime? now}) {
  Widget block(List<Widget> children, {double top = 0}) => Padding(
        padding: EdgeInsets.only(top: top),
        child: Container(
          width: _blockWidth,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      );

  Widget heading(String text) => block(
        [
          Text(text, style: _style(17, bold: true, color: _forest)),
          const SizedBox(height: 3),
          Container(height: 1.5, color: _forest),
        ],
        top: 10,
      );

  Widget note(String text, {Color color = _muted}) => Text(text, style: _style(11.5, color: color));

  final radiusKm = LivelihoodStrings.km(report.header.radiusM);
  final village = report.header.village(s.lang);
  final blocks = <Widget>[
    block([
      Text(s.t('pdf_title'), style: _style(24, bold: true, color: _forest)),
      const SizedBox(height: 6),
      Text(
        [report.header.name, if (village.isNotEmpty) village].where((e) => e.isNotEmpty).join(' • '),
        style: _style(14, bold: true),
      ),
      Text(
        '${s.t('pdf_made_on', {'date': _date(now ?? report.generatedAt)})} • $radiusKm km',
        style: _style(12, color: _muted),
      ),
      const SizedBox(height: 6),
      note(s.t('pdf_suggestion_note')),
      if (report.isSampleData) note(s.t('pdf_sample_note'), color: const Color(0xFF9A5B00)),
    ]),
    heading(s.t('pdf_section_ideas')),
    if (report.ideas.isEmpty) block([note(s.t('pdf_no_ideas'))]),
    for (final idea in report.ideas)
      block([
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(border: Border.all(color: _line), borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${idea.rank}. ${idea.name(s.lang)}', style: _style(15, bold: true)),
              const SizedBox(height: 2),
              Text(
                [s.fitText(idea.fit), s.wildlifeText(idea.wildlifeRisk), s.t('lv_cost_${idea.costLevel}'), s.t('lv_season_${idea.bestSeason}')]
                    .join(' • '),
                style: _style(11.5, color: _muted),
              ),
              const SizedBox(height: 4),
              Text(s.reason(idea.reason), style: _style(12.5)),
              for (final f in idea.flags) Text('• ${s.reason(f)}', style: _style(11.5, color: const Color(0xFF9A5B00))),
            ],
          ),
        ),
      ]),
    heading(s.t('pdf_section_resources')),
    if (report.resources.isEmpty) block([note(s.t('pdf_no_resources'))]),
    for (final r in report.resources)
      block([
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: _line), borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.name(s.lang), style: _style(13.5, bold: true)),
              Text(
                '${s.kind(r.kind)} • ${LivelihoodStrings.distance(r.distanceM)} • ${s.labelText(r.label)}',
                style: _style(11.5, color: _muted),
              ),
              Text(s.reason(r.reason), style: _style(12)),
            ],
          ),
        ),
      ]),
    if (report.removed.isNotEmpty) ...[
      heading(s.t('pdf_section_removed')),
      for (final x in report.removed)
        block([
          Text(x.name(s.lang), style: _style(13, bold: true)),
          Text(s.reason(x.reason), style: _style(12)),
        ]),
    ],
  ];
  return blocks;
}

/// Draws each block off-screen with Flutter's own text engine and returns it as a PNG. The blocks sit in an overlay
/// far outside the visible area for one frame and are removed again.
Future<List<Uint8List>> captureBlocks(BuildContext context, List<Widget> blocks, {double pixelRatio = 2.5}) async {
  final overlay = Overlay.of(context, rootOverlay: true);
  final keys = [for (final _ in blocks) GlobalKey()];
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -100000,
      top: 0,
      child: Material(
        color: Colors.white,
        child: DefaultTextStyle(
          style: _style(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (var i = 0; i < blocks.length; i++) RepaintBoundary(key: keys[i], child: blocks[i])],
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  try {
    await WidgetsBinding.instance.endOfFrame;
    final out = <Uint8List>[];
    for (final key in keys) {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      out.add(bytes!.buffer.asUint8List());
    }
    return out;
  } finally {
    entry.remove();
  }
}

/// A4 pages from the block pictures. Latin text only is drawn by the `pdf` package (the page footer).
Future<Uint8List> assemblePdf(List<Uint8List> blockPngs, {String footer = 'VanRozgar'}) async {
  const margin = 32.0;
  final doc = pw.Document(title: 'VanRozgar livelihood report', creator: 'VanRozgar');
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(margin),
      footer: (c) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('$footer  ${c.pageNumber}/${c.pagesCount}', style: const pw.TextStyle(fontSize: 8)),
      ),
      build: (c) => [
        for (final png in blockPngs)
          pw.Image(pw.MemoryImage(png), width: PdfPageFormat.a4.width - 2 * margin, fit: pw.BoxFit.fitWidth),
      ],
    ),
  );
  return doc.save();
}

/// Make the PDF of [report] in the language of [context] and hand it to the share sheet.
Future<void> exportReportPdf(BuildContext context, WidgetRef ref, Report report) async {
  final s = LivelihoodStrings.of(context);
  final pngs = await captureBlocks(context, reportBlocks(report, s));
  final bytes = await assemblePdf(pngs);
  final stamp = _date(report.generatedAt).replaceAll('-', '');
  await ref.read(pdfSaverProvider)(bytes, 'VanRozgar-livelihood-report-$stamp-${s.lang}.pdf');
}

/// The "Save as PDF" button on the report screen.
class PdfExportButton extends ConsumerStatefulWidget {
  const PdfExportButton(this.report, {super.key});

  final Report report;

  @override
  ConsumerState<PdfExportButton> createState() => _PdfExportButtonState();
}

class _PdfExportButtonState extends ConsumerState<PdfExportButton> {
  bool _busy = false;

  Future<void> _run() async {
    final s = LivelihoodStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await exportReportPdf(context, ref, widget.report);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.t('pdf_failed'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LivelihoodStrings.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        key: const ValueKey('pdf_button'),
        onPressed: _busy ? null : _run,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        icon: _busy
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.picture_as_pdf_outlined),
        label: Text(s.t('pdf_button')),
      ),
    );
  }
}
