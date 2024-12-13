import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/language_provider.dart';
import 'package:alletre_app/utils/button/textbutton.dart';
import 'package:alletre_app/utils/theme/app_theme.dart';
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
        toolbarHeight: 58,
        backgroundColor: Theme.of(context).primaryColor,
        title: SizedBox(
          width: 69,
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
                  fontSize: currentLanguage == 'English'
                      ? 13
                      : 17,
                      fontWeight: currentLanguage == 'English'
                      ? FontWeight.w500 
                      : FontWeight.w600 
                ),
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
              child: Text('//card banner will appear here...',
              style: TextStyle(color: onSecondaryColor)),
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
        padding: const EdgeInsets.only(right: 4, bottom: 61),
        child: SizedBox(
          height: 30,
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
        borderColor: primaryColor,
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
