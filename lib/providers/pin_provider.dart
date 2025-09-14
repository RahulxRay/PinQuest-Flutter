import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import '../models/pin_model.dart';
import '../services/local_storage_service_simple.dart';
import '../services/location_service.dart';

class PinProvider extends ChangeNotifier {
  List<PinModel> _allPins = [];
  List<PinModel> _nearbyPins = [];
  List<PinModel> _filteredPins = [];
  List<PinModel> _userPins = [];
  String _selectedCategory = 'All';
  bool _showSponsoredOnly = false;
  bool _isLoading = false;
  String? _errorMessage;
  LocationData? _currentLocation;

  List<PinModel> get allPins => _allPins;
  List<PinModel> get nearbyPins => _nearbyPins;
  List<PinModel> get filteredPins => _filteredPins;
  List<PinModel> get userPins => _userPins;
  String get selectedCategory => _selectedCategory;
  bool get showSponsoredOnly => _showSponsoredOnly;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LocationData? get currentLocation => _currentLocation;

  Future<void> loadPins() async {
    try {
      _setLoading(true);
      _allPins = LocalStorageServiceSimple.getAllPins();
      _applyFilters();
      await _loadCurrentLocation();
      await _loadNearbyPins();
    } catch (e) {
      _errorMessage = 'Failed to load pins: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserPins(String userId) async {
    try {
      _userPins = LocalStorageServiceSimple.getPinsByUser(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user pins: $e';
      notifyListeners();
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      _currentLocation = await LocationService.getCurrentLocation();
    } catch (e) {
      // Handle location error silently
      debugPrint('Failed to get current location: $e');
    }
  }

  Future<void> _loadNearbyPins() async {
    if (_currentLocation == null) {
      _nearbyPins = [];
      notifyListeners();
      return;
    }

    const double nearbyRadius = 5000; // 5km radius
    
    _nearbyPins = _allPins.where((pin) {
      final distance = LocationService.calculateDistance(
        startLatitude: _currentLocation!.latitude!,
        startLongitude: _currentLocation!.longitude!,
        endLatitude: pin.latitude,
        endLongitude: pin.longitude,
      );
      return distance <= nearbyRadius;
    }).toList();

    // Sort by distance
    _nearbyPins.sort((a, b) {
      final distanceA = LocationService.calculateDistance(
        startLatitude: _currentLocation!.latitude!,
        startLongitude: _currentLocation!.longitude!,
        endLatitude: a.latitude,
        endLongitude: a.longitude,
      );
      final distanceB = LocationService.calculateDistance(
        startLatitude: _currentLocation!.latitude!,
        startLongitude: _currentLocation!.longitude!,
        endLatitude: b.latitude,
        endLongitude: b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });

    notifyListeners();
  }

  Future<void> createPin(PinModel pin) async {
    try {
      _setLoading(true);
      await LocalStorageServiceSimple.savePin(pin);
      _allPins.add(pin);
      _applyFilters();
      await _loadNearbyPins();
    } catch (e) {
      _errorMessage = 'Failed to create pin: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePin(PinModel pin) async {
    try {
      _setLoading(true);
      await LocalStorageServiceSimple.savePin(pin);
      
      final index = _allPins.indexWhere((p) => p.id == pin.id);
      if (index != -1) {
        _allPins[index] = pin;
        _applyFilters();
        await _loadNearbyPins();
      }
    } catch (e) {
      _errorMessage = 'Failed to update pin: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePin(String pinId) async {
    try {
      _setLoading(true);
      await LocalStorageServiceSimple.deletePin(pinId);
      _allPins.removeWhere((pin) => pin.id == pinId);
      _applyFilters();
      await _loadNearbyPins();
    } catch (e) {
      _errorMessage = 'Failed to delete pin: $e';
    } finally {
      _setLoading(false);
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void toggleSponsoredFilter() {
    _showSponsoredOnly = !_showSponsoredOnly;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredPins = _allPins.where((pin) {
      // Category filter
      if (_selectedCategory != 'All' && pin.category != _selectedCategory) {
        return false;
      }
      
      // Sponsored filter
      if (_showSponsoredOnly && !pin.isSponsored) {
        return false;
      }
      
      return true;
    }).toList();
    
    notifyListeners();
  }

  List<PinModel> searchPins(String query) {
    if (query.isEmpty) return _filteredPins;
    
    final lowercaseQuery = query.toLowerCase();
    return _filteredPins.where((pin) {
      return pin.title.toLowerCase().contains(lowercaseQuery) ||
          pin.description.toLowerCase().contains(lowercaseQuery) ||
          pin.category.toLowerCase().contains(lowercaseQuery) ||
          pin.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  List<PinModel> getPinsByCategory(String category) {
    return _allPins.where((pin) => pin.category == category).toList();
  }

  List<PinModel> getSponsoredPins() {
    return _allPins.where((pin) => pin.isSponsored).toList();
  }

  PinModel? getPinById(String pinId) {
    try {
      return _allPins.firstWhere((pin) => pin.id == pinId);
    } catch (e) {
      return null;
    }
  }

  double getDistanceToPin(PinModel pin) {
    if (_currentLocation == null) return 0.0;
    
    return LocationService.calculateDistance(
      startLatitude: _currentLocation!.latitude!,
      startLongitude: _currentLocation!.longitude!,
      endLatitude: pin.latitude,
      endLongitude: pin.longitude,
    );
  }

  String getFormattedDistanceToPin(PinModel pin) {
    final distance = getDistanceToPin(pin);
    return LocationService.formatDistance(distance);
  }

  bool isUserNearPin(PinModel pin, {double radiusInMeters = 50.0}) {
    if (_currentLocation == null) return false;
    
    return LocationService.isWithinRadius(
      userLatitude: _currentLocation!.latitude!,
      userLongitude: _currentLocation!.longitude!,
      targetLatitude: pin.latitude,
      targetLongitude: pin.longitude,
      radiusInMeters: radiusInMeters,
    );
  }

  Future<void> refreshPins() async {
    await loadPins();
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
