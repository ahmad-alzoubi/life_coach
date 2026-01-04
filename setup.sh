#!/bin/bash

# Run environment check first
./check_environment.sh

echo "Setting up project dependencies..."

# Get Flutter packages
flutter pub get

# Clean iOS build if on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Setting up iOS environment..."
  cd ios
  rm -rf Pods Podfile.lock
  pod deintegrate
  pod setup
  pod install --repo-update
  cd ..
  
  # Configure Firebase if flutterfire is available
  if command -v flutterfire &> /dev/null; then
    echo "Configuring Firebase..."
    flutterfire configure
  else
    echo "⚠️ FlutterFire CLI not found, skipping Firebase configuration"
  fi
fi

echo "Setup complete!"
