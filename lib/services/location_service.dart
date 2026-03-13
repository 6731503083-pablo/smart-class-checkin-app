import 'package:geolocator/geolocator.dart';

class LocationAccessResult {
  const LocationAccessResult({
    this.position,
    this.errorMessage,
    this.permissionDenied = false,
    this.permissionDeniedForever = false,
    this.serviceDisabled = false,
  });

  final Position? position;
  final String? errorMessage;
  final bool permissionDenied;
  final bool permissionDeniedForever;
  final bool serviceDisabled;

  bool get hasError => errorMessage != null;
}

class LocationService {
  static Future<LocationAccessResult> tryGetCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationAccessResult(
        errorMessage: 'Location services are disabled.',
        serviceDisabled: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const LocationAccessResult(
        errorMessage: 'Location permission denied.',
        permissionDenied: true,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationAccessResult(
        errorMessage: 'Location permission denied forever. Open settings to allow access.',
        permissionDeniedForever: true,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return LocationAccessResult(position: position);
    } catch (_) {
      return const LocationAccessResult(
        errorMessage: 'Could not retrieve GPS location. Please try again.',
      );
    }
  }

  static Future<Position> getCurrentPosition() async {
    final result = await tryGetCurrentPosition();
    if (result.position != null) {
      return result.position!;
    }
    throw Exception(result.errorMessage ?? 'Location unavailable.');
  }
}
