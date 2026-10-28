import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the sign-in token is kept between app starts.
abstract class V2TokenStorage {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

/// Keeps the token in memory only (tests, and the fallback when secure storage is not available).
class MemoryTokenStorage implements V2TokenStorage {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

/// Keeps the token in the phone's secure storage, so the user stays signed in between app starts.
class SecureTokenStorage implements V2TokenStorage {
  static const _key = 'vanmitra_token';
  final FlutterSecureStorage _storage;

  const SecureTokenStorage([this._storage = const FlutterSecureStorage()]);

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
