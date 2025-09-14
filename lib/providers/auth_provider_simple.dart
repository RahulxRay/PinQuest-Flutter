import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Mock authentication methods
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock user
      _currentUser = UserModel(
        id: 'mock_user_123',
        email: email,
        displayName: email.split('@')[0],
        photoUrl: null,
        totalPoints: 150,
        badges: <String>['early_adopter', 'explorer'],
        completedPins: <String>[],
        completedTrails: <String>[],
        createdAt: DateTime.now(),
        isSponsored: false,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock user
      _currentUser = UserModel(
        id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        totalPoints: 0,
        badges: <String>[],
        completedPins: <String>[],
        completedTrails: <String>[],
        createdAt: DateTime.now(),
        isSponsored: false,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock Google user
      _currentUser = UserModel(
        id: 'google_user_123',
        email: 'user@gmail.com',
        displayName: 'Google User',
        totalPoints: 50,
        badges: <String>['social_signin'],
        completedPins: <String>[],
        completedTrails: <String>[],
        createdAt: DateTime.now(),
        isSponsored: false,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Google sign-in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> resetPassword({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate sending reset email
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
