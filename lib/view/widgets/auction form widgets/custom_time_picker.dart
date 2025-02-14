import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class CustomTimePicker {
  static Future<TimeOfDay?> showTimePickerDialog(BuildContext context) async {
    int selectedHour = TimeOfDay.now().hour;
    int selectedMinute = TimeOfDay.now().minute;
    String period = selectedHour >= 12 ? "PM" : "AM";

    // Convert to 12-hour format for display
    int selectedHour12 = selectedHour % 12 == 0 ? 12 : selectedHour % 12;

    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero, // Remove the default padding
          title: Container(
              decoration: const BoxDecoration(
                color: primaryColor, // Set background color for the top section
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), // Round the top corners
                  topRight: Radius.circular(15),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 25, top: 15, bottom: 15),
                child: Text("Select time",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor)),
              )),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour Picker
                  DropdownButton<int>(
                    value: selectedHour12,
                    items: List.generate(
                      12,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: onSecondaryColor),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedHour12 = value;
                        });
                      }
                    },
                  ),
                  const Text(" :  ", style: TextStyle(color: onSecondaryColor)),
                  // Minute Picker
                  DropdownButton<int>(
                    value: selectedMinute,
                    items: List.generate(
                      60,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: onSecondaryColor),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedMinute = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  // AM/PM Picker
                  DropdownButton<String>(
                    value: period,
                    items: ["AM", "PM"]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: onSecondaryColor),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          period = value;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text("Cancel",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () {
                // Convert selected hour back to 24-hour format
                int finalHour = (period == "PM" && selectedHour12 != 12)
                    ? selectedHour12 + 12
                    : (period == "AM" && selectedHour12 == 12)
                        ? 0
                        : selectedHour12;

                Navigator.pop(
                  context,
                  TimeOfDay(hour: finalHour, minute: selectedMinute),
                );
              },
              child: const Text("OK",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
