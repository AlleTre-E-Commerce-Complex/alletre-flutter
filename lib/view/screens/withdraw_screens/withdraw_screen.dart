import 'package:alletre_app/model/bank_account.dart';
import 'package:alletre_app/services/bank_account_service.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';
import 'add_bank_account_screen.dart';

class WithdrawScreen extends StatelessWidget {
  final double balance;
  
  const WithdrawScreen({super.key, required this.balance});

  Future<List<BankAccount>?> _getBankAccounts() async {
    try {
      final accounts = await BankAccountService.getAccountData();
      return accounts;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final ValueNotifier<int?> selectedAccountIndex = ValueNotifier<int?>(null);
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: onSecondaryColor,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasAccounts)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 370),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: bankAccounts.length,
                              itemBuilder: (context, index) => Container(
                                padding: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    selectedAccountIndex.value = index;
                                  },
                                  child: ValueListenableBuilder<int?>(
                                    valueListenable: selectedAccountIndex,
                                    builder: (context, selectedIndex, _) => Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: selectedIndex == index ? primaryColor : dividerColor,
                                          width: selectedIndex == index ? 1.3 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Account Holder Name : ${bankAccounts[index].accountHolderName}',
                                              style: const TextStyle(fontSize: 12, color: onSecondaryColor, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Bank Name : ${bankAccounts[index].bankName}',
                                              style: const TextStyle(fontSize: 12, color: onSecondaryColor, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Bank Account Number : ${bankAccounts[index].accountNumber}',
                                              style: const TextStyle(fontSize: 12, color: onSecondaryColor, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'IBAN Number : ${bankAccounts[index].routingNumber}',
                                              style: const TextStyle(fontSize: 12, color: onSecondaryColor, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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
                        
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddBankAccountScreen(balance: balance),
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
                  
                  const SizedBox(height: 10),
                  
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
                        if (selectedAccountIndex.value == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Center(child: Text('Please select a bank account')),
                              backgroundColor: errorColor,
                            ),
                          );
                          return;
                        }
                        
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
          ),
        );
      },
    );
  }
}
