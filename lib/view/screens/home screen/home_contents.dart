// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/utils/extras/common_navbar.dart';
import 'package:alletre_app/view/widgets/home%20widgets/chip_widget.dart';
import '../../widgets/home widgets/auction_list_widget.dart';
import '../../widgets/home widgets/bottom_navbar.dart';
import '../../widgets/home widgets/carousel_banner_widget.dart';
import '../../widgets/home widgets/create_auction_button.dart';
import '../../widgets/home widgets/home_appbar.dart';
import '../../widgets/home widgets/search_field_widget.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // API calls happen after the widget is built, using Future.microtask.
    Future.microtask(() async {
      await context.read<AuctionProvider>().getLiveAuctions();
      await context.read<AuctionProvider>().getListedProducts();
      await context.read<AuctionProvider>().getUpcomingAuctions();
      await context.read<AuctionProvider>().getExpiredAuctions();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building HomeScreenContent');
    final loginState = context.watch<LoggedInProvider>().isLoggedIn;
    final auctionProvider = context.watch<AuctionProvider>();

    // // Function to filter auctions based on searchQuery
    // List<AuctionItem> filterAuctions(List<AuctionItem> auctions) {
    //   if (searchQuery.isEmpty) return auctions;
    //   return auctions.where((auction) {
    //     // Adjust this filtering logic as needed, e.g. using title, description, etc.
    //     return auction.title.toLowerCase().contains(searchQuery.toLowerCase());
    //   }).toList();
    // }

    Future<void> refreshHomePage() async {
      await auctionProvider.getLiveAuctions();
      await auctionProvider.getListedProducts();
      await auctionProvider.getUpcomingAuctions();
      await auctionProvider.getExpiredAuctions();
    }

    // print('Live auctions count: ${auctionProvider.liveAuctions.length}');
    // print('Live auctions loading: ${auctionProvider.isLoadingLive}');
    // print('Live auctions error: ${auctionProvider.errorLive}');

    // log('Listed products count: ${auctionProvider.listedProducts.length}');
    // log('Listed products loading: ${auctionProvider.isLoadingListedProducts}');
    // log('Listed products error: ${auctionProvider.errorListedProducts}');

    // print("Live Auctions Count: ${auctionProvider.liveAuctions.length}");
    // print("Upcoming Auctions Count: ${auctionProvider.upcomingAuctions.length}");
    // print("Expired Auctions Count: ${auctionProvider.expiredAuctions.length}");

    return Scaffold(
      appBar: const HomeAppbar(),
      body: RefreshIndicator(
        onRefresh: refreshHomePage,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 9),
              SearchFieldWidget(
                isNavigable: false,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 5),
              const ChipWidget(),
              const SizedBox(height: 15),
              const CarouselBannerWidget(),
              const SizedBox(height: 16),
              AuctionListWidget(
                title: 'Live Auctions',
                subtitle: 'Live Deals, Real-Time Wins!',
                auctions: auctionProvider.filteredLiveAuctions,
                isLoading: auctionProvider.isLoadingLive,
                error: auctionProvider.errorLive,
                placeholder:
                    'No live auctions at the moment.\nPlace your auction right away.',
              ),
              AuctionListWidget(
                title: 'Listed Products',
                subtitle: 'Find and Reach the Product',
                auctions: auctionProvider.filteredListedProducts,
                isLoading: auctionProvider.isLoadingListedProducts,
                error: auctionProvider.errorListedProducts,
                placeholder:
                    'No products listed for sale.\nList your product here.',
              ),
              AuctionListWidget(
                title: 'Upcoming Auctions',
                subtitle: 'Coming Soon: Get Ready to Bid!',
                auctions: auctionProvider.filteredUpcomingAuctions,
                // auctions: auctionProvider.isLoadingUpcoming
                //     ? []
                //     : auctionProvider.filteredUpcomingAuctions,
                isLoading: auctionProvider.isLoadingUpcoming,
                error: auctionProvider.errorUpcoming,
                placeholder: 'No upcoming auctions available.',
              ),
              AuctionListWidget(
                title: 'Expired Auctions',
                subtitle: 'The Best Deals You Missed',
                auctions: auctionProvider.filteredExpiredAuctions,
                // auctions: auctionProvider.isLoadingExpired
                //     ? []
                //     : auctionProvider.filteredExpiredAuctions,
                isLoading: auctionProvider.isLoadingExpired,
                error: auctionProvider.errorExpired,
                placeholder: 'No expired auctions to display.',
              ),
              const SizedBox(height: 12)
            ],
          ),
        ),
      ),
      floatingActionButton: const CreateAuctionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color,
        height: Theme.of(context).bottomAppBarTheme.height,
        child: loginState
            ? NavBarUtils.buildAuthenticatedNavBar(
                context,
                onTabChange: (index) {
                  context.read<TabIndexProvider>().updateIndex(index);
                },
              )
            : const BottomNavBar(),
      ),
    );
  }
}
