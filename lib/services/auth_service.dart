// lib/services/auth_service.dart
// Auth wrapper that works with the parse_stub and with the real parse_server_sdk_flutter.
// It uses the small subset of Parse API needed by the app.

import 'package:task_manager_app/parse_stub.dart';

class AuthService {
  /// Sign up a new user using student email and password.
  /// Throws on failure.
  static Future<ParseUser> signUp(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPass = password.trim();

    // Use convenience constructor implemented in stub
    final user = ParseUser.createUser(trimmedEmail, trimmedPass, trimmedEmail);

    final ParseResponse response = await user.signUp();
    if (response.success && response.result != null) {
      return response.result as ParseUser;
    } else {
      final msg = response.error?.message ?? 'Sign up failed';
      throw Exception(msg);
    }
  }

  /// Login with email and password.
  /// Throws on failure.
  static Future<ParseUser> login(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPass = password.trim();

    // Create a ParseUser instance with named params so it works with stub and real SDK
    final user = ParseUser(username: trimmedEmail, password: trimmedPass);

    final ParseResponse response = await user.login();
    if (response.success && response.result != null) {
      return response.result as ParseUser;
    } else {
      final msg = response.error?.message ?? 'Login failed';
      throw Exception(msg);
    }
  }

  /// Return currently logged-in user or null.
  static Future<ParseUser?> currentUser() async {
    final ParseResponse response = await ParseUser.currentUser();
    if (response.success && response.result != null) {
      return response.result as ParseUser;
    } else {
      return null;
    }
  }

  /// Logout current user.
  static Future<void> logout() async {
    final ParseUser? user = await currentUser();
    if (user != null) {
      await user.logout(deleteLocalSession: true);
    }
  }
}
