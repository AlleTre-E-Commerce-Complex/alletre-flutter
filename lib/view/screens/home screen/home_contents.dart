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
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        // context.read<AuctionProvider>().getUpcomingAuctions());
        // ignore: use_build_context_synchronously
        context.read<AuctionProvider>().getExpiredAuctions());
  }

  @override
  Widget build(BuildContext context) {
    final loginState = context.watch<LoggedInProvider>().isLoggedIn;
    final auctionProvider = context.watch<AuctionProvider>();
    // final upcomingAuctions = auctionProvider.upcomingAuctions;
    final expiredAuctions = auctionProvider.expiredAuctions;

    return Scaffold(
      appBar: const HomeAppbar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 9),
            const SearchFieldWidget(isNavigable: true),
            const SizedBox(height: 5),
            const ChipWidget(),
            const SizedBox(height: 15),
            const CarouselBannerWidget(),
            const SizedBox(height: 5),
            // if (isLoading)
            //   const Center(child: CircularProgressIndicator())
            // else if (error != null)
            //   Center(child: Text(error))
            // else
            
            const AuctionListWidget(
              title: 'Live Auctions',
              subtitle: 'Live Deals, Real-Time Wins!',
              auctions: [],
            ),
            const AuctionListWidget(
              title: 'Listed Products',
              subtitle: 'Find and Reach the Product',
              auctions: [],
            ),
            const AuctionListWidget(
              title: 'Upcoming Auctions',
              subtitle: 'Coming Soon: Get Ready to Bid!',
              auctions: [],
            ),
            AuctionListWidget(
              title: 'Expired Auctions',
              subtitle: 'The Best Deals You Missed',
              auctions: expiredAuctions,
            ),
          ],
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
