import 'package:flutter/foundation.dart';
import '../db/user_database_helper.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  final UserDatabaseHelper _dbHelper = UserDatabaseHelper();

  UserProfile? _user;
  bool _isLoading = false;
  String? _error;

  // Fallback for display name if needed
  String? _fallbackDisplayName;

  // Getters
  UserProfile? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getter for display name that falls back to the local value if needed
  String? get displayName => _user?.name ?? _fallbackDisplayName;

  // Constructor
  AuthProvider() {
    // Check if user is already logged in (could implement with shared preferences)
    _checkCurrentUser();
  }

  // Check if user is already logged in
  Future<void> _checkCurrentUser() async {
    // This could be implemented with shared preferences to store the logged-in user's email
    // For now, we'll just set _user to null
    _user = null;
    notifyListeners();
  }

  // Sign in with email and password
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Attempt to login user
      final user = await _dbHelper.loginUser(email, password);

      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = "Invalid email or password";
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Login error: $e");
      _isLoading = false;
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailPassword(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Log the process
      print("Starting user registration for email: $email");

      // Check if user already exists
      bool exists = await _dbHelper.userExists(email);
      if (exists) {
        _isLoading = false;
        _error = "Email already in use";
        notifyListeners();
        return false;
      }

      // Create new user profile
      final newUser = UserProfile(
        email: email,
        password: password,
        name: name,
      );

      // Register the user
      int result = await _dbHelper.registerUser(newUser);

      if (result > 0) {
        // Registration successful, get the user with the ID
        newUser.id = result;
        _user = newUser;
        _fallbackDisplayName = name;

        print("User registered successfully with ID: $result");

        _isLoading = false;
        notifyListeners();
        return true;
      } else if (result == -1) {
        _isLoading = false;
        _error = "Email already in use";
        notifyListeners();
        return false;
      } else {
        _isLoading = false;
        _error = "Registration failed";
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Registration error details: $e");

      _isLoading = false;
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google (simplified for SQLite)
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Since we're removing Firebase, we'll just show an error message
      // In a real app, you might implement a different authentication method here
      _isLoading = false;
      _error = "Google Sign-In is not available with local authentication";
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simply set user to null
      _user = null;
      _fallbackDisplayName = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = _handleAuthError(e);
      notifyListeners();
    }
  }

  // Reset password using SQLite
  Future<bool> resetPassword(String email, [String? newPassword]) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if user exists
      bool exists = await _dbHelper.userExists(email);
      if (!exists) {
        _isLoading = false;
        _error = "No user found with this email";
        notifyListeners();
        return false;
      }

      // If newPassword is provided, reset the password
      // Otherwise, just return true to indicate the user exists
      bool result = true;
      if (newPassword != null && newPassword.isNotEmpty) {
        result = await _dbHelper.resetPassword(email, newPassword);
        if (!result) {
          _error = "Failed to reset password";
        }
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Handle authentication errors
  String _handleAuthError(dynamic error) {
    String errorMessage = "An unknown error occurred";

    // Since we're not using Firebase, we'll just return the error message
    errorMessage = error.toString();

    return errorMessage;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
