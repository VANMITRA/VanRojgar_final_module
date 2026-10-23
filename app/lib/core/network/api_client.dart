import 'dart:math';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../security/token_store.dart';
import '../storage/prefs.dart';
import 'app_exception.dart';
import '../demo/demo_backend.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 7),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Dynamic baseUrl override if configured
        final customUrl = await Prefs.getApiBaseUrl();
        if (customUrl != null && customUrl.isNotEmpty) {
          options.baseUrl = customUrl;
        }

        if (!options.baseUrl.endsWith('/')) {
          options.baseUrl = '${options.baseUrl}/';
        }

        if (options.path.startsWith('/')) {
          options.path = options.path.substring(1);
        }

        // Attach Auth Token
        final token = await TokenStore.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Attach Language
        final lang = await Prefs.getLanguage();
        options.headers['Accept-Language'] = lang;

        // Attach Request ID
        final randomId = 'req_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
        options.headers['X-Request-ID'] = randomId;

        handler.next(options);
      },
      onError: (DioException err, handler) async {
        // Clear token on 401 Unauthorized
        if (err.response?.statusCode == 401) {
          await TokenStore.clearToken();
        }

        if (err.response != null && err.response?.data is Map) {
          final data = err.response!.data as Map<String, dynamic>;
          final errorMap = data['error'] as Map<String, dynamic>?;
          if (errorMap != null) {
            handler.reject(DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              error: AppException(
                code: errorMap['code'] ?? 'UNKNOWN_ERROR',
                message: errorMap['message'] ?? 'Request failed',
                fields: errorMap['fields'] as Map<String, dynamic>?,
                phase: errorMap['phase'],
                requestId: errorMap['requestId'],
              ),
            ));
            return;
          }
        }
        handler.next(err);
      },
    ));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters, bool isRetry = false}) async {
    if (await DemoBackend.isActive()) return DemoBackend.handle('GET', path, query: queryParameters);
    try {
      final res = await dio.get(path, queryParameters: queryParameters);
      if (res.data is Map && res.data['data'] != null) {
        return res.data['data'];
      }
      return res.data;
    } on DioException catch (e) {
      // Retry once on transient network/timeout failure
      if (!isRetry && (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionError)) {
        await Future.delayed(const Duration(milliseconds: 500));
        return get(path, queryParameters: queryParameters, isRetry: true);
      }
      throw _wrapDioError(e);
    }
  }

  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? headers}) async {
    if (await DemoBackend.isActive()) return DemoBackend.handle('POST', path, data: data);
    try {
      final res = await dio.post(path, data: data, options: Options(headers: headers));
      if (res.data is Map && res.data['data'] != null) {
        return res.data['data'];
      }
      return res.data;
    } on DioException catch (e) {
      final err = _wrapDioError(e);
      // Server unreachable at login: fall back to the built-in offline demo accounts.
      if (err.code == 'NETWORK_ERROR' && path.contains('auth/login') && data is Map &&
          await DemoBackend.canLogin('${data['phone']}', '${data['password']}')) {
        await DemoBackend.activate();
        return DemoBackend.handle('POST', path, data: data);
      }
      throw err;
    }
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    if (await DemoBackend.isActive()) return DemoBackend.handle('PATCH', path, data: data);
    try {
      final res = await dio.patch(path, data: data);
      if (res.data is Map && res.data['data'] != null) {
        return res.data['data'];
      }
      return res.data;
    } on DioException catch (e) {
      throw _wrapDioError(e);
    }
  }

  AppException _wrapDioError(DioException e) {
    if (e.error is AppException) return e.error as AppException;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return AppException(
        code: 'NETWORK_ERROR',
        message: 'सर्व्हरशी संपर्क होऊ शकला नाही (Server unreachable).\n• खात्री करा की PC वर बॅकएंड (npm run dev) चालू आहे.\n• USB असल्यास PC Terminal मध्ये "adb reverse tcp:3000 tcp:3000" चालवा.\n• खालील "Server Target 🌐" दाबून योग्य URL निवडा.',
      );
    }
    return AppException(code: 'NETWORK_ERROR', message: e.message ?? 'Network connection failed');
  }
}
