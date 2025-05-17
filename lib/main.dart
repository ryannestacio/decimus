import 'package:decimus/screens/caixa.dart';
import 'package:decimus/screens/despesas.dart';
import 'package:decimus/screens/devedores.dart';
import 'package:decimus/screens/recebiveis.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Decimus',

      initialRoute: '/login',

      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/recebiveis': (context) => RecebiveisScreen(),
        '/despesas': (context) => DespesasScreen(),
        '/devedores': (context) => DevedoresScreen(),
        '/caixa': (context) => CaixaScreen(),
      },
    );
  }
}
