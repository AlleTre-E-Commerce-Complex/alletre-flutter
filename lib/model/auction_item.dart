class AuctionItem {
  final int id;
  final String title;
  final String price;
  final int bids;
  final String description;
  final String startBidAmount;
  String status;
  final DateTime startDate;
  final DateTime expiryDate;
  final List<String> imageLinks; // List of image URLs

  AuctionItem({
    required this.id,
    required this.title,
    required this.price,
    required this.bids,
    required this.description,
    required this.startBidAmount,
    required this.status,
    required this.startDate,
    required this.expiryDate,
    required this.imageLinks,
  });

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    // Safely handle nested product data
    final product = json['product'] as Map<String, dynamic>? ?? {};

    // Safely handle image list
    final List<dynamic> images = (product['images'] as List<dynamic>?) ?? [];
    final List<String> imageLinks = images
        .map((image) => (image as Map<String, dynamic>)['imageLink'] as String? ?? '')
        .where((link) => link.isNotEmpty)
        .toList();

    // final List<dynamic> images = json['product']['images'];
    // // ignore: unnecessary_null_comparison
    // final List<String> imageLinks = images != null
    //     ? images.map((image) => image['imageLink'] as String? ?? '').toList()
    //     : [];

    // Safely handle counts
    final counts = json['_count'] as Map<String, dynamic>? ?? {};

  //   return AuctionItem(
  //     id: json['id'],
  //     title: json['product']['title'] ?? 'No Title',
  //     price: json['product']['price'] ?? '0',
  //     bids: json['_count']['bids'] ?? '0',
  //     description: json['product']['description'] ?? 'No Description',
  //     startBidAmount: json['startBidAmount'] ?? '0',
  //     status: json['status'] ?? 'UNKNOWN',
  //     startDate: json['startDate'] != null
  //         ? DateTime.parse(json['startDate'])
  //         : DateTime.now(),
  //     expiryDate: json['expiryDate'] != null
  //         ? DateTime.parse(json['expiryDate'])
  //         : DateTime.now(),
  //     imageLinks: imageLinks,
  //   );
  // }

  return AuctionItem(
      id: json['id'] as int? ?? 0,
      title: product['title'] as String? ?? 'No Title',
      price: product['price']?.toString() ?? '0',
      bids: counts['bids'] as int? ?? 0,
      description: product['description'] as String? ?? 'No Description',
      startBidAmount: json['startBidAmount']?.toString() ?? '0',
      status: json['status'] as String? ?? 'UNKNOWN',
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : DateTime.now(),
      imageLinks: imageLinks,
    );
  }

  /// Determines if the auction is active
  bool isActive() {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(expiryDate);
  }

  /// Calculates time remaining
  String timeRemaining() {
    final now = DateTime.now();
    if (now.isAfter(expiryDate)) {
      return "Expired";
    }
    final difference = expiryDate.difference(now);
    return "${difference.inDays} days : ${difference.inHours % 24} hrs : ${difference.inMinutes % 60} min : ${difference.inSeconds % 60} sec";
  }
}
