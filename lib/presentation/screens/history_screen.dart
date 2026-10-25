import 'package:flutter/material.dart';
import '../../core/telephony/sip_service.dart';
import 'call_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeFilter = 'All';

  // Sample Call Detail Records with 1-sec pulse billing
  final List<Map<String, dynamic>> _cdrs = [
    {
      'number': '+8801711998877',
      'name': 'Rafiqul Islam',
      'type': 'outbound',
      'duration': 142, // seconds
      'cost': '৳ 1.07',
      'time': '10:45 AM',
    },
    {
      'number': '+8801819223344',
      'name': 'Tanvir Ahmed',
      'type': 'inbound',
      'duration': 310,
      'cost': 'Free',
      'time': 'Yesterday',
    },
    {
      'number': '+8801911334455',
      'name': 'Nasrin Sultana',
      'type': 'missed',
      'duration': 0,
      'cost': '৳ 0.00',
      'time': '2 days ago',
    },
    {
      'number': '9196',
      'name': 'FreeSWITCH Echo Test',
      'type': 'outbound',
      'duration': 45,
      'cost': '৳ 0.34',
      'time': '3 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _cdrs.where((cdr) {
      if (_activeFilter == 'All') return true;
      if (_activeFilter == 'Missed') return cdr['type'] == 'missed';
      if (_activeFilter == 'Inbound') return cdr['type'] == 'inbound';
      if (_activeFilter == 'Outbound') return cdr['type'] == 'outbound';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Call Logs (CDRs)', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Missed', 'Inbound', 'Outbound'].map((tab) {
                final isSelected = _activeFilter == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tab),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _activeFilter = tab),
                    backgroundColor: const Color(0xFF1E293B),
                    selectedColor: const Color(0xFFF43F5E),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final cdr = filtered[index];
                return ListTile(
                  leading: Icon(
                    cdr['type'] == 'missed'
                        ? Icons.call_missed
                        : cdr['type'] == 'inbound'
                            ? Icons.call_received
                            : Icons.call_made,
                    color: cdr['type'] == 'missed'
                        ? const Color(0xFFF43F5E)
                        : const Color(0xFF10B981),
                  ),
                  title: Text(
                    cdr['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${cdr['number']} · ${cdr['duration']}s · ${cdr['cost']}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.call, color: Color(0xFF10B981)),
                    onPressed: () {
                      SipService().makeCall(cdr['number']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CallScreen(calleeNumber: cdr['number']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
