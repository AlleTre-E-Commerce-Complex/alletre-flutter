// create_auction_screen.dart
import 'package:alletre_app/controller/helpers/auction_screen_helper.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/view/widgets/auction_form_fields.dart';
import 'package:alletre_app/view/widgets/auction_screen_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateAuctionScreen extends StatelessWidget {
  const CreateAuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final imageUrlController = TextEditingController();
    final priceController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Auction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuctionFormFields(
                titleController: titleController,
                imageUrlController: imageUrlController,
                priceController: priceController,
              ),
              Consumer<AuctionProvider>(
                builder: (context, auctionProvider, child) {
                  return AuctionScreenButtons(
                    onPickTime: () => AuctionHelper.pickScheduledTime(context),
                    onSave: () => AuctionHelper.saveAuction(
                      context: context,
                      formKey: formKey,
                      titleController: titleController,
                      imageUrlController: imageUrlController,
                      priceController: priceController,
                    ),
                    scheduledTime: auctionProvider.scheduledTime,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
