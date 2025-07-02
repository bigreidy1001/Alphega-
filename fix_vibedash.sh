#!/bin/bash

echo "🛠️ Fixing VibeDash Flutter dependencies..."

PROJECT_DIR=~/vibedash_project/vibedash_flutter

if [ ! -d "$PROJECT_DIR" ]; then
  echo "❌ Project directory not found: $PROJECT_DIR"
  exit 1
fi

cd "$PROJECT_DIR" || exit 1

# Backup the pubspec.yaml
cp pubspec.yaml pubspec.yaml.bak
echo "✅ Backed up pubspec.yaml"

# Clean and re-init dependencies
flutter clean

# Remove problematic packages
flutter pub remove flutter_audio_capture permission_handler fft flutter_fft

# Add the fixed packages
flutter pub add flutter_audio_capture:^1.1.11
flutter pub add permission_handler:^11.0.1
flutter pub add flutter_fft:^1.0.2+6

echo "📦 Dependencies updated!"

# Ensure Android permissions exist
MANIFEST="android/app/src/main/AndroidManifest.xml"
RECORD_PERMISSION='<uses-permission android:name="android.permission.RECORD_AUDIO"/>'

if grep -q "$RECORD_PERMISSION" "$MANIFEST"; then
  echo "🎤 Microphone permission already present"
else
  echo "🎤 Adding microphone permission to AndroidManifest.xml"
  sed -i "/<manifest/a \ \ \ \ $RECORD_PERMISSION" "$MANIFEST"
fi

# Set min SDK version to 21 if it's not already
BUILD_GRADLE="android/app/build.gradle"
if grep -q "minSdkVersion 21" "$BUILD_GRADLE"; then
  echo "📱 minSdkVersion already set to 21"
else
  echo "📱 Setting minSdkVersion to 21"
  sed -i 's/minSdkVersion .*/minSdkVersion 21/' "$BUILD_GRADLE"
fi

# Final dependency get
flutter pub get

echo "🚀 All done. You can now run:"
echo ""
echo "    flutter run -d <your_device_id>"
echo ""
echo "or to list devices:"
echo "    flutter devices"

