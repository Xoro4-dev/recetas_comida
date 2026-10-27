import 'package:flutter/material.dart';

import '../theme/pixel_theme.dart';
import '../widgets/checker_background.dart';
import '../widgets/pixel_button.dart';

/// Pantalla base de cada sección. Incluye siempre botones Atrás e Inicio,
/// de modo que nunca se queda uno atascado sin poder navegar.
class SectionScreen extends StatelessWidget {
  const SectionScreen({
    super.key,
    required this.title,
    required this.color,
    required this.body,
  });

  final String title;
  final Color color;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CheckerBackground(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: PixelColors.outline, width: 3),
                ),
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: pixelText(18, color: PixelColors.blue)),
              ),
              Expanded(child: body),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: PixelButton(
                        label: 'ATRÁS',
                        color: PixelColors.blue,
                        fontSize: 12,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PixelButton(
                        label: 'INICIO',
                        color: PixelColors.orange,
                        fontSize: 12,
                        onPressed: () => Navigator.of(context)
                            .popUntil((route) => route.isFirst),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
