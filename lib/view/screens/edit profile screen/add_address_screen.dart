import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class GoogleMapScreen extends StatelessWidget {
  const GoogleMapScreen({super.key});

  Future<String?> _getCurrentLocation() async {
    // Fetch the current location (for initial position)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && 
          permission != LocationPermission.always) return null;
    }

    Position position = await Geolocator.getCurrentPosition();
    return "${position.latitude},${position.longitude}";
  }

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    try {
      // Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude, 
        latLng.longitude
      );
      Placemark placemark = placemarks[0];
      
      // Build address string, handling null values
      // String locality = placemark.locality ?? '';
      String street = placemark.street ?? '';
      // String adminArea = placemark.administrativeArea ?? '';
      String thoroughFare = placemark.thoroughfare ?? '';
      // String country = placemark.country ?? '';
      
      return [street, thoroughFare]
          .where((element) => element.isNotEmpty)
          .join(", ");
    } catch (e) {
      return "Unknown Location";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Address'),
      ),
      body: FutureBuilder<String?>(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error fetching location'));
          }

          final initialPosition = snapshot.data!;
          List<String> latLng = initialPosition.split(",");
          final lat = double.parse(latLng[0]);
          final lng = double.parse(latLng[1]);

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, lng),
              zoom: 14,
            ),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: (LatLng tappedLocation) async {
              String address = await _getAddressFromLatLng(tappedLocation);
              Navigator.pop(context, address);
            },
          );
        },
      ),
    );
  }
}