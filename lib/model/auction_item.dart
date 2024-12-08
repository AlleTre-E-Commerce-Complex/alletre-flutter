class AuctionItem {
  final String title;
  final String imageUrl;
  final String price;
  final String type; // "Buy Now" or "Bid Now"
  final String status; // "Active" or "Scheduled"

  AuctionItem({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.type,
    required this.status,
  });
}
