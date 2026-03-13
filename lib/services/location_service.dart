import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:http/http.dart' as http;

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
  static Future<String> toHumanReadable(Position position) async {
    const fallbackText = 'Approximate area (city unavailable)';

    try {
      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final area = <String?>[
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
        ]
            .where((part) => part != null && part.trim().isNotEmpty)
            .cast<String>()
            .toList();

        final country = (place.country ?? '').trim();
        final localityText = area.take(2).join(', ');

        if (localityText.isNotEmpty && country.isNotEmpty) {
          return '$localityText, $country';
        }
        if (localityText.isNotEmpty) {
          return localityText;
        }
        if (country.isNotEmpty) {
          return country;
        }
      }
    } catch (_) {
      // Try HTTP fallback below.
    }

    try {
      final uri = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client'
        '?latitude=${position.latitude}'
        '&longitude=${position.longitude}'
        '&localityLanguage=en',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final locality = (body['city'] ?? body['locality'] ?? body['principalSubdivision'] ?? '')
            .toString()
            .trim();
        final subdivision = (body['principalSubdivision'] ?? '').toString().trim();
        final country = (body['countryName'] ?? '').toString().trim();

        final parts = <String>[];
        if (locality.isNotEmpty) {
          parts.add(locality);
        }
        if (subdivision.isNotEmpty && subdivision != locality) {
          parts.add(subdivision);
        }
        if (country.isNotEmpty) {
          parts.add(country);
        }

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
    } catch (_) {
      // Fall back below.
    }

    try {
      final uri = Uri.parse(
        'https://geocode.maps.co/reverse'
        '?lat=${position.latitude}'
        '&lon=${position.longitude}'
        '&format=jsonv2',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final address = (body['address'] as Map<String, dynamic>? ?? const {});
        final city = (address['city'] ??
                address['town'] ??
                address['village'] ??
                address['municipality'] ??
                '')
            .toString()
            .trim();
        final state = (address['state'] ?? address['county'] ?? '').toString().trim();
        final country = (address['country'] ?? '').toString().trim();

        final parts = <String>[];
        if (city.isNotEmpty) {
          parts.add(city);
        }
        if (state.isNotEmpty && state != city) {
          parts.add(state);
        }
        if (country.isNotEmpty) {
          parts.add(country);
        }

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
    } catch (_) {
      // Fall back below.
    }

    return fallbackText;
  }

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
