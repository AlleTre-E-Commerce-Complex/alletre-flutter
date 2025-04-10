import 'package:alletre_app/model/bank_account.dart';
import 'package:alletre_app/services/bank_account_service.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'add_bank_account_screen.dart';

class WithdrawScreen extends StatelessWidget {
  final double balance;
  
  const WithdrawScreen({super.key, required this.balance});

  Future<List<BankAccount>?> _getBankAccounts() async {
    try {
      debugPrint('Fetching bank accounts in WithdrawScreen');
      final accounts = await BankAccountService.getAccountData();
      debugPrint('Received ${accounts.length} accounts in WithdrawScreen');
      return accounts;
    } catch (e) {
      debugPrint('Error getting bank accounts in WithdrawScreen: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final refreshKey = UniqueKey();
    debugPrint('Building WithdrawScreen with key: $refreshKey');
    
    return FutureBuilder<List<BankAccount>?>(
      key: refreshKey,
      future: _getBankAccounts(),
      builder: (context, snapshot) {
        debugPrint('FutureBuilder state: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Error in FutureBuilder: ${snapshot.error}');
          return Scaffold(
            appBar: const NavbarElementsAppbar(
              appBarTitle: 'Bank Details',
              showBackButton: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: errorColor),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading bank accounts',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Force a rebuild of the FutureBuilder
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final bankAccounts = snapshot.data;
        final hasAccounts = bankAccounts != null && bankAccounts.isNotEmpty;
        debugPrint('Has accounts: $hasAccounts (${bankAccounts?.length ?? 0} accounts)');

        return Scaffold(
          appBar: const NavbarElementsAppbar(
            appBarTitle: 'Bank Details',
            showBackButton: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasAccounts)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: bankAccounts.length,
                            itemBuilder: (context, index) => Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account Holder Name : ${bankAccounts[index].accountHolderName}',
                                    style: const TextStyle(fontSize: 14, color: onSecondaryColor),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bank Name : ${bankAccounts[index].bankName}',
                                    style: const TextStyle(fontSize: 14, color: onSecondaryColor),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bank Account Number : ${bankAccounts[index].accountNumber}',
                                    style: const TextStyle(fontSize: 14, color: onSecondaryColor),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'IBAN Number : ${bankAccounts[index].routingNumber}',
                                    style: const TextStyle(fontSize: 14, color: onSecondaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_sharp,
                                size: 44,
                                color: Theme.of(context).disabledColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No bank accounts added yet..!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddBankAccountScreen(),
                              ),
                            ).then((_) {
                              // Force a rebuild of the FutureBuilder
                              (context as Element).markNeedsBuild();
                            });
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size(58, 32),
                            maximumSize: const Size(108, 32),
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Add Account', style: TextStyle(color: secondaryColor)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter the amount:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Amount',
                        hintStyle: const TextStyle(fontSize: 14),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixText: 'AED ',
                        prefixStyle: const TextStyle(fontSize: 14, color: onSecondaryColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                      Icon(Icons.info_outline, color: avatarColor, size: 15),
                      const SizedBox(width: 4),
                    Text(
                      'Amount must be more than AED 1',
                      style: TextStyle(
                        fontSize: 11,
                        color: avatarColor,
                      ),
                    ),
                  ],
                ),
                  ],
                ),
                
                const SizedBox(height: 30),

                Center(
                  child: ElevatedButton(
                    onPressed: !hasAccounts ? null : () {
                      final amount = amountController.text;
                      if (amount.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Center(child: Text('Please enter an amount')),
                            backgroundColor: errorColor,
                          ),
                        );
                        return;
                      }
                      
                      final amountValue = double.tryParse(amount);
                      if (amountValue == null || amountValue <= 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Amount must be greater than AED 1'),
                            backgroundColor: errorColor,
                          ),
                        );
                        return;
                      }
                      
                      if (amountValue > balance) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Insufficient balance'),
                            backgroundColor: errorColor,
                          ),
                        );
                        return;
                      }
                    },
                    style: ElevatedButton.styleFrom(       
                        backgroundColor: primaryColor,
                        disabledBackgroundColor: Theme.of(context).disabledColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    child: const Text('Submit withdrawal request', style: TextStyle(color: secondaryColor, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
