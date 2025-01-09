import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:provider/provider.dart';

class CreateAuctionButton extends StatelessWidget {
  const CreateAuctionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<LoggedInProvider>().isLoggedIn;

    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 58),
      child: SizedBox(
        height: 29,
        width: 94,
        child: FloatingActionButton.extended(
          onPressed: isLoggedIn
              ? () {
                  context.read<TabIndexProvider>().updateIndex(10);
                }
              : null, 
          label: Text(
            'Create Auction',
            style: TextStyle(
              color: isLoggedIn
                  ? Theme.of(context).primaryColor
                  : const Color(0xFFFFFFFF).withAlpha(102),
            ),
          ),
          backgroundColor: isLoggedIn
              ? Theme.of(context).splashColor
              : const Color(0xFFBDBDBD).withAlpha(62),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 0, 
          disabledElevation: 0, 
        ),
      ),
    );
  }
}
