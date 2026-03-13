import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/database_service.dart';
import 'check_in_screen.dart';
import 'finish_class_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<Map<String, String>> _recentRecords = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _loading = true;
    });

    final records = await DatabaseService.instance.getRecentRecords(limit: 10);
    if (!mounted) {
      return;
    }

    setState(() {
      _recentRecords = records;
      _loading = false;
    });
  }

  String _formatDate(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) {
      return isoDate;
    }
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  Future<void> _openCheckIn() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const CheckInScreen()),
    );
    _loadRecords();
  }

  Future<void> _openFinishClass() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const FinishClassScreen()),
    );
    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Class Check-in')),
      body: Stack(
        children: [
          const _BackdropShapes(),
          RefreshIndicator(
            onRefresh: _loadRecords,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _HeroCard(
                  onCheckIn: _openCheckIn,
                  onFinishClass: _openFinishClass,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Records',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadRecords,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_recentRecords.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Icon(Icons.inbox_rounded, color: Color(0xFF64748B)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No records yet. Complete your first check-in.',
                              style: TextStyle(color: Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._recentRecords.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: record['type'] == 'Check-in'
                                  ? const Color(0xFFCFFAFE)
                                  : const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              record['type'] == 'Check-in'
                                  ? Icons.login_rounded
                                  : Icons.task_alt_rounded,
                              color: record['type'] == 'Check-in'
                                  ? const Color(0xFF0E7490)
                                  : const Color(0xFFC2410C),
                            ),
                          ),
                          title: Text(
                            record['type'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${_formatDate(record['createdAt'] ?? '-')}\n${record['details'] ?? ''}',
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropShapes extends StatelessWidget {
  const _BackdropShapes();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0x66A7F3D0), Color(0x33BAE6FD)],
                ),
              ),
            ),
          ),
          Positioned(
            left: -70,
            top: 220,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0x44FDBA74), Color(0x11FB923C)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onCheckIn, required this.onFinishClass});

  final VoidCallback onCheckIn;
  final VoidCallback onFinishClass;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E7490), Color(0xFF155E75)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33155E75),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome',
            style: TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Capture attendance and reflections in one smooth flow.',
            style: TextStyle(color: Color(0xFFE0F2FE), height: 1.4),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCheckIn,
            icon: const Icon(Icons.login_rounded),
            label: const Text('Start Check-in'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0E7490),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onFinishClass,
            icon: const Icon(Icons.task_alt_rounded),
            label: const Text('Start Finish Class'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0x80FFFFFF)),
            ),
          ),
        ],
      ),
    );
  }
}
