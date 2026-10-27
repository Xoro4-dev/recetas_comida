import 'package:flutter/widgets.dart' show EditableText;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recetas_comida/data/app_services.dart';
import 'package:recetas_comida/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppServices> _services([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return AppServices.local(await SharedPreferences.getInstance());
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('sin código de pareja se pide primero y luego se entra al menú',
      (tester) async {
    await tester.pumpWidget(RecetasApp(services: await _services()));
    expect(find.text('CÓDIGO DE PAREJA'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'abcdefgh23');
    await tester.tap(find.text('ENTRAR'));
    await tester.pumpAndSettle();
    expect(find.text('MENÚ PRINCIPAL'), findsOneWidget);
  });

  testWidgets('el menú principal navega a una sección y vuelve a inicio',
      (tester) async {
    await tester.pumpWidget(RecetasApp(
        services: await _services({'couple_code': 'abcdefgh23'})));
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

  testWidgets('lista de la compra: añadir, marcar y borrar marcados',
      (tester) async {
    await tester.pumpWidget(RecetasApp(
        services: await _services({'couple_code': 'abcdefgh23'})));
    await tester.tap(find.text('LISTA DE LA COMPRA'));
    await tester.pumpAndSettle();
    expect(find.text('La lista está vacía'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'Leche');
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    expect(find.text('Leche'), findsOneWidget);

    await tester.tap(find.text('Leche'));
    await tester.pumpAndSettle();
    expect(find.text('✅'), findsOneWidget);

    await tester.tap(find.text('BORRAR MARCADOS'));
    await tester.pumpAndSettle();
    expect(find.text('Leche'), findsNothing);
  });
}
