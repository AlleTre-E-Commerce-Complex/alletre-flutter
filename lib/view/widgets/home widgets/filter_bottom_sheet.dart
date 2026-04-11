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
              ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  _buildExpandableTile(
                      title: "CATEGORIES",
                      children: [
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'cars', label: Text('Cars'), icon: Icon(Icons.car_rental)),
                            ButtonSegment(value: 'properties', label: Text('Properties'), icon: Icon(Icons.apartment)),
                          ],
                          emptySelectionAllowed: true,
                          selected: {},
                          onSelectionChanged: (newSelection) {},
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Theme.of(context)
                                      .textSelectionTheme
                                      .selectionColor!
                                      .withValues(alpha: 0.1); // Selected background
                                }
                                return Theme.of(context).scaffoldBackgroundColor; // Unselected background
                              },
                            ),
                            // 2. Foreground (Text/Icon) Color
                            foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                return Theme.of(context).textSelectionTheme.selectionColor; // Selected text color
                              },
                            ),
                            // 3. Border (Side) customization
                            side: WidgetStateProperty.resolveWith<BorderSide>((Set<WidgetState> states) {
                              return BorderSide(
                                color: Theme.of(context).textSelectionTheme.selectionColor!, // Border color
                                width: 1.0, // Border thickness
                              );
                            }),
                          ),
                        )
                      ],
                      context: context),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Generic tile builder
  Widget _buildExpandableTile({required String title, required List<Widget> children, BuildContext? context}) {
    return Theme(
      data: Theme.of(context!).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD4AF37), // Golden color from screenshot
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: children,
        ),
      ),
    );
  }
}
