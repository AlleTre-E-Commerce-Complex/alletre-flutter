import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/search_provider.dart';
import 'package:alletre_app/view/widgets/home%20widgets/auction_list_widget.dart';
import 'package:alletre_app/view/widgets/home%20widgets/bottom_navbar.dart';
import 'package:alletre_app/view/widgets/home%20widgets/carousel_banner_widget.dart';
import 'package:alletre_app/view/widgets/home%20widgets/chip_widget.dart';
import 'package:alletre_app/view/widgets/home%20widgets/create_auction_button.dart';
import 'package:alletre_app/view/widgets/home%20widgets/home_appbar.dart';
import 'package:alletre_app/view/widgets/home%20widgets/search_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ongoingAuctions = context.watch<AuctionProvider>().ongoingAuctions;
    final upcomingAuctions = context.watch<AuctionProvider>().upcomingAuctions;

    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<SearchProvider>().setAllAuctions([
        ...ongoingAuctions,
        ...upcomingAuctions,
      ]);
    });

    return Scaffold(
      appBar: const HomeAppbar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 9),
            const SearchFieldWidget(
              isNavigable: true, // Enables navigation to search screen
            ),
            const SizedBox(height: 5),
            const ChipWidget(),
            const SizedBox(height: 15),
            const CarouselBannerWidget(),
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
      floatingActionButton: const CreateAuctionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      bottomNavigationBar: const BottomNavBarWidget(),
    );
  }
}
