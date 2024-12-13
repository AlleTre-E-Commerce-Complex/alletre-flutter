import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/language_provider.dart';
import 'package:alletre_app/view/widgets/auction_list_widget.dart';
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
        backgroundColor: Theme.of(context).primaryColor,
        title: Padding(
          padding: const EdgeInsets.only(right: 81),
          child: SizedBox(
            height: 28,
            child: SvgPicture.asset(
              'assets/images/alletre_header.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                context.read<LanguageProvider>().toggleLanguage();
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 138),
                    child: Text(
                      currentLanguage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
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
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Get the ideal Buyer for Your unique Item...'),
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
        padding: const EdgeInsets.only(right: 4, bottom: 58),
        child: SizedBox(
          height: 32,
          width: 110,
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
            TextButton(
              onPressed: () {},
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
