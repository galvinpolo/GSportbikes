import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/price_model.dart';
import '../models/currency_model.dart';
import '../services/price_service.dart';

class PricePage extends StatefulWidget {
  const PricePage({super.key});

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  List<BikePrice> _allPrices = [];
  List<BikePrice> _filteredPrices = [];
  Currency _selectedCurrency = Currency.fromCode('IDR');
  Map<int, double> _convertedPrices = {};
  bool _isLoading = true;
  bool _isConverting = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'brand';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load prices and selected currency
      final prices = await PriceService.getBikePrices();
      final currency = await PriceService.getSelectedCurrency();

      setState(() {
        _allPrices = prices;
        _filteredPrices = PriceService.sortPrices(prices, _sortBy);
        _selectedCurrency = currency;
        _isLoading = false;
      });

      // Convert prices if not IDR
      if (_selectedCurrency.code != 'IDR') {
        _convertAllPrices();
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convertAllPrices() async {
    if (_selectedCurrency.code == 'IDR') {
      setState(() {
        _convertedPrices.clear();
      });
      return;
    }

    setState(() {
      _isConverting = true;
    });

    Map<int, double> newConvertedPrices = {};

    for (BikePrice price in _allPrices) {
      try {
        double convertedPrice = await PriceService.convertPrice(
            price.priceIDR, _selectedCurrency.code);
        newConvertedPrices[price.id] = convertedPrice;
      } catch (e) {
        print('Error converting price for ${price.brand} ${price.type}: $e');
        newConvertedPrices[price.id] =
            price.priceIDR; // Fallback to original price
      }
    }

    setState(() {
      _convertedPrices = newConvertedPrices;
      _isConverting = false;
    });
  }

  void _searchPrices(String query) {
    setState(() {
      _searchQuery = query;
      List<BikePrice> searchResults =
          PriceService.searchPrices(_allPrices, query);
      _filteredPrices = PriceService.sortPrices(searchResults, _sortBy);
    });
  }

  void _changeCurrency(Currency newCurrency) async {
    setState(() {
      _selectedCurrency = newCurrency;
    });

    await PriceService.setSelectedCurrency(newCurrency.code);
    await _convertAllPrices();
  }

  void _changeSortOrder(String newSortBy) {
    setState(() {
      _sortBy = newSortBy;
      _filteredPrices = PriceService.sortPrices(_filteredPrices, _sortBy);
    });
  }

  double _getDisplayPrice(BikePrice bikePrice) {
    if (_selectedCurrency.code == 'IDR') {
      return bikePrice.priceIDR;
    }
    return _convertedPrices[bikePrice.id] ?? bikePrice.priceIDR;
  }

  Widget _buildPriceCard(BikePrice bikePrice) {
    double displayPrice = _getDisplayPrice(bikePrice);
    bool isConverting = _isConverting && _selectedCurrency.code != 'IDR';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Bike Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child:
                  bikePrice.bikeImage != null && bikePrice.bikeImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildBikeImage(bikePrice.bikeImage!),
                        )
                      : const Icon(
                          Icons.motorcycle,
                          size: 40,
                          color: Colors.grey,
                        ),
            ),
            const SizedBox(width: 16),

            // Bike Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bikePrice.brand,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bikePrice.type,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  if (isConverting)
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.green[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Converting...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      PriceService.formatPrice(displayPrice, _selectedCurrency),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeImage(String base64Image) {
    try {
      String base64String = base64Image;
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }

      Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.motorcycle,
            size: 40,
            color: Colors.grey,
          );
        },
      );
    } catch (e) {
      return const Icon(
        Icons.motorcycle,
        size: 40,
        color: Colors.grey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Bike Prices',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Currency Selector
          PopupMenuButton<Currency>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedCurrency.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
            onSelected: _changeCurrency,
            itemBuilder: (context) => Currency.getSupportedCurrencies()
                .map((currency) => PopupMenuItem<Currency>(
                      value: currency,
                      child: Row(
                        children: [
                          Text(currency.symbol),
                          const SizedBox(width: 8),
                          Text('${currency.code} - ${currency.name}'),
                        ],
                      ),
                    ))
                .toList(),
          ),

          // Sort Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: _changeSortOrder,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'brand',
                child: Text('Sort by Brand'),
              ),
              const PopupMenuItem(
                value: 'type',
                child: Text('Sort by Type'),
              ),
              const PopupMenuItem(
                value: 'price_low',
                child: Text('Price: Low to High'),
              ),
              const PopupMenuItem(
                value: 'price_high',
                child: Text('Price: High to Low'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchPrices,
                decoration: InputDecoration(
                  hintText: 'Search by brand or type...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.deepPurple),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _searchPrices('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Price List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.deepPurple),
                        SizedBox(height: 16),
                        Text('Loading bike prices...'),
                      ],
                    ),
                  )
                : _filteredPrices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.price_check,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No bikes found for "$_searchQuery"'
                                  : 'No price data available',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _searchPrices('');
                                },
                                child: const Text('Clear search'),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredPrices.length,
                          itemBuilder: (context, index) {
                            return _buildPriceCard(_filteredPrices[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
