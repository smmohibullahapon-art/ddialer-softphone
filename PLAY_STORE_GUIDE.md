# Google Play Store Submission Guide for DDialer
**App Name:** DDialer (Cloud IP Phone)  
**Package:** `xyz.ddialer.app`  
**Target SDK:** 36 (Android 16) / **Version:** 2.0.0 (versionCode: 2)

---

## 1. Google Play Console Mandatory Declarations (SDK 36 / Version 2)

### A. Foreground Service Policy (Target SDK 36 Requirement)
Under **App Content -> Foreground Service Permissions**:
1. Select **`FOREGROUND_SERVICE_PHONE_CALL`**:
   - **Reason:** Real-time VoIP communication via SIP stack (RFC 3261). Maintains active audio session even when phone is locked or another app is open.
2. Select **`FOREGROUND_SERVICE_MICROPHONE`**:
   - **Reason:** Two-way WebRTC RTP audio transmission during phone conversations.
3. Select **`USE_FULL_SCREEN_INTENT`** and **`SYSTEM_ALERT_WINDOW`**:
   - **Reason:** Wakes phone on lock screen with full-screen incoming call UI, or displays floating heads-up banner when other apps are open.

### B. Always-On Background Execution (Doze Battery Exemption)
- Uses `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` and `RECEIVE_BOOT_COMPLETED` so the SIP UDP 5060 / WSS 5066 socket stays alive across device reboots and low-power Doze cycles.

### C. Build Release AAB Command
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Build Release AAB (Version 2 / SDK 36)
flutter build appbundle --release
```
Output bundle: `build/app/outputs/bundle/release/app-release.aab`
