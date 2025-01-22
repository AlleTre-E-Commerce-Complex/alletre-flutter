// class AuctionItem {
//   final String title;
//   final String imageUrl;
//   final String price;
//   String status;  // "scheduled" or "active"
//   final DateTime scheduledTime;

//   AuctionItem({
//     required this.title,
//     required this.imageUrl,
//     required this.price,
//     this.status = 'scheduled',  // Default status is 'scheduled'
//     required this.scheduledTime,
//   });

//   // Method to check if the auction should be marked as active
//   bool isActive() {
//     return DateTime.now().isAfter(scheduledTime);
//   }
// }


class AuctionItem {
  final String title;
  final String imageUrl; // Main image or placeholder
  final String price;
  final String description;
  final String category;
  final List<String> media;
  final String condition; // "new" or "used"
  String status; // "scheduled" or "active"
  final DateTime scheduledTime;

  AuctionItem({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category,
    required this.media,
    required this.condition,
    this.status = 'scheduled', // Default status is 'scheduled'
    required this.scheduledTime,
  });

  // Method to check if the auction should be marked as active
  bool isActive() {
    return DateTime.now().isAfter(scheduledTime);
  }
}
