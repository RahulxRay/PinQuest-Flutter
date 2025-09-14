import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/pin_model.dart';
import '../models/trail_model.dart';
import '../models/badge_model.dart';

class LocalStorageService {
  static const String userBox = 'users';
  static const String pinBox = 'pins';
  static const String trailBox = 'trails';
  static const String badgeBox = 'badges';
  static const String settingsBox = 'settings';

  static Future<void> initializeHive() async {
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PinModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SponsorInfoAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TrailModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TrailDifficultyAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(BadgeModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(BadgeCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(BadgeRarityAdapter());
    }

    // Open boxes
    await Hive.openBox<UserModel>(userBox);
    await Hive.openBox<PinModel>(pinBox);
    await Hive.openBox<TrailModel>(trailBox);
    await Hive.openBox<BadgeModel>(badgeBox);
    await Hive.openBox(settingsBox);
  }

  // User operations
  static Box<UserModel> get _userBox => Hive.box<UserModel>(userBox);
  
  static Future<void> saveUser(UserModel user) async {
    await _userBox.put(user.id, user);
  }

  static UserModel? getUser(String userId) {
    return _userBox.get(userId);
  }

  static Future<void> deleteUser(String userId) async {
    await _userBox.delete(userId);
  }

  static List<UserModel> getAllUsers() {
    return _userBox.values.toList();
  }

  // Pin operations
  static Box<PinModel> get _pinBox => Hive.box<PinModel>(pinBox);
  
  static Future<void> savePin(PinModel pin) async {
    await _pinBox.put(pin.id, pin);
  }

  static PinModel? getPin(String pinId) {
    return _pinBox.get(pinId);
  }

  static Future<void> deletePin(String pinId) async {
    await _pinBox.delete(pinId);
  }

  static List<PinModel> getAllPins() {
    return _pinBox.values.toList();
  }

  static List<PinModel> getPinsByCategory(String category) {
    return _pinBox.values.where((pin) => pin.category == category).toList();
  }

  static List<PinModel> getPinsByUser(String userId) {
    return _pinBox.values.where((pin) => pin.createdBy == userId).toList();
  }

  // Trail operations
  static Box<TrailModel> get _trailBox => Hive.box<TrailModel>(trailBox);
  
  static Future<void> saveTrail(TrailModel trail) async {
    await _trailBox.put(trail.id, trail);
  }

  static TrailModel? getTrail(String trailId) {
    return _trailBox.get(trailId);
  }

  static Future<void> deleteTrail(String trailId) async {
    await _trailBox.delete(trailId);
  }

  static List<TrailModel> getAllTrails() {
    return _trailBox.values.toList();
  }

  static List<TrailModel> getPublicTrails() {
    return _trailBox.values.where((trail) => trail.isPublic).toList();
  }

  static List<TrailModel> getTrailsByUser(String userId) {
    return _trailBox.values.where((trail) => trail.createdBy == userId).toList();
  }

  // Badge operations
  static Box<BadgeModel> get _badgeBox => Hive.box<BadgeModel>(badgeBox);
  
  static Future<void> saveBadge(BadgeModel badge) async {
    await _badgeBox.put(badge.id, badge);
  }

  static BadgeModel? getBadge(String badgeId) {
    return _badgeBox.get(badgeId);
  }

  static List<BadgeModel> getAllBadges() {
    return _badgeBox.values.toList();
  }

  // Settings operations
  static Box get _settingsBox => Hive.box(settingsBox);
  
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  static Future<void> clearAllData() async {
    await _userBox.clear();
    await _pinBox.clear();
    await _trailBox.clear();
    await _badgeBox.clear();
    await _settingsBox.clear();
  }
}
