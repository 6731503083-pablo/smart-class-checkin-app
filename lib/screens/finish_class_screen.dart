import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../models/finish_class_record.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learnedTodayController = TextEditingController();
  final _feedbackController = TextEditingController();

  final DateTime _timestamp = DateTime.now();
  Position? _position;
  String? _qrValue;
  bool _loadingLocation = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  @override
  void dispose() {
    _learnedTodayController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    try {
      final pos = await LocationService.getCurrentPosition();
      if (!mounted) {
        return;
      }
      setState(() {
        _position = pos;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  Future<void> _scanQr() async {
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
      final record = FinishClassRecord(
        id: const Uuid().v4(),
        createdAt: _timestamp.toIso8601String(),
        qrCodeValue: _qrValue!,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        learnedToday: _learnedTodayController.text.trim(),
        classFeedback: _feedbackController.text.trim(),
      );

      await DatabaseService.instance.insertFinishClass(record);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish Class saved successfully.')),
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
    final formattedTime = DateFormat('dd MMM yyyy, HH:mm').format(_timestamp);

    return Scaffold(
      appBar: AppBar(title: const Text('Finish Class (After Class)')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _SectionCard(
              title: 'Session Capture',
              child: Column(
                children: [
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
                              ? 'GPS not captured yet'
                              : '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
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
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Reflection After Class',
              child: Column(
                children: [
                  TextFormField(
                    controller: _learnedTodayController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'What I learned today',
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Required field'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Class or instructor feedback',
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Required field'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Submit Finish Class'),
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
