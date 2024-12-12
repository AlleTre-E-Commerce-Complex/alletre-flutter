import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/model/auction_item.dart';

class CreateAuctionScreen extends StatelessWidget {
  const CreateAuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final imageUrlController = TextEditingController();
    final priceController = TextEditingController();
    DateTime? scheduledTime;

    void saveAuction() {
      if (!formKey.currentState!.validate()) return;

      final newAuction = AuctionItem(
        title: titleController.text,
        imageUrl: imageUrlController.text,
        price: priceController.text,
        scheduledTime: scheduledTime!,
      );

      context.read<AuctionProvider>().addUpcomingAuction(newAuction);
      Navigator.of(context).pop();
    }

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
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Text(
                'Scheduled Time',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedTime != null) {
                    scheduledTime = pickedTime;
                  }
                },
                child: const Text('Pick Scheduled Time'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (scheduledTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a scheduled time')),
                    );
                    return;
                  }
                  saveAuction();
                },
                child: const Text('Save Auction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}