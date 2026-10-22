class TransactionModel {
  final String id;
  final String title;
  final String category;
  final String wallet;
  final int amount;
  final String type; // 'EXPENSE' or 'INCOME'
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.wallet,
    required this.amount,
    required this.type,
    required this.date,
  });

  bool get isExpense => type == 'EXPENSE';
  bool get isIncome => type == 'INCOME';

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'wallet': wallet,
        'amount': amount,
        'type': type,
        'date': date.toIso8601String(),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      wallet: json['wallet'] as String,
      amount: json['amount'] as int,
      type: json['type'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
