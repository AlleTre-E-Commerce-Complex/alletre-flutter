import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/controller/providers/search_provider.dart';
import 'package:alletre_app/utils/extras/common_navbar.dart';
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
    final loginState = context.watch<LoggedInProvider>().isLoggedIn;

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
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context)
            .bottomAppBarTheme
            .color, 
        height: Theme.of(context)
            .bottomAppBarTheme
            .height, 
        child: !loginState
            ? const BottomNavBar()
            : NavBarUtils.buildAuthenticatedNavBar(context),
      ),
    );
  }
}

// import 'package:alletre_app/view/screens/bids%20screen/bids_screen.dart';
// import 'package:alletre_app/view/screens/home%20screen/home_contents.dart';
// import 'package:alletre_app/view/screens/profile%20screen/profile_screen.dart';
// import 'package:alletre_app/view/screens/purchases%20screen/purchases_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
// import 'package:provider/provider.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final selectedIndex = context.watch<BottomNavBarProvider>().selectedIndex;

//     // Define tab pages
//     final List<Widget> pages = [
//       const HomeScreenContent(), // Home tab content
//       const PurchaseScreen(),  // Purchases tab content
//       const BidsScreen(),       // Bids tab content
//       const ProfileScreen(),    // Profile tab content
//     ];

//     return Scaffold(
//       body: IndexedStack(
//         index: selectedIndex,
//         children: pages,
//       ),
      
//     );
//   }
// }
