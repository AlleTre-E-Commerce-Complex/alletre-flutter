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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        foregroundColor: Theme.of(context).textTheme.bodyMedium!.color,
                        minimumSize: const Size(59, 25),
                        maximumSize: const Size(150, 26),
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(fontSize: 14),
                        side: BorderSide(color: Theme.of(context).textSelectionTheme.selectionColor!)),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textSelectionTheme.selectionColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    'Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        foregroundColor: Theme.of(context).textTheme.bodyMedium!.color,
                        minimumSize: const Size(59, 25),
                        maximumSize: const Size(60, 26),
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(fontSize: 14),
                        side: BorderSide(color: Theme.of(context).primaryColor)),
                    child: Text(
                      'Apply',
                      style:
                          TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                    ),
                  )
                ],
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
              // Center(
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Handle filter application logic
              //       Navigator.pop(context); // Close the bottom sheet
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Theme.of(context).primaryColorDark,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8), // Adjust border radius here
              //       ),
              //       padding: const EdgeInsets.symmetric(
              //           horizontal: 24, vertical: 12), // Optional padding for better appearance
              //     ),
              //     child: Text(
              //       'Apply',
              //       style: TextStyle(
              //           color: Theme.of(context).textTheme.bodyMedium!.color,
              //           fontWeight: FontWeight.w600,
              //           fontSize: 13),
              //     ),
              //   ),
              // ),
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
