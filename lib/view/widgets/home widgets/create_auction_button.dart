import 'package:flutter/material.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:provider/provider.dart';
import '../../../utils/auth_helper.dart';
import '../../screens/auction screen/product_details_screen.dart';

class CreateAuctionButton extends StatelessWidget {
  const CreateAuctionButton({super.key});

  // Generate a unique hero tag for each instance
  static int _tagCounter = 0;
  static String _getUniqueHeroTag() => 'create_auction_fab_${_tagCounter++}';

  void _handleOptionSelected(BuildContext context, String option) {
    if (option == 'Create Auction') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailsScreen(title: 'Create Auction'))); 
    } else if (option == 'List Product') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailsScreen(title: 'List Product'))); 
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
          child: FloatingActionButton.extended(
            heroTag: _getUniqueHeroTag(), // Use unique hero tag
            onPressed: () {
              if (!isLoggedIn) {
                AuthHelper.showAuthenticationRequiredMessage(context);
                return;
              }
              // Show popup menu manually
              final RenderBox button = context.findRenderObject() as RenderBox;
              final Offset offset = button.localToGlobal(Offset.zero);
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy + 40, // 40 is the offset we defined
                  offset.dx + button.size.width,
                  offset.dy + button.size.height + 40,
                ),
                items: [
                  PopupMenuItem<String>(
                    value: 'Create Auction',
                    child: const Center(child: Text('Create Auction')),
                    onTap: () => _handleOptionSelected(context, 'Create Auction'),
                  ),
                  PopupMenuItem<String>(
                    value: 'List Product',
                    child: const Center(child: Text('List Product')),
                    onTap: () => _handleOptionSelected(context, 'List Product'),
                  ),
                ],
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
    );
  }
}
