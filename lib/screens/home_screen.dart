import 'package:flutter/material.dart';

import '../theme/pixel_theme.dart';
import '../widgets/checker_background.dart';
import '../widgets/pixel_button.dart';
import 'pair_code_screen.dart';
import 'section_screen.dart';
import 'shopping_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openPairCode(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PairCodeScreen(
        onDone: () => Navigator.of(context).popUntil((r) => r.isFirst),
      ),
    ));
  }

  void _open(BuildContext context, String title, Color color) {
    if (title == 'Lista de la compra') {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const ShoppingScreen()));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SectionScreen(
        title: title.toUpperCase(),
        color: color,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Próximamente',
                textAlign: TextAlign.center,
                style: pixelText(14, color: PixelColors.yellow)),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CheckerBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: PixelColors.orange,
                    border: Border.all(color: PixelColors.outline, width: 3),
                  ),
                  child: Text('MENÚ PRINCIPAL',
                      textAlign: TextAlign.center,
                      style: pixelText(16, color: PixelColors.blue)),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _entry(context, 'Recetas', '🍳', PixelColors.red),
                      _entry(context, 'Restaurantes', '🍣', PixelColors.blue),
                      _entry(context, 'Rinconcitos', '🌄', PixelColors.yellow),
                      _entry(context, 'Lista de la compra', '🛒',
                          PixelColors.green),
                    ],
                  ),
                ),
                PixelButton(
                  label: 'CÓDIGO DE PAREJA',
                  color: PixelColors.orange,
                  fontSize: 10,
                  onPressed: () => _openPairCode(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _entry(BuildContext context, String label, String icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: PixelButton(
        label: label.toUpperCase(),
        icon: icon,
        color: color,
        fontSize: 14,
        onPressed: () => _open(context, label, color),
      ),
    );
  }
}
