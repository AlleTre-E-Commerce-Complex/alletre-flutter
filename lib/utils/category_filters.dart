import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<Map<String, dynamic>>> fetchCarBrandData() async {
  final strCarBrandData = await rootBundle.loadString('assets/car-data.json');
  Map<String, dynamic> carBrandData = jsonDecode(strCarBrandData);

  List<Map<String, dynamic>> lstCarBrands = [];
  for (var brand in carBrandData.keys) {
    lstCarBrands.add({brand: carBrandData[brand]});
  }
  return lstCarBrands;
}

final filtersCar = [
  {
    'name': 'CONDITION',
    'type': 'toggle_group',
    'backend_key_name': 'usageStatus',
    'show_in_quick_menu': false,
    'values': ['New', 'Used']
  },
  {
    'name': 'PRICE',
    'type': 'range_selector',
    'backend_key_name': 'ProductListingPrice',
    'need_adjuster': true,
    'show_in_quick_menu': true,
    'values': {'min': 1, 'max': 1000000}
  },
  {'name': 'BRAND', 'type': 'toggle_group', 'backend_key_name': 'brand', 'values': 'dynamic'},
  {'name': 'MODEL', 'type': 'toggle_group', 'backend_key_name': 'model', 'values': []},
  {
    'name': 'YEAR',
    'type': 'range_selector',
    'backend_key_name': 'releaseYear',
    'need_adjuster': false,
    'show_in_quick_menu': true,
    'values': {'min': 1, 'max': 1000000}
  },
  {
    'name': 'EMIRATE',
    'type': 'toggle_group',
    'backend_key_name': 'emirate',
    'show_in_quick_menu': true,
    'values': ['ABU DHABI', 'DUBAI', 'SHARJAH', 'AJMAN', 'RAS AL KHAIMAH', 'FUJAIRAH', 'UMM AL QUWAIN']
  },
  {
    'name': 'KILOMETERS',
    'type': 'range_selector',
    'backend_key_name': 'kilometers',
    'need_adjuster': true,
    'show_in_quick_menu': true,
    'values': {'min': 1, 'max': 1000000}
  },
  {
    'name': 'REGIONAL SPECS',
    'type': 'toggle_group',
    'backend_key_name': 'regionalSpecs',
    'show_in_quick_menu': true,
    'values': ['GCC SPECS', 'AMERICAN SPECS', 'CANADIAN SPECS', 'EUROPEAN', 'JAPANESE', 'KOREAN', 'CHINESE', 'OTHER']
  },
  {
    'name': 'BODY TYPE',
    'type': 'toggle_group',
    'backend_key_name': 'carType',
    'show_in_quick_menu': true,
    'values': ['MICRO CARS', 'HATCHBACK', 'SEDAN', 'SUV', 'MPV', 'COUPE', 'CONVERTIBLE', 'WAGON', 'LUXURY', 'ANTIQUE', 'SPORTS CAR', 'SUPERCAR', 'LIMOUSINE', 'HYBRID CAR', 'OFF-ROAD' 'CLASSIC']
  },
  {
    'name': 'SEATS',
    'type': 'toggle_group',
    'backend_key_name': 'seatingCapacity',
    'values': ['2 SEATER', '4 SEATER', '5 SEATER', '6 SEATER', '7 SEATE', '8 SEATER', '8+ SEATER']
  },
  {
    'name': 'TRANSMISSION TYPE',
    'type': 'toggle_group',
    'backend_key_name': 'transmissionType',
    'show_in_quick_menu': true,
    'values': ['AUTOMATIC', 'MANUAL', 'SEMI AUTOMATIC']
  },
  {
    'name': 'FUEL TYPE',
    'type': 'toggle_group',
    'backend_key_name': 'fuelType',
    'show_in_quick_menu': true,
    'values': ['PETROL', 'DIESEL', 'ELECTRIC', 'HYBRID']
  },
  {
    'name': 'EXTERIOR COLOR',
    'type': 'toggle_group',
    'backend_key_name': 'color',
    'show_in_quick_menu': false,
    'values': ['WHITE', 'BLACK', 'SILVER', 'GREY', 'RED', 'BLUE', 'NAVY BLUE', 'GREEN', 'YELLOW', 'ORANGE', 'PURPLE', 'BROWN', 'BEIGE', 'BURGUNDY', 'PINK', 'CYAN', 'TURQUOISE', 'BRONZE', 'GOLDEN', 'MATTE BLACK', 'ROSE GOLD', 'PEARL', 'CHAMPAGNE', 'TITANIUM']
  },
  {
    'name': 'INTERIOR COLOR',
    'type': 'toggle_group',
    'backend_key_name': 'interiorColor',
    'show_in_quick_menu': false,
    'values': [
      'WHITE',
      'BLACK',
      'SILVER',
      'GREY',
      'RED',
      'BLUE',
      'NAVY BLUE',
      'GREEN',
      'YELLOW',
      'ORANGE',
      'PURPLE',
      'BROWN',
      'BEIGE',
      'BURGUNDY',
      'PINK',
      'CYAN',
      'TURQUOISE',
      'BRONZE',
      'GOLDEN',
      'MATTE BLACK',
      'ROSE GOLD',
      'PEARL',
      'CHAMPAGNE',
      'TITANIUM',
      'NARDO GREY',
      'MULTI COLOR',
      'OTHER COLOR',
    ]
  },
  {
    'name': 'HORSEPOWER',
    'type': 'toggle_group',
    'backend_key_name': 'horsepower',
    'show_in_quick_menu': false,
    'values': ['0 - 99 HP', '100 - 199 HP', '200 - 299 HP', '300 - 399 HP', '400 - 499 HP', '500 - 599 HP', '600 - 699 HP', '700 - 799 HP', '800 - 899 HP', '900+ HP', 'UNKNOWN']
  },
  {
    'name': 'ENGINE CAPACITY (CC)',
    'type': 'toggle_group',
    'backend_key_name': 'engineCapacity',
    'values': ['0 - 499 CC', '500 - 999 CC', '1000 - 1499 CC', '1500 - 1999 CC', '2000 - 2499 CC', '2500 - 2999 CC', '3000 - 3499 CC', '3500 - 3999 CC', '4000+ CC', 'UNKNOWN']
  },
  {
    'name': 'DOORS',
    'type': 'toggle_group',
    'backend_key_name': 'doors',
    'show_in_quick_menu': false,
    'values': ['2 DOOR', '3 DOOR', '4 DOOR', '5+ DOORS']
  },
  {
    'name': 'WARRANTY',
    'type': 'toggle_group',
    'backend_key_name': 'warranty',
    'show_in_quick_menu': false,
    'values': [
      'YES',
      'NO',
      'DOES NOT APPLY',
    ]
  },
  {
    'name': 'NUMBER OF CYLINDERS',
    'type': 'toggle_group',
    'backend_key_name': 'numberOfCylinders',
    'values': ['3', '4', '5', '6', '8', '10', '12', 'UNKNOWN']
  }
];

final filtersProperty = [
  {
    'name': 'CONDITION',
    'type': 'toggle_group',
    'backend_key_name': 'usageStatus',
    'show_in_quick_menu': false,
    'values': ['NEW', 'USED']
  },
  {
    'name': 'TYPE',
    'type': 'toggle_group',
    'backend_key_name': 'residentialType',
    'show_in_quick_menu': true,
    'values': ['LAND', 'RESIDENTIAL', 'MULTIPLE UNITS', 'COMMERCIAL']
  },
  {
    'name': 'PRICE',
    'type': 'range_selector',
    'backend_key_name': 'ProductListingPrice',
    'need_adjuster': true,
    'values': {'min': 1, 'max': 1000000}
  },
  {
    'name': 'AREA / SIZE(SQFT)',
    'type': 'range_selector',
    'backend_key_name': 'totalArea',
    'need_adjuster': false,
    'show_in_quick_menu': true,
    'values': {'min': 1, 'max': 1000000}
  },
  {
    'name': 'PROPERTY TYPE',
    'type': 'toggle_group',
    'backend_key_name': 'landType',
    'show_in_quick_menu': true,
    'values': ['APARTMENT', 'VILLA', 'TOWNHOUSE', 'PENTHOUSE', 'HOTEL APARTMENT', 'OFFICE', 'WAREHOUSE', 'LAND']
  },
  {
    'name': 'AMNETIES',
    'type': 'toggle_group',
    'backend_key_name': 'amenities',
    'show_in_quick_menu': true,
    'values': [
      'MAIDS ROOM',
      'STUDY',
      'CONCIERGE SERVICE',
      'CENTRAL A/C & HEATING',
      'BALCONY',
      'PRIVATE GARDEN',
      'PRIVATE POOL',
      'PRIVATE GYM',
      'PRIVATE JACUZZI',
      'SHARED POOL',
      'SHARED SPA',
      'SHARED GYM',
      'SECURITY',
      'MAID SERVICE',
      'COVERED PARKING',
      'BUILT IN WARDROBES',
      'WALK-IN CLOSET',
      'BUILT IN KITCHEN APPLIANCES',
      'VIEW OF WATER',
      'VIEW OF LANDMARK',
      'PETS ALLOWED',
      'DOUBLE GLAZED WINDOWS',
      'DAY CARE CENTER',
      'ELECTRICITY BACKUP',
      'FIRST AID MEDICAL CENTER',
      'SERVICE ELEVATORS',
      'PRAYER ROOM',
      'LAUNDRY ROOM',
      'BROADBAND INTERNET',
      'SATELLITE / CABLE TV',
      'BUSINESS CENTER',
      'INTERCOM',
      'ATM FACILITY',
      'KIDS PLAY AREA',
      'RECEPTION / WAITING ROOM',
      'MAINTENANCE STAFF',
      'CCTV SECURITY',
      'CAFETERIA OR CANTEEN',
      'SHARED KITCHEN',
      'FACILITIES FOR DISABLED',
      'STORAGE AREAS',
      'CLEANING SERVICES',
      'BARBEQUE AREA',
      'LOBBY IN BUILDING',
      'WASTE DISPOSAL'
    ]
  },
  {
    'name': 'BEDROOMS',
    'type': 'toggle_group',
    'backend_key_name': 'numberOfRooms',
    'show_in_quick_menu': true,
    'values': ['STUDIO', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12+']
  },
  {
    'name': 'BATHS',
    'type': 'toggle_group',
    'backend_key_name': 'numberOfBathrooms',
    'show_in_quick_menu': true,
    'values': ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12+']
  },
  {
    'name': 'FURNISHED',
    'type': 'toggle_group',
    'backend_key_name': 'isFurnished',
    'show_in_quick_menu': true,
    'values': ['FURNISHED', 'UNFURNISHED']
  }
];
