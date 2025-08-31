import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> purchases = [
      {
        "name": "Maruti 800 AC",
        "price": "AED 3,800.00",
        "date": "31 August 2025",
        "status": "Sold",
        "images": [
          "https://firebasestorage.googleapis.com/v0/b/alletre-auctions.firebasestorage.app/o/uploadedImage-dc05f004-5c3d-49ed-a116-7ab6fd9b277d.jpg?alt=media&token=dc05f004-5c3d-49ed-a116-7ab6fd9b277d",
          "https://firebasestorage.googleapis.com/v0/b/alletre-auctions.firebasestorage.app/o/uploadedImage-41e6e735-92ff-4a82-a3dd-aacf056f84ef.jpg?alt=media&token=41e6e735-92ff-4a82-a3dd-aacf056f84ef"
        ]
      },
      {
        "name": "Baleno Kondotty Kizhisseri Kuzhinjolam",
        "price": "AED 4,500.00",
        "date": "31 August 2025",
        "status": "Sold",
        "images": [
          "https://firebasestorage.googleapis.com/v0/b/alletre-auctions.firebasestorage.app/o/uploadedImage-dc05f004-5c3d-49ed-a116-7ab6fd9b277d.jpg?alt=media&token=dc05f004-5c3d-49ed-a116-7ab6fd9b277d",
          "https://firebasestorage.googleapis.com/v0/b/alletre-auctions.firebasestorage.app/o/uploadedImage-41e6e735-92ff-4a82-a3dd-aacf056f84ef.jpg?alt=media&token=41e6e735-92ff-4a82-a3dd-aacf056f84ef"
        ]
      },
    ];

    return Scaffold(
      appBar: const NavbarElementsAppbar(appBarTitle: 'Purchases'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // two columns
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.74,
          ),
          itemCount: purchases.length,
          itemBuilder: (context, index) {
            final item = purchases[index];
            return PurchaseCard(item: item);
          },
        ),
      ),
    );
  }
}

class PurchaseCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const PurchaseCard({super.key, required this.item});

  @override
  State<PurchaseCard> createState() => _PurchaseCardState();
}

class _PurchaseCardState extends State<PurchaseCard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.item["images"] as List<String>;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ shrink-wrap height
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
              // Price Tag
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.item["price"],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
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
                        color: _currentIndex == entry.key
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          // Details
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item["name"],
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.item["status"],
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: surfaceColor),
                    const SizedBox(width: 4),
                    Text(
                      widget.item["date"],
                      style: const TextStyle(
                          fontSize: 12, color: surfaceColor),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom action icons (own row)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    // TODO: Share functionality
                  },
                  child: const Icon(Icons.share, size: 18, color: Colors.grey),
                ),
                InkWell(
                  onTap: () {
                    // TODO: Save functionality
                  },
                  child: const Icon(Icons.bookmark_border,
                      size: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
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
            },
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    ),
  );
}
