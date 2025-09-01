import 'package:alletre_app/app.dart';
import 'package:alletre_app/controller/helpers/date_formatter_helper.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/view/screens/all%20auctions%20screen/all_auctions_screen.dart';
import 'package:alletre_app/view/screens/item_details/item_details.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final List<Map<String, dynamic>> purchases = [
    //   {
    //     "name": "Maruti 800 AC",
    //     "price": "AED 3,800.00",
    //     "date": "31 August 2025",
    //     "status": "Sold",
    //     "images": [
    //       "https://firebasestorage.googleapis.com/v0/b/alletre-auctions.firebasestorage.app/o/uploadedImage-dc05f004-5c3d-49ed-a116-7ab6fd9b277d.jpg?alt=media&token=dc05f004-5c3d-49ed-a116-7ab6fd9b277d",
    //       "https://firebasestorage.googleapis.com/v0/b/alletre-auctions.firebasestorage.app/o/uploadedImage-41e6e735-92ff-4a82-a3dd-aacf056f84ef.jpg?alt=media&token=41e6e735-92ff-4a82-a3dd-aacf056f84ef"
    //     ]
    //   },
    //   {
    //     "name": "Baleno Kondotty Kizhisseri Kuzhinjolam",
    //     "price": "AED 4,500.00",
    //     "date": "31 August 2025",
    //     "status": "Sold",
    //     "images": [
    //       "https://firebasestorage.googleapis.com/v0/b/alletre-auctions.firebasestorage.app/o/uploadedImage-dc05f004-5c3d-49ed-a116-7ab6fd9b277d.jpg?alt=media&token=dc05f004-5c3d-49ed-a116-7ab6fd9b277d",
    //       "https://firebasestorage.googleapis.com/v0/b/alletre-auctions.firebasestorage.app/o/uploadedImage-41e6e735-92ff-4a82-a3dd-aacf056f84ef.jpg?alt=media&token=41e6e735-92ff-4a82-a3dd-aacf056f84ef"
    //     ]
    //   },
    // ];

    if (context.read<LoggedInProvider>().isLoggedIn) {
      context.read<AuctionProvider>().getPurchasedAuctions();
    }

    return Consumer<AuctionProvider>(
      builder: (context, provider, child) {
        if (provider.purchasedAuctions.isNotEmpty) {
          return Scaffold(
            appBar: const NavbarElementsAppbar(appBarTitle: 'Purchases'),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // two columns
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.65,
                ),
                itemCount: provider.purchasedAuctions.length,
                itemBuilder: (context, index) {
                  final item = provider.purchasedAuctions[index];
                  return PurchaseCard(item: item);
                },
              ),
            ),
          );
        } else {
          return emptyPurchases();
        }
      },
    );
  }
}

class PurchaseCard extends StatefulWidget {
  final AuctionItem item;
  const PurchaseCard({super.key, required this.item});

  @override
  State<PurchaseCard> createState() => _PurchaseCardState();
}

class _PurchaseCardState extends State<PurchaseCard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.item.imageLinks;
    final soldDate = DateFormatter.getDDMMYYYYRepresentation(dateTime: DateTime.parse(widget.item.payment![0]['createdAt']));

    return GestureDetector(
      onTap: () {
        // doing this to make ItemDetailsScreen not to show Buy Now or Submit Bid.
        // this is a hacky code to trick the existing flow
        widget.item.isMyAuction = true;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(
              user: UserModel.empty(),
              item: widget.item,
              title: 'Live Auctions',
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ shrink-wrap height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel with dots
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 120,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: images.map((img) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        img,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  }).toList(),
                ),

                // Price Tag (top-left)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                    ),
                    child: Text(
                      '${NumberFormat("#,##0.00").format(double.parse(widget.item.buyNowPrice))} AED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),

                // ✅ Usage Status Tag (top-right)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(0)),
                    ),
                    child: Text(
                      widget.item.product!['usageStatus'],
                      style: const TextStyle(
                        fontSize: 7,
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Dots Indicator
                Positioned(
                  bottom: 6,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: images.asMap().entries.map((entry) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == entry.key ? Colors.white : Colors.white.withOpacity(0.5),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 0, 0),
              child: Text(
                widget.item.product!['title'],
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 0, 0),
              child: Row(
                children: [
                  const Icon(Icons.note_alt, size: 14, color: Color.fromARGB(255, 115, 115, 115)),
                  const SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: Text(
                      widget.item.product!['description'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 115, 115, 115),
                      ),
                      maxLines: 3, // show up to 3 lines
                      overflow: TextOverflow.ellipsis, // fade out if too long
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 0, 0),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.black87),
                  const SizedBox(width: 4),
                  Text(
                    soldDate,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            // Details
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [

            //     ],
            //   ),
            // ),

            // Bottom action icons (own row)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final String itemUrl = 'https://alletre.com/items/${widget.item.id}';
                      await Share.share(
                        'Check out this ${widget.item.title.toLowerCase()}: ${widget.item.title}\n'
                        '${widget.item.title == "Listed Products" ? "Price" : "Starting bid"}: AED ${widget.item.title == "Listed Products" ? widget.item.productListingPrice : widget.item.startBidAmount}\n'
                        '${widget.item.itemLocation?.address != null ? "Location: ${widget.item.itemLocation!.address}\n" : ""}'
                        '$itemUrl',
                        subject: widget.item.title == "Listed Products" ? 'Interesting Product on Alletre' : 'Interesting Auction on Alletre',
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: buttonBgColor,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.share,
                        size: 13,
                        color: primaryColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget emptyPurchases() {
  return Scaffold(
    appBar: const NavbarElementsAppbar(appBarTitle: 'Purchases'),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart,
            size: 100,
            color: greyColor,
          ),
          const SizedBox(height: 20),
          const Text(
            'No purchases yet!',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add functionality to navigate to the home screen or shop
              Navigator.push(
                MyApp.navigatorKey.currentContext!,
                MaterialPageRoute(
                  builder: (context) => AllAuctionsScreen(
                    title: 'Live Auctions',
                    user: UserModel.empty(),
                    auctions: context.read<AuctionProvider>().liveAuctions,
                    placeholder: 'No live auctions at the moment.\nPlace your auction right away.',
                  ),
                ),
              );
            },
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    ),
  );
}
