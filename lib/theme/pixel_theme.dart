import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelColors {
  static const pinkLight = Color(0xFFFFE4EC);
  static const pinkDark = Color(0xFFFFC2D6);
  static const outline = Color(0xFF8A5A00);
  static const orange = Color(0xFFFFA726);
  static const red = Color(0xFFF77B65);
  static const blue = Color(0xFF7FD0F5);
  static const yellow = Color(0xFFE6D84F);
  static const green = Color(0xFF4CE05A);
}

TextStyle pixelText(double size, {Color color = Colors.white}) {
  return GoogleFonts.pressStart2p(
    fontSize: size,
    color: color,
    shadows: const [
      Shadow(color: PixelColors.outline, offset: Offset(2, 2)),
      Shadow(color: PixelColors.outline, offset: Offset(-1, -1)),
      Shadow(color: PixelColors.outline, offset: Offset(1, -1)),
      Shadow(color: PixelColors.outline, offset: Offset(-1, 1)),
    ],
  );
}

ThemeData buildPixelTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: PixelColors.orange),
    scaffoldBackgroundColor: PixelColors.pinkLight,
  );
}
