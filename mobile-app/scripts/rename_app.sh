#!/bin/bash

# Navigate to the directory where the script is located (scripts folder)
cd "$(dirname "$0")"
# Navigate up to the project root
cd ..

echo "=========================================="
echo "🏷️  Renaming App"
echo "=========================================="

# Defaults
APP_NAME="OmlaPay"

# Check if an argument is provided
if [ ! -z "$1" ]; then
    APP_NAME="$1"
fi

echo "🏷️  Renaming app to: $APP_NAME"
dart run rename_app:main all="$APP_NAME"

if [ $? -ne 0 ]; then
    echo "❌ Error: rename_app failed"
    exit 1
fi

echo "✅ App renaming complete!"
