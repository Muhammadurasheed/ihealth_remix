import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DioClient {
  final Dio dio= Dio();
  final FlutterSecureStorage _secureStorage;
  static const String baseUrl = 'https://backend-dap2.onrender.com';
  static const String tokenKey = 'auth_token';

  DioClient(this._secureStorage) {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(
      seconds: 60,
    ); // Increased timeout
    dio.options.receiveTimeout = const Duration(
      seconds: 60,
    ); // Increased timeout
    dio.options.contentType = Headers.jsonContentType;
    dio.options.responseType = ResponseType.json;
    dio.options.validateStatus = (status) {
      // Log all responses, even errors
      if (status != null) {
        developer.log('Response status: $status', name: 'DIO');
      }
      return status != null && status < 500; // Don't throw on 4xx
    };
    // Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Log request
          developer.log(
            'REQUEST[${options.method}] => PATH: ${options.path}',
            name: 'DIO',
          );
          developer.log('Request Headers: ${options.headers}', name: 'DIO');
          if (options.data != null) {
            developer.log('Request Data: ${options.data}', name: 'DIO');
          }

          // Add user agent
          options.headers[HttpHeaders.userAgentHeader] =
              'iHealth Naija App v1.0';

          // Add auth token if available
          final token = await _secureStorage.read(key: tokenKey);
          if (token != null && token.isNotEmpty) {
            developer.log('Adding auth token to request', name: 'DIO');
            options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response
          developer.log(
            'RESPONSE[${response.statusCode}] <= PATH: ${response.requestOptions.path}',
            name: 'DIO',
          );
          developer.log('Response Headers: ${response.headers}', name: 'DIO');
          developer.log('Response Data: ${response.data}', name: 'DIO');

          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log error
          developer.log(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
            name: 'DIO_ERROR',
          );
          developer.log('Error: ${error.message}', name: 'DIO_ERROR');

          if (error.response != null) {
            developer.log(
              'Error Response: ${error.response?.data}',
              name: 'DIO_ERROR',
            );
          }

          // Handle unauthorized errors (401)
          if (error.response?.statusCode == 401) {
            developer.log(
              'Unauthorized error, clearing token',
              name: 'DIO_ERROR',
            );
            // Clear token
            await _secureStorage.delete(key: tokenKey);
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      developer.log('Exception in GET request: $e', name: 'DIO_ERROR');
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      developer.log('Exception in POST request: $e', name: 'DIO_ERROR');
      rethrow;
    }
  }

  Future<Response> postFormData(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      developer.log(
        'Exception in POST FormData request: $e',
        name: 'DIO_ERROR',
      );
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      developer.log('Exception in PUT request: $e', name: 'DIO_ERROR');
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      developer.log('Exception in DELETE request: $e', name: 'DIO_ERROR');
      rethrow;
    }
  }

  // Method to save token
  Future<void> saveToken(String token) async {
    developer.log('Saving auth token', name: 'DIO');
    await _secureStorage.write(key: tokenKey, value: token);
  }

  // Method to check if token exists
  Future<bool> hasToken() async {
    final token = await _secureStorage.read(key: tokenKey);
    final hasValidToken = token != null && token.isNotEmpty;
    developer.log('Checking for token: $hasValidToken', name: 'DIO');
    return hasValidToken;
  }

  // Method to delete token
  Future<void> deleteToken() async {
    developer.log('Deleting auth token', name: 'DIO');
    await _secureStorage.delete(key: tokenKey);
  }
}

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(const FlutterSecureStorage());
});
