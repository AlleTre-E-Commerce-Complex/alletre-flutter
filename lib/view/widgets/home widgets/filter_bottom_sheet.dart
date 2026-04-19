import 'package:alletre_app/utils/category_filters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> carBrandData;
  final String defaultCategory;
  const FilterBottomSheet({super.key, required this.carBrandData, required this.defaultCategory});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final categoryNotifier = ValueNotifier<String>('');
  ValueNotifier<List<String>>? modelNotifier;
  List<Map<String, dynamic>> lstSelectedValues = [];
  @override
  void initState() {
    super.initState();
    categoryNotifier.value = widget.defaultCategory;
  }

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
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textSelectionTheme.selectionColor, fontWeight: FontWeight.w600),
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
                        style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
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
                    ValueListenableBuilder(
                      valueListenable: categoryNotifier,
                      builder: (context, value, child) {
                        return _buildExpandableTile(
                          title: "CATEGORIES",
                          initiallyExpanded: true,
                          children: [
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'cars', label: Text('Cars'), icon: Icon(Icons.car_rental)),
                                ButtonSegment(value: 'properties', label: Text('Properties'), icon: Icon(Icons.apartment)),
                              ],
                              emptySelectionAllowed: true,
                              selected: {categoryNotifier.value},
                              onSelectionChanged: (newSelection) {
                                categoryNotifier.value = newSelection.single;
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Theme.of(context).textSelectionTheme.selectionColor!.withValues(alpha: 0.1); // Selected background
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
                        );
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ValueListenableBuilder(
                      valueListenable: categoryNotifier,
                      builder: (context, value, child) {
                        if (value != "") {
                          var lstWidgets = generateFilterWidgets(value, context);
                          lstWidgets
                              .map((widget) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 0),
                                    child: widget,
                                  ))
                              .toList();
                          return Column(
                            children: lstWidgets,
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
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

  List<Widget> generateFilterWidgets(String category, BuildContext context) {
    List<Widget> lstFilters = [];
    var filterFields = [];
    if (category == 'cars') {
      filterFields = filtersCar;
    } else if (category == 'property') {
      filterFields = filtersProperty;
    }
    int index = 0;
    for (var filter in filterFields) {
      if (filter['type'] == 'toggle_group') {
        List<String> lstValues = [];
        if (filter['values'] is String && filter['name'] == 'BRAND') {
          for (var name in widget.carBrandData) {
            lstValues.add(name.keys.single);
          }
        } else if (filter['name'] == 'MODEL') {
          modelNotifier = ValueNotifier<List<String>>([]);
        } else {
          lstValues = filter['values'] as List<String>;
        }
        lstFilters.add(_buildExpandableTile(
          title: filter['name'].toString(),
          initiallyExpanded: false,
          context: context,
          children: [
            ToggleGroup(
              key: ValueKey(index),
              lstValues: lstValues,
              modelFilterNotifier: filter['name'] == 'MODEL' ? modelNotifier : null,
              onSelectionChanged: (selectedValues) {
                int _idxFilter = lstSelectedValues.indexWhere((_filter) => filter['name'] == _filter['name']);
                if (_idxFilter == -1) {
                  lstSelectedValues.add({'name': filter['name'], 'type': filter['type'], 'values': selectedValues});
                } else if (_idxFilter > -1) {
                  lstSelectedValues[_idxFilter] = {'name': filter['name'], 'type': filter['type'], 'values': selectedValues};
                }
                if (selectedValues.isEmpty) {
                  lstSelectedValues.removeAt(_idxFilter);
                }
                if (filter['name'] == 'BRAND') {
                  List<String> lstModelValues = [];
                  for (String brandName in selectedValues) {
                    for (Map<String, dynamic> brandInfo in widget.carBrandData) {
                      if (brandName == brandInfo.keys.single) {
                        for (String modelName in (brandInfo[brandName]['models'] as Map<String, dynamic>).keys) {
                          lstModelValues.add(modelName);
                        }
                        break;
                      }
                    }
                  }
                  int _idxModel = lstSelectedValues.indexWhere((_filterModel) => _filterModel['name'] == 'MODEL');
                  if (_idxModel > -1) {
                    lstSelectedValues[_idxModel]['values'].removeWhere((_selectedModel) {
                      int _idxModel = lstModelValues.indexWhere((_model) => _model == _selectedModel);
                      if (_idxModel == -1) {
                        return true;
                      } else {
                        return false;
                      }
                    });
                  }
                  Future.delayed(const Duration(milliseconds: 500), () {
                    modelNotifier!.value = lstModelValues;
                  });
                }
              },
              fetchInitialValues: () {
                Set<String> initialValues = Set<String>.from(lstSelectedValues.singleWhere(
                  (_selectedFilter) => _selectedFilter['name'] == filter['name'],
                  orElse: () {
                    return Map<String, dynamic>.from({'name': 'default', 'values': []});
                  },
                )['values']);
                return initialValues;
              },
            ),
          ],
        ));
        lstFilters.add(SizedBox(
          height: 10,
        ));
      } else if (filter['type'] == 'range_selector') {
        print(filter['need_adjuster']);
        lstFilters.add(_buildExpandableTile(
          title: filter['name'].toString(),
          initiallyExpanded: false,
          context: context,
          children: [
            RangeWidget(
              key: ValueKey(index),
              adjusterEnabled: filter['need_adjuster'] as bool,
              minValue: double.parse((filter['values'] as Map<String, dynamic>)['min'].toString()),
              maxValue: double.parse((filter['values'] as Map<String, dynamic>)['max'].toString()),
              onSelectionChanged: (minValue, maxValue) {
                int _idxFilter = lstSelectedValues.indexWhere((_filter) => filter['name'] == _filter['name']);
                if (_idxFilter == -1) {
                  lstSelectedValues.add({
                    'name': filter['name'],
                    'type': filter['type'],
                    'values': {'min': minValue, 'max': maxValue}
                  });
                } else if (_idxFilter > -1) {
                  lstSelectedValues[_idxFilter] = {
                    'name': filter['name'],
                    'type': filter['type'],
                    'values': {'min': minValue, 'max': maxValue}
                  };
                }
              },
              fetchInitialValues: () {
                var rangeValues = lstSelectedValues.singleWhere(
                  (_selectedFilter) => _selectedFilter['name'] == filter['name'],
                  orElse: () {
                    return Map<String, dynamic>.from({'name': 'default', 'values': filter['values']});
                  },
                )['values'];
                double selectedMinValue = double.parse(rangeValues['min'].toString());
                double selectedMaxValue = double.parse(rangeValues['max'].toString());
                return RangeValues(selectedMinValue, selectedMaxValue);
              },
            ),
          ],
        ));
        lstFilters.add(SizedBox(
          height: 10,
        ));
      }
      index++;
    }
    return lstFilters;
  }

  // Generic tile builder
  Widget _buildExpandableTile({required String title, required List<Widget> children, BuildContext? context, required bool initiallyExpanded}) {
    return Theme(
      data: Theme.of(context!).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
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
  final bool adjusterEnabled;
  final double minValue;
  final double maxValue;
  final Function(double minValue, double maxValue) onSelectionChanged;
  final RangeValues Function() fetchInitialValues;
  const RangeWidget({super.key, required this.adjusterEnabled, required this.minValue, required this.maxValue, required this.onSelectionChanged, required this.fetchInitialValues});

  @override
  State<RangeWidget> createState() => _RangeWidgetState();
}

class _RangeWidgetState extends State<RangeWidget> {
  RangeValues _currentRangeValues = RangeValues(1, 1000000);
  TextEditingController _minController = TextEditingController(text: "1");
  TextEditingController _maxController = TextEditingController(text: "100000");

  @override
  void initState() {
    super.initState();
    _currentRangeValues = widget.fetchInitialValues();
    _minController = TextEditingController(text: _currentRangeValues.start.round().toString());
    _maxController = TextEditingController(text: _currentRangeValues.end.round().toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.adjusterEnabled)
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
              min: widget.minValue,
              max: widget.maxValue,
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                  _minController.text = values.start.round().toString();
                  _maxController.text = values.end.round().toString();
                  widget.onSelectionChanged(_currentRangeValues.start, _currentRangeValues.end);
                });
              },
            ),
          ),
        const SizedBox(height: 16),
        // 2. The Input Boxes
        Row(
          children: [
            Expanded(
                child: _buildRangeInput(
              controller: _minController,
              onRangeChanged: (rangeValue) {
                double rangeStart = double.parse(rangeValue == "" ? "0" : rangeValue);
                if (rangeStart >= widget.minValue && rangeStart < widget.maxValue) {
                  setState(() {
                    if (rangeStart > _currentRangeValues.end) {
                      _currentRangeValues = RangeValues(_currentRangeValues.end, _currentRangeValues.end);
                    } else {
                      _currentRangeValues = RangeValues(rangeStart, _currentRangeValues.end);
                    }
                    widget.onSelectionChanged(_currentRangeValues.start, _currentRangeValues.end);
                  });
                }
              },
            )),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text("—", style: TextStyle(color: Colors.grey)),
            ),
            Expanded(
                child: _buildRangeInput(
              controller: _maxController,
              onRangeChanged: (rangeValue) {
                double rangeEnd = double.parse(rangeValue == "" ? "0" : rangeValue);
                if (rangeEnd <= widget.maxValue && rangeEnd > widget.minValue) {
                  setState(() {
                    if (rangeEnd < _currentRangeValues.start) {
                      _currentRangeValues = RangeValues(_currentRangeValues.start, _currentRangeValues.start);
                    } else {
                      _currentRangeValues = RangeValues(_currentRangeValues.start, rangeEnd);
                    }
                    widget.onSelectionChanged(_currentRangeValues.start, _currentRangeValues.end);
                  });
                }
              },
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildRangeInput({required TextEditingController controller, required Function(String rangeValue) onRangeChanged}) {
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
              onChanged: onRangeChanged,
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
  final List<String> lstValues;
  final Function(Set<String> selectedValues) onSelectionChanged;
  final ValueNotifier<List<String>>? modelFilterNotifier;
  final Set<String> Function() fetchInitialValues;
  const ToggleGroup({super.key, required this.lstValues, required this.onSelectionChanged, this.modelFilterNotifier, required this.fetchInitialValues});

  @override
  State<ToggleGroup> createState() => _ToggleGroupState();
}

class _ToggleGroupState extends State<ToggleGroup> {
  // Store multiple selected values
  final Set<String> _selected = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selected.clear();
    _selected.addAll(widget.fetchInitialValues());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = 0;
    if (widget.lstValues.isEmpty) {
      height = 50;
    } else {
      height = widget.lstValues.length * 30;
      if (height > 200) {
        height = 200;
      }
    }
    Widget scrollbarWidget = SizedBox(
      height: height,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Wrap(
            spacing: 8.0, // Gap between adjacent chips
            runSpacing: 8.0, // Gap between lines
            children: _generateChildWidgets(widget.lstValues),
          ),
        ),
      ),
    );
    if (widget.modelFilterNotifier != null) {
      return ValueListenableBuilder(
        valueListenable: widget.modelFilterNotifier!,
        builder: (context, value, child) {
          if (value.isNotEmpty) {
            widget.lstValues.clear();
            widget.lstValues.addAll(value);
            double height = 0;
            if (widget.lstValues.isEmpty) {
              height = 50;
            } else {
              height = widget.lstValues.length * 50;
              if (height > 200) {
                height = 200;
              }
            }
            scrollbarWidget = SizedBox(
              height: height,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Wrap(
                    spacing: 8.0, // Gap between adjacent chips
                    runSpacing: 8.0, // Gap between lines
                    children: _generateChildWidgets(widget.lstValues),
                  ),
                ),
              ),
            );
          }
          return scrollbarWidget;
        },
      );
    }
    return scrollbarWidget;
  }

  List<Widget> _generateChildWidgets(List<String> lstValues) {
    List<Widget> childWidgets = [];
    for (var value in lstValues) {
      final isSelected = _selected.contains(value);

      childWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selected.remove(value);
              } else {
                _selected.add(value);
              }
            });
            widget.onSelectionChanged(_selected);
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
              value,
              style: TextStyle(
                color: isSelected ? Theme.of(context).textSelectionTheme.selectionColor : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }
    return childWidgets;
  }
}
