import 'package:shared_preferences/shared_preferences.dart';
import '../models/bike_model.dart';
import '../models/price_model.dart';
import '../models/currency_model.dart';
import '../services/api_service.dart';
import '../services/currency_service.dart';
import 'dart:convert';

class PriceService {
  static const String _pricesKey = 'bike_prices';
  static const String _selectedCurrencyKey = 'selected_price_currency';

  // Get all bike prices
  static Future<List<BikePrice>> getBikePrices() async {
    try {
      // First try to get from local storage
      final prefs = await SharedPreferences.getInstance();
      final pricesJson = prefs.getStringList(_pricesKey);

      if (pricesJson != null && pricesJson.isNotEmpty) {
        return pricesJson
            .map((item) => BikePrice.fromJson(json.decode(item)))
            .toList();
      }

      // If no local data, generate from API bikes
      return await _generatePricesFromAPI();
    } catch (e) {
      print('Error getting bike prices: $e');
      return [];
    }
  }

  // Generate prices from API bikes data
  static Future<List<BikePrice>> _generatePricesFromAPI() async {
    try {
      final bikes = await ApiService.getBikes();
      List<BikePrice> bikePrices = [];

      for (Bike bike in bikes) {
        double price = BikePrice.generateDummyPrice(bike.brand, bike.type);
        bikePrices.add(BikePrice.fromBike(bike, price));
      }

      // Save to local storage
      await _savePricesToLocal(bikePrices);
      return bikePrices;
    } catch (e) {
      print('Error generating prices from API: $e');
      return [];
    }
  }

  // Save prices to local storage
  static Future<void> _savePricesToLocal(List<BikePrice> prices) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pricesJson =
          prices.map((price) => json.encode(price.toJson())).toList();
      await prefs.setStringList(_pricesKey, pricesJson);
    } catch (e) {
      print('Error saving prices to local: $e');
    }
  }

  // Get selected currency for price display
  static Future<Currency> getSelectedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // First check if we have a price-specific currency set
      String currencyCode = prefs.getString(_selectedCurrencyKey) ?? '';

      // If no price-specific currency, use the last used currency from converter
      if (currencyCode.isEmpty) {
        currencyCode = await CurrencyService.getLastUsedCurrency();
      }

      return Currency.fromCode(currencyCode);
    } catch (e) {
      print('Error getting selected currency: $e');
      return Currency.fromCode('IDR');
    }
  }

  // Set selected currency for price display
  static Future<void> setSelectedCurrency(String currencyCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedCurrencyKey, currencyCode);
    } catch (e) {
      print('Error setting selected currency: $e');
    }
  }

  // Convert price to selected currency
  static Future<double> convertPrice(double priceIDR, String toCurrency) async {
    if (toCurrency == 'IDR') {
      return priceIDR;
    }

    try {
      return await CurrencyService.convertCurrency(
        amount: priceIDR,
        fromCurrency: 'IDR',
        toCurrency: toCurrency,
      );
    } catch (e) {
      print('Error converting price: $e');
      return priceIDR; // Return original price if conversion fails
    }
  }

  // Format price with currency symbol
  static String formatPrice(double price, Currency currency) {
    return CurrencyService.formatCurrency(price, currency);
  }

  // Refresh prices (regenerate from API)
  static Future<List<BikePrice>> refreshPrices() async {
    try {
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pricesKey);

      // Generate new prices
      return await _generatePricesFromAPI();
    } catch (e) {
      print('Error refreshing prices: $e');
      return [];
    }
  }

  // Search prices by brand or type
  static List<BikePrice> searchPrices(List<BikePrice> prices, String query) {
    if (query.isEmpty) return prices;

    return prices
        .where((price) =>
            price.brand.toLowerCase().contains(query.toLowerCase()) ||
            price.type.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Sort prices
  static List<BikePrice> sortPrices(List<BikePrice> prices, String sortBy) {
    List<BikePrice> sortedPrices = List.from(prices);

    switch (sortBy) {
      case 'price_low':
        sortedPrices.sort((a, b) => a.priceIDR.compareTo(b.priceIDR));
        break;
      case 'price_high':
        sortedPrices.sort((a, b) => b.priceIDR.compareTo(a.priceIDR));
        break;
      case 'brand':
        sortedPrices.sort((a, b) => a.brand.compareTo(b.brand));
        break;
      case 'type':
        sortedPrices.sort((a, b) => a.type.compareTo(b.type));
        break;
      default:
        // Default sort by brand then type
        sortedPrices.sort((a, b) {
          int brandCompare = a.brand.compareTo(b.brand);
          if (brandCompare != 0) return brandCompare;
          return a.type.compareTo(b.type);
        });
    }

    return sortedPrices;
  }
}
