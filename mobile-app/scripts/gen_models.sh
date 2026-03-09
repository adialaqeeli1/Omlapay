#!/bin/bash

# Navigate to the directory where the script is located (scripts folder)
cd "$(dirname "$0")"
# Navigate up to the project root
cd ..

echo "=========================================="
echo "❄️  Generating Models (Freezed/JSON)"
echo "=========================================="

echo "❄️  Running build_runner..."
dart run build_runner build --delete-conflicting-outputs

if [ $? -ne 0 ]; then
    echo "❌ Error: build_runner failed"
    exit 1
fi

echo "✅ Model generation complete!"
