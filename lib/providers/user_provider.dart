import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/badge_model.dart';
import '../services/local_storage_service.dart';
import '../core/config/app_config.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  List<BadgeModel> _availableBadges = [];
  List<BadgeModel> _userBadges = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  List<BadgeModel> get availableBadges => _availableBadges;
  List<BadgeModel> get userBadges => _userBadges;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      _loadUserBadges();
    }
    notifyListeners();
  }

  Future<void> _loadUserBadges() async {
    if (_currentUser == null) return;

    try {
      _availableBadges = LocalStorageService.getAllBadges();
      _userBadges = _availableBadges
          .where((badge) => _currentUser!.badges.contains(badge.id))
          .toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load badges: $e';
      notifyListeners();
    }
  }

  Future<void> checkInAtPin(String pinId) async {
    if (_currentUser == null) return;

    try {
      _setLoading(true);
      
      // Add pin to completed pins if not already there
      if (!_currentUser!.completedPins.contains(pinId)) {
        final updatedUser = _currentUser!.copyWith(
          completedPins: [..._currentUser!.completedPins, pinId],
          totalPoints: _currentUser!.totalPoints + AppConfig.pointsPerCheckIn,
          lastActiveAt: DateTime.now(),
        );

        await LocalStorageService.saveUser(updatedUser);
        _currentUser = updatedUser;
        
        // Check for new badges
        await _checkForNewBadges();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to check in: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createPin() async {
    if (_currentUser == null) return;

    try {
      _setLoading(true);
      
      final updatedUser = _currentUser!.copyWith(
        totalPoints: _currentUser!.totalPoints + AppConfig.pointsPerPinCreation,
        lastActiveAt: DateTime.now(),
      );

      await LocalStorageService.saveUser(updatedUser);
      _currentUser = updatedUser;
      
      // Check for new badges
      await _checkForNewBadges();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to award points for pin creation: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeTrail(String trailId) async {
    if (_currentUser == null) return;

    try {
      _setLoading(true);
      
      // Add trail to completed trails if not already there
      if (!_currentUser!.completedTrails.contains(trailId)) {
        final updatedUser = _currentUser!.copyWith(
          completedTrails: [..._currentUser!.completedTrails, trailId],
          totalPoints: _currentUser!.totalPoints + AppConfig.pointsPerTrailCompletion,
          lastActiveAt: DateTime.now(),
        );

        await LocalStorageService.saveUser(updatedUser);
        _currentUser = updatedUser;
        
        // Check for new badges
        await _checkForNewBadges();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to complete trail: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _checkForNewBadges() async {
    if (_currentUser == null) return;

    final newBadges = <String>[];
    
    for (final badge in _availableBadges) {
      if (_currentUser!.badges.contains(badge.id)) continue;
      
      bool shouldAward = false;
      
      switch (badge.category) {
        case BadgeCategory.general:
          if (_currentUser!.totalPoints >= badge.requiredPoints) {
            shouldAward = true;
          }
          break;
        case BadgeCategory.explorer:
          if (_currentUser!.completedPins.length >= (badge.requiredCount ?? 0)) {
            shouldAward = true;
          }
          break;
        case BadgeCategory.creator:
          final userPins = LocalStorageService.getPinsByUser(_currentUser!.id);
          if (userPins.length >= (badge.requiredCount ?? 0)) {
            shouldAward = true;
          }
          break;
        case BadgeCategory.social:
          if (_currentUser!.completedTrails.length >= (badge.requiredCount ?? 0)) {
            shouldAward = true;
          }
          break;
        case BadgeCategory.achievement:
          // Custom achievement logic can be added here
          break;
      }
      
      if (shouldAward) {
        newBadges.add(badge.id);
      }
    }
    
    if (newBadges.isNotEmpty) {
      final updatedUser = _currentUser!.copyWith(
        badges: [..._currentUser!.badges, ...newBadges],
      );
      
      await LocalStorageService.saveUser(updatedUser);
      _currentUser = updatedUser;
      _loadUserBadges();
    }
  }

  bool hasCompletedPin(String pinId) {
    return _currentUser?.completedPins.contains(pinId) ?? false;
  }

  bool hasCompletedTrail(String trailId) {
    return _currentUser?.completedTrails.contains(trailId) ?? false;
  }

  int getTrailProgress(List<String> pinIds) {
    if (_currentUser == null) return 0;
    
    int completedCount = 0;
    for (final pinId in pinIds) {
      if (_currentUser!.completedPins.contains(pinId)) {
        completedCount++;
      }
    }
    return completedCount;
  }

  double getTrailProgressPercentage(List<String> pinIds) {
    if (pinIds.isEmpty) return 0.0;
    return getTrailProgress(pinIds) / pinIds.length;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
