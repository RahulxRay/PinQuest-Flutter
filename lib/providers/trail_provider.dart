import 'package:flutter/foundation.dart';
import '../models/trail_model.dart';
import '../models/pin_model.dart';
import '../services/local_storage_service_simple.dart';

class TrailProvider extends ChangeNotifier {
  List<TrailModel> _allTrails = [];
  List<TrailModel> _publicTrails = [];
  List<TrailModel> _userTrails = [];
  List<TrailModel> _filteredTrails = [];
  TrailDifficulty? _selectedDifficulty;
  bool _isLoading = false;
  String? _errorMessage;

  List<TrailModel> get allTrails => _allTrails;
  List<TrailModel> get publicTrails => _publicTrails;
  List<TrailModel> get userTrails => _userTrails;
  List<TrailModel> get filteredTrails => _filteredTrails;
  TrailDifficulty? get selectedDifficulty => _selectedDifficulty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTrails() async {
    try {
      _setLoading(true);
      _allTrails = LocalStorageServiceSimple.getAllTrails();
      _publicTrails = LocalStorageServiceSimple.getPublicTrails();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load trails: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserTrails(String userId) async {
    try {
      _userTrails = LocalStorageServiceSimple.getTrailsByUser(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user trails: $e';
      notifyListeners();
    }
  }

  Future<void> createTrail(TrailModel trail) async {
    try {
      _setLoading(true);
      await LocalStorageServiceSimple.saveTrail(trail);
      _allTrails.add(trail);
      
      if (trail.isPublic) {
        _publicTrails.add(trail);
      }
      
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to create trail: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTrail(TrailModel trail) async {
    try {
      _setLoading(true);
      await LocalStorageServiceSimple.saveTrail(trail);
      
      final index = _allTrails.indexWhere((t) => t.id == trail.id);
      if (index != -1) {
        _allTrails[index] = trail;
      }
      
      final publicIndex = _publicTrails.indexWhere((t) => t.id == trail.id);
      if (trail.isPublic) {
        if (publicIndex != -1) {
          _publicTrails[publicIndex] = trail;
        } else {
          _publicTrails.add(trail);
        }
      } else {
        if (publicIndex != -1) {
          _publicTrails.removeAt(publicIndex);
        }
      }
      
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to update trail: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTrail(String trailId) async {
    try {
      _setLoading(true);
      await LocalStorageServiceSimple.deleteTrail(trailId);
      _allTrails.removeWhere((trail) => trail.id == trailId);
      _publicTrails.removeWhere((trail) => trail.id == trailId);
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to delete trail: $e';
    } finally {
      _setLoading(false);
    }
  }

  void setDifficultyFilter(TrailDifficulty? difficulty) {
    _selectedDifficulty = difficulty;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredTrails = _publicTrails.where((trail) {
      // Difficulty filter
      if (_selectedDifficulty != null && trail.difficulty != _selectedDifficulty) {
        return false;
      }
      
      return true;
    }).toList();
    
    notifyListeners();
  }

  List<TrailModel> searchTrails(String query) {
    if (query.isEmpty) return _filteredTrails;
    
    final lowercaseQuery = query.toLowerCase();
    return _filteredTrails.where((trail) {
      return trail.title.toLowerCase().contains(lowercaseQuery) ||
          trail.description.toLowerCase().contains(lowercaseQuery) ||
          trail.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  List<TrailModel> getTrailsByDifficulty(TrailDifficulty difficulty) {
    return _publicTrails.where((trail) => trail.difficulty == difficulty).toList();
  }

  TrailModel? getTrailById(String trailId) {
    try {
      return _allTrails.firstWhere((trail) => trail.id == trailId);
    } catch (e) {
      return null;
    }
  }

  List<PinModel> getTrailPins(String trailId) {
    final trail = getTrailById(trailId);
    if (trail == null) return [];
    
    final pins = <PinModel>[];
    for (final pinId in trail.pinIds) {
      final pin = LocalStorageServiceSimple.getPin(pinId);
      if (pin != null) {
        pins.add(pin);
      }
    }
    
    return pins;
  }

  double getTrailDistance(String trailId) {
    final trail = getTrailById(trailId);
    return trail?.distance ?? 0.0;
  }

  int getTrailDuration(String trailId) {
    final trail = getTrailById(trailId);
    return trail?.estimatedDuration ?? 0;
  }

  double getTrailCompletionPercentage(String trailId, List<String> userCompletedPins) {
    final trail = getTrailById(trailId);
    if (trail == null) return 0.0;
    
    return trail.getCompletionPercentage(userCompletedPins);
  }

  bool isTrailCompleted(String trailId, List<String> userCompletedPins) {
    final trail = getTrailById(trailId);
    if (trail == null) return false;
    
    return trail.isCompleted(userCompletedPins);
  }

  int getTrailProgress(String trailId, List<String> userCompletedPins) {
    final trail = getTrailById(trailId);
    if (trail == null) return 0;
    
    int completedCount = 0;
    for (final pinId in trail.pinIds) {
      if (userCompletedPins.contains(pinId)) {
        completedCount++;
      }
    }
    
    return completedCount;
  }

  Future<void> refreshTrails() async {
    await loadTrails();
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
