import 'package:hive_flutter/hive_flutter.dart';
import '../models/review_model.dart';

class ReviewService {
  static const String _boxName = 'reviews';
  static Box<Review>? _box;

  // Initialize Hive database
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ReviewAdapter());
    }

    _box = await Hive.openBox<Review>(_boxName);
  }

  // Get box instance
  static Box<Review> get _reviewBox {
    if (_box == null) {
      throw Exception('ReviewService not initialized. Call init() first.');
    }
    return _box!;
  }

  // Add new review
  static Future<String> addReview({
    required int bikeId,
    required String reviewerName,
    required String reviewText,
    required int rating,
  }) async {
    try {
      final reviewId = DateTime.now().millisecondsSinceEpoch.toString();

      final review = Review(
        id: reviewId,
        bikeId: bikeId,
        reviewerName: reviewerName.trim(),
        reviewText: reviewText.trim(),
        rating: rating,
        createdAt: DateTime.now(),
      );

      await _reviewBox.put(reviewId, review);
      return reviewId;
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Get all reviews for a specific bike
  static List<Review> getReviewsForBike(int bikeId) {
    try {
      final reviews =
          _reviewBox.values.where((review) => review.bikeId == bikeId).toList();

      // Sort by creation date (newest first)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reviews;
    } catch (e) {
      print('Error getting reviews for bike $bikeId: $e');
      return [];
    }
  }

  // Get total number of reviews for a bike
  static int getReviewCountForBike(int bikeId) {
    try {
      return _reviewBox.values
          .where((review) => review.bikeId == bikeId)
          .length;
    } catch (e) {
      print('Error getting review count for bike $bikeId: $e');
      return 0;
    }
  }

  // Get average rating for a bike
  static double getAverageRatingForBike(int bikeId) {
    try {
      final reviews =
          _reviewBox.values.where((review) => review.bikeId == bikeId).toList();

      if (reviews.isEmpty) return 0.0;

      final totalRating =
          reviews.fold<int>(0, (sum, review) => sum + review.rating);
      return totalRating / reviews.length;
    } catch (e) {
      print('Error getting average rating for bike $bikeId: $e');
      return 0.0;
    }
  }

  // Delete a review
  static Future<bool> deleteReview(String reviewId) async {
    try {
      await _reviewBox.delete(reviewId);
      return true;
    } catch (e) {
      print('Error deleting review $reviewId: $e');
      return false;
    }
  }

  // Update a review
  static Future<bool> updateReview({
    required String reviewId,
    required String reviewerName,
    required String reviewText,
    required int rating,
  }) async {
    try {
      final review = _reviewBox.get(reviewId);
      if (review == null) {
        throw Exception('Review not found');
      }

      review.reviewerName = reviewerName.trim();
      review.reviewText = reviewText.trim();
      review.rating = rating;

      await review.save();
      return true;
    } catch (e) {
      print('Error updating review $reviewId: $e');
      return false;
    }
  }

  // Get all reviews (for debugging)
  static List<Review> getAllReviews() {
    try {
      return _reviewBox.values.toList();
    } catch (e) {
      print('Error getting all reviews: $e');
      return [];
    }
  }

  // Clear all reviews (for debugging)
  static Future<void> clearAllReviews() async {
    try {
      await _reviewBox.clear();
    } catch (e) {
      print('Error clearing all reviews: $e');
    }
  }

  // Close the box
  static Future<void> close() async {
    try {
      await _box?.close();
    } catch (e) {
      print('Error closing review box: $e');
    }
  }
}
