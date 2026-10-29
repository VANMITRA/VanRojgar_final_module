import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/livelihood/models/report.dart';
import '../../../../features/livelihood/pdf/report_pdf.dart';
import '../../../../features/livelihood/providers/livelihood_providers.dart';
import '../../l10n/livelihood_ui_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../widgets/community/community_widgets.dart';
import '../../widgets/livelihood/livelihood_widgets.dart';

/// `/livelihood/report`: Livelihood report view with analysis, ideas, legal checks, and PDF export.
class LivelihoodReportPage extends ConsumerWidget {
  const LivelihoodReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = LivelihoodUiStrings.of(context, language);

    final reportAsync = ref.watch(reportProvider);

    return CommunityPage(
      title: strings.lhTitle,
      body: reportAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (err, _) => CommunityCentered(
          child: CommunityMessageCard(
            key: const Key('lh_report_error'),
            icon: Icons.cloud_off_outlined,
            body: strings.lhReportLoadError,
            actions: [
              CommunityPrimaryButton(
                key: const Key('lh_report_retry'),
                label: strings.lhRetry,
                onPressed: () => ref.invalidate(reportProvider),
              ),
            ],
          ),
        ),
        data: (result) {
          final r = result.report;
          final h = r.header;
          final lang = language.name;

          return CommunityScroll(
            scrollKey: const Key('lh_report_scroll'),
            children: [
              // Header Card
              CommunityCard(
                key: const Key('lh_report_header'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${strings.lhReportFor} ${h.name}',
                      style: TextStyle(
                        fontSize: 18.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                      ),
                    ),
                    SizedBox(height: 4.0 * s),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16.0 * s, color: tokens.mutedText),
                        SizedBox(width: 4.0 * s),
                        Expanded(
                          child: Text(
                            '${h.village(lang)} · ${h.level == 'plot' ? strings.lhPlotCentre : strings.lhVillageCentre}',
                            style: TextStyle(fontSize: 13.0 * s, color: tokens.mutedText),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0 * s),
                    TrustLabelCard(trust: h.trust, strings: strings),
                  ],
                ),
              ),
              SizedBox(height: 12.0 * s),

              // PDF Export button
              KeyedSubtree(
                key: const Key('lh_report_pdf_export'),
                child: _PdfActionButton(report: r, strings: strings),
              ),
              SizedBox(height: 16.0 * s),

              // Community Forest notice
              GramSabhaNoticeCard(strings: strings),
              SizedBox(height: 16.0 * s),

              // Analysis Section
              CommunityCard(
                key: const Key('lh_report_analysis'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.raw.reason(r.analysis.headline),
                      style: TextStyle(
                        fontSize: 16.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                      ),
                    ),
                    if (r.analysis.strengths.isNotEmpty) ...[
                      SizedBox(height: 8.0 * s),
                      for (final st in r.analysis.strengths)
                        Padding(
                          padding: EdgeInsets.only(bottom: 4.0 * s),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check, size: 16.0 * s, color: tokens.primaryGreen),
                              SizedBox(width: 6.0 * s),
                              Expanded(
                                child: Text(
                                  strings.raw.reason(st),
                                  style: TextStyle(fontSize: 13.5 * s, color: tokens.bodyText, height: 1.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.0 * s),

              // Ideas Section
              Text(
                strings.raw.t('lv_sec_ideas'),
                style: TextStyle(fontSize: 16.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
              ),
              SizedBox(height: 8.0 * s),
              if (r.ideas.isEmpty) ...[
                CommunityCard(
                  child: Text(
                    strings.lhMissingNotAvailable,
                    style: TextStyle(fontSize: 13.5 * s, color: tokens.mutedText),
                  ),
                ),
              ] else ...[
                for (final idea in r.ideas) ...[
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0 * s),
                    child: IdeaCardWidget(
                      idea: idea,
                      strings: strings,
                      onTap: () => context.push('/livelihood/idea/${idea.code}'),
                    ),
                  ),
                ],
              ],
              SizedBox(height: 12.0 * s),

              // Schemes link
              CommunityCard(
                key: const Key('lh_report_schemes_link'),
                onTap: () => context.push('/livelihood/schemes'),
                child: Row(
                  children: [
                    Container(
                      width: 36.0 * s,
                      height: 36.0 * s,
                      decoration: BoxDecoration(color: tokens.chipBg, shape: BoxShape.circle),
                      child: Icon(Icons.account_balance_outlined, size: 20.0 * s, color: tokens.primaryGreen),
                    ),
                    SizedBox(width: 12.0 * s),
                    Expanded(
                      child: Text(
                        strings.lhHubSchemes,
                        style: TextStyle(fontSize: 14.5 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 22.0 * s, color: tokens.mutedText),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PdfActionButton extends ConsumerStatefulWidget {
  final Report report;
  final LivelihoodUiStrings strings;

  const _PdfActionButton({required this.report, required this.strings});

  @override
  ConsumerState<_PdfActionButton> createState() => _PdfActionButtonState();
}

class _PdfActionButtonState extends ConsumerState<_PdfActionButton> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      await exportReportPdf(context, ref, widget.report);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.strings.raw.t('pdf_failed'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);

    return OutlinedButton.icon(
      key: const Key('pdf_button'),
      onPressed: _busy ? null : _export,
      style: OutlinedButton.styleFrom(
        foregroundColor: tokens.primaryGreen,
        side: BorderSide(color: tokens.primaryGreen),
        minimumSize: Size(double.infinity, 48.0 * s),
        padding: EdgeInsets.symmetric(horizontal: 16.0 * s, vertical: 10.0 * s),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0 * s)),
      ),
      icon: _busy
          ? SizedBox(
              width: 18.0 * s,
              height: 18.0 * s,
              child: CircularProgressIndicator(strokeWidth: 2, color: tokens.primaryGreen),
            )
          : Icon(Icons.picture_as_pdf_outlined, size: 20.0 * s),
      label: Text(
        widget.strings.lhSavePdf,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.0 * s,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
