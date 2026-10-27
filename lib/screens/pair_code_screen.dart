import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/app_services.dart';
import '../theme/pixel_theme.dart';
import '../widgets/pixel_button.dart';
import '../widgets/pixel_text_field.dart';
import 'section_screen.dart';

class PairCodeScreen extends StatefulWidget {
  const PairCodeScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<PairCodeScreen> createState() => _PairCodeScreenState();
}

class _PairCodeScreenState extends State<PairCodeScreen> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.text.isEmpty) {
      _controller.text = AppScope.of(context).coupleCode ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    const alphabet = 'abcdefghjkmnpqrstuvwxyz23456789';
    final rnd = Random.secure();
    setState(() {
      _controller.text =
          List.generate(12, (_) => alphabet[rnd.nextInt(alphabet.length)])
              .join();
      _error = null;
    });
  }

  Future<void> _enter() async {
    final code = AppServices.normalizeCode(_controller.text);
    if (!AppServices.isValidCode(code)) {
      setState(() => _error = 'Mínimo 8 letras o números');
      return;
    }
    await AppScope.of(context).setCoupleCode(code);
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return SectionScreen(
      title: 'CÓDIGO DE PAREJA',
      color: PixelColors.orange,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Genera un código y compártelo con tu pareja. Los dos tenéis '
              'que escribir el mismo para compartir los datos.',
              textAlign: TextAlign.center,
              style: pixelText(10, color: PixelColors.yellow),
            ),
            const SizedBox(height: 20),
            PixelTextField(
              controller: _controller,
              hint: 'tu código',
              onSubmitted: (_) => _enter(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: pixelText(9, color: PixelColors.red)),
            ],
            const SizedBox(height: 16),
            PixelButton(
              label: 'GENERAR CÓDIGO',
              color: PixelColors.blue,
              fontSize: 11,
              onPressed: _generate,
            ),
            const SizedBox(height: 16),
            PixelButton(
              label: 'ENTRAR',
              color: PixelColors.green,
              fontSize: 14,
              onPressed: _enter,
            ),
            if (!services.firebaseReady) ...[
              const SizedBox(height: 20),
              Text(
                'Modo local: Firebase no está configurado, los datos no se '
                'sincronizan.',
                textAlign: TextAlign.center,
                style: pixelText(8, color: PixelColors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
