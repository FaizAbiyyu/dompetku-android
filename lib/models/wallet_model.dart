class WalletModel {
  final String name;
  final String icon;
  int balance;

  WalletModel({
    required this.name,
    required this.icon,
    required this.balance,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'balance': balance,
      };

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '💳',
      balance: json['balance'] as int,
    );
  }
}
