import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/telephony/sip_service.dart';
import 'presentation/screens/dialer_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SipService().initialize();
  runApp(const ProviderScope(child: DDialerApp()));
}

class DDialerApp extends StatelessWidget {
  const DDialerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DDialer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070D18),
        primaryColor: const Color(0xFFF43F5E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF43F5E),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const MainTabNavigator(),
    );
  }
}

class MainTabNavigator extends StatefulWidget {
  const MainTabNavigator({super.key});

  @override
  State<MainTabNavigator> createState() => _MainTabNavigatorState();
}

class _MainTabNavigatorState extends State<MainTabNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DialerScreen(),
    HistoryScreen(),
    LoginScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkBtrcComplianceAndPermissions();
  }

  Future<void> _checkBtrcComplianceAndPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasAgreed = prefs.getBool('btrc_compliance_accepted') ?? false;

    if (!hasAgreed && mounted) {
      _showBtrcComplianceDialog(prefs);
    } else {
      _requestAndroid14Permissions();
    }
  }

  void _showBtrcComplianceDialog(SharedPreferences prefs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text(
              'Regulatory Compliance',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'DDialer is a white-label SIP softphone compliant with BTRC (Bangladesh Telecommunication Regulatory Commission) statutory guidelines and Google Play Store policies.\n\n'
            '1. Call Recording: Audio is strictly routed through authorized SIP softswitch cores.\n'
            '2. Privacy: Encrypted credentials stored locally using Android KeyStore.\n'
            '3. Foreground Service: Microphone & phone call background service are used solely while in an active VoIP call.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () async {
              await prefs.setBool('btrc_compliance_accepted', true);
              if (mounted) Navigator.pop(context);
              _requestAndroid14Permissions();
            },
            child: const Text(
              'I Agree & Continue',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestAndroid14Permissions() async {
    await [
      Permission.microphone,
      Permission.notification,
      Permission.contacts,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: const Color(0xFFF43F5E).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dialpad, color: Colors.white70),
            selectedIcon: Icon(Icons.dialpad, color: Color(0xFFF43F5E)),
            label: 'Keypad',
          ),
          NavigationDestination(
            icon: Icon(Icons.history, color: Colors.white70),
            selectedIcon: Icon(Icons.history, color: Color(0xFFF43F5E)),
            label: 'Recents',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings, color: Colors.white70),
            selectedIcon: Icon(Icons.settings, color: Color(0xFFF43F5E)),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
