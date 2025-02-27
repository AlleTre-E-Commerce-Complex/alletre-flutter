class ApiEndpoints {
  static const String baseUrl = 'https://www.alletre.com/api';
  static const String categories = '/categories/all';
  static const String _subCategoriesPath = '/categories/sub-categories';

  static String getSubCategoriesUrl(int categoryId) {
  return '$_subCategoriesPath?categoryId=$categoryId';
  }
}
