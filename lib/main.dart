import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/pixel_theme.dart';

void main() {
  runApp(const RecetasApp());
}

class RecetasApp extends StatelessWidget {
  const RecetasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetas',
      debugShowCheckedModeBanner: false,
      theme: buildPixelTheme(),
      home: const HomeScreen(),
    );
  }
}
