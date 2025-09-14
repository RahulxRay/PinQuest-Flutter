class AppConfig {
  static const String appName = 'PinQuest';
  static const String appVersion = '1.0.0';
  
  // Map Configuration
  static const double defaultZoom = 15.0;
  static const double maxZoom = 20.0;
  static const double minZoom = 3.0;
  
  // Pin Configuration
  static const int maxPinsPerUser = 1000;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi'];
  
  // Gamification
  static const int pointsPerCheckIn = 10;
  static const int pointsPerPinCreation = 25;
  static const int pointsPerTrailCompletion = 100;
  
  // Categories
  static const List<String> pinCategories = [
    'Restaurant',
    'Tourist Attraction',
    'Shopping',
    'Entertainment',
    'Outdoor',
    'Historical',
    'Art & Culture',
    'Sports',
    'Business',
    'Other'
  ];
  
  // Database
  static const String localDbName = 'pinquest_local.db';
  static const int localDbVersion = 1;
}
