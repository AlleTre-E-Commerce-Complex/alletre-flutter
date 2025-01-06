import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/controller/providers/search_provider.dart';
import 'package:alletre_app/utils/extras/common_navbar.dart';
import 'package:alletre_app/view/screens/home%20screen/home_contents.dart';
import 'package:alletre_app/view/widgets/home%20widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/view/screens/purchases%20screen/purchases_screen.dart';
import 'package:alletre_app/view/screens/bids%20screen/bids_screen.dart';
import 'package:alletre_app/view/screens/profile%20screen/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginState = context.watch<LoggedInProvider>().isLoggedIn;
    final ongoingAuctions = context.watch<AuctionProvider>().ongoingAuctions;
    final upcomingAuctions = context.watch<AuctionProvider>().upcomingAuctions;

    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<SearchProvider>().setAllAuctions([
        ...ongoingAuctions,
        ...upcomingAuctions,
      ]);
    });

    // Uses Consumer to listen for index changes from TabIndexProvider
    return Consumer<TabIndexProvider>(
      builder: (context, tabIndexProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: tabIndexProvider
                .selectedIndex, // Uses the selected index from provider
            children: const [
              HomeScreenContent(),
              PurchaseScreen(),
              BidsScreen(),
              ProfileScreen(),
              // CreateAuctionScreen(),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: Theme.of(context).bottomAppBarTheme.color,
            height: Theme.of(context).bottomAppBarTheme.height,
            child: loginState
                ? NavBarUtils.buildAuthenticatedNavBar(
                    context,
                    onTabChange: (index) {
                      context
                          .read<TabIndexProvider>()
                          .updateIndex(index); // Updates index on tap
                    },
                  ) 
                : const BottomNavBar(), // default navbar for unauthenticated users
          ),
        );
      },
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
