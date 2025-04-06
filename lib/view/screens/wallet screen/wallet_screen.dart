import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alletre_app/controller/helpers/user_services.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:provider/provider.dart';

const errorColor = Colors.red;

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  Future<String?> _getValidToken() async {
    try {
      final storage = const FlutterSecureStorage();
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

      final response = await ApiService.get('/wallet/get_balance');
      double balance = 0.0;
      List<WalletTransaction> transactions = [];

      if (response.statusCode == 200) {
        balance = double.tryParse(response.data.toString()) ?? 0.0;
      }

      return {
        'balance': balance,
        'transactions': transactions,
      };
    } catch (e) {
      debugPrint('Error fetching wallet data: $e');
      if (e.toString().contains('403') || e.toString().contains('token')) {
        throw Exception('Session expired. Please login again.');
      }
      throw Exception('Failed to load wallet data');
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
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: errorColor),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: errorColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TabIndexProvider>()
                        .updateIndex(0), // 0 is wallet page index
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final walletBalance = data['balance'] as double;
          final transactions = data['transactions'] as List<WalletTransaction>;

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
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildTransactionItem(context, transactions[index]),
                    childCount: transactions.length,
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
      margin: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wallet Balance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AED ${NumberFormat('#,##0.00').format(balance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement withdraw functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, WalletTransaction transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.type == TransactionType.deposit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.type == TransactionType.deposit
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: transaction.type == TransactionType.deposit
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(transaction.date),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.type == TransactionType.deposit ? '+' : '-'} AED ${NumberFormat('#,##0.00').format(transaction.amount)}',
            style: TextStyle(
              color: transaction.type == TransactionType.deposit
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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

  WalletTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      description: json['description'],
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
      type: json['type'] == 'deposit'
          ? TransactionType.deposit
          : TransactionType.withdrawal,
    );
  }
}
