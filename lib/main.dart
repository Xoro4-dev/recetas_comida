import 'package:flutter/material.dart';

import 'data/app_scope.dart';
import 'data/app_services.dart';
import 'screens/home_screen.dart';
import 'screens/pair_code_screen.dart';
import 'theme/pixel_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.init();
  runApp(RecetasApp(services: services));
}

class RecetasApp extends StatefulWidget {
  const RecetasApp({super.key, required this.services});

  final AppServices services;

  @override
  State<RecetasApp> createState() => _RecetasAppState();
}

class _RecetasAppState extends State<RecetasApp> {
  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: widget.services,
      child: MaterialApp(
        title: 'Recetas',
        debugShowCheckedModeBanner: false,
        theme: buildPixelTheme(),
        home: widget.services.coupleCode == null
            ? PairCodeScreen(onDone: () => setState(() {}))
            : const HomeScreen(),
      ),
    );
  }
}
