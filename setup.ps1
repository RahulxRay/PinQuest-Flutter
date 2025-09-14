# PinQuest Setup Script for Windows PowerShell
# This script helps set up the PinQuest Flutter project

Write-Host "🚀 Setting up PinQuest Flutter Project" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Flutter found" -ForegroundColor Green
        Write-Host "📱 Flutter version: $($flutterVersion[0])" -ForegroundColor Cyan
    } else {
        throw "Flutter not found"
    }
} catch {
    Write-Host "❌ Flutter is not installed. Please install Flutter first:" -ForegroundColor Red
    Write-Host "   https://docs.flutter.dev/get-started/install" -ForegroundColor Yellow
    exit 1
}

# Clean and get dependencies
Write-Host "📦 Getting Flutter dependencies..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Generate Hive adapters
Write-Host "🔄 Generating Hive adapters..." -ForegroundColor Yellow
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check for Firebase configuration
Write-Host "🔥 Checking Firebase configuration..." -ForegroundColor Yellow
if (-not (Test-Path "android\app\google-services.json")) {
    Write-Host "⚠️  Warning: google-services.json not found in android\app\" -ForegroundColor Yellow
    Write-Host "   Please download it from your Firebase project console" -ForegroundColor Yellow
}

if (-not (Test-Path "ios\Runner\GoogleService-Info.plist")) {
    Write-Host "⚠️  Warning: GoogleService-Info.plist not found in ios\Runner\" -ForegroundColor Yellow
    Write-Host "   Please download it from your Firebase project console" -ForegroundColor Yellow
}

# Check for Google Maps API key
Write-Host "🗺️  Checking Google Maps configuration..." -ForegroundColor Yellow
if (Select-String -Path "android\app\src\main\AndroidManifest.xml" -Pattern "YOUR_GOOGLE_MAPS_API_KEY_HERE" -Quiet) {
    Write-Host "⚠️  Warning: Google Maps API key not configured" -ForegroundColor Yellow
    Write-Host "   Please replace 'YOUR_GOOGLE_MAPS_API_KEY_HERE' in AndroidManifest.xml" -ForegroundColor Yellow
}

# Analyze project
Write-Host "🔍 Running Flutter analyze..." -ForegroundColor Yellow
flutter analyze

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Configure Firebase:" -ForegroundColor White
Write-Host "   - Download google-services.json and place in android\app\" -ForegroundColor Gray
Write-Host "   - Download GoogleService-Info.plist and place in ios\Runner\" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Configure Google Maps:" -ForegroundColor White
Write-Host "   - Get API key from Google Cloud Console" -ForegroundColor Gray
Write-Host "   - Replace 'YOUR_GOOGLE_MAPS_API_KEY_HERE' in android\app\src\main\AndroidManifest.xml" -ForegroundColor Gray
Write-Host "   - Add the key to ios\Runner\Info.plist if needed" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Run the app:" -ForegroundColor White
Write-Host "   flutter run" -ForegroundColor Gray
Write-Host ""
Write-Host "🎉 Happy coding with PinQuest!" -ForegroundColor Green
