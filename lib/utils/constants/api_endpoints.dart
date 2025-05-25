class ApiEndpoints {
  static const String baseUrl = 'http://192.168.0.158:3001/api';

  // Auction endpoints
  static const String auctions = '/auctions';
  static const String productListing = '/auctions/product-listing';

  // Draft auction details endpoint
  static String userAuctionDetails(String auctionId) => '/auctions/user/$auctionId';

  // Category endpoints
  static const String categories = '/categories/all';
  static const String _subCategoriesPath = '/categories/sub-categories';

  static String getSubCategoriesUrl(int categoryId) {
    return '$_subCategoriesPath?categoryId=$categoryId';
  }

  // Wishlist endpoints
  static const String saveToWishlist = '/watch-lists/save';
  static const String getSavedWishlist = '/watch-lists/saved';
  static String unSaveFromWishlist(int auctionId) => '/watch-lists/un-save?auctionId=$auctionId';
}