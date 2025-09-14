#!/bin/bash

# PinQuest Setup Script
# This script helps set up the PinQuest Flutter project

echo "🚀 Setting up PinQuest Flutter Project"
echo "======================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found"

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
echo "📱 Flutter version: $FLUTTER_VERSION"

# Clean and get dependencies
echo "📦 Getting Flutter dependencies..."
flutter clean
flutter pub get

# Generate Hive adapters
echo "🔄 Generating Hive adapters..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check for Firebase configuration
echo "🔥 Checking Firebase configuration..."
if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️  Warning: google-services.json not found in android/app/"
    echo "   Please download it from your Firebase project console"
fi

if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  Warning: GoogleService-Info.plist not found in ios/Runner/"
    echo "   Please download it from your Firebase project console"
fi

# Check for Google Maps API key
echo "🗺️  Checking Google Maps configuration..."
if grep -q "YOUR_GOOGLE_MAPS_API_KEY_HERE" android/app/src/main/AndroidManifest.xml; then
    echo "⚠️  Warning: Google Maps API key not configured"
    echo "   Please replace 'YOUR_GOOGLE_MAPS_API_KEY_HERE' in AndroidManifest.xml"
fi

# Analyze project
echo "🔍 Running Flutter analyze..."
flutter analyze

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Configure Firebase:"
echo "   - Download google-services.json and place in android/app/"
echo "   - Download GoogleService-Info.plist and place in ios/Runner/"
echo ""
echo "2. Configure Google Maps:"
echo "   - Get API key from Google Cloud Console"
echo "   - Replace 'YOUR_GOOGLE_MAPS_API_KEY_HERE' in android/app/src/main/AndroidManifest.xml"
echo "   - Add the key to ios/Runner/Info.plist if needed"
echo ""
echo "3. Run the app:"
echo "   flutter run"
echo ""
echo "🎉 Happy coding with PinQuest!"
