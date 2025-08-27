import 'dart:async';
import 'package:dio/dio.dart';
import 'package:payments_app/core/constants/constants.dart';
import 'package:payments_app/features/auth/data/token_storage.dart';
import 'package:payments_app/core/exceptions.dart';

class HttpClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  HttpClient(this._tokenStorage)
      : _dio = Dio(BaseOptions(
          baseUrl: kApiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'Accept': 'application/json',
          },
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.readToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        // If 401, try refresh
        if (e.response?.statusCode == 401) {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            final req = e.requestOptions;
            final token = await _tokenStorage.readToken();
            if (token == null) return handler.next(e);
            req.headers['Authorization'] = 'Bearer $token';
            final clone = await _dio.fetch(req);
            return handler.resolve(clone);
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null) return false;
      final res = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      final data = res.data as Map<String, dynamic>;
      final newAccess = data['access_token'] ?? data['token'] ?? data['accessToken'];
      final newRefresh = data['refresh_token'] ?? data['refreshToken'];
      if (newAccess is String) {
        await _tokenStorage.saveToken(newAccess);
      }
      if (newRefresh is String) {
        await _tokenStorage.saveRefreshToken(newRefresh);
      }
      return true;
    } catch (e) {
      await _tokenStorage.clear();
      return false;
    }
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get(path, queryParameters: query);
    } catch (e) {
      throw _wrap(e);
    }
  }

  Future<Response<T>> post<T>(String path, {Object? data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      throw _wrap(e);
    }
  }

  Future<Response<T>> patch<T>(String path, {Object? data}) async {
    try {
      return await _dio.patch(path, data: data);
    } catch (e) {
      throw _wrap(e);
    }
  }

Future<Response<T>> put<T>(String path, {Object? data}) async {
  try {
    return await _dio.put(path, data: data);
  } catch (e) {
    throw _wrap(e);
  }
}

Future<Response<T>> delete<T>(String path) async {
  try {
    return await _dio.delete(path);
  } catch (e) {
    throw _wrap(e);
  }
}


  AppException _wrap(Object e) {
    if (e is DioException) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['message']?.toString() ?? 'Erreur réseau')
          : (e.message ?? 'Erreur réseau');
      return AppException(msg, statusCode: e.response?.statusCode);
    }
    return AppException(e.toString());
  }
}
