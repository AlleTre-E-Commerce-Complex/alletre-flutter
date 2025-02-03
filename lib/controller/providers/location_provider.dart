import 'package:alletre_app/model/location_model.dart';
import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  
  final List<Location> _locations = [];
  List<Location> get locations => _locations;

  void updateCountry(String? country) {
    selectedCountry = country;
    notifyListeners();
  }

  void updateState(String? state) {
    selectedState = state;
    notifyListeners();
  }

  void updateCity(String? city) {
    selectedCity = city;
    notifyListeners();
  }
  
  void addLocation(Location location) {
    _locations.add(location);
    notifyListeners();
  }
}
