# Proguard Rules for DDialer Softphone (Google Play Store Release)

# Flutter wrapper classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# WebRTC & Native JNI Media Engine (CRITICAL: Never strip audio codecs & SDP engines)
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**
-keepclasseswithmembers class * {
    native <methods>;
}

# SIP UA and WebSocket Stack
-keep class com.cloudwebrtc.webrtc.** { *; }
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Android 14 CallKit Incoming
-keep class com.hiennv.flutter_callkit_incoming.** { *; }

# Kotlin Coroutines and Reflection
-keepnames class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**
