import 'package:flutter/material.dart';

import '../theme/pixel_theme.dart';

class PixelTextField extends StatelessWidget {
  const PixelTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: PixelColors.outline, width: 3),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        style: pixelText(12, color: PixelColors.outline).copyWith(shadows: []),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: pixelText(11, color: Colors.black26).copyWith(shadows: []),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}
