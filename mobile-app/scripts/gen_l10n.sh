#!/bin/bash

# Navigate to the directory where the script is located (scripts folder)
cd "$(dirname "$0")"
# Navigate up to the project root
cd ..

echo "=========================================="
echo "🌍 Generating Localizations Only"
echo "=========================================="

echo "🌍 Running flutter gen-l10n..."
flutter gen-l10n
if [ $? -ne 0 ]; then
    echo "❌ Error: flutter gen-l10n failed"
    exit 1
fi

echo "✅ Localization generation complete!"
