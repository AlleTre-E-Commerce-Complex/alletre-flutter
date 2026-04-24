import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:alletre_app/model/sub_category.dart';

void main() {
  group('SubCategory Tests', () {
    late Map<String, dynamic> testData;

    setUpAll(() {
      final file = File('test/test_subcategory.json');
      testData = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('fromJson parses basic fields correctly', () {
      final subCategory = SubCategory.fromJson(testData);

      expect(subCategory.id, 2);
      expect(subCategory.nameEn, 'Computers & tablets');
      expect(subCategory.nameAr, 'أجهزة الكمبيوتر والأجهزة اللوحية');
      expect(subCategory.categoryId, 1);
      expect(subCategory.imageLink, contains('alletre-auctions.firebasestorage.app'));
      expect(subCategory.imagePath, startsWith('uploadedImage-'));
      expect(subCategory.createdAt, '2025-02-20T11:02:53.191Z');
    });

    test('fromJson parses custom fields correctly', () {
      final subCategory = SubCategory.fromJson(testData);
      final fields = subCategory.customFields?.fields;

      expect(fields, isNotNull);
      expect(fields!.length, 10); // All fields from test data

      // Test screen size field
      final screenSize = fields.firstWhere((f) => f.key == 'screenSize');
      expect(screenSize.type, 'number');
      expect(screenSize.unit, 'inches');
      expect(screenSize.validation, 'positive');
      expect(screenSize.labelEn, 'Screen Size');
      expect(screenSize.labelAr, 'حجم الشاشة');

      // Test RAM field
      final ram = fields.firstWhere((f) => f.key == 'ramSize');
      expect(ram.type, 'number');
      expect(ram.unit, 'GB');
      expect(ram.validation, 'positive');
      expect(ram.labelEn, 'Ram Size');
      expect(ram.labelAr, 'حجم الرامات');

      // Test year field
      final year = fields.firstWhere((f) => f.key == 'releaseYear');
      expect(year.type, 'number');
      expect(year.validation, 'year');
      expect(year.labelEn, 'Release Year');
      expect(year.labelAr, 'سنة الاصدار');

      // Test color field (array type)
      final color = fields.firstWhere((f) => f.key == 'color');
      expect(color.type, 'text');
      expect(color.isArray, true);
      expect(color.labelEn, 'Color');
      expect(color.labelAr, 'اللون');

      // Test brand field
      final brand = fields.firstWhere((f) => f.key == 'brandId');
      expect(brand.type, 'text');
      expect(brand.resKey, 'brand');
      expect(brand.isRequired, true); // Brand is required for Electronics
      expect(brand.labelEn, 'Brand');
      expect(brand.labelAr, 'ماركة');

      // Test model field
      final model = fields.firstWhere((f) => f.key == 'model');
      expect(model.type, 'text');
      expect(model.isRequired, true); // Model is required for Electronics
      expect(model.labelEn, 'Model');
      expect(model.labelAr, 'موديل');
    });

    test('handles required fields for Electronics category', () {
      // Create a minimal subcategory without brand/model
      final minimalJson = {
        'id': 3,
        'nameEn': 'Test Category',
        'nameAr': 'تجربة',
        'categoryId': 1,
        'customFields': [
          {
            'id': 1,
            'subCategoryId': 3,
            'key': 'screenSize',
            'resKey': 'screenSize',
            'type': 'number',
            'labelAr': 'حجم الشاشة',
            'labelEn': 'Screen Size',
          }
        ]
      };

      final subCategory = SubCategory.fromJson(minimalJson);
      final fields = subCategory.customFields?.fields;

      expect(fields, isNotNull);
      expect(fields!.length, 3); // Screen size + auto-added brand and model
      
      // Brand and Model should be present and required
      final brand = fields.firstWhere((f) => f.resKey == 'brand');
      final model = fields.firstWhere((f) => f.key == 'model');
      
      expect(brand.isRequired, true);
      expect(model.isRequired, true);
    });
  });
}
