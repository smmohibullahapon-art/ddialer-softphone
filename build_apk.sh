#!/usr/bin/env bash
# ==============================================================================
# DDialer - 1-Click Android APK & AAB Builder
# Target: Android 16 (Target SDK 36, Version 2.0.0+2)
# ==============================================================================

set -e

echo "=== [1/5] Checking Flutter Environment ==="
flutter doctor -v

echo "=== [2/5] Cleaning & Fetching Dependencies ==="
flutter clean
flutter pub get

echo "=== [3/5] Setting up Keystore ==="
mkdir -p android/app
if [ ! -f "android/app/ddialer-release.jks" ]; then
  echo "Generating upload keystore..."
  keytool -genkey -v -keystore android/app/ddialer-release.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias ddialer-upload \
    -storepass ddialer123 -keypass ddialer123 \
    -dname "CN=DDialer Architect, OU=Telecom, O=DDialer Cloud, L=Dhaka, C=BD"
fi

cat <<EOF > android/key.properties
storePassword=ddialer123
keyPassword=ddialer123
keyAlias=ddialer-upload
storeFile=ddialer-release.jks
EOF

echo "=== [4/5] Building Android Universal Release APK ==="
flutter build apk --release

echo "=== [5/5] Building Architecture-Specific Split APKs (arm64-v8a, armeabi-v7a) ==="
flutter build apk --release --split-per-abi

echo ""
echo "✅ BUILD COMPLETE!"
echo "Your APK files are ready at:"
echo "👉 Universal APK: build/app/outputs/flutter-apk/app-release.apk"
echo "👉 64-bit ARM APK: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
echo "👉 32-bit ARM APK: build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
