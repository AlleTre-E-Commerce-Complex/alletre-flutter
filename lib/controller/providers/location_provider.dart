// ignore_for_file: avoid_print

import 'package:alletre_app/model/location_model.dart';
import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  int? _selectedLocationId;
  
  // Display names
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;

  // IDs for backend
  int? countryId;
  int? stateId;
  int? cityId;
  
  final List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;
  int? get selectedLocationId => _selectedLocationId;

  set selectedLocationId(int? id) {
    if (_selectedLocationId != id) {
      _selectedLocationId = id;
      notifyListeners();
    }
  }
  
  // Update methods that store both display name and ID
  void updateCountry(String? country, {int? id}) {
    selectedCountry = country;
    countryId = id ?? 1; // Default to UAE (ID: 1) if not provided
    notifyListeners();
  }

  void updateState(String? state, {int? id}) {
    selectedState = state;
    stateId = id;
    notifyListeners();
  }

  void updateCity(String? city, {int? id}) {
    selectedCity = city;
    cityId = id;
    notifyListeners();
  }

  // Helper method to get location data for product creation
  Map<String, dynamic> getLocationData() {
    return {
      'countryId': countryId ?? 1, // Default to UAE
      'cityId': cityId ?? 1, // Default to Dubai
    };
  }
  
  void addLocation(LocationModel location) {
    _locations.add(location);
    notifyListeners();
  }
  
  // For debugging
  void printLocationInfo() {
    print('🌍 Location Info:');
    print('Country: $selectedCountry (ID: $countryId)');
    print('State: $selectedState (ID: $stateId)');
    print('City: $selectedCity (ID: $cityId)');
  }
}