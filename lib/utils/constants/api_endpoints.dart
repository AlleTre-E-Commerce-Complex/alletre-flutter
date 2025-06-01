class ApiEndpoints {
  static const String baseUrl = 'http://192.168.0.158:3001/api';

  // Auction endpoints
  static const String auctions = '/auctions';
  static const String productListing = '/auctions/product-listing';

  // Category endpoints
  static const String categories = '/categories/all';
  static const String _subCategoriesPath = '/categories/sub-categories';

  static String getSubCategoriesUrl(int categoryId) {
    return '$_subCategoriesPath?categoryId=$categoryId';
  }
}
