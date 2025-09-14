# PinQuest

A comprehensive location-based discovery app with gamification features built with Flutter.

## Features

### 🗺️ Map & Location
- Interactive Google Maps integration with clustered pins
- Real-time location tracking
- Nearby location discovery
- Location-based check-ins with proximity validation

### 📍 Pin Management
- Create pins with photos/videos using device camera or gallery
- Rich pin details with categories, descriptions, and tags
- Sponsored pins with special perks and promotions
- Offline caching of pin data and media

### 🎯 Trails System
- Create and follow curated trails (collections of pins)
- Track progress on trails with completion percentages
- Difficulty levels: Easy, Medium, Hard, Expert
- Public and private trail sharing

### 🏆 Gamification
- Points system for check-ins, pin creation, and trail completion
- Badge system with multiple categories and rarity levels
- User profile with stats dashboard
- Achievement tracking and progress visualization

### 👥 User System
- Email/password and Google OAuth authentication
- User profiles with avatar and stats
- Sponsor accounts with special privileges
- Activity timeline and progress tracking

### 📱 Modern UI/UX
- Material Design 3 guidelines
- Clean, responsive interface
- Dark and light theme support
- Smooth animations and transitions

### 🔧 Technical Features
- State management with Provider
- Local storage with Hive and SQLite
- Offline support with cached data
- Clean architecture with separated concerns
- Cross-platform (Android & iOS)

## Project Structure

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart         # App configuration constants
│   └── theme/
│       └── app_theme.dart          # Material Design 3 theme
├── models/
│   ├── user_model.dart             # User data model
│   ├── pin_model.dart              # Pin and sponsor info models
│   ├── trail_model.dart            # Trail model with difficulty enum
│   └── badge_model.dart            # Badge system models
├── providers/
│   ├── auth_provider.dart          # Authentication state management
│   ├── user_provider.dart          # User data and gamification
│   ├── pin_provider.dart           # Pin management and location
│   └── trail_provider.dart         # Trail management
├── services/
│   ├── auth_service.dart           # Firebase Auth integration
│   ├── location_service.dart       # Location and GPS handling
│   └── local_storage_service.dart  # Hive database operations
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart      # App initialization screen
│   │   ├── login_screen.dart       # Login with email/Google
│   │   └── register_screen.dart    # User registration
│   ├── main/
│   │   └── main_screen.dart        # Main navigation with bottom bar
│   ├── map/
│   │   └── map_screen.dart         # Interactive map view
│   ├── pins/
│   │   ├── create_pin_screen.dart  # Pin creation with media
│   │   └── pin_detail_screen.dart  # Pin details and check-in
│   ├── trails/
│   │   ├── trails_screen.dart      # Trail discovery and management
│   │   └── trail_detail_screen.dart # Trail details and progress
│   └── profile/
│       └── profile_screen.dart     # User dashboard and badges
├── widgets/
│   └── pin_cluster_widget.dart     # Map pin clustering widget
└── main.dart                       # App entry point
```

## Dependencies

### Core Dependencies
- `flutter`: Flutter SDK
- `provider`: State management
- `firebase_core` & `firebase_auth`: Authentication
- `google_sign_in`: Google OAuth
- `google_maps_flutter`: Maps integration
- `location` & `geolocator`: GPS and location services

### Storage & Caching
- `hive` & `hive_flutter`: Local NoSQL database
- `sqflite`: SQLite database
- `cached_network_image`: Image caching

### Media & UI
- `image_picker`: Camera and gallery access
- `cupertino_icons`: iOS-style icons
- `shimmer`: Loading animations
- `lottie`: Advanced animations

### Utilities
- `http` & `dio`: Network requests
- `path_provider`: File system paths
- `uuid`: Unique ID generation
- `intl`: Internationalization

## Getting Started

### Prerequisites
1. Flutter SDK (3.16.0 or higher)
2. Firebase project setup
3. Google Maps API key
4. Android Studio / VS Code

### Installation

1. **Clone and setup**
   ```bash
   git clone <repository-url>
   cd pinquest
   flutter pub get
   ```

2. **Firebase Configuration**
   - Create a Firebase project
   - Enable Authentication (Email/Password and Google)
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place in respective platform directories

3. **Google Maps Setup**
   - Get API key from Google Cloud Console
   - Enable Maps SDK for Android/iOS
   - Add key to `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data android:name="com.google.android.geo.API_KEY"
                android:value="YOUR_API_KEY"/>
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Mock Data

The app includes comprehensive mock data:
- **Pins**: 6 sample locations in San Francisco
- **Trails**: 4 curated trails with different difficulties
- **Badges**: 10 achievement badges with various requirements

Mock data is automatically loaded on first app launch.

## Key Features Implementation

### Authentication Flow
- Splash screen with app initialization
- Login/Register with email or Google OAuth
- Persistent authentication state
- Password reset functionality

### Map Integration
- Google Maps with custom markers
- Pin clustering for better performance
- Current location tracking
- Category-based filtering
- Distance calculation and formatting

### Gamification System
- Points: 10 for check-ins, 25 for pin creation, 100 for trail completion
- Automatic badge awarding based on achievements
- Progress tracking with visual indicators
- User stats dashboard

### Offline Support
- Local caching with Hive database
- Offline pin and trail data
- Image caching for offline viewing
- Sync when connection restored

### Sponsor System
- Special sponsor account type
- Sponsored pins with custom perks
- Perk redemption with codes
- Visual highlighting of sponsored content

## Architecture

The app follows clean architecture principles:

- **Models**: Data structures with Hive serialization
- **Services**: External API integration and business logic
- **Providers**: State management with ChangeNotifier
- **Screens**: UI components with separation of concerns
- **Core**: Configuration, themes, and shared utilities

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow Flutter/Dart style guidelines
4. Add tests for new features
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the mock data examples

---

**PinQuest** - Discover, Explore, Achieve!
