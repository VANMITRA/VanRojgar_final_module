import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/app_exception.dart';
import '../../core/security/token_store.dart';
import '../../core/storage/prefs.dart';
import '../../shared/models/user.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final activeLocaleProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('en') {
    _init();
  }

  Future<void> _init() async {
    state = await Prefs.getLanguage();
  }

  Future<void> setLanguage(String lang) async {
    state = lang;
    await Prefs.setLanguage(lang);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final api = ref.watch(apiClientProvider);
  return AuthController(api);
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final ApiClient _api;

  AuthController(this._api) : super(const AsyncValue.loading()) {
    checkSession();
  }

  Future<void> checkSession() async {
    final token = await TokenStore.getToken();
    if (token == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final res = await _api.get('/auth/me');
      final user = UserModel.fromJson(res);
      state = AsyncValue.data(user);
    } on AppException catch (e) {
      // Only drop the saved login when the server says it is invalid
      if (e.code == 'UNAUTHENTICATED') await TokenStore.clearToken();
      state = const AsyncValue.data(null);
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<UserModel> login(String phone, String password) async {
    state = const AsyncValue.loading();
    try {
      final res = await _api.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });

      final token = res['token'];
      await TokenStore.saveToken(token);

      final user = UserModel.fromJson(res['user']);
      await Prefs.setLastPortal(user.role);
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final res = await _api.post('/auth/register', data: data);
      final token = res['token'];
      await TokenStore.saveToken(token);

      final user = UserModel.fromJson(res['user']);
      await Prefs.setLastPortal(user.role);
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await TokenStore.clearToken();
    state = const AsyncValue.data(null);
  }
}
