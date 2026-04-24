import 'package:csc_picker_plus/csc_picker_plus.dart';

class CountryModel {
  int id;
  String nameAr;
  String nameEn;
  String currency;
  CscCountry cscCountry;

  CountryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.currency,
    required this.cscCountry,
  });
}
