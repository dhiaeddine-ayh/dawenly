class FinanceItemModel {
  final int id;
  final double amount;
  final String category;
  final String? note;
  final String type; // 'expense' or 'income'
  final String date;

  FinanceItemModel({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    this.type = 'expense',
    required this.date,
  });

  factory FinanceItemModel.fromJson(Map<String, dynamic> json) {
    return FinanceItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : (double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0),
      category: json['category']?.toString() ?? 'أخرى',
      note: json['note']?.toString(),
      type: json['type']?.toString() ?? 'expense',
      date: json['date']?.toString() ?? DateTime.now().toIso8601String().substring(0, 10),
    );
  }
}
