import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/api/api_client.dart';

export '../../../core/api/api_client.dart' show ApiException;

/// There is no usable connection to the server: no network, a timeout, a dropped connection, or an answer that is
/// not ours (a Wi-Fi sign-in page). Different from [ApiException], which means the server answered.
class NetworkException implements Exception {
  const NetworkException([this.cause]);

  final Object? cause;

  @override
  String toString() => 'NetworkException(${cause ?? 'offline'})';
}

/// The four calls the livelihood feature makes. Paths start with `/` and are relative to `/api/v1`.
abstract class LivelihoodApi {
  Future<dynamic> get(String path);
  Future<dynamic> post(String path, {Map<String, dynamic>? body});
  Future<dynamic> put(String path, {Map<String, dynamic>? body});
  Future<dynamic> delete(String path);
}

/// Adapts the app's [ApiClient] to [LivelihoodApi]: it adds a timeout, and turns every "could not reach the server"
/// failure into one [NetworkException]. A server answer, even an error, is passed through untouched.
class HostApiAdapter implements LivelihoodApi {
  HostApiAdapter(this._client, {this.timeout = const Duration(seconds: 20)});

  final ApiClient _client;
  final Duration timeout;

  Future<dynamic> _guard(Future<dynamic> Function() call) async {
    try {
      return await call().timeout(timeout);
    } on ApiException {
      rethrow;
    } on TimeoutException catch (e) {
      throw NetworkException(e);
    } on SocketException catch (e) {
      throw NetworkException(e);
    } on http.ClientException catch (e) {
      throw NetworkException(e);
    } on FormatException catch (e) {
      throw NetworkException(e);
    } on HandshakeException catch (e) {
      throw NetworkException(e);
    }
  }

  @override
  Future<dynamic> get(String path) => _guard(() => _client.get(path));

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _guard(() => _client.post(path, body: body));

  @override
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) =>
      _guard(() => _client.put(path, body: body));

  @override
  Future<dynamic> delete(String path) => _guard(() => _client.delete(path));
}
