class AuctionItem {
  final String title;
  final String imageUrl;
  final String price;
  String status;  // "scheduled" or "active"
  final DateTime scheduledTime;

  AuctionItem({
    required this.title,
    required this.imageUrl,
    required this.price,
    this.status = 'scheduled',  // Default status is 'scheduled'
    required this.scheduledTime,
  });

  // Method to check if the auction should be marked as active
  bool isActive() {
    return DateTime.now().isAfter(scheduledTime);
  }
}
