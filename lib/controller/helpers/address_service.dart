// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:alletre_app/model/country.dart';
import 'package:alletre_app/model/state.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';

class AddressService {
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<List<Map<String, dynamic>>> fetchAddresses() async {
    final token = await _getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/users/my-locations');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }
    return [];
  }

  static Future<bool> addAddress(Map<String, dynamic> address) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/users/locations');
    final body = json.encode({
      'address': address['address'],
      'addressLabel': address['addressLabel'] ?? address['address'],
      'countryId': address['countryId'],
      'cityId': address['cityId'],
      'phone': address['phone'],
      if (address['lat'] != null) 'lat': address['lat'],
      if (address['lng'] != null) 'lng': address['lng'],
    });
    print('[DEBUG] AddressService.addAddress payload:');
    print(body);
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    print('[DEBUG] AddressService.addAddress status: ${response.statusCode}');
    print('[DEBUG] AddressService.addAddress response: ${response.body}');
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> updateAddress(String locationId, Map<String, dynamic> updatedAddress) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/users/locations/$locationId');
    final body = json.encode({
      'address': updatedAddress['address'],
      'addressLabel': updatedAddress['addressLabel'] ?? updatedAddress['address'],
      'countryId': updatedAddress['countryId'] is Map ? updatedAddress['countryId']['id'] ?? updatedAddress['countryId']['nameEn'] : updatedAddress['countryId'],
      'cityId': updatedAddress['cityId'] is Map ? updatedAddress['cityId']['id'] ?? updatedAddress['cityId']['nameEn'] : updatedAddress['cityId'],
      'phone': updatedAddress['phone'] ?? '',
    });
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> deleteAddress(String locationId) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/users/locations/$locationId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> makeDefaultAddress(String locationId) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/users/locations/$locationId/make-default');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<CountryModel>> getCountries() async {
    List<CountryModel> resp = [];
    final token = await _getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/regions/countries');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var country in json.decode(response.body)['data']) {
        var arrText = country['nameEn'].toString().replaceAll(' ', '_');
        var cscCountry = CscCountry.values.singleWhere((e) => e.name == arrText);
        var model = CountryModel(id: country['id'], nameAr: country['nameAr'], nameEn: country['nameEn'], currency: country['currency'], cscCountry: cscCountry);
        resp.add(model);
      }
    }
    return resp;
  }

  Future<List<StateModel>> getStates(int countryId) async {
    List<StateModel> resp = [];
    final token = await _getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/regions/cities?countryId=$countryId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var state in json.decode(response.body)['data']) {
        resp.add(StateModel(id: state['id'], nameAr: state['nameAr'], nameEn: state['nameEn'], countryId: state['countryId']));
      }
    }
    return resp;
  }
}
