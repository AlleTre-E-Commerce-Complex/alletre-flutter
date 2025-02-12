// // class AuctionItem {
// //   final String title;
// //   final String imageUrl; // Main image or placeholder
// //   final String price;
// //   final String description;
// //   final String category;
// //   final List<String> media;
// //   final String condition; // "new" or "used"
// //   String status; // "scheduled" or "active"
// //   final DateTime scheduledTime;

// //   AuctionItem({
// //     required this.title,
// //     required this.imageUrl,
// //     required this.price,
// //     required this.description,
// //     required this.category,
// //     required this.media,
// //     required this.condition,
// //     this.status = 'scheduled', // Default status is 'scheduled'
// //     required this.scheduledTime,
// //   });

// //   // Factory constructor to create an AuctionItem from JSON
// //   factory AuctionItem.fromJson(Map<String, dynamic> json) {
// //     try {
// //       return AuctionItem(
// //         title: json['title'] ?? 'No Title',
// //         imageUrl: json['imageUrl'] ?? '',
// //         price: json['price'] ?? '0',
// //         description: json['description'] ?? '',
// //         category: json['category'] ?? 'Uncategorized',
// //         media: List<String>.from(json['media'] ?? []),
// //         condition: json['condition'] ?? 'new',
// //         status: json['status'] ?? 'scheduled',
// //         scheduledTime: DateTime.parse(json['scheduledTime']),
// //       );
// //     } catch (e) {
// //       // ignore: avoid_print
// //       print('Error parsing AuctionItem: $e');
// //       throw const FormatException('Invalid JSON data for AuctionItem');
// //     }
// //   }
  
// //   // Method to check if the auction should be marked as active
// //   bool isActive() {
// //     return DateTime.now().isAfter(scheduledTime);
// //   }
// // }

// class AuctionItem {
//   final int id;
//   final String title;
//   final String price;
//   final String description;
//   final String startBidAmount;
//   String status;
//   final DateTime startDate;
//   final DateTime expiryDate;
//   final List<String> imageLinks; // List of image URLs

//   AuctionItem({
//     required this.id,
//     required this.title,
//     required this.price,
//     required this.description,
//     required this.startBidAmount,
//     required this.status,
//     required this.startDate,
//     required this.expiryDate,
//     required this.imageLinks,
//   });

//   factory AuctionItem.fromJson(Map<String, dynamic> json) {
//     // Extract image links from the product.images array
//     final List<dynamic> images = json['product']['images'];
//     // final List<String> imageLinks = images.map((image) => image['imageLink'] as String).toList();
//     // ignore: unnecessary_null_comparison
//     final List<String> imageLinks = images != null
//       ? images.map((image) => image['imageLink'] as String? ?? '').toList()
//       : [];

//     return AuctionItem(
//     id: json['id'],
//     title: json['product']['title'] ?? 'No Title', // Handle null case
//     price: json['product']['price'] ?? '0', // Default price to '0' if null
//     description: json['product']['description'] ?? 'No Description',
//     startBidAmount: json['startBidAmount'] ?? '0', 
//     status: json['status'] ?? 'UNKNOWN',
//     startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
//     expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : DateTime.now(),
//     imageLinks: imageLinks,
//   );
//   }

//   /// Determines if the auction is active
//   bool isActive() {
//     final now = DateTime.now();
//     return now.isAfter(startDate) && now.isBefore(expiryDate);
//   }
// }

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
