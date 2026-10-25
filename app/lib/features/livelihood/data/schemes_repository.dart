import '../models/scheme.dart';
import 'livelihood_api.dart';

abstract class SchemesRepository {
  /// The scheme register, optionally filtered by the kind of help or the audience.
  Future<SchemesResult> schemes(SchemeFilter filter);

  /// One idea from his current report, in detail. 404 if his report does not contain it.
  Future<IdeaDetail> idea(String code);
}

class RemoteSchemesRepository implements SchemesRepository {
  RemoteSchemesRepository(this._api);

  final LivelihoodApi _api;

  @override
  Future<SchemesResult> schemes(SchemeFilter filter) async {
    final query = <String, String>{
      if (filter.help != null) 'help': filter.help!,
      if (filter.audience != null) 'audience': filter.audience!,
    };
    final path = Uri(path: '/livelihood/schemes', queryParameters: query.isEmpty ? null : query).toString();
    final json = await _api.get(path) as Map<String, dynamic>;
    return SchemesResult.fromJson(json);
  }

  @override
  Future<IdeaDetail> idea(String code) async {
    final json = await _api.get('/livelihood/ideas/${Uri.encodeComponent(code)}') as Map<String, dynamic>;
    return IdeaDetail.fromJson(json);
  }
}
