import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/database_service.dart';
import '../widgets/animated_entry.dart';
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
    return DateFormat('EEEE, MMM d • h:mm a').format(dt);
  }

  Future<void> _openCheckIn() async {
    await _openWithSlide(const CheckInScreen());
    _loadRecords();
  }

  Future<void> _openFinishClass() async {
    await _openWithSlide(const FinishClassScreen());
    _loadRecords();
  }

  Future<void> _openWithSlide(Widget page) async {
    await Navigator.push<void>(
      context,
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const AnimatedEntry(child: _TopIdentityRow()),
            const SizedBox(height: 18),
            const AnimatedEntry(
              delay: Duration(milliseconds: 40),
              child: Text(
                'DASHBOARD',
                style: TextStyle(
                  letterSpacing: 1.1,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedEntry(
              delay: const Duration(milliseconds: 80),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 40,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  children: [
                    TextSpan(text: 'Welcome back,\n'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            AnimatedEntry(
              delay: const Duration(milliseconds: 120),
              child: _ActionCard(
                title: 'Check-in to Class',
                description: 'Scan campus QR or enter room code to register presence.',
                icon: Icons.login_rounded,
                backgroundGradient: const [Color(0xFF021B3A), Color(0xFF042E57)],
                textColor: Colors.white,
                buttonLabel: 'Begin Now',
                buttonFilled: true,
                onTap: _openCheckIn,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedEntry(
              delay: const Duration(milliseconds: 170),
              child: _ActionCard(
                title: 'Finish Current Class',
                description: 'Currently in: Advanced Macroeconomics (Room 402)',
                icon: Icons.logout_rounded,
                backgroundGradient: const [Color(0xFFC7DDF6), Color(0xFFB8D3F1)],
                textColor: const Color(0xFF0F172A),
                buttonLabel: 'End Session',
                buttonFilled: false,
                onTap: _openFinishClass,
              ),
            ),
            const SizedBox(height: 18),
            AnimatedEntry(
              delay: const Duration(milliseconds: 220),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextButton(onPressed: _loadRecords, child: const Text('View All')),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_recentRecords.isEmpty)
              const AnimatedEntry(
                delay: Duration(milliseconds: 260),
                child: _EmptyActivityCard(),
              )
            else
              ..._recentRecords.take(5).toList().asMap().entries.map(
                (entry) => AnimatedEntry(
                  delay: Duration(milliseconds: 260 + (entry.key * 50)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ActivityRow(
                      title: entry.value['details'] ?? '-',
                      subtitle: _formatDate(entry.value['createdAt'] ?? '-'),
                      verified: entry.value['type'] == 'Check-in',
                      icon: entry.value['type'] == 'Check-in'
                          ? Icons.meeting_room_rounded
                          : Icons.menu_book_rounded,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopIdentityRow extends StatelessWidget {
  const _TopIdentityRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFFFED7AA),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 18, color: Color(0xFF78350F)),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'University Connect',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        const Icon(Icons.notifications_rounded, size: 20, color: Color(0xFF334155)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundGradient,
    required this.textColor,
    required this.buttonLabel,
    required this.buttonFilled,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Color> backgroundGradient;
  final Color textColor;
  final String buttonLabel;
  final bool buttonFilled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundGradient,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 26),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 34,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.82),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (buttonFilled)
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                minimumSize: const Size(132, 44),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
              ),
              child: Text('$buttonLabel  ->'),
            )
          else
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                minimumSize: const Size(132, 44),
                backgroundColor: const Color(0xFF082F5B),
                foregroundColor: Colors.white,
              ),
              child: Text(buttonLabel),
            ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.title,
    required this.subtitle,
    required this.verified,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final bool verified;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            verified ? 'VERIFIED' : 'PENDING',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: verified ? const Color(0xFF14532D) : const Color(0xFF78716C),
            ),
          ),
        ],
      ),
    );
  }
}


class _EmptyActivityCard extends StatelessWidget {
  const _EmptyActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'No records yet. Complete your first check-in.',
        style: TextStyle(color: Color(0xFF475569)),
      ),
    );
  }
}
