import 'package:geolocator/geolocator.dart';

/// A position from the phone's GPS and how accurate it is, in metres.
class GpsFix {
  const GpsFix({required this.lat, required this.lng, required this.accuracyM});

  final double lat;
  final double lng;
  final double accuracyM;
}

enum LocationFailure { servicesOff, denied, deniedForever, failed }

class LocationException implements Exception {
  const LocationException(this.failure);

  final LocationFailure failure;

  @override
  String toString() => 'LocationException($failure)';
}

abstract class LocationService {
  /// Where the phone is now. Throws [LocationException] with the reason when it cannot say.
  Future<GpsFix> currentFix();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<GpsFix> currentFix() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationException(LocationFailure.servicesOff);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const LocationException(LocationFailure.denied);
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(LocationFailure.deniedForever);
      }
      final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      return GpsFix(lat: p.latitude, lng: p.longitude, accuracyM: p.accuracy);
    } on LocationException {
      rethrow;
    } catch (_) {
      throw const LocationException(LocationFailure.failed);
    }
  }
}
