import '../api/order_mapping.dart';
import '../api/v2_api_client.dart';
import '../providers/catalog_providers.dart' show AuthUser;
import 'token_storage.dart';
import 'villages.dart';

export 'token_storage.dart';

/// Sign in, create an account and sign out against the shop server.
class AuthRepository {
  final V2ApiClient api;
  final V2TokenStorage storage;

  AuthRepository(this.api, this.storage);

  AuthUser _userFrom(Object? raw) {
    final u = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final role = (u['role'] ?? 'buyer').toString();
    return AuthUser(
      name: (u['name'] ?? '').toString(),
      role: role == 'villager' ? 'cfrholder' : role,
      phone: (u['phone'] ?? '').toString(),
      villageId: villageIdFromName(u['village'] as String?),
    );
  }

  Future<AuthUser> _finish(Object? data) async {
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final token = (map['token'] ?? '').toString();
    if (token.isEmpty) {
      throw const V2ApiException(statusCode: 500, code: 'BAD_RESPONSE', message: 'The server did not send a sign-in token.');
    }
    await storage.write(token);
    return _userFrom(map['user']);
  }

  /// [phone] is 10 digits (or with +91), [pin] is the 6-digit PIN.
  Future<AuthUser> signIn({required String phone, required String pin}) async =>
      _finish(await api.post('/auth/login', body: {'phone': phone, 'password': pin}));

  /// [role] is `buyer`, `gramsabha` or `cfrholder`. Gram Sabha and CFR holder need a village (the English name).
  Future<AuthUser> signUp({
    required String role,
    required String name,
    required String phone,
    required String pin,
    required String language,
    String? villageId,
  }) async {
    final village = villageNameFromId(villageId);
    return _finish(await api.post('/auth/register', body: {
      'role': role,
      'name': name,
      'phone': phone,
      'password': pin,
      'language': language,
      if (village != null) 'village': village,
      if (village != null && role == 'gramsabha') 'taluka': taluka(villageId),
    }));
  }

  /// The user of the saved token, or null when there is none or the server no longer accepts it.
  Future<AuthUser?> restore() async {
    if (await storage.read() == null) return null;
    try {
      return _userFrom(await api.get('/auth/me'));
    } on V2ApiException catch (e) {
      if (e.statusCode == 401) {
        await storage.clear();
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await api.post('/auth/logout');
    } on V2ApiException {
      // the token is dropped here either way
    } on V2NetworkException {
      // offline: the token is still dropped
    }
    await storage.clear();
  }

  /// The taluka of a pilot village (the server wants it for a Gram Sabha).
  static String? taluka(String? villageId) {
    for (final v in pilotVillages) {
      if (v.id == villageId) return v.taluka;
    }
    return null;
  }
}
