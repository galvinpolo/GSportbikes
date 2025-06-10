import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        if (index < rating.floor()) {
          // Full star
          return Icon(
            Icons.star,
            size: size,
            color: activeColor,
          );
        } else if (index < rating) {
          // Half star
          return Icon(
            Icons.star_half,
            size: size,
            color: activeColor,
          );
        } else {
          // Empty star
          return Icon(
            Icons.star_border,
            size: size,
            color: inactiveColor,
          );
        }
      }),
    );
  }
}

class InteractiveRatingStars extends StatefulWidget {
  final int initialRating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final Function(int) onRatingChanged;

  const InteractiveRatingStars({
    super.key,
    required this.onRatingChanged,
    this.initialRating = 0,
    this.maxRating = 5,
    this.size = 24,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  });

  @override
  State<InteractiveRatingStars> createState() => _InteractiveRatingStarsState();
}

class _InteractiveRatingStarsState extends State<InteractiveRatingStars> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = starIndex;
            });
            widget.onRatingChanged(starIndex);
          },
          child: Icon(
            starIndex <= _currentRating ? Icons.star : Icons.star_border,
            size: widget.size,
            color: starIndex <= _currentRating
                ? widget.activeColor
                : widget.inactiveColor,
          ),
        );
      }),
    );
  }
}
