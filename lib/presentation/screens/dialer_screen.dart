import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/telephony/sip_service.dart';
import 'call_screen.dart';

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  String _enteredNumber = '';
  final SipService _sipService = SipService();
  final double _walletBalance = 500.00; // In-app prepaid balance

  final List<Map<String, String>> _keys = const [
    {'digit': '1', 'sub': ''},
    {'digit': '2', 'sub': 'ABC'},
    {'digit': '3', 'sub': 'DEF'},
    {'digit': '4', 'sub': 'GHI'},
    {'digit': '5', 'sub': 'JKL'},
    {'digit': '6', 'sub': 'MNO'},
    {'digit': '7', 'sub': 'PQRS'},
    {'digit': '8', 'sub': 'TUV'},
    {'digit': '9', 'sub': 'WXYZ'},
    {'digit': '*', 'sub': ''},
    {'digit': '0', 'sub': '+'},
    {'digit': '#', 'sub': ''},
  ];

  void _onKeyPress(String digit) {
    HapticFeedback.lightImpact();
    _sipService.sendDTMF(digit);
    setState(() {
      _enteredNumber += digit;
    });
  }

  void _onBackspace() {
    if (_enteredNumber.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _enteredNumber = _enteredNumber.substring(0, _enteredNumber.length - 1);
      });
    }
  }

  void _initiateCall() async {
    if (_enteredNumber.trim().isEmpty) return;

    HapticFeedback.mediumImpact();
    // Auto format Bangladesh 01XXXXXXXXX -> +8801XXXXXXXXX
    String finalNumber = _enteredNumber.trim();
    if (finalNumber.startsWith('01') && finalNumber.length == 11) {
      finalNumber = '+88$finalNumber';
    }

    final success = await _sipService.makeCall(finalNumber);
    if (mounted && success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(calleeNumber: finalNumber),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'DDialer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          // Prepaid Wallet Chip
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 6),
                Text(
                  '৳ ${_walletBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Displayed Number
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _enteredNumber.isEmpty ? 'Enter Number' : _enteredNumber,
                style: TextStyle(
                  color: _enteredNumber.isEmpty ? Colors.white38 : Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            if (_enteredNumber.startsWith('01') && _enteredNumber.length >= 3)
              const Text(
                'Bangladesh Mobile (1-sec pulse tariff: ৳0.45/min)',
                style: TextStyle(color: Color(0xFF10B981), fontSize: 12),
              ),
            const Spacer(),
            // Keypad Grid
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _keys.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final key = _keys[index];
                  return InkWell(
                    onTap: () => _onKeyPress(key['digit']!),
                    onLongPress: key['digit'] == '0'
                        ? () => _onKeyPress('+')
                        : null,
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            key['digit']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (key['sub']!.isNotEmpty)
                            Text(
                              key['sub']!,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Call & Backspace Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(width: 48), // spacer
                  // Call Button
                  FloatingActionButton.large(
                    heroTag: 'btn_call',
                    onPressed: _initiateCall,
                    backgroundColor: const Color(0xFF10B981),
                    child: const Icon(Icons.call, color: Colors.white, size: 36),
                  ),
                  // Backspace Button
                  IconButton(
                    onPressed: _onBackspace,
                    icon: const Icon(Icons.backspace_outlined, color: Colors.white60, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
