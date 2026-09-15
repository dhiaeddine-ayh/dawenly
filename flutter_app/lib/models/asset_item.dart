class AssetItemModel {
  final int id;
  final String name;
  final String type; // 'gold', 'cash', 'other', 'liability'
  final double quantity;
  final int? karat; // 24, 22, 21, 18, 14
  final String currency; // 'EGP', 'USD', 'EUR', 'SAR', 'AED', 'GBP'
  final double? manualValue;
  final double? goal;

  AssetItemModel({
    required this.id,
    required this.name,
    required this.type,
    this.quantity = 0.0,
    this.karat = 21,
    this.currency = 'EGP',
    this.manualValue,
    this.goal,
  });

  factory AssetItemModel.fromJson(Map<String, dynamic> json) {
    return AssetItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'gold',
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toDouble()
          : double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      karat: json['karat'] is int
          ? json['karat']
          : int.tryParse(json['karat']?.toString() ?? '21'),
      currency: json['currency']?.toString() ?? 'EGP',
      manualValue: json['manual_value'] != null
          ? (json['manual_value'] as num).toDouble()
          : null,
      goal: json['goal'] != null ? (json['goal'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'quantity': quantity,
      'karat': karat,
      'currency': currency,
      'manual_value': manualValue,
      'goal': goal,
    };
  }

  double calculateValueEgp({double goldG24 = 3700.0, Map<String, double>? rates}) {
    final currencyRates = rates ?? {
      'EGP': 1.0,
      'USD': 48.60,
      'EUR': 52.80,
      'SAR': 12.95,
      'AED': 13.23,
      'GBP': 62.10,
    };

    if (type == 'gold') {
      final k = karat ?? 21;
      return quantity * goldG24 * (k / 24.0);
    } else if (type == 'cash' || type == 'liability') {
      final rate = currencyRates[currency] ?? 1.0;
      return quantity * rate;
    } else {
      return manualValue ?? 0.0;
    }
  }
}
