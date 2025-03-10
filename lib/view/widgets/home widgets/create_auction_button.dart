import 'package:alletre_app/view/screens/login%20screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:provider/provider.dart';
import '../../screens/auction screen/product_details_screen.dart';

class CreateAuctionButton extends StatelessWidget {
  const CreateAuctionButton({super.key});

  void _handleOptionSelected(BuildContext context, String option) {
    if (option == 'Create Auction') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailsScreen())); // Navigate to Add Location Screen
    } else if (option == 'List Products') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailsScreen())); // Navigate to List Products
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<LoggedInProvider>().isLoggedIn;

    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 58),
      child: SizedBox(
        height: 29,
        width: 86,
        child: Center(
          child: PopupMenuButton<String>(
            enabled: isLoggedIn,
            onSelected: (value) => _handleOptionSelected(context, value),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Create Auction',
                  child: Center(
                    child: Text(
                      'Create Auction',
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'List Products',
                  child: Center(
                    child: Text(
                      'List Products',
                    ),
                  ),
                ),
              ];
            },
            offset: const Offset(0, 40), // Position dropdown below the button
            child: FloatingActionButton.extended(
              onPressed: isLoggedIn
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
              label: Text(
                'Sell Now',
                style: TextStyle(
                  color: Theme.of(context).primaryColor
                ),
              ),
              backgroundColor: Theme.of(context).splashColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 0, // Remove elevation
              disabledElevation: 0, // Remove disabled elevation
            ),
          ),
        ),
      ),
    );
  }
}
