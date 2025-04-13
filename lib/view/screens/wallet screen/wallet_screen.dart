import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alletre_app/controller/helpers/user_services.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:provider/provider.dart';
import '../withdraw_screens/withdraw_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  Future<String?> _getValidToken() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      if (token == null) {
        debugPrint('No access token found, attempting refresh');
        final refreshResult = await UserService().refreshTokens();
        if (refreshResult['success']) {
          return refreshResult['data']['accessToken'];
        }
        return null;
      }
      return token;
    } catch (e) {
      debugPrint('Error getting/refreshing token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchWalletData() async {
    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('Session expired. Please login again.');
      }

      // Fetch balance
      final balanceResponse = await ApiService.get('/wallet/get_balance');
      double balance = 0.0;
      if (balanceResponse.statusCode == 200) {
        final dynamic balanceData = balanceResponse.data;
        if (balanceData is int) {
          balance = balanceData.toDouble();
        } else if (balanceData is double) {
          balance = balanceData;
        } else {
          balance = double.tryParse(balanceData.toString()) ?? 0.0;
        }
      } else if (balanceResponse.statusCode == 403) {
        throw Exception('Session expired. Please login again.');
      }

      // Fetch transactions
      final transactionsResponse =
          await ApiService.get('/wallet/get_from_wallet');
      List<WalletTransaction> transactions = [];
      if (transactionsResponse.statusCode == 200 &&
          transactionsResponse.data is List) {
        transactions = (transactionsResponse.data as List)
            .map((json) => WalletTransaction.fromJson(json))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } else if (transactionsResponse.statusCode == 403) {
        throw Exception('Session expired. Please login again.');
      }

      return {
        'balance': balance,
        'transactions': transactions,
        'needsAuth': false,
      };
    } catch (e) {
      debugPrint('Error fetching wallet data: $e');
      if (e.toString().contains('403') || e.toString().contains('token')) {
        throw Exception('Session expired. Please login again.');
      }
      // Return empty data instead of throwing an error
      return {
        'balance': 0.0,
        'transactions': [],
        'needsAuth': false,
      };
    }
  }

  void _handleSessionExpired(BuildContext context) {
    // Clear stored tokens
    const FlutterSecureStorage().delete(key: 'access_token');

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your session has expired. Please log in again.'),
        backgroundColor: errorColor,
      ),
    );

    // Navigate to login screen using TabIndexProvider
    context.read<TabIndexProvider>().updateIndex(18); // login page index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavbarElementsAppbar(
        appBarTitle: 'My Wallet',
        showBackButton: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchWalletData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            if (snapshot.error.toString().contains('Session expired')) {
              // Handle session expiration
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleSessionExpired(context);
              });
              return const Center(child: CircularProgressIndicator());
            }
            
            // Show a more user-friendly error state
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load wallet data',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Force a rebuild to retry loading the data
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Tap to retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final walletBalance = data['balance'] as double;
          final transactions = data['transactions'] as List<WalletTransaction>;
          final needsAuth = data['needsAuth'] as bool;

          if (needsAuth) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please login to view wallet data',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Navigate to login screen using TabIndexProvider
                      context.read<TabIndexProvider>().updateIndex(18); // login page index
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Force a rebuild with new data
              context
                  .read<TabIndexProvider>()
                  .updateIndex(0); // 0 is wallet page index
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildWalletCard(context, walletBalance),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),

                // const SliverToBoxAdapter(
                //   child: Padding(
                //     padding: EdgeInsets.all(16.0),
                //     child: Text(
                //       'Transaction History',
                //       style: TextStyle(
                //         color: onSecondaryColor,
                //         fontSize: 18,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
                SliverToBoxAdapter(
                  child: transactions.isEmpty
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: Theme.of(context).disabledColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.only(bottom: 26),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Table Header
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.4),
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildHeaderCell('Date', 120),
                                      _buildHeaderCell('Description', 200),
                                      _buildHeaderCell('Withdrawals', 120),
                                      _buildHeaderCell('Deposits', 120),
                                      _buildHeaderCell('Balance', 120),
                                    ],
                                  ),
                                ),
                                // Table Rows
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.6),
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    children: transactions
                                        .map((transaction) =>
                                            _buildTransactionRow(
                                                context, transaction))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, double balance) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 26, bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wallet Balance',
            style: TextStyle(
              color: secondaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AED ${NumberFormat('#,##0.00').format(balance)}',
            style: const TextStyle(
              color: secondaryColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WithdrawScreen(balance: balance),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Withdraw', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: onSecondaryColor,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text, double width,
      {Color? textColor, bool alignCenter = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? onSecondaryColor,
          fontSize: 11,
        ),
        textAlign: alignCenter ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Widget _buildTransactionRow(
      BuildContext context, WalletTransaction transaction) {
    final dateStr = DateFormat('MMM d, yyyy').format(transaction.date);
    final amountStr = NumberFormat('#,##0.00').format(transaction.amount);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell(dateStr, 120, alignCenter: true),
          _buildDataCell(transaction.description, 200, alignCenter: true),
          _buildDataCell(
            transaction.type == TransactionType.withdrawal
                ? 'AED $amountStr'
                : '-',
            120,
            textColor: transaction.type == TransactionType.withdrawal
                ? errorColor
                : null,
            alignCenter: true,
          ),
          _buildDataCell(
            transaction.type == TransactionType.deposit
                ? 'AED $amountStr'
                : '-',
            120,
            textColor: transaction.type == TransactionType.deposit
                ? activeColor
                : null,
            alignCenter: true,
          ),
          _buildDataCell(
            'AED ${NumberFormat('#,##0.00').format(transaction.balance)}',
            120,
            alignCenter: true,
          ),
        ],
      ),
    );
  }
}

enum TransactionType { deposit, withdrawal }

class WalletTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String transactionType;
  final double balance;

  WalletTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.transactionType,
    required this.balance,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.parse(value.toString());
    }

    return WalletTransaction(
      id: json['id'].toString(),
      description: json['description'],
      amount: parseAmount(json['amount']),
      date: DateTime.parse(json['date']),
      type: json['status'] == 'DEPOSIT'
          ? TransactionType.deposit
          : TransactionType.withdrawal,
      transactionType: json['transactionType'] ?? '',
      balance: parseAmount(json['balance']),
    );
  }
}
