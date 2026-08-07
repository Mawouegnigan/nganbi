import 'package:geolocator/geolocator.dart';

class LocalisationService {
  static const double latitudeParDefaut = 6.3654;
  static const double longitudeParDefaut = 2.4183;

  static Future<(double, double)> obtenirPosition() async {
    try {
      final permissionAccordee = await _verifierPermission();
      if (!permissionAccordee) {
        return (latitudeParDefaut, longitudeParDefaut);
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return (position.latitude, position.longitude);
    } catch (_) {
      return (latitudeParDefaut, longitudeParDefaut);
    }
  }

  static Future<bool> _verifierPermission() async {
    final serviceActif = await Geolocator.isLocationServiceEnabled();
    if (!serviceActif) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return false;
    }
    return true;
  }
}