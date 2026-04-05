import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:decimus/screens/login.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Evita tentativa de fetch HTTP de fontes durante testes.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Tela de login renderiza elementos principais', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Decimus App'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Digite seu e-mail'), findsOneWidget);
    expect(find.text('Digite sua senha'), findsOneWidget);
  });
}
