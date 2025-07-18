import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../services/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController {
  final DioClient dioClient;

  AuthController(this.dioClient);

  Future<Map<String, dynamic>> signup({
  required String name,
  required String email,
  required String password,
  required String dateOfBirth,
  required String gender,
}) async {
  developer.log('Starting signup process', name: 'AUTH');
  developer.log('Params: email=$email, name=$name, dob=$dateOfBirth, gender=$gender', name: 'AUTH');
  
  try {
    // Make sure dateOfBirth is in the expected format (YYYY-MM-DD)
    final formattedDate = dateOfBirth.split('T')[0]; // Remove any time component
    
    final data = {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'dateOfBirth': formattedDate,
      'gender': gender,
    };
    
    developer.log('Sending signup request to /api/auth/signup', name: 'AUTH');
    developer.log('Request data: $data', name: 'AUTH');
    
    // Add additional options to the request
    final options = Options(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    );
    
    final response = await dioClient.post(
      '/api/auth/signup',
      data: data,
      options: options,
    );

      developer.log(
        'Signup response received: ${response.statusCode}',
        name: 'AUTH',
      );
      developer.log('Response data: ${response.data}', name: 'AUTH');

      // Check if we got an error response but with 200 status
      if (response.data is Map && response.data.containsKey('error')) {
        developer.log(
          'Error in response body: ${response.data['error']}',
          name: 'AUTH_ERROR',
        );
        return {
          'success': false,
          'message':
              response.data['error'] ??
              response.data['message'] ??
              'Registration failed',
          'data': response.data,
        };
      }

      // Save token if registration successful and token exists in response
      if (response.data['token'] != null) {
        developer.log('Token found in response, saving...', name: 'AUTH');
        await dioClient.saveToken(response.data['token']);
        developer.log('Token saved successfully', name: 'AUTH');
      } else {
        developer.log('No token found in response', name: 'AUTH');
      }

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      // More detailed Dio error logging
      developer.log(
        'DioException during signup: ${e.type}',
        name: 'AUTH_ERROR',
      );
      developer.log(
        'Status code: ${e.response?.statusCode}',
        name: 'AUTH_ERROR',
      );
      developer.log('Error response: ${e.response?.data}', name: 'AUTH_ERROR');
      developer.log('Error message: ${e.message}', name: 'AUTH_ERROR');

      return {
        'success': false,
        'message':
            e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            'Registration failed: ${e.message}',
        'statusCode': e.response?.statusCode,
        'data': e.response?.data,
      };
    } catch (e) {
      // Handle other errors
      developer.log('Exception during signup: $e', name: 'AUTH_ERROR');

      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    developer.log('Starting login process', name: 'AUTH');
    developer.log('Params: email=$email', name: 'AUTH');

    try {
      final response = await dioClient.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      developer.log(
        'Login response received: ${response.statusCode}',
        name: 'AUTH',
      );
      developer.log('Response data: ${response.data}', name: 'AUTH');

      // Save token if login successful
      if (response.data['token'] != null) {
        developer.log('Token found in response, saving...', name: 'AUTH');
        await dioClient.saveToken(response.data['token']);
        developer.log('Token saved successfully', name: 'AUTH');
      } else {
        developer.log('No token found in response', name: 'AUTH');
      }

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      // Handle Dio specific errors
      developer.log('DioException during login: ${e.type}', name: 'AUTH_ERROR');
      developer.log(
        'Status code: ${e.response?.statusCode}',
        name: 'AUTH_ERROR',
      );
      developer.log('Error response: ${e.response?.data}', name: 'AUTH_ERROR');

      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Login failed',
        'statusCode': e.response?.statusCode,
        'data': e.response?.data,
      };
    } catch (e) {
      // Handle other errors
      developer.log('Exception during login: $e', name: 'AUTH_ERROR');

      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    developer.log('Getting user profile', name: 'AUTH');

    try {
      final response = await dioClient.get('/api/auth/profile');
      developer.log(
        'Profile response received: ${response.statusCode}',
        name: 'AUTH',
      );
      developer.log('Profile data: ${response.data}', name: 'AUTH');

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      developer.log('Error fetching profile: ${e.message}', name: 'AUTH_ERROR');

      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to get profile',
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      developer.log('Exception getting profile: $e', name: 'AUTH_ERROR');

      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> checkToken() async {
    developer.log('Checking token validity', name: 'AUTH');

    try {
      final response = await dioClient.get('/api/auth/check-token');
      developer.log(
        'Token check response: ${response.statusCode}',
        name: 'AUTH',
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      developer.log(
        'Token validation failed: ${e.message}',
        name: 'AUTH_ERROR',
      );

      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Token validation failed',
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      developer.log('Exception checking token: $e', name: 'AUTH_ERROR');

      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    developer.log('Logging out user', name: 'AUTH');
    // Just delete the token for logout
    await dioClient.deleteToken();
    developer.log('User logged out successfully', name: 'AUTH');
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.read(dioClientProvider));
});
