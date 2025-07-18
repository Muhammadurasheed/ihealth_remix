import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../models/user.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthController _authController;
  User? _user;
  String? _errorMessage;

  AuthNotifier(this._authController) : super(AuthState.initial);

  User? get user => _user;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuth() async {
    try {
      // Only change to loading if not already authenticated
      if (state != AuthState.authenticated) {
        state = AuthState.loading;
      }
      
      // Clear any previous error message
      _errorMessage = null;
      
      // Check if we have a stored token
      final hasToken = await _authController.dioClient.hasToken();
      
      debugPrint('AuthNotifier: Token exists: $hasToken');

      if (!hasToken) {
        debugPrint('AuthNotifier: No token found, setting to unauthenticated');
        state = AuthState.unauthenticated;
        return;
      }

      // Verify token validity with backend
      debugPrint('AuthNotifier: Verifying token with backend');
      final tokenCheckResult = await _authController.checkToken();
      
      if (tokenCheckResult['success']) {
        debugPrint('AuthNotifier: Token is valid, getting user profile');
        
        // Get user profile
        final profileResult = await _authController.getProfile();
        
        if (profileResult['success']) {
          try {
            debugPrint('AuthNotifier: Got profile, parsing user data');
            _user = User.fromJson(profileResult['data']['user']);
            
            // Log user data for debugging
            debugPrint('AuthNotifier: User authenticated: ${_user?.name}');
            
            state = AuthState.authenticated;
          } catch (e) {
            debugPrint('AuthNotifier: Error parsing user data: $e');
            await _authController.logout();
            _errorMessage = 'Invalid user data format';
            state = AuthState.unauthenticated;
          }
        } else {
          debugPrint('AuthNotifier: Failed to get profile: ${profileResult['message']}');
          await _authController.logout();
          _errorMessage = profileResult['message'];
          state = AuthState.unauthenticated;
        }
      } else {
        debugPrint('AuthNotifier: Token is invalid: ${tokenCheckResult['message']}');
        await _authController.logout();
        _errorMessage = tokenCheckResult['message'];
        state = AuthState.unauthenticated;
      }
    } catch (e) {
      debugPrint('AuthNotifier: Exception during auth check: $e');
      _errorMessage = e.toString();
      state = AuthState.error;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = AuthState.loading;
      _errorMessage = null;

      debugPrint('AuthNotifier: Attempting login for $email');
      
      final result = await _authController.login(
        email: email,
        password: password,
      );

      debugPrint('AuthNotifier: Login API result: $result');

      if (result['success']) {
        try {
          final userData = result['data']['user'];
          debugPrint('AuthNotifier: User data for login: $userData');

          _user = User.fromJson(userData);
          debugPrint('AuthNotifier: User object created: ${_user?.name}');

          // Set authenticated state
          state = AuthState.authenticated;
          return true;
        } catch (e) {
          debugPrint('AuthNotifier: Error parsing user data: $e');
          _errorMessage = 'Invalid user data format';
          state = AuthState.unauthenticated;
          return false;
        }
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        debugPrint('AuthNotifier: Login failed: $_errorMessage');
        state = AuthState.unauthenticated;
        return false;
      }
    } catch (e) {
      debugPrint('AuthNotifier: Exception during login: $e');
      _errorMessage = e.toString();
      state = AuthState.error;
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String dateOfBirth,
    required String gender,
  }) async {
    try {
      state = AuthState.loading;
      _errorMessage = null;

      debugPrint('AuthNotifier: Attempting signup for $email');
      
      final result = await _authController.signup(
        name: name,
        email: email,
        password: password,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      debugPrint('AuthNotifier: Signup response: $result');

      if (result['success']) {
        try {
          final userData = result['data']['user'];
          debugPrint('AuthNotifier: User data received: $userData');

          _user = User.fromJson(userData);
          
          debugPrint('AuthNotifier: User created successfully: ${_user?.name}');
          
          state = AuthState.authenticated;
          return true;
        } catch (e) {
          debugPrint('AuthNotifier: Error parsing user data: $e');
          _errorMessage = 'Server returned invalid user data: $e';
          state = AuthState.unauthenticated;
          return false;
        }
      } else {
        _errorMessage = result['message'] ?? 'Registration failed';
        debugPrint('AuthNotifier: Registration failed: $_errorMessage');
        state = AuthState.unauthenticated;
        return false;
      }
    } catch (e) {
      debugPrint('AuthNotifier: Exception during signup: $e');
      _errorMessage = 'An unexpected error occurred: $e';
      state = AuthState.error;
      return false;
    }
  }

  Future<void> logout() async {
    try {
      state = AuthState.loading;
      
      debugPrint('AuthNotifier: Logging out user');
      
      await _authController.logout();
      _user = null;
      _errorMessage = null;
      
      debugPrint('AuthNotifier: Logout successful');
      
      state = AuthState.unauthenticated;
    } catch (e) {
      debugPrint('AuthNotifier: Error during logout: $e');
      _errorMessage = e.toString();
      state = AuthState.error;
    }
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authControllerProvider));
});

final userProvider = Provider<User?>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return authNotifier.user;
});

final authErrorProvider = Provider<String?>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return authNotifier.errorMessage;
});