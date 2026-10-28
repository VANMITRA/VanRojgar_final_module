import 'dart:convert';
import 'package:http/http.dart' as http;

/// The server answered with an error (`{ success: false, error: { code, message, details } }`).
class V2ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const V2ApiException({required this.statusCode, required this.code, required this.message, this.details});

  @override
  String toString() => 'V2ApiException($statusCode $code $message)';
}

/// The server could not be reached (no network, wrong address, timeout).
class V2NetworkException implements Exception {
  final Object cause;
  const V2NetworkException(this.cause);

  @override
  String toString() => 'V2NetworkException($cause)';
}

typedef V2TokenProvider = Future<String?> Function();

/// Small client for the shop server (`/api/v1`). Every call returns the `data` of the answer.
class V2ApiClient {
  final String baseUrl;
  final V2TokenProvider? tokenProvider;
  final http.Client _client;
  final Duration timeout;

  V2ApiClient({
    required this.baseUrl,
    this.tokenProvider,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  String get _root {
    final trimmed = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return trimmed.endsWith('/api/v1') ? trimmed : '$trimmed/api/v1';
  }

  Uri _uri(String path, Map<String, String?>? query) {
    final params = <String, String>{
      for (final e in (query ?? const <String, String?>{}).entries)
        if (e.value != null && e.value!.isNotEmpty) e.key: e.value!,
    };
    return Uri.parse('$_root$path').replace(queryParameters: params.isEmpty ? null : params);
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await tokenProvider?.call();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path, {Map<String, String?>? query}) =>
      _send(() async => _client.get(_uri(path, query), headers: await _headers()));

  Future<dynamic> post(String path, {Object? body}) => _send(() async =>
      _client.post(_uri(path, null), headers: await _headers(json: true), body: jsonEncode(body ?? const {})));

  Future<dynamic> patch(String path, {Object? body}) => _send(() async =>
      _client.patch(_uri(path, null), headers: await _headers(json: true), body: jsonEncode(body ?? const {})));

  Future<dynamic> _send(Future<http.Response> Function() call) async {
    final http.Response res;
    try {
      res = await call().timeout(timeout);
    } catch (e) {
      throw V2NetworkException(e);
    }
    if (res.statusCode == 204 || res.body.isEmpty) return null;
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      throw V2ApiException(statusCode: res.statusCode, code: 'BAD_RESPONSE', message: 'The server sent an unreadable answer.');
    }
    final map = decoded is Map<String, dynamic> ? decoded : const <String, dynamic>{};
    if (res.statusCode >= 200 && res.statusCode < 300) return map.containsKey('data') ? map['data'] : decoded;
    final err = map['error'] is Map<String, dynamic> ? map['error'] as Map<String, dynamic> : const <String, dynamic>{};
    throw V2ApiException(
      statusCode: res.statusCode,
      code: (err['code'] as String?) ?? 'ERROR',
      message: (err['message'] as String?) ?? 'The request failed.',
      details: err['details'] is Map<String, dynamic> ? err['details'] as Map<String, dynamic> : null,
    );
  }
}
