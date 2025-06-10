import 'package:hive/hive.dart';

part 'review_model.g.dart';

@HiveType(typeId: 0)
class Review extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int bikeId;

  @HiveField(2)
  String reviewerName;

  @HiveField(3)
  String reviewText;

  @HiveField(4)
  int rating;

  @HiveField(5)
  DateTime createdAt;

  Review({
    required this.id,
    required this.bikeId,
    required this.reviewerName,
    required this.reviewText,
    required this.rating,
    required this.createdAt,
  });

  // Convert to JSON for debugging
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bikeId': bikeId,
      'reviewerName': reviewerName,
      'reviewText': reviewText,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      bikeId: json['bikeId'] ?? 0,
      reviewerName: json['reviewerName'] ?? '',
      reviewText: json['reviewText'] ?? '',
      rating: json['rating'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
