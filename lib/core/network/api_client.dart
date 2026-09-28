import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_error.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});

class ApiClient {
  final SecureStorageService _storage;
  late final Dio _dio;
  late final Dio _refreshDio;
  final _uuid = const Uuid();
  Completer<bool>? _refreshCompleter;

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _refreshDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach X-Request-Id
          options.headers['X-Request-Id'] = _uuid.v4();

          // Attach Bearer token if available
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final is401 = error.response?.statusCode == 401;
          final isRefreshRequest = error.requestOptions.path.contains('/auth/refresh') ||
              error.requestOptions.path.contains('/auth/login');

          if (is401 && !isRefreshRequest) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final newAccessToken = await _storage.getAccessToken();
              final opts = Options(
                method: error.requestOptions.method,
                headers: {
                  ...error.requestOptions.headers,
                  'Authorization': 'Bearer $newAccessToken',
                },
              );
              try {
                final retryResponse = await _dio.request(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: opts,
                );
                return handler.resolve(retryResponse);
              } on DioException catch (retryError) {
                return handler.reject(retryError);
              }
            } else {
              await _storage.clearAuth();
            }
          }

          return handler.reject(error);
        },
      ),
    );
  }

  String _cleanPath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final p = path.replaceAll(RegExp(r'^/+'), '');
    return '$base/$p';
  }

  Future<bool> _refreshToken() async {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final currentRefreshToken = await _storage.getRefreshToken();
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final res = await _refreshDio.post(
        _cleanPath('/auth/refresh'),
        data: {'refreshToken': currentRefreshToken},
      );

      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        final newAccess = data['accessToken'] as String?;
        final newRefresh = data['refreshToken'] as String?;

        if (newAccess != null && newRefresh != null) {
          await _storage.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          _refreshCompleter!.complete(true);
          return true;
        }
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  ApiError _parseError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 0;
      final data = error.response?.data;
      String message = 'Không thể kết nối máy chủ.';
      String? code;

      if (data is Map<String, dynamic>) {
        final rawMsg = data['message'];
        if (rawMsg is List) {
          message = rawMsg.join(' · ');
        } else if (rawMsg is String) {
          message = rawMsg;
        }
        code = data['code']?.toString() ?? data['error']?.toString();
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        message = 'Yêu cầu đã hết thời gian chờ.';
        code = 'REQUEST_TIMEOUT';
      } else if (error.type == DioExceptionType.connectionError) {
        final uri = error.requestOptions.uri;
        message = 'Không thể kết nối máy chủ (${uri.host}:${uri.port}). Vui lòng kiểm tra backend hoặc mạng.';
        code = 'CONNECTION_ERROR';
      }

      debugPrint('[ApiClient] Error: ${error.type} | Status: $statusCode | URI: ${error.requestOptions.uri} | Details: ${error.message}');

      return ApiError(
        message: message,
        statusCode: statusCode,
        code: code,
        requestId: error.requestOptions.headers['X-Request-Id']?.toString(),
        data: data,
      );
    }

    return ApiError(message: error.toString());
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        _cleanPath(path),
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      throw _parseError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        _cleanPath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      throw _parseError(e);
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        _cleanPath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      throw _parseError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        _cleanPath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      throw _parseError(e);
    }
  }
}
