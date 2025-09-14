import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
// import '../services/auth_service.dart';
// import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  // final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // _initializeAuth();
  }

  // Temporarily disabled Firebase auth
  // void _initializeAuth() {
  //   _authService.authStateChanges.listen((User? firebaseUser) {
  //     if (firebaseUser != null) {
  //       _loadUserFromStorage(firebaseUser.uid);
  //     } else {
  //       _currentUser = null;
  //       notifyListeners();
  //     }
  //   });
  // }

  Future<void> _loadUserFromStorage(String userId) async {
    try {
      _currentUser = LocalStorageService.getUser(userId);
      
      // If user not found in local storage, create from Firebase user
      if (_currentUser == null) {
        final firebaseUser = _authService.currentUser;
        if (firebaseUser != null) {
          _currentUser = _authService.firebaseUserToUserModel(firebaseUser);
          if (_currentUser != null) {
            await LocalStorageService.saveUser(_currentUser!);
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        await _loadUserFromStorage(credential!.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
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
    try {
      _setLoading(true);
      _clearError();

      final credential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (credential?.user != null) {
        // Create new user model
        final newUser = UserModel(
          id: credential!.user!.uid,
          email: email,
          displayName: displayName,
          photoUrl: credential.user!.photoURL,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );

        // Save to local storage
        await LocalStorageService.saveUser(newUser);
        _currentUser = newUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _authService.signInWithGoogle();

      if (credential?.user != null) {
        await _loadUserFromStorage(credential!.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email: email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (_currentUser == null) return;

    try {
      _setLoading(true);
      _clearError();

      final updatedUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
      );

      await LocalStorageService.saveUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
