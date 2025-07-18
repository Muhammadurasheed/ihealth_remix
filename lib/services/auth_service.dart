import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';  
import '../providers/auth_provider.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage;
  final Ref _ref;
  
  static const String _userKey = 'user_data';
  
  AuthService(this._secureStorage, this._ref);
  
  // Listen for authentication state changes and perform appropriate actions
  void initialize() {
    _ref.listen(authProvider, (previous, current) {
      debugPrint('Auth state changed: $previous -> $current');
      // Additional initialization logic can be added here if needed
    });
  }
  
  // Check if user is logged in based on auth state
  Future<bool> isLoggedIn() async {
    final authState = _ref.read(authProvider);
    return authState == AuthState.authenticated;
  }
  
  // Get the current logged-in user
  Future<User?> getCurrentUser() async {
    return _ref.read(userProvider);
  }
  
  // Get current error message if any
  String? getErrorMessage() {
    return _ref.read(authErrorProvider);
  }
  
  // Handle login process
  Future<User?> login(String email, String password) async {
    debugPrint('AuthService: Attempting login for $email');
    
    final success = await _ref
        .read(authProvider.notifier)
        .login(email, password);
        
    if (success) {
      debugPrint('AuthService: Login successful');
      return _ref.read(userProvider);
    } else {
      debugPrint('AuthService: Login failed: ${getErrorMessage()}');
      return null;
    }
  }
  
  // Handle registration process
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    String? dateOfBirth,
    String? gender,
  }) async {
    debugPrint('AuthService: Attempting registration for $email');
    
    // Get the current date in the format YYYY-MM-DD as default if not provided
    final formattedDateOfBirth = dateOfBirth ?? _getDefaultDateOfBirth();
    final selectedGender = gender ?? 'not_specified';
    
    final success = await _ref
        .read(authProvider.notifier)
        .signup(
          name: name,
          email: email,
          password: password,
          dateOfBirth: formattedDateOfBirth,
          gender: selectedGender,
        );
        
    if (success) {
      debugPrint('AuthService: Registration successful');
      return _ref.read(userProvider);
    } else {
      debugPrint('AuthService: Registration failed: ${getErrorMessage()}');
      return null;
    }
  }
  
  // Handle logout process
  Future<void> logout() async {
    debugPrint('AuthService: Logging out user');
    await _ref.read(authProvider.notifier).logout();
  }
  
  // Check initial authentication state on app start
  Future<void> checkInitialAuthState() async {
    debugPrint('AuthService: Checking initial auth state');
    await _ref.read(authProvider.notifier).checkAuth();
  }
  
  // Helper method to get a default date of birth (25 years ago)
  String _getDefaultDateOfBirth() {
    final today = DateTime.now();
    return "${today.year - 25}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  }
}

// Updated provider using the standard Provider pattern
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(const FlutterSecureStorage(), ref);
});