class Currency {
  final String code;
  final String name;
  final String symbol;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  static Currency fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'IDR':
        return Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp');
      case 'USD':
        return Currency(code: 'USD', name: 'US Dollar', symbol: '\$');
      case 'EUR':
        return Currency(code: 'EUR', name: 'Euro', symbol: '€');
      case 'THB':
        return Currency(code: 'THB', name: 'Thai Baht', symbol: '฿');
      default:
        return Currency(code: code, name: code, symbol: code);
    }
  }

  static List<Currency> getSupportedCurrencies() {
    return [
      Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp'),
      Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
      Currency(code: 'EUR', name: 'Euro', symbol: '€'),
      Currency(code: 'THB', name: 'Thai Baht', symbol: '฿'),
    ];
  }

  // Add equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code - $name';
}

class ExchangeRate {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime date;

  ExchangeRate({
    required this.baseCurrency,
    required this.rates,
    required this.date,
  });
  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    // Convert rates ensuring all values are doubles
    Map<String, double> convertedRates = {};
    if (json['rates'] != null) {
      (json['rates'] as Map<String, dynamic>).forEach((key, value) {
        if (value is num) {
          convertedRates[key] = value.toDouble();
        }
      });
    }

    return ExchangeRate(
      baseCurrency: json['base'] ?? 'IDR',
      rates: convertedRates,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  double? getRate(String currencyCode) {
    return rates[currencyCode.toUpperCase()];
  }

  double convertAmount(double amount, String toCurrency) {
    final rate = getRate(toCurrency);
    if (rate == null) return 0.0;
    return amount * rate;
  }
}

class ConversionHistory {
  final double amount;
  final Currency fromCurrency;
  final Currency toCurrency;
  final double result;
  final double rate;
  final DateTime timestamp;

  ConversionHistory({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.result,
    required this.rate,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'fromCurrency': fromCurrency.code,
      'toCurrency': toCurrency.code,
      'result': result,
      'rate': rate,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ConversionHistory.fromJson(Map<String, dynamic> json) {
    return ConversionHistory(
      amount: json['amount']?.toDouble() ?? 0.0,
      fromCurrency: Currency.fromCode(json['fromCurrency'] ?? 'IDR'),
      toCurrency: Currency.fromCode(json['toCurrency'] ?? 'USD'),
      result: json['result']?.toDouble() ?? 0.0,
      rate: json['rate']?.toDouble() ?? 0.0,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
