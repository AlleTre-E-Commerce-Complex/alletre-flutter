class BankAccount {
  final int id;
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String routingNumber;

  BankAccount({
    required this.id,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.routingNumber,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      accountHolderName: json['accountHolderName'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      routingNumber: json['routingNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'routingNumber': routingNumber,
    };
  }
}