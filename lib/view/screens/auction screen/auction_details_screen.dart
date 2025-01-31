import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/validators/create_auction_validators.dart';
import 'package:alletre_app/view/widgets/auction%20widgets/switch_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuctionDetailsScreen extends StatelessWidget {
  const AuctionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final priceController = TextEditingController();
    final condition = ValueNotifier<String?>(null);
    final selectedDuration = ValueNotifier<String?>(null);
    final scheduleBidSwitch = ValueNotifier<bool>(false);
    final startDateController = TextEditingController();
    final startTimeController = TextEditingController();
    final buyNowSwitch = ValueNotifier<bool>(false);
    final buyNowController = TextEditingController();
    final returnPolicySwitch = ValueNotifier<bool>(false);
    final returnPolicyController = TextEditingController();
    final warrantyPolicySwitch = ValueNotifier<bool>(false);
    final warrantyPolicyController = TextEditingController();
    final isSubmitted = ValueNotifier<bool>(false);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () {
            context.read<TabIndexProvider>().updateIndex(19);
          },
        ),
        title: const Text(
          'Create Auction',
          style: TextStyle(color: secondaryColor, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Divider(thickness: 1, color: primaryColor),
                      const Center(
                        child: Text(
                          "Auction Details",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: onSecondaryColor),
                        ),
                      ),
                      const Divider(thickness: 1, color: primaryColor),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Auction Type",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: onSecondaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<bool>(
                        valueListenable: isSubmitted,
                        builder: (context, submitted, child) {
                          return ValueListenableBuilder<String?>(
                            valueListenable: condition,
                            builder: (context, value, child) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: "quickAuction",
                                        groupValue: value,
                                        onChanged: (selected) {
                                          condition.value = selected!;
                                          selectedDuration.value =
                                              null; // Reset dropdown
                                        },
                                      ),
                                      const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Quick Auction",
                                              style: radioTextStyle),
                                          Text(
                                            "Short-term auction with faster results",
                                            style: TextStyle(
                                                fontSize: 11, color: greyColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: "longAuction",
                                        groupValue: value,
                                        onChanged: (selected) {
                                          condition.value = selected!;
                                          selectedDuration.value =
                                              null; // Reset dropdown
                                        },
                                      ),
                                      const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Long Auction",
                                              style: radioTextStyle),
                                          Text(
                                            "Extended auction for better reach",
                                            style: TextStyle(
                                                fontSize: 11, color: greyColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (submitted && value == null)
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 8, top: 4),
                                        child: Text(
                                          "Please select an auction type",
                                          style: TextStyle(
                                              color: errorColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  if (value != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        ValueListenableBuilder<String?>(
                                          valueListenable: selectedDuration,
                                          builder:
                                              (context, selectedValue, child) {
                                            return DropdownButtonFormField<
                                                String>(
                                              decoration: InputDecoration(
                                                labelText: "Auction Duration",
                                                labelStyle: const TextStyle(
                                                    fontSize: 14),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color: errorColor),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color: errorColor),
                                                ),
                                              ),
                                              value: selectedValue,
                                              isExpanded: true,
                                              items: (value == "quickAuction"
                                                      ? List.generate(
                                                          24,
                                                          (index) =>
                                                              "${index + 1} hrs")
                                                      : List.generate(
                                                          7,
                                                          (index) =>
                                                              "${index + 1} days"))
                                                  .map((duration) =>
                                                      DropdownMenuItem<String>(
                                                        value: duration,
                                                        child: Text(duration,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  onSecondaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 15,
                                                            )),
                                                      ))
                                                  .toList(),
                                              onChanged: (newValue) {
                                                selectedDuration.value =
                                                    newValue;
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Please select a duration.";
                                                }
                                                return null;
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 18),
                                  SwitchWithField(
                                      label: 'Schedule Bid',
                                      leadingText:
                                          'If a start date and time are not chosen,\nyour listing becomes active immediately',
                                      switchNotifier: scheduleBidSwitch,
                                      isSchedulingEnabled: true,
                                      startDateController: startDateController,
                                      startTimeController: startTimeController),
                                  const SizedBox(height: 8),
                                  const Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Pricing",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: onSecondaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                    controller: priceController,
                                    decoration: InputDecoration(
                                      labelText: "Start Price",
                                      labelStyle: const TextStyle(fontSize: 14),
                                      hintText: "AED XXX",
                                      hintStyle: const TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide:
                                            const BorderSide(color: errorColor),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide:
                                            const BorderSide(color: errorColor),
                                      ),
                                    ),
                                    validator:
                                        CreateAuctionValidation.validatePrice,
                                  ),
                                  const SizedBox(height: 22),
                                  // Buy Now Logic
                                  SwitchWithField(
                                    label: 'Buy Now',
                                    leadingText:
                                        'Amount the user should pay\nto buy the item directly without auction',
                                    switchNotifier: buyNowSwitch,
                                    textController: buyNowController,
                                    labelText: 'Purchase Price',
                                    hintText: 'AED XXX',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                  ),
                                  const SizedBox(height: 12),
                                  // Return Policy Logic
                                  SwitchWithField(
                                    label: 'Return Policy',
                                    leadingText:
                                        'Write your own return related policy here',
                                    switchNotifier: returnPolicySwitch,
                                    textController: returnPolicyController,
                                    labelText: 'Return Policy Description',
                                    hintText:
                                        'Enter the return policy description',
                                  ),
                                  const SizedBox(height: 12),
                                  // Warranty Policy Logic
                                  SwitchWithField(
                                    label: 'Warranty Policy',
                                    leadingText:
                                        'Write your own warranty related policy here',
                                    switchNotifier: warrantyPolicySwitch,
                                    textController: warrantyPolicyController,
                                    labelText: 'Warranty Policy Description',
                                    hintText:
                                        'Enter the warranty policy description',
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<TabIndexProvider>().updateIndex(10);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      "Previous",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Set submitted to true to show validation errors
                      isSubmitted.value = true;
                      final isValid = formKey.currentState!.validate();

                      if (isValid) {
                        context.read<TabIndexProvider>().updateIndex(18);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text("Next",
                        style: TextStyle(color: secondaryColor)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
