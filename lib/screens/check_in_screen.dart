import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../models/check_in_record.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in (Before Class)')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Timestamp: ${_timestamp.toLocal()}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _position == null
                        ? 'GPS: not captured'
                        : 'GPS: ${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
                  ),
                ),
                IconButton(
                  onPressed: _loadingLocation ? null : _captureLocation,
                  icon: _loadingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('QR Code'),
                subtitle: Text(_qrValue ?? 'No QR scanned yet'),
                trailing: FilledButton(
                  onPressed: _scanQr,
                  child: const Text('Scan'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _previousTopicController,
              decoration: const InputDecoration(
                labelText: 'Previous class topic',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required field' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _expectedTopicController,
              decoration: const InputDecoration(
                labelText: 'Expected topic for today',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required field' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _moodBeforeClass,
              decoration: const InputDecoration(
                labelText: 'Mood before class',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 - Very negative')),
                DropdownMenuItem(value: 2, child: Text('2 - Negative')),
                DropdownMenuItem(value: 3, child: Text('3 - Neutral')),
                DropdownMenuItem(value: 4, child: Text('4 - Positive')),
                DropdownMenuItem(value: 5, child: Text('5 - Very positive')),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _moodBeforeClass = value;
                });
              },
              validator: (value) {
                if (value == null || value < 1 || value > 5) {
                  return 'Mood must be between 1 and 5';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
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
