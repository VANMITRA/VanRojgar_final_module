import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  static const _keyToken = 'vr_jwt_token';
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _keyToken);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }
}
