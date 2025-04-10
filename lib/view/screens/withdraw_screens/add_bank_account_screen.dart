// ignore_for_file: use_build_context_synchronously

import 'package:alletre_app/model/bank_account.dart';
import 'package:alletre_app/services/bank_account_service.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';
import 'success_dialog.dart';
import 'withdraw_screen.dart'; // Import WithdrawScreen

class AddBankAccountScreen extends StatelessWidget {
  final double balance;
  
  const AddBankAccountScreen({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final accountHolderController = TextEditingController();
    final bankNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final ibanController = TextEditingController();

    return Scaffold(
      appBar: const NavbarElementsAppbar(
        appBarTitle: 'Add new account',
        showBackButton: true,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: accountHolderController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                  labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account holder name';
                  }
                  if (value.length < 3) {
                    return 'Account name must be at least 3 characters long';
                  }
                  if (!RegExp(r'^[a-zA-Z\s]*$').hasMatch(value)) {
                    return 'Account name can only contain letters and spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank name';
                  }
                  if (value.length < 3) {
                    return 'Bank name must be at least 3 characters long';
                  }
                  if (!RegExp(r'^[a-zA-Z\s]*$').hasMatch(value)) {
                    return 'Bank name can only contain letters and spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Bank Account Number',
                  labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  if (value.length < 8) {
                    return 'Account number must be at least 8 characters long';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Account number must contain only numbers';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: ibanController,
                decoration: const InputDecoration(
                  labelText: 'IBAN Number',
                  labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter IBAN number';
                  }
                  if (!RegExp(r'^AE[0-9]{21}$').hasMatch(value.toUpperCase())) {
                    return 'Invalid IBAN format.\nMust start with AE followed by 21 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final bankAccount = BankAccount(
                        accountHolderName: accountHolderController.text,
                        bankName: bankNameController.text,
                        accountNumber: accountNumberController.text,
                        routingNumber: ibanController.text.toUpperCase(),
                      );
                              
                      await BankAccountService.addBankAccount(bankAccount);
                              
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const SuccessDialog(),
                        ).then((_) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WithdrawScreen(balance: balance),
                            ),
                          );
                        });
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: errorColor,
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                child: const Text('Add Bank Account', style: TextStyle(fontSize: 13, color: secondaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
