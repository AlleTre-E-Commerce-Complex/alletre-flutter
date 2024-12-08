import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:flutter/material.dart';

class CreateAuctionScreen extends StatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateAuctionScreenState createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Input fields
  String _title = '';
  String _imageUrl = '';
  String _price = '';
  String _status = 'active'; // Default value

  // void _saveAuction() {
  //   if (!_formKey.currentState!.validate()) return;

  //   _formKey.currentState!.save();

  //   final newAuction = AuctionItem(
  //     title: _title,
  //     imageUrl: _imageUrl,
  //     price: _price,
  //     status: _status,
  //   );

  //   // Add to the relevant list based on status
  //   if (_status == 'active') {
  //     context.read<AuctionProvider>().addOngoingAuction(newAuction);
  //   } else if (_status == 'scheduled') {
  //     context.read<AuctionProvider>().addUpcomingAuction(newAuction);
  //   }

  //   Navigator.of(context).pop(); // Return to previous screen
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Auction'),
        backgroundColor: const Color(0xFF5b0c1f),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Image URL'),
                onSaved: (value) => _imageUrl = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an image URL' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _price = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a price' : null,
              ),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('active')),
                  DropdownMenuItem(value: 'scheduled', child: Text('scheduled')),
                ],
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAuction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFc73659),
                ),
                child: const Text('Create Auction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
