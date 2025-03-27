class ApiEndpoints {
  static const String baseUrl = 'http://192.168.0.139:3001/api';
  static const String categories = '/categories/all';
  static const String _subCategoriesPath = '/categories/sub-categories';

  static String getSubCategoriesUrl(int categoryId) {
    return '$_subCategoriesPath?categoryId=$categoryId';
  }
}
