// lib/data/providers/api_provider.dart
// ─────────────────────────────────────────
// Central Dio HTTP client. All API calls go through here.
// Handles: auth tokens, timeouts, error normalization, logging.
//
// PHP Backend integration guide:
// 1. Set AppConstants.kBaseUrl to your PHP server URL
// 2. Each PHP file should return JSON: {"status": true/false, "message": "...", "data": {...}}
// 3. For protected routes, PHP should validate Bearer token from Authorization header
// ─────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import '../../../core/constants/app_constants.dart';

class ApiProvider {
  late final Dio _dio;
  final _storage = GetStorage();
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  ApiProvider() {
    _dio = Dio(BaseOptions(
      baseUrl:        AppConstants.kBaseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.kConnectTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.kReceiveTimeout),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _initInterceptors();
  }

  void _initInterceptors() {
    // ── Request: inject auth token ────────────────────────────────────────
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.read<String>(AppConstants.kTokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        _logger.d('→ ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('← ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (DioException e, handler) {
        _logger.e('✗ ${e.requestOptions.path}: ${e.message}');
        handler.next(e);
      },
    ));
  }

  // ── CRUD helpers ─────────────────────────────────────────────────────────

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return await _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path, data: data);
  }

  // ── Error normalizer ─────────────────────────────────────────────────────
  static String handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Check your internet.';
        case DioExceptionType.connectionError:
          return 'Cannot reach server. Check your connection.';
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          if (code == 401) return 'Session expired. Please log in again.';
          if (code == 403) return 'You do not have permission to do that.';
          if (code == 404) return 'Resource not found.';
          if (code == 422) return error.response?.data?['message'] ?? 'Validation error.';
          if (code != null && code >= 500) return 'Server error. Please try again.';
          return error.response?.data?['message'] ?? AppStrings.serverError;
        default:
          return AppStrings.networkError;
      }
    }
    return error.toString();
  }
}
