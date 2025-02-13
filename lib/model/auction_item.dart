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
    final List<dynamic> images = json['product']['images'];
    // ignore: unnecessary_null_comparison
    final List<String> imageLinks = images != null
        ? images.map((image) => image['imageLink'] as String? ?? '').toList()
        : [];

    return AuctionItem(
      id: json['id'],
      title: json['product']['title'] ?? 'No Title',
      price: json['product']['price'] ?? '0',
      bids: json['_count']['bids'] ?? '0',
      description: json['product']['description'] ?? 'No Description',
      startBidAmount: json['startBidAmount'] ?? '0',
      status: json['status'] ?? 'UNKNOWN',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
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
