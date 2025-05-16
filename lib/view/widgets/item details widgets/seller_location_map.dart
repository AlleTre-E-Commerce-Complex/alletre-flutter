import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SellerLocationMap extends StatelessWidget {
  final double lat;
  final double lng;
  final String? label;

  const SellerLocationMap({
    super.key,
    required this.lat,
    required this.lng,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final CameraPosition initialPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14.5,
    );

    return SizedBox(
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GoogleMap(
          initialCameraPosition: initialPosition,
          markers: {
            Marker(
              markerId: const MarkerId('seller_location'),
              position: LatLng(lat, lng),
              infoWindow: label != null ? InfoWindow(title: label) : InfoWindow.noText,
            ),
          },
          zoomControlsEnabled: true,
          myLocationButtonEnabled: false,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
        ),
      ),
    );
  }
}
