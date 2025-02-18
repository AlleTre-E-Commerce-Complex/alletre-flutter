import 'package:flutter/material.dart';

class AuctionFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController imageUrlController;
  final TextEditingController priceController;

  const AuctionFormFields({
    super.key,
    required this.titleController,
    required this.imageUrlController,
    required this.priceController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
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
      ],
    );
  }
}
