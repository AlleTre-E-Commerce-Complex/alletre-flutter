import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/language_provider.dart';
import 'package:alletre_app/utils/button/textbutton.dart';
import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:alletre_app/view/widgets/auction_list_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'create_auction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ongoingAuctions = context.watch<AuctionProvider>().ongoingAuctions;
    final upcomingAuctions = context.watch<AuctionProvider>().upcomingAuctions;
    final currentLanguage = context.watch<LanguageProvider>().currentLanguage;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: Theme.of(context).primaryColor,
        title: SizedBox(
          width: 74,
          child: SvgPicture.asset(
            'assets/images/alletre_header.svg',
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              context.read<LanguageProvider>().toggleLanguage();
            },
            child: SizedBox(
              width: 185,
              child: Text(
                currentLanguage,
                style: TextStyle(
                    color: secondaryColor,
                    fontSize: currentLanguage == 'English' ? 13 : 17,
                    fontWeight: currentLanguage == 'English'
                        ? FontWeight.w500
                        : FontWeight.w600),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 18, right: 18),
              child: SizedBox(
                height: 44,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search on Alletre',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
              label: const Text('Category 1'),
              backgroundColor: Colors.grey.shade200,
              labelStyle: const TextStyle(color: Colors.black),
              
                        ),
                        Chip(
              label: const Text('Category 2'),
              backgroundColor: Colors.grey.shade200,
              labelStyle: const TextStyle(color: Colors.black),
                        ),
                        Chip(
              label: const Text('Category 3'),
              backgroundColor: Colors.grey.shade200,
              labelStyle: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            CarouselSlider(
              items: [
                'assets/images/banner1.svg',
                'assets/images/banner2.svg',
                'assets/images/banner3.svg',
                'assets/images/banner4.svg',
                'assets/images/banner5.svg',
              ].map((imagePath) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SvgPicture.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      width: double.infinity
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 140,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.91,
                aspectRatio: 16 / 9,
              ),
            ),
            AuctionListWidget(
              title: 'Ongoing Auctions',
              auctions: ongoingAuctions,
            ),
            AuctionListWidget(
              title: 'Upcoming Auctions',
              auctions: upcomingAuctions,
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 6, bottom: 60),
        child: SizedBox(
          height: 32,
          width: 105,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const CreateAuctionScreen(),
                ),
              );
            },
            label: Text(
              'Create Auction',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            backgroundColor: Theme.of(context).splashColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildFixedSizeButton(
              text: 'Login',
              onPressed: () {},
              backgroundColor: secondaryColor,
              borderColor: const Color.fromARGB(255, 253, 215, 222),
              textStyle: Theme.of(context).textTheme.bodySmall!,
            ),
            buildFixedSizeButton(
              text: 'Sign Up',
              onPressed: () {},
              backgroundColor: primaryColor,
              borderColor: secondaryColor,
              textStyle: Theme.of(context).textTheme.bodyMedium!,
            ),
          ],
        ),
      ),
    );
  }
}
