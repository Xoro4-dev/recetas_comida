import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recetas_comida/main.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('el menú principal navega a una sección y vuelve a inicio',
      (tester) async {
    await tester.pumpWidget(const RecetasApp());
    expect(find.text('RECETAS'), findsOneWidget);
    expect(find.text('RESTAURANTES'), findsOneWidget);
    expect(find.text('RINCONCITOS'), findsOneWidget);
    expect(find.text('LISTA DE LA COMPRA'), findsOneWidget);

    await tester.tap(find.text('RECETAS'));
    await tester.pumpAndSettle();
    expect(find.text('ATRÁS'), findsOneWidget);

    await tester.tap(find.text('INICIO'));
    await tester.pumpAndSettle();
    expect(find.text('MENÚ PRINCIPAL'), findsOneWidget);
  });
}
