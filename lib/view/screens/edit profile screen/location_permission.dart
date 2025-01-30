import 'package:geolocator/geolocator.dart';

Future<bool> _checkLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return false;  // If location services are not enabled
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
      return false;  // If permission is denied permanently
    }
  }
  return true;  // If permission is granted
}
