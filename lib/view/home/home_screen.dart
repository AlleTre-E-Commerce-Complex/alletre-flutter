import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/view/widgets/auction_list_widget.dart';
import 'package:alletre_app/view/widgets/bottom_navbar.dart';
import 'package:alletre_app/view/widgets/carousel_banner_widget.dart';
import 'package:alletre_app/view/widgets/chip_widget.dart';
import 'package:alletre_app/view/widgets/create_auction_button.dart';
import 'package:alletre_app/view/widgets/home_appbar.dart';
import 'package:alletre_app/view/widgets/search_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ongoingAuctions = context.watch<AuctionProvider>().ongoingAuctions;
    final upcomingAuctions = context.watch<AuctionProvider>().upcomingAuctions;

    return Scaffold(
      appBar: const AppBarWidget(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            const SearchFieldWidget(),
            const SizedBox(height: 5),
            const ChipWidget(),
            const SizedBox(height: 18),
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
