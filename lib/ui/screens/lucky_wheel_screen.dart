import 'dart:math';

import 'package:flutter/material.dart';

class LuckyWheel extends StatefulWidget {
  @override
  _LuckyWheelState createState() => _LuckyWheelState();
}

class _LuckyWheelState extends State<LuckyWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startSpinning() {
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200.0,
          height: 200.0,
          child: RotationTransition(
            turns: _animationController,
            child: GestureDetector(
              onTap: () {
                _startSpinning();
              },
              child: CustomPaint(
                painter: WheelPainter(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            _startSpinning();
          },
          child: const Text('Spin the Wheel'),
        ),
      ],
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(radius, radius);

    double startAngle = 0.0;
    double sweepAngle = 2 * pi / colors.length;

    for (int i = 0; i < colors.length; i++) {
      Paint paint = Paint()..color = colors[i];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
