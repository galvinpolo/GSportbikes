import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency_model.dart';

class CurrencyService {
  static const String _baseUrl = 'https://api.frankfurter.dev/v1';
  static const String _historyKey = 'conversion_history';
  static const String _lastUsedCurrencyKey = 'last_used_currency';
  static const int _maxHistoryItems = 10;
  // Get exchange rates from API
  static Future<ExchangeRate> getExchangeRates({
    String baseCurrency = 'IDR',
    List<String>? symbols,
  }) async {
    try {
      String symbolsParam = '';
      if (symbols != null && symbols.isNotEmpty) {
        symbolsParam = '&symbols=${symbols.join(',')}';
      }

      final url = '$_baseUrl/latest?from=$baseCurrency$symbolsParam';
      print('Fetching exchange rates from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Exchange rate data: $data');
        return ExchangeRate.fromJson(data);
      } else {
        throw Exception(
            'Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
      throw Exception('Failed to fetch exchange rates: $e');
    }
  }

  // Convert currency
  static Future<double> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final exchangeRate = await getExchangeRates(
        baseCurrency: fromCurrency,
        symbols: [toCurrency],
      );

      final rate = exchangeRate.getRate(toCurrency);
      if (rate == null) {
        throw Exception('Exchange rate not found for $toCurrency');
      }

      final result = amount * rate;

      // Save to history
      await _saveConversionHistory(ConversionHistory(
        amount: amount,
        fromCurrency: Currency.fromCode(fromCurrency),
        toCurrency: Currency.fromCode(toCurrency),
        result: result,
        rate: rate,
        timestamp: DateTime.now(),
      ));

      // Track last used currencies for price integration
      await setLastUsedCurrency(toCurrency);

      return result;
    } catch (e) {
      print('Error converting currency: $e');
      throw Exception('Failed to convert currency: $e');
    }
  }

  // Get conversion history
  static Future<List<ConversionHistory>> getConversionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      return historyJson
          .map((item) => ConversionHistory.fromJson(json.decode(item)))
          .toList()
          .reversed
          .toList(); // Most recent first
    } catch (e) {
      print('Error loading conversion history: $e');
      return [];
    }
  }

  // Save conversion to history
  static Future<void> _saveConversionHistory(
      ConversionHistory conversion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      // Add new conversion to the beginning
      historyJson.insert(0, json.encode(conversion.toJson()));

      // Keep only the most recent items
      if (historyJson.length > _maxHistoryItems) {
        historyJson.removeRange(_maxHistoryItems, historyJson.length);
      }

      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      print('Error saving conversion history: $e');
    }
  }

  // Clear conversion history
  static Future<void> clearConversionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing conversion history: $e');
    }
  }

  // Format currency amount
  static String formatCurrency(double amount, Currency currency) {
    if (currency.code == 'IDR') {
      // Format IDR with thousands separator
      return '${currency.symbol} ${_formatNumber(amount.round())}';
    } else {
      // Format other currencies with 2 decimal places
      return '${currency.symbol} ${amount.toStringAsFixed(2)}';
    }
  }

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  // Get currency flag emoji (optional)
  static String getCurrencyFlag(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'IDR':
        return '🇮🇩';
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'THB':
        return '🇹🇭';
      case 'JPY':
        return '🇯🇵';
      case 'GBP':
        return '🇬🇧';
      case 'SGD':
        return '🇸🇬';
      case 'MYR':
        return '🇲🇾';
      default:
        return '💱';
    }
  }

  // Get last used currency for price integration
  static Future<String> getLastUsedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastUsedCurrencyKey) ?? 'IDR';
    } catch (e) {
      print('Error getting last used currency: $e');
      return 'IDR';
    }
  }

  // Set last used currency for price integration
  static Future<void> setLastUsedCurrency(String currencyCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUsedCurrencyKey, currencyCode);
    } catch (e) {
      print('Error setting last used currency: $e');
    }
  }
}
