import 'package:flutter/material.dart';
import 'package:ndvpn/ui/screens/spin_wheel/controller/lucky_wheel_controller.dart';
import 'dart:math' as math;

class Wheel extends CustomPainter {
  final List<SpinItem> items;

  Wheel({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25) // Adjust the shadow color and opacity as needed
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0); // Adjust the blur radius as needed

    const spaceBetweenItems = 0.05; // Adjust this value to set the desired space between items
    final totalSections = items.length;
    const totalAngle = 2 * math.pi;
    final sectionAngleWithSpace = (totalAngle - (totalSections * spaceBetweenItems)) / totalSections;
    const spaceOnBothSides = spaceBetweenItems / 2;

    for (var i = 0; i < items.length; i++) {
      final startAngle = i * (sectionAngleWithSpace + spaceBetweenItems) + spaceOnBothSides;

      paint.color = items[i].color;

      // Draw shadow before drawing the arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngleWithSpace,
        true,
        shadowPaint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngleWithSpace,
        true,
        paint,
      );
    }

    // Draw a circle at the center of the wheel
    final centerCircleRadius = radius * 0.05; // Adjust the radius of the center circle as needed
    final centerCirclePaint = Paint()..color = Colors.white; // Adjust the color of the center circle as needed
    canvas.drawCircle(center, centerCircleRadius, centerCirclePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}