import 'package:flutter/material.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Filter Option: Categories
              _buildFilterTile(
                context,
                title: 'Categories',
                icon: Icons.category,
                onTap: () {
                  // Navigate to or display a category picker
                },
              ),
              // Filter Option: Brand
              _buildFilterTile(
                context,
                title: 'Brand',
                icon: Icons.branding_watermark,
                onTap: () {
                  // Navigate to or display a brand picker
                },
              ),
              // Filter Option: Selling Type
              _buildFilterTile(
                context,
                title: 'Selling Type',
                icon: Icons.sell,
                onTap: () {
                  // Navigate to or display selling type options
                },
              ),
              // Filter Option: Auction State
              _buildFilterTile(
                context,
                title: 'Auction State',
                icon: Icons.gavel,
                onTap: () {
                  // Navigate to or display auction state options
                },
              ),
              // Filter Option: Location
              _buildFilterTile(
                context,
                title: 'Location',
                icon: Icons.location_on,
                onTap: () {
                  // Navigate to or display location options
                },
              ),
              // Filter Option: Condition
              _buildFilterTile(
                context,
                title: 'Condition',
                icon: Icons.build,
                onTap: () {
                  // Navigate to or display condition picker
                },
              ),
              // Filter Option: Price
              _buildFilterTile(
                context,
                title: 'Price',
                icon: Icons.price_change,
                onTap: () {
                  // Navigate to or display price range picker
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle filter application logic
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Adjust border radius here
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12), // Optional padding for better appearance
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(height: 8), // Bottom padding for the button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
