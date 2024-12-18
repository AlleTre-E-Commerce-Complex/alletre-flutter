import 'package:alletre_app/view/auction%20screen/create_auction_screen.dart';
import 'package:flutter/material.dart';
class CreateAuctionButton extends StatelessWidget {
  const CreateAuctionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 58),
      child: SizedBox(
        height: 29,
        width: 94,
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
    );
  }
}
