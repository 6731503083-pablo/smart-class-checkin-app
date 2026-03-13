import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../models/check_in_record.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../widgets/animated_entry.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();

  final DateTime _timestamp = DateTime.now();
  Position? _position;
  String? _qrValue;
  int _moodBeforeClass = 3;
  bool _loadingLocation = false;
  bool _submitting = false;
  String? _locationMessage;
  bool _locationDeniedForever = false;
  bool _locationServiceDisabled = false;
  String? _cameraMessage;
  bool _cameraDeniedForever = false;
  String? _locationDisplay;

  static const List<_MoodChoice> _moodChoices = [
    _MoodChoice(value: 1, emoji: '😫', label: 'EXHAUSTED'),
    _MoodChoice(value: 2, emoji: '🧐', label: 'CURIOUS'),
    _MoodChoice(value: 3, emoji: '😊', label: 'READY'),
    _MoodChoice(value: 4, emoji: '⚡', label: 'FOCUSED'),
    _MoodChoice(value: 5, emoji: '🚀', label: 'INSPIRED'),
  ];

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    final result = await LocationService.tryGetCurrentPosition();
    if (!mounted) {
      return;
    }

    setState(() {
      _loadingLocation = false;
      _position = result.position;
      _locationMessage = result.errorMessage;
      _locationDeniedForever = result.permissionDeniedForever;
      _locationServiceDisabled = result.serviceDisabled;
      if (result.position == null) {
        _locationDisplay = null;
      }
    });

    if (result.position != null) {
      final display = await LocationService.toHumanReadable(result.position!);
      if (!mounted) {
        return;
      }
      setState(() {
        _locationDisplay = display;
      });
    }

    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!)),
      );
    }
  }

  Future<bool> _ensureCameraPermission() async {
    if (kIsWeb) {
      return true;
    }

    final status = await Permission.camera.status;
    if (!mounted) {
      return false;
    }

    if (status.isGranted) {
      setState(() {
        _cameraMessage = null;
        _cameraDeniedForever = false;
      });
      return true;
    }

    final requested = await Permission.camera.request();
    if (!mounted) {
      return false;
    }

    if (requested.isGranted) {
      setState(() {
        _cameraMessage = null;
        _cameraDeniedForever = false;
      });
      return true;
    }

    setState(() {
      _cameraDeniedForever = requested.isPermanentlyDenied;
      _cameraMessage = requested.isPermanentlyDenied
          ? 'Camera permission is blocked. Open settings to enable scanning.'
          : 'Camera permission is required to scan QR codes.';
    });

    return false;
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> _openPermissionSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> _scanQr() async {
    final cameraOk = await _ensureCameraPermission();
    if (!mounted || !cameraOk) {
      return;
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => const _QrScannerPage(),
      ),
    );

    if (!mounted || result == null || result.trim().isEmpty) {
      return;
    }

    setState(() {
      _qrValue = result.trim();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS location is required before submit.')),
      );
      return;
    }
    if (_qrValue == null || _qrValue!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code value is required before submit.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final record = CheckInRecord(
        id: const Uuid().v4(),
        createdAt: _timestamp.toIso8601String(),
        qrCodeValue: _qrValue!,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        previousTopic: _previousTopicController.text.trim(),
        expectedTopicToday: _expectedTopicController.text.trim(),
        moodBeforeClass: _moodBeforeClass,
      );

      await DatabaseService.instance.insertCheckIn(record);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in saved successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('dd MMM yyyy, h:mm a').format(_timestamp);

    return Scaffold(
      appBar: AppBar(title: const Text('Check-in (Before Class)')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AnimatedEntry(
              child: _SectionCard(
                title: 'Session Capture',
                child: Column(
                  children: [
                  if (_locationMessage != null) ...[
                    _PermissionNotice(
                      icon: Icons.location_off_rounded,
                      message: _locationMessage!,
                      tone: const Color(0xFF7C2D12),
                      background: const Color(0xFFFFEDD5),
                      actions: [
                        if (_locationServiceDisabled)
                          TextButton(
                            onPressed: _openLocationSettings,
                            child: const Text('Open Location'),
                          ),
                        if (_locationDeniedForever)
                          TextButton(
                            onPressed: _openPermissionSettings,
                            child: const Text('Open Settings'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_cameraMessage != null) ...[
                    _PermissionNotice(
                      icon: Icons.videocam_off_rounded,
                      message: _cameraMessage!,
                      tone: const Color(0xFF1E3A8A),
                      background: const Color(0xFFDBEAFE),
                      actions: [
                        if (_cameraDeniedForever)
                          TextButton(
                            onPressed: _openAppSettings,
                            child: const Text('Open Settings'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.place_rounded,
                          size: 18,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _position == null
                              ? 'Location not captured yet'
                              : (_locationDisplay ?? 'Resolving location...'),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh location',
                        onPressed: _loadingLocation ? null : _captureLocation,
                        icon: _loadingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD7E3EC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place_rounded, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _position == null
                                ? 'Coordinates unavailable'
                                : '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD7E3EC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner_rounded, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _qrValue == null
                                ? 'No QR scanned yet'
                                : 'QR: $_qrValue',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _scanQr,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(90, 42),
                          ),
                          child: const Text('Scan'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
              ),
            const SizedBox(height: 12),
            AnimatedEntry(
              delay: const Duration(milliseconds: 80),
              child: _SectionCard(
                title: 'Reflection Before Class',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  _FormLabel(
                    label: 'Previous Class Topic',
                    child: TextFormField(
                      controller: _previousTopicController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Introduction to Macroeconomics',
                        fillColor: Color(0xFFBFDBFE),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Required field'
                              : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FormLabel(
                    label: 'Expected Topic Today',
                    child: TextFormField(
                      controller: _expectedTopicController,
                      decoration: const InputDecoration(
                        hintText: 'What are you excited to learn?',
                        fillColor: Color(0xFFBFDBFE),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Required field'
                              : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mood Before Class',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'How are you feeling intellectually today?',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: _moodChoices
                              .map(
                                (choice) => Expanded(
                                  child: _MoodChip(
                                    emoji: choice.emoji,
                                    label: choice.label,
                                    selected: _moodBeforeClass == choice.value,
                                    onTap: () {
                                      setState(() {
                                        _moodBeforeClass = choice.value;
                                      });
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
              ),
            const SizedBox(height: 18),
            AnimatedEntry(
              delay: const Duration(milliseconds: 140),
              child: FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Submit Check-in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFCD34D) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? const Color(0xFF92400E) : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodChoice {
  const _MoodChoice({
    required this.value,
    required this.emoji,
    required this.label,
  });

  final int value;
  final String emoji;
  final String label;
}

class _PermissionNotice extends StatelessWidget {
  const _PermissionNotice({
    required this.icon,
    required this.message,
    required this.tone,
    required this.background,
    this.actions = const [],
  });

  final IconData icon;
  final String message;
  final Color tone;
  final Color background;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: tone, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: tone, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(spacing: 6, children: actions),
            ),
        ],
      ),
    );
  }
}

class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage();

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  bool _found = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_found) {
            return;
          }
          final code =
              capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
          if (code == null || code.isEmpty) {
            return;
          }

          _found = true;
          Navigator.pop(context, code);
        },
      ),
    );
  }
}
