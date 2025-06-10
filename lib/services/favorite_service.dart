import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bike_model.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorite_bikes';

  // Get all favorite bikes
  static Future<List<Bike>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      List<Bike> favorites = [];
      for (String bikeJson in favoritesJson) {
        try {
          final Map<String, dynamic> bikeMap = jsonDecode(bikeJson);
          favorites.add(Bike.fromJson(bikeMap));
        } catch (e) {
          print('Error parsing favorite bike: $e');
        }
      }

      return favorites;
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  // Add bike to favorites
  static Future<bool> addToFavorites(Bike bike) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();

      // Check if bike is already in favorites
      if (favorites.any((favBike) => favBike.id == bike.id)) {
        return false; // Already in favorites
      }

      // Add to favorites
      favorites.add(bike);

      // Convert to JSON strings
      List<String> favoritesJson =
          favorites.map((bike) => jsonEncode(bike.toJson())).toList();

      // Save to SharedPreferences
      await prefs.setStringList(_favoritesKey, favoritesJson);
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove bike from favorites
  static Future<bool> removeFromFavorites(int bikeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();

      // Remove bike with matching ID
      favorites.removeWhere((bike) => bike.id == bikeId);

      // Convert to JSON strings
      List<String> favoritesJson =
          favorites.map((bike) => jsonEncode(bike.toJson())).toList();

      // Save to SharedPreferences
      await prefs.setStringList(_favoritesKey, favoritesJson);
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Check if bike is in favorites
  static Future<bool> isFavorite(int bikeId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((bike) => bike.id == bikeId);
    } catch (e) {
      print('Error checking if favorite: $e');
      return false;
    }
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(Bike bike) async {
    try {
      final isCurrentlyFavorite = await isFavorite(bike.id);

      if (isCurrentlyFavorite) {
        await removeFromFavorites(bike.id);
        return false; // Removed from favorites
      } else {
        await addToFavorites(bike);
        return true; // Added to favorites
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Clear all favorites
  static Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  // Get favorites count
  static Future<int> getFavoritesCount() async {
    try {
      final favorites = await getFavorites();
      return favorites.length;
    } catch (e) {
      print('Error getting favorites count: $e');
      return 0;
    }
  }
}
