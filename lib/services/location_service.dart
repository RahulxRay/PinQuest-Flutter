import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final Location _location = Location();

  // Check and request location permissions
  static Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    // Check if location permissions are granted
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  // Get current location
  static Future<LocationData?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        throw Exception('Location permission not granted');
      }

      final locationData = await _location.getLocation();
      return locationData;
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  // Get location stream for real-time updates
  static Stream<LocationData> getLocationStream() {
    return _location.onLocationChanged;
  }

  // Calculate distance between two points using Geolocator
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Check if user is within a certain radius of a location (in meters)
  static bool isWithinRadius({
    required double userLatitude,
    required double userLongitude,
    required double targetLatitude,
    required double targetLongitude,
    required double radiusInMeters,
  }) {
    final distance = calculateDistance(
      startLatitude: userLatitude,
      startLongitude: userLongitude,
      endLatitude: targetLatitude,
      endLongitude: targetLongitude,
    );
    
    return distance <= radiusInMeters;
  }

  // Get bearing between two points
  static double calculateBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  // Check if location services are available
  static Future<bool> isLocationServiceEnabled() async {
    return await _location.serviceEnabled();
  }

  // Get location permission status
  static Future<PermissionStatus> getPermissionStatus() async {
    return await _location.hasPermission();
  }
}
