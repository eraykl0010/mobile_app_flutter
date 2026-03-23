import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Konum izni kontrolü ve isteme
  static Future<bool> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  /// Mevcut konumu al (tek seferlik)
  static Future<Position?> getCurrentPosition() async {
    if (!await ensurePermission()) return null;
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Sahte konum kontrolü
  static bool isMockLocation(Position position) {
    return position.isMocked;
  }
}
