// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum SipConnectionStatus {
  unregistered,
  connecting,
  registered,
  failed,
}

class RtpQualityStats {
  final int latencyMs;
  final double jitterMs;
  final double packetLossPercent;
  final int signalBars;
  final double mosScore;
  final String audioCodec;

  const RtpQualityStats({
    required this.latencyMs,
    required this.jitterMs,
    required this.packetLossPercent,
    required this.signalBars,
    required this.mosScore,
    this.audioCodec = 'Opus HD 48kHz',
  });
}

class SipService implements SipUaHelperListener {
  static final SipService _instance = SipService._internal();
  factory SipService() => _instance;

  final SIPUAHelper _helper = SIPUAHelper();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SipConnectionStatus _status = SipConnectionStatus.unregistered;
  Call? _currentCall;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isOnHold = false;
  Timer? _rtpStatsTimer;

  final _statusController = StreamController<SipConnectionStatus>.broadcast();
  final _callStateController = StreamController<CallState>.broadcast();
  final _rtpQualityController = StreamController<RtpQualityStats>.broadcast();

  Stream<SipConnectionStatus> get statusStream => _statusController.stream;
  Stream<CallState> get callStateStream => _callStateController.stream;
  Stream<RtpQualityStats> get rtpQualityStream => _rtpQualityController.stream;

  SipConnectionStatus get status => _status;
  Call? get currentCall => _currentCall;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isOnHold => _isOnHold;

  SipService._internal() {
    _helper.addSipUaHelperListener(this);
  }

  /// Initialize and configure SIP User Agent for FreeSWITCH
  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  /// Register SIP Account (Supports FreeSWITCH WSS port 5066 or UDP 5060)
  Future<void> register({
    required String domain,
    required String extension,
    required String password,
    int port = 5066,
    String transport = 'WSS',
    String? displayName,
  }) async {
    _updateStatus(SipConnectionStatus.connecting);

    // Save credentials securely in Android KeyStore
    await _storage.write(key: 'sip_domain', value: domain);
    await _storage.write(key: 'sip_extension', value: extension);
    await _storage.write(key: 'sip_password', value: password);
    await _storage.write(key: 'sip_port', value: port.toString());
    await _storage.write(key: 'sip_transport', value: transport);

    final String wsUri = transport == 'WSS'
        ? 'wss://$domain:$port'
        : 'ws://$domain:$port';

    final UaSettings settings = UaSettings();
    settings.webSocketUrl = wsUri;
    settings.webSocketSettings.allowBadCertificate = true; // For self-signed lab testbeds
    settings.uri = 'sip:$extension@$domain';
    settings.authorizationUser = extension;
    settings.password = password;
    settings.displayName = displayName ?? 'DDialer User';
    settings.userAgent = 'DDialer-Android-1.0 (TargetSDK 34)';
    settings.dtmfMode = DtmfMode.RFC2833;

    try {
      _helper.start(settings);
    } catch (e) {
      debugPrint('SIP Registration start error: $e');
      _updateStatus(SipConnectionStatus.failed);
    }
  }

  /// Unregister from Softswitch
  void unregister() {
    _helper.unregister(true);
    _helper.stop();
    _updateStatus(SipConnectionStatus.unregistered);
  }

  /// Make Outbound Call
  Future<bool> makeCall(String targetNumber) async {
    if (_status != SipConnectionStatus.registered) {
      debugPrint('Cannot make call: SIP is not registered');
      return false;
    }

    // Auto prepend +88 for Bangladesh numbers if needed
    String dialTarget = targetNumber.trim();
    if (dialTarget.startsWith('01') && dialTarget.length == 11) {
      dialTarget = '+88$dialTarget';
    }

    try {
      final success = await _helper.call(
        dialTarget,
        voiceOnly: true,
      );
      return success;
    } catch (e) {
      debugPrint('Error placing SIP call: $e');
      return false;
    }
  }

  /// Answer incoming call
  void answerCall() {
    if (_currentCall != null) {
      _currentCall!.answer(_helper.buildCallOptions(true));
    }
  }

  /// Decline / Hang up call
  void hangup() {
    if (_currentCall != null) {
      _currentCall!.hangup();
      _currentCall = null;
    }
    _resetCallState();
  }

  /// Toggle Audio Mute
  void toggleMute() {
    if (_currentCall == null) return;
    _isMuted = !_isMuted;
    _currentCall!.mute(true, _isMuted);
  }

  /// Toggle Speakerphone vs Earpiece
  Future<void> toggleSpeakerphone() async {
    _isSpeakerOn = !_isSpeakerOn;
    final session = await AudioSession.instance;
    if (_isSpeakerOn) {
      await session.setSpeakerphoneOn(true);
    } else {
      await session.setSpeakerphoneOn(false);
    }
  }

  /// Hold / Resume Call
  void toggleHold() {
    if (_currentCall == null) return;
    if (_isOnHold) {
      _currentCall!.unhold();
      _isOnHold = false;
    } else {
      _currentCall!.hold();
      _isOnHold = true;
    }
  }

  /// Send DTMF tone for IVR navigation (0-9, *, #)
  void sendDTMF(String tone) {
    if (_currentCall != null) {
      _currentCall!.sendDTMF(tone);
    }
  }

  /// Blind Transfer (SIP REFER RFC 3515)
  void blindTransfer(String targetExtension) {
    if (_currentCall != null) {
      _currentCall!.refer(targetExtension);
    }
  }

  /// Attended Transfer
  void attendedTransfer(String targetExtension) {
    if (_currentCall != null) {
      toggleHold();
      makeCall(targetExtension);
    }
  }

  void _resetCallState() {
    _isMuted = false;
    _isSpeakerOn = false;
    _isOnHold = false;
  }

  void _updateStatus(SipConnectionStatus newStatus) {
    _status = newStatus;
    _statusController.add(_status);
  }

  // --- SipUaHelperListener Callbacks ---

  @override
  void registrationStateChanged(RegistrationState state) {
    debugPrint('SIP Registration State: ${state.state}');
    switch (state.state) {
      case RegistrationStateEnum.REGISTERED:
        _updateStatus(SipConnectionStatus.registered);
        break;
      case RegistrationStateEnum.REGISTRATION_FAILED:
        _updateStatus(SipConnectionStatus.failed);
        break;
      case RegistrationStateEnum.UNREGISTERED:
        _updateStatus(SipConnectionStatus.unregistered);
        break;
      default:
        break;
    }
  }

  @override
  void callStateChanged(Call call, CallState state) {
    _currentCall = call;
    _callStateController.add(state);

    if (state.state == CallStateEnum.ENDED ||
        state.state == CallStateEnum.FAILED) {
      _currentCall = null;
      _resetCallState();
    }
  }

  @override
  void transportStateChanged(TransportState state) {
    debugPrint('SIP Transport State: ${state.state}');
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void onNewNotify(Notify ntf) {}
}
