import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/report.dart';
import 'livelihood_api.dart';
import 'livelihood_cache.dart';

/// A report, and where it came from: the server just now, or the last one kept on the phone.
class ReportResult {
  const ReportResult(this.report, {this.fromCache = false, this.savedAt});

  final Report report;
  final bool fromCache;
  final DateTime? savedAt;
}

abstract class LivelihoodRepository {
  /// His report. [radiusM] is the search radius in metres; null lets the server use its default (5 km).
  Future<ReportResult> report({int? radiusM});
}

/// The live one: build the report on the server and keep it on the phone. When the server cannot be reached, or fails
/// (5xx), show the last saved report and say so. A refusal (4xx) is always shown: an old report must never hide it.
class RemoteLivelihoodRepository implements LivelihoodRepository {
  RemoteLivelihoodRepository(this._api, this._cache);

  final LivelihoodApi _api;
  final LivelihoodCache _cache;

  @override
  Future<ReportResult> report({int? radiusM}) async {
    try {
      final json = await _api.post(
        '/livelihood/report',
        body: radiusM == null ? <String, dynamic>{} : {'radius_m': radiusM},
      ) as Map<String, dynamic>;
      final report = Report.fromJson(json);
      await _cache.writeJson(LivelihoodCache.reportKey, {
        'saved_at': DateTime.now().toUtc().toIso8601String(),
        'report': json,
      });
      return ReportResult(report);
    } on NetworkException {
      final saved = await _saved();
      if (saved != null) return saved;
      rethrow;
    } on ApiException catch (e) {
      if (e.statusCode >= 500) {
        final saved = await _saved();
        if (saved != null) return saved;
      }
      rethrow;
    }
  }

  Future<ReportResult?> _saved() async {
    final entry = await _cache.readJson(LivelihoodCache.reportKey);
    if (entry == null) return null;
    try {
      final report = Report.fromJson(Map<String, dynamic>.from(entry['report'] as Map));
      return ReportResult(report, fromCache: true, savedAt: DateTime.tryParse('${entry['saved_at']}'));
    } catch (_) {
      await _cache.remove(LivelihoodCache.reportKey); // unreadable: drop it, show the real error
      return null;
    }
  }
}

/// The bundled SAMPLE report (assets/livelihood/sample_report.json), for demos and tests with no server.
class SeedLivelihoodRepository implements LivelihoodRepository {
  const SeedLivelihoodRepository();

  @override
  Future<ReportResult> report({int? radiusM}) async {
    final text = await rootBundle.loadString('assets/livelihood/sample_report.json');
    return ReportResult(Report.fromJson(jsonDecode(text) as Map<String, dynamic>));
  }
}
