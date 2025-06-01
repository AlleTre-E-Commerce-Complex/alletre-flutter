import 'package:alletre_app/utils/location_maps.dart';

class Location {
  final int id;
  final String address;
  final double lat;
  final double lng;
  final String phone;
  final String addressLabel;
  final String city;
  final String country;

  Location({
    required this.id,
    required this.address,
    required this.lat,
    required this.lng,
    required this.phone,
    required this.addressLabel,
    required this.city,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as int,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      phone: json['phone'] as String,
      addressLabel: json['addressLabel'] as String,
      city: json['city']['nameEn'] as String,
      country: json['country']['nameEn'] as String,
    );
  }
  factory Location.fromIds({
    required int id,
    required int? cityId,
    required int? countryId,
    String address = '',
    String addressLabel = '',
  }) {
    return Location(
      id: id,
      address: address,
      lat: 0.0,
      lng: 0.0,
      phone: '',
      addressLabel: addressLabel,
      city: cityIdToName[cityId] ?? '',
      country: countryIdToName[countryId] ?? '',
    );
  }
}
