#!/bin/bash

# Navigate to the directory where the script is located (scripts folder)
cd "$(dirname "$0")"
# Navigate up to the project root
cd ..

# Defaults
MODE="release"
VERSION_ARG=""

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
        --version=*)
        VERSION_ARG="${arg#*=}"
        shift
        ;;
    esac
done

# --- Version handling ---
PUBSPEC="pubspec.yaml"
CURRENT_VERSION=$(grep -E '^version:' "$PUBSPEC" | sed 's/version: //')
CURRENT_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
CURRENT_BUILD=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)
NEW_BUILD=$((CURRENT_BUILD + 1))

if [ -n "$VERSION_ARG" ]; then
    NEW_VERSION="${VERSION_ARG}+${NEW_BUILD}"
else
    NEW_VERSION="${CURRENT_NAME}+${NEW_BUILD}"
fi

# Update pubspec.yaml
sed -i '' "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"
echo "Version updated: $CURRENT_VERSION -> $NEW_VERSION"

echo "=========================================="
echo "OmlaPay APK Builder ($MODE) - v${NEW_VERSION}"
echo "=========================================="

# 1. Clean Project
echo "Running flutter clean..."
flutter clean
if [ $? -ne 0 ]; then
    echo "Error: flutter clean failed"
    exit 1
fi

# 2. Install dependencies
echo "Running flutter pub get..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "Error: flutter pub get failed"
    exit 1
fi

# 3. Generate Localizations
echo "Running gen_l10n.sh..."
bash "$(dirname "$0")/gen_l10n.sh"
if [ $? -ne 0 ]; then
    echo "Error: gen_l10n.sh failed"
    exit 1
fi

# 4. Generate Models
echo "Running gen_models.sh..."
bash "$(dirname "$0")/gen_models.sh"
if [ $? -ne 0 ]; then
    echo "Error: gen_models.sh failed"
    exit 1
fi

# 5. Generate Icons
echo "Running gen_icons.sh..."
bash "$(dirname "$0")/gen_icons.sh"
if [ $? -ne 0 ]; then
    echo "Error: gen_icons.sh failed"
    exit 1
fi

# 6. Rename App
echo "Running rename_app.sh..."
bash "$(dirname "$0")/rename_app.sh"
if [ $? -ne 0 ]; then
    echo "Error: rename_app.sh failed"
    exit 1
fi

# 7. Build APK
echo "Building APK in $MODE mode..."
flutter build apk --$MODE
if [ $? -ne 0 ]; then
    echo "Error: flutter build apk failed"
    exit 1
fi

echo "=========================================="
echo "APK build ($MODE) completed successfully!"
echo "=========================================="
