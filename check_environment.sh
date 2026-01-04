#!/bin/bash

echo "Checking environment for Coach Life app..."

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
echo "Flutter: $FLUTTER_VERSION"

# Check if flutterfire is installed
if command -v flutterfire &> /dev/null; then
  echo "✅ FlutterFire CLI: Installed"
else
  echo "❌ FlutterFire CLI: Not installed"
  echo "   Run: dart pub global activate flutterfire_cli"
fi

# Check CocoaPods version (for iOS)
if command -v pod &> /dev/null; then
  POD_VERSION=$(pod --version)
  echo "✅ CocoaPods: $POD_VERSION"
else
  echo "❌ CocoaPods: Not installed"
  echo "   Required for iOS builds"
fi

# Check for Xcode (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    echo "✅ $XCODE_VERSION"
  else
    echo "❌ Xcode: Not installed"
    echo "   Required for iOS builds"
  fi
else
  echo "⚠️ Not on macOS - iOS builds will not be possible"
fi

echo "Environment check complete."
