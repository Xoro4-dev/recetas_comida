import 'package:flutter/material.dart';

import '../theme/pixel_theme.dart';

class CheckerBackground extends StatelessWidget {
  const CheckerBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CheckerPainter(), child: child);
  }
}

class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 28.0;
    final light = Paint()..color = PixelColors.pinkLight;
    final dark = Paint()..color = PixelColors.pinkDark;
    canvas.drawRect(Offset.zero & size, light);
    for (var y = 0; y * cell < size.height; y++) {
      for (var x = 0; x * cell < size.width; x++) {
        if ((x + y).isEven) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), dark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
