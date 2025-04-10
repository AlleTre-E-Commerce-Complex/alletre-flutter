class BankAccount {
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String routingNumber;

  BankAccount({
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.routingNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'routingNumber': routingNumber,
    };
  }

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountHolderName: json['accountHolderName'] as String,
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      routingNumber: json['routingNumber'] as String,
    );
  }
}