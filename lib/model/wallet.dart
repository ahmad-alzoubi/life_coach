class Wallet {
  String userId;
  String balance;

  Wallet({
    required this.userId,
    required this.balance,
  });

  Wallet.fromJson(Map<String, dynamic> json)
      : userId = json['user_id'].toString(),
        balance = json['balance'].toString();

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'balance': balance,
      };
}