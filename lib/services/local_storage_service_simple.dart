import '../models/user_model.dart';
import '../models/pin_model.dart';
import '../models/trail_model.dart';
import '../models/badge_model.dart';

class LocalStorageServiceSimple {
  // Mock data storage
  static final Map<String, UserModel> _users = {};
  static final Map<String, PinModel> _pins = {};
  static final Map<String, TrailModel> _trails = {};
  static final Map<String, BadgeModel> _badges = {};
  static final Map<String, dynamic> _settings = {};

  static bool _isInitialized = false;

  static Future<void> initializeHive() async {
    if (_isInitialized) return;
    
    _initializeSampleData();
    _isInitialized = true;
  }

  static void _initializeSampleData() {
    // Sample pins
    final samplePins = [
      // NYC Landmarks
      PinModel(
        id: 'pin1',
        title: 'Central Park',
        description: 'Beautiful park in the heart of Manhattan with lakes, meadows, and walking paths',
        latitude: 40.7829,
        longitude: -73.9654,
        category: 'Nature',
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        imageUrls: const [],
        tags: const ['park', 'nature', 'walking'],
        isSponsored: false,
        checkInCount: 1247,
        rating: 4.8,
      ),
      PinModel(
        id: 'pin2',
        title: 'Times Square',
        description: 'Famous commercial intersection and tourist destination with bright lights and billboards',
        latitude: 40.7580,
        longitude: -73.9855,
        category: 'Landmark',
        createdBy: 'user2',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        imageUrls: const [],
        tags: const ['landmark', 'tourist', 'lights'],
        isSponsored: true,
        sponsorInfo: SponsorInfo(
          companyName: 'NYC Tourism',
          companyLogo: '',
          perkTitle: 'Tourist Discount',
          perkDescription: 'Get 10% off tours',
        ),
        checkInCount: 2834,
        rating: 4.2,
      ),
      PinModel(
        id: 'pin3',
        title: 'Brooklyn Bridge',
        description: 'Historic suspension bridge connecting Manhattan and Brooklyn with stunning city views',
        latitude: 40.7061,
        longitude: -73.9969,
        category: 'Landmark',
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        imageUrls: const [],
        tags: const ['bridge', 'history', 'architecture'],
        isSponsored: false,
        checkInCount: 892,
        rating: 4.7,
      ),
      PinModel(
        id: 'pin4',
        title: 'Joe\'s Pizza',
        description: 'Authentic New York style pizza slice - a local favorite since 1975',
        latitude: 40.7505,
        longitude: -73.9934,
        category: 'Restaurant',
        createdBy: 'user3',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        imageUrls: const [],
        tags: const ['pizza', 'food', 'casual'],
        isSponsored: false,
        checkInCount: 445,
        rating: 4.5,
      ),
      PinModel(
        id: 'pin5',
        title: 'High Line Park',
        description: 'Elevated linear park built on former railway line with gardens and art installations',
        latitude: 40.7480,
        longitude: -74.0048,
        category: 'Nature',
        createdBy: 'user2',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        imageUrls: const [],
        tags: const ['park', 'walkway', 'urban'],
        isSponsored: false,
        checkInCount: 634,
        rating: 4.6,
      ),
      // More diverse locations
      PinModel(
        id: 'pin6',
        title: 'Statue of Liberty',
        description: 'Iconic symbol of freedom and democracy on Liberty Island',
        latitude: 40.6892,
        longitude: -74.0445,
        category: 'Landmark',
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        imageUrls: const [],
        tags: const ['landmark', 'history', 'freedom'],
        isSponsored: true,
        sponsorInfo: SponsorInfo(
          companyName: 'National Park Service',
          companyLogo: '',
          perkTitle: 'Early Access Tours',
          perkDescription: 'Skip the line with advance booking',
        ),
        checkInCount: 1567,
        rating: 4.9,
      ),
      PinModel(
        id: 'pin7',
        title: 'The Metropolitan Museum',
        description: 'World-class art museum with collections spanning 5,000 years',
        latitude: 40.7794,
        longitude: -73.9632,
        category: 'Education',
        createdBy: 'user4',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        imageUrls: const [],
        tags: const ['museum', 'art', 'culture'],
        isSponsored: false,
        checkInCount: 789,
        rating: 4.8,
      ),
      PinModel(
        id: 'pin8',
        title: 'Chelsea Market',
        description: 'Indoor food hall and shopping mall in a former factory building',
        latitude: 40.7420,
        longitude: -74.0065,
        category: 'Shopping',
        createdBy: 'user3',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        imageUrls: const [],
        tags: const ['food', 'shopping', 'market'],
        isSponsored: false,
        checkInCount: 523,
        rating: 4.4,
      ),
      PinModel(
        id: 'pin9',
        title: 'Bryant Park',
        description: 'Charming park behind the NY Public Library with seasonal activities',
        latitude: 40.7536,
        longitude: -73.9832,
        category: 'Nature',
        createdBy: 'user2',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        imageUrls: const [],
        tags: const ['park', 'events', 'reading'],
        isSponsored: false,
        checkInCount: 312,
        rating: 4.5,
      ),
      PinModel(
        id: 'pin10',
        title: 'One World Observatory',
        description: 'Breathtaking 360-degree views from the top of One World Trade Center',
        latitude: 40.7127,
        longitude: -74.0134,
        category: 'Entertainment',
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        imageUrls: const [],
        tags: const ['views', 'observatory', 'skyscraper'],
        isSponsored: true,
        sponsorInfo: SponsorInfo(
          companyName: 'One World Observatory',
          companyLogo: '',
          perkTitle: 'Skip-the-Line Tickets',
          perkDescription: '15% off express elevator tickets',
        ),
        checkInCount: 945,
        rating: 4.7,
      ),
      PinModel(
        id: 'pin11',
        title: 'Katz\'s Delicatessen',
        description: 'Historic Jewish deli famous for pastrami sandwiches since 1888',
        latitude: 40.7223,
        longitude: -73.9877,
        category: 'Restaurant',
        createdBy: 'user5',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        imageUrls: const [],
        tags: const ['deli', 'pastrami', 'historic'],
        isSponsored: false,
        checkInCount: 678,
        rating: 4.6,
      ),
      PinModel(
        id: 'pin12',
        title: 'Prospect Park',
        description: 'Brooklyn\'s premier park designed by the creators of Central Park',
        latitude: 40.6602,
        longitude: -73.9690,
        category: 'Nature',
        createdBy: 'user4',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        imageUrls: const [],
        tags: const ['park', 'brooklyn', 'outdoor'],
        isSponsored: false,
        checkInCount: 287,
        rating: 4.5,
      ),
      PinModel(
        id: 'pin13',
        title: 'Coney Island',
        description: 'Historic amusement area with beach, boardwalk, and iconic rides',
        latitude: 40.5755,
        longitude: -73.9707,
        category: 'Adventure',
        createdBy: 'user3',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        imageUrls: const [],
        tags: const ['amusement', 'beach', 'historic'],
        isSponsored: false,
        checkInCount: 456,
        rating: 4.2,
      ),
      PinModel(
        id: 'pin14',
        title: 'Broadway Theatre District',
        description: 'The heart of American theater with world-class shows and musicals',
        latitude: 40.7590,
        longitude: -73.9845,
        category: 'Entertainment',
        createdBy: 'user2',
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
        imageUrls: const [],
        tags: const ['theater', 'broadway', 'shows'],
        isSponsored: true,
        sponsorInfo: SponsorInfo(
          companyName: 'Broadway League',
          companyLogo: '',
          perkTitle: 'Show Discounts',
          perkDescription: 'Up to 30% off select performances',
        ),
        checkInCount: 1123,
        rating: 4.8,
      ),
      PinModel(
        id: 'pin15',
        title: 'Stone Street Historic District',
        description: 'Charming cobblestone streets with outdoor dining and historic architecture',
        latitude: 40.7041,
        longitude: -74.0112,
        category: 'Landmark',
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        imageUrls: const [],
        tags: const ['historic', 'dining', 'cobblestone'],
        isSponsored: false,
        checkInCount: 189,
        rating: 4.3,
      ),
    ];

    for (final pin in samplePins) {
      _pins[pin.id] = pin;
    }

    // Sample trails
    final sampleTrails = [
      TrailModel(
        id: 'trail1',
        title: 'Manhattan Discovery Trail',
        description: 'Explore the best landmarks in Manhattan',
        difficulty: TrailDifficulty.easy,
        estimatedDuration: 180, // 3 hours in minutes
        pinIds: ['pin1', 'pin2', 'pin3'],
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        tags: const ['manhattan', 'landmarks', 'walking'],
        isPublic: true,
      ),
      TrailModel(
        id: 'trail2',
        title: 'Food Lover\'s Journey',
        description: 'Best eats in the city',
        difficulty: TrailDifficulty.medium,
        estimatedDuration: 240, // 4 hours in minutes
        pinIds: ['pin4'],
        createdBy: 'user3',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: const ['food', 'restaurants'],
        isPublic: true,
      ),
    ];

    for (final trail in sampleTrails) {
      _trails[trail.id] = trail;
    }

    // Sample badges
    final sampleBadges = [
      BadgeModel(
        id: 'badge1',
        title: 'Explorer',
        description: 'Visit 5 different pins',
        iconPath: 'assets/icons/explore.png',
        category: BadgeCategory.explorer,
        rarity: BadgeRarity.common,
        requiredAction: 'Visit 5 pins',
        requiredPoints: 50,
      ),
      BadgeModel(
        id: 'badge2',
        title: 'Trail Blazer',
        description: 'Complete your first trail',
        iconPath: 'assets/icons/trail.png',
        category: BadgeCategory.achievement,
        rarity: BadgeRarity.uncommon,
        requiredAction: 'Complete 1 trail',
        requiredPoints: 100,
      ),
    ];

    for (final badge in sampleBadges) {
      _badges[badge.id] = badge;
    }
  }

  // User operations
  static Future<void> saveUser(UserModel user) async {
    _users[user.id] = user;
  }

  static UserModel? getUser(String userId) {
    return _users[userId];
  }

  static Future<void> deleteUser(String userId) async {
    _users.remove(userId);
  }

  static List<UserModel> getAllUsers() {
    return _users.values.toList();
  }

  // Pin operations
  static Future<void> savePin(PinModel pin) async {
    _pins[pin.id] = pin;
  }

  static PinModel? getPin(String pinId) {
    return _pins[pinId];
  }

  static Future<void> deletePin(String pinId) async {
    _pins.remove(pinId);
  }

  static List<PinModel> getAllPins() {
    return _pins.values.toList();
  }

  static List<PinModel> getPinsByCategory(String category) {
    return _pins.values.where((pin) => pin.category == category).toList();
  }

  static List<PinModel> getPinsByUser(String userId) {
    return _pins.values.where((pin) => pin.createdBy == userId).toList();
  }

  // Trail operations
  static Future<void> saveTrail(TrailModel trail) async {
    _trails[trail.id] = trail;
  }

  static TrailModel? getTrail(String trailId) {
    return _trails[trailId];
  }

  static Future<void> deleteTrail(String trailId) async {
    _trails.remove(trailId);
  }

  static List<TrailModel> getAllTrails() {
    return _trails.values.toList();
  }

  static List<TrailModel> getTrailsByUser(String userId) {
    return _trails.values.where((trail) => trail.createdBy == userId).toList();
  }

  static List<TrailModel> getPublicTrails() {
    return _trails.values.where((trail) => trail.isPublic).toList();
  }

  // Badge operations
  static Future<void> saveBadge(BadgeModel badge) async {
    _badges[badge.id] = badge;
  }

  static BadgeModel? getBadge(String badgeId) {
    return _badges[badgeId];
  }

  static List<BadgeModel> getAllBadges() {
    return _badges.values.toList();
  }

  static List<BadgeModel> getBadgesByCategory(BadgeCategory category) {
    return _badges.values.where((badge) => badge.category == category).toList();
  }

  // Settings operations
  static Future<void> saveSetting(String key, dynamic value) async {
    _settings[key] = value;
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return _settings[key] as T? ?? defaultValue;
  }

  static Future<void> deleteSetting(String key) async {
    _settings.remove(key);
  }

  static Map<String, dynamic> getAllSettings() {
    return Map.from(_settings);
  }

  // Utility methods
  static Future<void> clearAllData() async {
    _users.clear();
    _pins.clear();
    _trails.clear();
    _badges.clear();
    _settings.clear();
  }

  static int getUserCount() => _users.length;
  static int getPinCount() => _pins.length;
  static int getTrailCount() => _trails.length;
  static int getBadgeCount() => _badges.length;
}
