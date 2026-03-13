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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Class Check-in'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Welcome',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('Record your attendance and reflection for each class.'),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _openCheckIn,
              icon: const Icon(Icons.login),
              label: const Text('Start Check-in'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _openFinishClass,
              icon: const Icon(Icons.task_alt),
              label: const Text('Start Finish Class'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Records',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: _loadRecords,
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_recentRecords.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No records yet. Complete your first check-in.'),
                ),
              )
            else
              ..._recentRecords.map(
                (record) => Card(
                  child: ListTile(
                    leading: Icon(
                      record['type'] == 'Check-in'
                          ? Icons.login
                          : Icons.task_alt,
                    ),
                    title: Text(record['type'] ?? '-'),
                    subtitle: Text(
                      '${_formatDate(record['createdAt'] ?? '-')}\n${record['details'] ?? ''}',
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
