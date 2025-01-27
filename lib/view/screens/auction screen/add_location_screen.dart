import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddLocationScreen extends StatelessWidget {
  const AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final countryController = TextEditingController();
    final cityController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final labelController = TextEditingController();

    return AlertDialog(
      title: const Text('Location is required *'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "In order to finish the procedure, we have to get access to your location. You can manage them later.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixText: '+971 ',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Address Label'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (countryController.text.isNotEmpty &&
                cityController.text.isNotEmpty &&
                addressController.text.isNotEmpty &&
                phoneController.text.isNotEmpty &&
                labelController.text.isNotEmpty) {
              context.read<TabIndexProvider>().updateIndex(10);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
