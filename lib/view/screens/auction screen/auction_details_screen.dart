import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/validators/create_auction_validators.dart';
import 'package:alletre_app/view/widgets/auction%20form%20widgets/switch_field.dart';
import 'package:flutter/material.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import 'shipping_details_screen.dart';

class AuctionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> productData;
  final List<String> imagePaths;

  const AuctionDetailsScreen({
    super.key, 
    required this.productData,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    // Controllers for auction-specific fields
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
      appBar: const NavbarElementsAppbar(
          appBarTitle: 'Create Auction', showBackButton: true),
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
                      Navigator.pop(context);
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
                        // Collect form data
                        final auctionData = {
                          ...productData, // Keep the product data structure intact
                          'startingPrice': double.tryParse(priceController.text)?.toString() ?? '0',
                          'duration': selectedDuration.value ?? '1 DAYS', // Pass full duration string including unit
                          'scheduleBid': scheduleBidSwitch.value,
                          'startDate': startDateController.text,
                          'startTime': startTimeController.text,
                          'buyNowEnabled': buyNowSwitch.value,
                          'buyNowPrice': double.tryParse(buyNowController.text)?.toString() ?? '0',
                          'returnPolicy': returnPolicySwitch.value ? returnPolicyController.text.trim() : null,
                          'warrantyPolicy': warrantyPolicySwitch.value ? warrantyPolicyController.text.trim() : null,
                        };

                        // Validate required fields
                        final product = auctionData['product'] as Map<String, dynamic>;
                        
                        if (product['title']?.isEmpty ?? true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Title is required')),
                          );
                          return;
                        }
                        if (product['description']?.isEmpty ?? true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Description is required')),
                          );
                          return;
                        }

                        // Debug log media files
                        debugPrint('AuctionDetailsScreen - Media files before navigation:');
                        debugPrint('Total files: ${imagePaths.length}');
                        for (var i = 0; i < imagePaths.length; i++) {
                          final path = imagePaths[i];
                          final isVideo = path.toLowerCase().endsWith('.mp4') || path.toLowerCase().endsWith('.mov');
                          debugPrint('  File $i: $path');
                          debugPrint('    Type: ${isVideo ? 'Video' : 'Image'}');
                        }

                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => ShippingDetailsScreen(
                              auctionData: auctionData,
                              imagePaths: imagePaths, 
                            )
                          )
                        );
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
