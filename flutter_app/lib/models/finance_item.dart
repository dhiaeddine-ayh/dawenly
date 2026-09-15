class FinanceItemModel {
  final int id;
  final double amount;
  final String category;
  final String? note;
  final String type; // 'expense' or 'income'
  final String date;
  final String? currency;

  FinanceItemModel({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    this.type = 'expense',
    required this.date,
    this.currency,
  });

  factory FinanceItemModel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString() ?? json['direction']?.toString() ?? 'expense';
    return FinanceItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : (double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0),
      category: json['category']?.toString() ?? 'أخرى',
      note: json['note']?.toString(),
      type: rawType == 'income' ? 'income' : 'expense',
      date: json['date']?.toString() ?? json['entry_date']?.toString() ?? DateTime.now().toIso8601String().substring(0, 10),
      currency: json['currency']?.toString() ?? 'EGP',
    );
  }

  bool get isExpense => type == 'expense';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'note': note,
      'direction': type,
      'entry_date': date,
      'currency': currency,
    };
  }
}
