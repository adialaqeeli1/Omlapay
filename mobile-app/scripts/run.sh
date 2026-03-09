#!/bin/bash

# Navigate to the directory where the script is located (scripts folder)
cd "$(dirname "$0")"
# Navigate up to the project root
cd ..

# Defaults
MODE="debug"
BUILD_ONLY=false
GEN_ICONS=false

# Parse arguments
for arg in "$@"
do
    case $arg in
        --release)
        MODE="release"
        shift
        ;;
        --debug)
        MODE="debug"
        shift
        ;;
        --build-only)
        BUILD_ONLY=true
        shift
        ;;
        --icons)
        GEN_ICONS=true
        shift
        ;;
    esac
done

echo "=========================================="
echo "🚀 OmlaPay Mobile App Runner"
echo "=========================================="

# 1. Clean Project
echo "🧹 Running flutter clean..."
flutter clean
if [ $? -ne 0 ]; then
    echo "❌ Error: flutter clean failed"
    exit 1
fi

# 2. Install dependencies
echo "📦 Running flutter pub get..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Error: flutter pub get failed"
    exit 1
fi

# 3. Generate App Icons (Optional)
if [ "$GEN_ICONS" = true ]; then
    echo "🎨 Generating App Icons..."
    dart run flutter_launcher_icons
    if [ $? -ne 0 ]; then
        echo "❌ Error: Icon generation failed"
        exit 1
    fi
fi

# 4. Generate localizations
echo "🌍 Running flutter gen-l10n..."
flutter gen-l10n
if [ $? -ne 0 ]; then
    echo "❌ Error: flutter gen-l10n failed"
    exit 1
fi

# 5. Generate Freeze/JSON Models
echo "❄️  Running build_runner for Freezed/JSON..."
dart run build_runner build --delete-conflicting-outputs
if [ $? -ne 0 ]; then
    echo "❌ Error: build_runner failed"
    exit 1
fi

# 6. Set App name
echo "❄️  Running rename_app..."
dart run rename_app:main all="OmlaPay"
if [ $? -ne 0 ]; then
    echo "❌ Error: rename_app failed"
    exit 1
fi

# 7. Run the app (Skip if --build-only)
if [ "$BUILD_ONLY" = true ]; then
    echo "✅ Build setup complete. Ready for IDE launch."
    exit 0
fi

echo "📱 Running app in $MODE mode..."
flutter run --$MODE
