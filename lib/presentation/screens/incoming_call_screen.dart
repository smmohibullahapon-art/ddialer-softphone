import 'package:flutter/material.dart';
import '../../core/telephony/sip_service.dart';
import 'call_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callerNumber;
  final String callerName;

  const IncomingCallScreen({
    super.key,
    required this.callerNumber,
    this.callerName = 'Incoming FreeSWITCH Call',
  });

  @override
  Widget build(BuildContext context) {
    final sipService = SipService();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF070D18),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                'INCOMING CALL',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF1E293B),
                child: const Icon(Icons.person, size: 54, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                callerNumber,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              // Slide or Accept / Decline Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Decline
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'btn_decline',
                          backgroundColor: const Color(0xFFF43F5E),
                          onPressed: () {
                            sipService.hangup();
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.call_end, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text('Decline', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    // Accept
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'btn_accept',
                          backgroundColor: const Color(0xFF10B981),
                          onPressed: () {
                            sipService.answerCall();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CallScreen(
                                  calleeNumber: callerNumber,
                                  calleeName: callerName,
                                ),
                              ),
                            );
                          },
                          child: const Icon(Icons.call, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text('Accept', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
