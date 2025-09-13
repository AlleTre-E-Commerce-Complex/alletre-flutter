// ignore_for_file: avoid_print

import 'package:alletre_app/controller/helpers/address_service.dart';
import 'package:alletre_app/model/country.dart';
import 'package:alletre_app/model/location_model.dart';
import 'package:alletre_app/model/state.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
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
  String? phone;
  List<CscCountry> lsCscCountries = [];
  List<CountryModel> lsCountries = [];
  List<StateModel> lsStates = [];

  final List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;
  int? get selectedLocationId => _selectedLocationId;
  final addressService = AddressService();

  set selectedLocationId(int? id) {
    if (_selectedLocationId != id) {
      _selectedLocationId = id;
      notifyListeners();
    }
  }

  // Update methods that store both display name and ID
  void updateCountry(String? country, {int? id}) {
    selectedCountry = country;
    countryId = id;
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
      'phone': phone ?? 'xxxxxxxxxx',
    };
  }

  void addLocation(LocationModel location) {
    _locations.add(location);
    notifyListeners();
  }

  void reset() {
    selectedCountry = null;
    selectedState = null;
    selectedCity = null;
    countryId = null;
    stateId = null;
    cityId = null;
    phone = null;
    _selectedLocationId = null;
    notifyListeners();
  }

  // For debugging
  void printLocationInfo() {
    print('🌍 Location Info:');
    print('Country: $selectedCountry (ID: $countryId)');
    print('State: $selectedState (ID: $stateId)');
    print('City: $selectedCity (ID: $cityId)');
  }

  fetchCountries() async {
    try {
      if (lsCscCountries.isEmpty) {
        var countries = await addressService.getCountries();
        lsCountries = countries;
        for (var country in countries) {
          lsCscCountries.add(country.cscCountry);
        }
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      notifyListeners();
    }
  }

  fetchStates(int countryId) async {
    try {
      lsStates = await addressService.getStates(countryId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
