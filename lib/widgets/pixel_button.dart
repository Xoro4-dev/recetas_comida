import 'package:flutter/material.dart';

import '../theme/pixel_theme.dart';

class PixelButton extends StatelessWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon,
    this.fontSize = 16,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;
  final String? icon;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withValues(alpha: 0.7), color, color],
              stops: const [0, 0.3, 1],
            ),
            border: Border.all(color: PixelColors.outline, width: 3),
            boxShadow: const [
              BoxShadow(color: PixelColors.outline, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Text(icon!, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: pixelText(fontSize, color: PixelColors.yellow)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
