// import 'package:alletre_app/controller/providers/auction_provider.dart';
// import 'package:alletre_app/model/auction_item.dart';
// import 'package:alletre_app/utils/themes/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:alletre_app/controller/providers/wishlist_provider.dart';
// import '../../widgets/auction card widgets/image_placeholder.dart';

// class AuctionDetailScreen extends StatefulWidget {
//   final AuctionItem auction;

//   const AuctionDetailScreen({
//     Key? key,
//     required this.auction,
//   }) : super(key: key);

//   @override
//   _AuctionDetailScreenState createState() => _AuctionDetailScreenState();
// }

// class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
//   int _currentImageIndex = 0;
//   final CarouselController _carouselController = CarouselController();

//   @override
//   void initState() {
//     super.initState();
//     // Fetch auction details when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<AuctionProvider>().getAuctionDetails(widget.auction.id);
//     });
//   }

//   // @override
//   // void dispose() {
//   //   // Clear details when leaving the screen
//   //   context.read<AuctionProvider>().clearAuctionDetails();
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Auction Details'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () async {
//               await Share.share(
//                 'Check out this auction: ${widget.auction.title}\nStarting bid: AED ${widget.auction.startBidAmount}',
//                 subject: 'Interesting Auction on Alletre',
//               );
//             },
//           ),
//           Consumer<WishlistProvider>(
//             builder: (context, wishlistProvider, child) {
//               final isWishlisted = wishlistProvider.isWishlisted(widget.auction.id);
//               return IconButton(
//                 icon: Icon(isWishlisted ? Icons.bookmark : Icons.bookmark_border),
//                 onPressed: () {
//                   wishlistProvider.toggleWishlist(widget.auction);
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Consumer<AuctionProvider>(
//         builder: (context, detailProvider, child) {
//           if (detailProvider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (detailProvider.error != null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Error: ${detailProvider.error}'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       detailProvider.getAuctionDetails(widget.auction.id);
//                     },
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final detailData = detailProvider.auctionDetails;
//           final auction = widget.auction;

//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Image Carousel
//                 Stack(
//                   alignment: Alignment.bottomCenter,
//                   children: [
//                     // CarouselSlider(
//                     //   carouselController: _carouselController,
//                     //   options: CarouselOptions(
//                     //     height: 250,
//                     //     viewportFraction: 1.0,
//                     //     enlargeCenterPage: false,
//                     //     onPageChanged: (index, reason) {
//                     //       setState(() {
//                     //         _currentImageIndex = index;
//                     //       });
//                     //     },
//                     //   ),
//                     //   items: auction.imageLinks.isNotEmpty
//                     //       ? auction.imageLinks.map((imageUrl) {
//                     //           return Builder(
//                     //             builder: (BuildContext context) {
//                     //               return Container(
//                     //                 width: MediaQuery.of(context).size.width,
//                     //                 color: Colors.grey[200],
//                     //                 child: _isSvg(imageUrl)
//                     //                     ? SvgPicture.network(
//                     //                         imageUrl,
//                     //                         fit: BoxFit.contain,
//                     //                         placeholderBuilder: (context) =>
//                     //                             const PlaceholderImage(),
//                     //                       )
//                     //                     : Image.network(
//                     //                         imageUrl,
//                     //                         fit: BoxFit.contain,
//                     //                         errorBuilder: (context, error, stackTrace) =>
//                     //                             const PlaceholderImage(),
//                     //                       ),
//                     //               );
//                     //             },
//                     //           );
//                     //         }).toList()
//                     //       : [const PlaceholderImage()],
//                     // ),
//                     // Indicator dots for carousel
//                     if (auction.imageLinks.length > 1)
//                       Positioned(
//                         bottom: 10,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: auction.imageLinks.asMap().entries.map((entry) {
//                             return Container(
//                               width: 8.0,
//                               height: 8.0,
//                               margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: _currentImageIndex == entry.key
//                                     ? primaryColor
//                                     : Colors.white.withOpacity(0.8),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                   ],
//                 ),

//                 // Auction Details
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Status Badge
//                       _buildStatusText(context, auction.status),
//                       const SizedBox(height: 12),

//                       // Title
//                       Text(
//                         auction.title,
//                         // style: Theme.of(context).textTheme.headline6,
//                       ),
//                       const SizedBox(height: 16),

//                       // Price and Bids Info
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // Starting Bid
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text('Starting Bid', style: TextStyle(color: greyColor)),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'AED ${NumberFormat.decimalPattern().format(double.tryParse(auction.startBidAmount) ?? 0.0)}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ],
//                           ),
                          
//                           // Total Bids
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               const Text('Total Bids', style: TextStyle(color: greyColor)),
//                               const SizedBox(height: 4),
//                               Text(
//                                 '${auction.bids}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),

//                       // Time Info
//                       if (auction.status != 'EXPIRED')
//                         Card(
//                           color: Colors.grey[50],
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text('Time Remaining', style: TextStyle(fontWeight: FontWeight.bold)),
//                                 const SizedBox(height: 8),
//                                 AuctionCountdown(
//                                   startDate: auction.startDate,
//                                   endDate: auction.expiryDate,
//                                   showLabels: true,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       const SizedBox(height: 16),

//                       // Location
//                       Card(
//                         color: Colors.grey[50],
//                         child: Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.location_on, size: 16, color: primaryColor),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(auction.location),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Description
//                       const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                       const SizedBox(height: 8),
//                       Text(auction.description),
//                       const SizedBox(height: 24),

//                       // Auction details from API response
//                       if (detailData != null) ...[
//                         // Additional details from API
//                         const Text('Additional Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                         const SizedBox(height: 8),
//                         _buildAdditionalDetails(detailData),
//                         const SizedBox(height: 24),
//                       ],

//                       // Action Buttons
//                       if (auction.status == 'ACTIVE' || auction.status == 'IN_PROGRESS') ...[
//                         auction.hasBuyNow
//                             ? Row(
//                                 children: [
//                                   Expanded(
//                                     child: ElevatedButton(
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: primaryColor,
//                                         padding: const EdgeInsets.symmetric(vertical: 12),
//                                       ),
//                                       onPressed: () {
//                                         // Implement bid now functionality
//                                       },
//                                       child: const Text('Bid Now', style: TextStyle(color: secondaryColor)),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: ElevatedButton(
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: secondaryColor,
//                                         side: const BorderSide(color: primaryColor),
//                                         padding: const EdgeInsets.symmetric(vertical: 12),
//                                       ),
//                                       onPressed: () {
//                                         // Implement buy now functionality
//                                       },
//                                       child: const Text('Buy Now', style: TextStyle(color: primaryColor)),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: primaryColor,
//                                   minimumSize: const Size(double.infinity, 50),
//                                 ),
//                                 onPressed: () {
//                                   // Implement bid now functionality
//                                 },
//                                 child: const Text('Bid Now', style: TextStyle(color: secondaryColor)),
//                               ),
//                       ] else if (auction.status == 'EXPIRED') {
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey,
//                             minimumSize: const Size(double.infinity, 50),
//                           ),
//                           onPressed: null,
//                           child: const Text('Auction Ended', style: TextStyle(color: Colors.white)),
//                         ),
//                       } else if (auction.status == 'SCHEDULED' || auction.status == 'IN_SCHEDULED') {
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.amber,
//                             minimumSize: const Size(double.infinity, 50),
//                           ),
//                           onPressed: null,
//                           child: const Text('Coming Soon', style: TextStyle(color: Colors.white)),
//                         ),
//                       }
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAdditionalDetails(Map<String, dynamic> detailData) {
//     // Extract and display additional details from the API response
//     // This will depend on the actual structure of your API response
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Example of displaying additional details
//         if (detailData.containsKey('seller')) ...[
//           const Text('Seller', style: TextStyle(color: greyColor, fontWeight: FontWeight.bold)),
//           Text(detailData['seller']['name'] ?? 'Unknown'),
//           const SizedBox(height: 8),
//         ],
        
//         if (detailData.containsKey('category')) ...[
//           const Text('Category', style: TextStyle(color: greyColor, fontWeight: FontWeight.bold)),
//           Text(detailData['category']['name'] ?? 'Unknown'),
//           const SizedBox(height: 8),
//         ],
        
//         // Add more fields as needed based on your API response
//       ],
//     );
//   }

//   Widget _buildStatusText(BuildContext context, String status) {
//     final baseColor = getStatusColor(status);
//     String displayStatus = status;

//     if (status == "WAITING_FOR_PAYMENT") {
//       displayStatus = "SOLD";
//     } else if (status == "IN_SCHEDULED") {
//       displayStatus = "SCHEDULED";
//     } else if (status == "CANCELLED_BEFORE_EXP_DATE") {
//       displayStatus = "CANCELLED";
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: baseColor.withAlpha(26),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         displayStatus,
//         style: TextStyle(
//           fontSize: 12,
//           color: baseColor,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   bool _isSvg(String url) {
//     final Uri uri = Uri.parse(url);
//     final String path = uri.path;
//     final String extension = path.split('.').last.toLowerCase();
//     return extension == 'svg';
//   }
// }