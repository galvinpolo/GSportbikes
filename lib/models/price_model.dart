import 'bike_model.dart';

class BikePrice {
  final int id;
  final String brand;
  final String type;
  final double priceIDR; // Base price in IDR
  final String? bikeImage;

  BikePrice({
    required this.id,
    required this.brand,
    required this.type,
    required this.priceIDR,
    this.bikeImage,
  });

  factory BikePrice.fromBike(Bike bike, double price) {
    return BikePrice(
      id: bike.id,
      brand: bike.brand,
      type: bike.type,
      priceIDR: price,
      bikeImage: bike.bikeImage,
    );
  }

  // Generate dummy prices based on brand and type
  static double generateDummyPrice(String brand, String type) {
    Map<String, double> brandMultipliers = {
      'Honda': 1.0,
      'Yamaha': 1.1,
      'Suzuki': 0.9,
      'Kawasaki': 1.2,
      'Ducati': 3.0,
      'BMW': 4.0,
      'Harley-Davidson': 5.0,
    };

    // Base prices for different categories
    double basePrice = 25000000; // 25 million IDR

    if (type.toLowerCase().contains('sport') ||
        type.toLowerCase().contains('racing')) {
      basePrice = 45000000; // 45 million IDR
    } else if (type.toLowerCase().contains('touring') ||
        type.toLowerCase().contains('adventure')) {
      basePrice = 60000000; // 60 million IDR
    } else if (type.toLowerCase().contains('cruiser')) {
      basePrice = 80000000; // 80 million IDR
    } else if (type.toLowerCase().contains('scooter') ||
        type.toLowerCase().contains('matic')) {
      basePrice = 15000000; // 15 million IDR
    }

    // Apply brand multiplier
    double multiplier = brandMultipliers[brand] ?? 1.0;

    // Add some randomness (±20%)
    double randomFactor = 0.8 + (type.hashCode % 400) / 1000.0; // 0.8 to 1.2

    return (basePrice * multiplier * randomFactor).roundToDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'type': type,
      'priceIDR': priceIDR,
      'bikeImage': bikeImage,
    };
  }

  factory BikePrice.fromJson(Map<String, dynamic> json) {
    return BikePrice(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      type: json['type'] ?? '',
      priceIDR: (json['priceIDR'] ?? 0).toDouble(),
      bikeImage: json['bikeImage'],
    );
  }
}
