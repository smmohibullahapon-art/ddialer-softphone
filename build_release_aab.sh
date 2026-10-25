#!/usr/bin/env bash
# ==============================================================================
# DDialer - Production Android App Bundle (.AAB) Build Script
# Target: Google Play Store (Target SDK 36, Version 2.0.0+2)
# Package: xyz.ddialer.app
# ==============================================================================

set -e

echo "=== [1/5] Verifying Flutter and Dart Environment ==="
flutter --version
dart --version

echo "=== [2/5] Cleaning and Fetching Dependencies ==="
flutter clean
flutter pub get

echo "=== [3/5] Verifying Keystore Configuration ==="
KEYSTORE_PATH="android/app/ddialer-release.jks"
KEY_PROPERTIES="android/key.properties"

if [ ! -f "$KEYSTORE_PATH" ]; then
  echo "Generating standard Play Store upload keystore..."
  keytool -genkey -v -keystore "$KEYSTORE_PATH" \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias ddialer-upload \
    -storepass ddialer123 -keypass ddialer123 \
    -dname "CN=DDialer Architect, OU=Telecom, O=DDialer Cloud, L=Dhaka, C=BD"
fi

if [ ! -f "$KEY_PROPERTIES" ]; then
  cat <<EOF > "$KEY_PROPERTIES"
storePassword=ddialer123
keyPassword=ddialer123
keyAlias=ddialer-upload
storeFile=ddialer-release.jks
EOF
  echo "Created android/key.properties"
fi

echo "=== [4/5] Building Signed Android App Bundle (app-release.aab) [v2.0.0+2 / SDK 36] ==="
flutter build appbundle --release \
  --target-platform android-arm,android-arm64,android-x64 \
  --obfuscate --split-debug-info=build/app/outputs/symbols

echo "=== [5/5] Build Completed Successfully! ==="
echo "Artifact location:"
echo "👉 build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "Google Play Console Submission Steps (v2.0.0+2):"
echo "1. Go to Google Play Console: https://play.google.com/console"
echo "2. Create or select App: 'DDialer' (Package: xyz.ddialer.app)"
echo "3. Under Production -> Releases, click 'Create new release'"
echo "4. Upload the generated 'app-release.aab'"
echo "5. Complete Data Safety form: Declare Audio Record (Microphone for VoIP) and Foreground Service (Phone Call & Over-App Overlay)"
echo "6. Submit for review!"
