import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/model/auction_item.dart';

class CreateAuctionScreen extends StatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateAuctionScreenState createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _imageUrl;
  late String _price;
  late DateTime _scheduledTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Auction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                onSaved: (value) {
                  _title = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                onSaved: (value) {
                  _imageUrl = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                onSaved: (value) {
                  _price = value ?? '';
                },
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
                    setState(() {
                      _scheduledTime = pickedTime;
                    });
                  }
                },
                child: const Text('Pick Scheduled Time'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAuction,
                child: const Text('Save Auction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAuction() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final newAuction = AuctionItem(
      title: _title,
      imageUrl: _imageUrl,
      price: _price,
      scheduledTime: _scheduledTime,
    );

    context.read<AuctionProvider>().addUpcomingAuction(newAuction);

    Navigator.of(context).pop();
  }
}
