#!/bin/bash

# R.T. Lapeña DTR App Build Script

echo "🏗️  R.T. Lapeña Construction DTR App Setup"
echo "==========================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "   Please install Flutter first: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Navigate to project directory
cd "$(dirname "$0")"

echo ""
echo "📦 Installing dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo ""
echo "🔧 Running Flutter doctor..."
flutter doctor

echo ""
echo "🚀 Setup complete! You can now run:"
echo "   flutter run                    # Run in debug mode"
echo "   flutter build apk --release    # Build Android APK"
echo "   flutter build ios --release    # Build iOS (Mac only)"

echo ""
echo "📱 App Features:"
echo "   • Local SQLite storage"
echo "   • Camera integration for photos"
echo "   • PDF export functionality"
echo "   • Photo annotation with drawing"
echo "   • Offline operation"

echo ""
echo "🎯 Ready to build construction reports!"
