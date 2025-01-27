import 'package:alletre_app/model/location_model.dart';
import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  final List<Location> _locations = [];

  List<Location> get locations => _locations;

  void addLocation(Location location) {
    _locations.add(location);
    notifyListeners();
  }
}
