// ignore_for_file: library_private_types_in_public_api

import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/view/widgets/auction_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_auction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ongoingAuctions = context.watch<AuctionProvider>().ongoingAuctions;
    final upcomingAuctions = context.watch<AuctionProvider>().upcomingAuctions;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5b0c1f),
        title: const Text('Alletre'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.language),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const CreateAuctionScreen(),
                ),
              );
            },
            child: const Text('Create Auction'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search on Alletre',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Get the ideal Buyer for Your unique Item...'),
            ),
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
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFc73659),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
