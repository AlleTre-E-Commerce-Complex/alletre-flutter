import 'package:flutter/material.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
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
                      context: context,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Inside your FilterBottomSheet ListView:
                    _buildExpandableTile(
                      title: "PRICE",
                      context: context,
                      children: [
                        const RangeWidget(),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildExpandableTile(
                      title: "BRAND",
                      context: context,
                      children: [
                        const ToggleGroup(),
                      ],
                    ),
                  ],
                )
              ],
            ),
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
            style: TextStyle(
              color: Theme.of(context).textSelectionTheme.selectionColor, // Golden color from screenshot
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

class RangeWidget extends StatefulWidget {
  const RangeWidget({super.key});

  @override
  State<RangeWidget> createState() => _RangeWidgetState();
}

class _RangeWidgetState extends State<RangeWidget> {
  RangeValues _currentRangeValues = const RangeValues(1, 1000000);
  final TextEditingController _minController = TextEditingController(text: "1");
  final TextEditingController _maxController = TextEditingController(text: "1000000");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. The Range Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).textSelectionTheme.selectionColor, // Gold color
            inactiveTrackColor: Theme.of(context).textSelectionTheme.selectionColor!.withValues(alpha: 0.3),
            thumbColor: Theme.of(context).scaffoldBackgroundColor,
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
          ),
          child: RangeSlider(
            values: _currentRangeValues,
            min: 1,
            max: 1000000,
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
                _minController.text = values.start.round().toString();
                _maxController.text = values.end.round().toString();
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        // 2. The Input Boxes
        Row(
          children: [
            Expanded(child: _buildRangeInput(_minController)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text("—", style: TextStyle(color: Colors.grey)),
            ),
            Expanded(child: _buildRangeInput(_maxController)),
          ],
        ),
      ],
    );
  }

  Widget _buildRangeInput(TextEditingController controller) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16, color: Color(0xFF2E3E5C)),
            ),
          ),
          // Up/Down arrows icon
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_arrow_up, size: 14, color: Colors.grey.shade400),
                Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey.shade400),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ToggleGroup extends StatefulWidget {
  const ToggleGroup({super.key});

  @override
  State<ToggleGroup> createState() => _ToggleGroupState();
}

class _ToggleGroupState extends State<ToggleGroup> {
  // Store multiple selected brands
  final Set<String> _selectedBrands = {'AION', 'AUDI'};

  final List<String> _brands = [
    '212',
    'ABARTH',
    'ACURA',
    'AION',
    'ALFA ROMEO',
    'ASTON MARTIN',
    'AUDI',
    'AVATR',
    'BAIC',
    'BENTLEY',
    'BESTUNE',
    'BMW',
    'BORGWARD',
    'BRILLIANCE',
    'BUGATTI',
    'BYD'
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // Gap between adjacent chips
      runSpacing: 8.0, // Gap between lines
      children: _brands.map((brand) {
        final isSelected = _selectedBrands.contains(brand);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedBrands.remove(brand);
              } else {
                _selectedBrands.add(brand);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF9E7) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Theme.of(context).textSelectionTheme.selectionColor! : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Text(
              brand,
              style: TextStyle(
                color: isSelected ? Theme.of(context).textSelectionTheme.selectionColor : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
