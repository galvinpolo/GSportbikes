import 'package:flutter/material.dart';
import 'dart:math' as math;

class CompassWidget extends StatelessWidget {
  final double heading;
  final double size;

  const CompassWidget({
    super.key,
    required this.heading,
    this.size = 250.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass background
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  Colors.grey.shade100,
                  Colors.grey.shade200,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // Compass markings
          Transform.rotate(
            angle: -heading * (math.pi / 180),
            child: CustomPaint(
              size: Size(size, size),
              painter: CompassPainter(),
            ),
          ),

          // North indicator (static)
          Positioned(
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'N',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Compass needle (static)
          Container(
            width: 4,
            height: size * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.red,
                  Colors.white,
                  Colors.blue,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Center dot
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw degree markings
    for (int i = 0; i < 360; i += 30) {
      final angle = i * (math.pi / 180);
      final startRadius = radius - 20;
      final endRadius = radius - 10;

      final start = Offset(
        center.dx + startRadius * math.cos(angle - math.pi / 2),
        center.dy + startRadius * math.sin(angle - math.pi / 2),
      );

      final end = Offset(
        center.dx + endRadius * math.cos(angle - math.pi / 2),
        center.dy + endRadius * math.sin(angle - math.pi / 2),
      );

      canvas.drawLine(start, end, paint);
    }

    // Draw minor degree markings
    final minorPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 360; i += 10) {
      if (i % 30 != 0) {
        final angle = i * (math.pi / 180);
        final startRadius = radius - 15;
        final endRadius = radius - 10;

        final start = Offset(
          center.dx + startRadius * math.cos(angle - math.pi / 2),
          center.dy + startRadius * math.sin(angle - math.pi / 2),
        );

        final end = Offset(
          center.dx + endRadius * math.cos(angle - math.pi / 2),
          center.dy + endRadius * math.sin(angle - math.pi / 2),
        );

        canvas.drawLine(start, end, minorPaint);
      }
    }

    // Draw direction labels
    final directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = i * 90 * (math.pi / 180);
      final labelRadius = radius - 35;

      final position = Offset(
        center.dx + labelRadius * math.cos(angle - math.pi / 2),
        center.dy + labelRadius * math.sin(angle - math.pi / 2),
      );

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: i == 0 ? Colors.red : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
