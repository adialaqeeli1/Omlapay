#!/bin/bash

# Navigate to the directory where the script is located (scripts folder)
cd "$(dirname "$0")"
# Navigate up to the project root
cd ..

echo "=========================================="
echo "🎨 Generating App Icons"
echo "=========================================="

echo "🎨 Running flutter_launcher_icons..."
dart run flutter_launcher_icons

if [ $? -ne 0 ]; then
    echo "❌ Error: Icon generation failed"
    exit 1
fi

echo "✅ Icon generation complete!"
