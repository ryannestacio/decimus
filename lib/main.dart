import 'package:decimus/screens/caixa.dart';
import 'package:decimus/screens/despesas.dart';
import 'package:decimus/screens/devedores.dart';
import 'package:decimus/screens/recebiveis.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:page_transition/page_transition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/home':
            return PageTransition(
              type: PageTransitionType.fade, // Escolha o tipo de transição
              child: const HomeScreen(),
            );
          case '/recebiveis':
            return PageTransition(
              type: PageTransitionType.fade,
              child: const RecebiveisScreen(),
            );
          case '/despesas':
            return PageTransition(
              type: PageTransitionType.fade,
              child: const DespesasScreen(),
            );
          case '/devedores':
            return PageTransition(
              type: PageTransitionType.fade,
              child: const DevedoresScreen(),
            );
          case '/caixa':
            return PageTransition(
              type: PageTransitionType.fade,
              child: const CaixaScreen(),
            );
          case '/login':
            return PageTransition(
              type: PageTransitionType.bottomToTop,
              child: const LoginScreen(),
              duration: Duration(milliseconds: 550),
            );
          default:
            return null;
        }
      },

      /*routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/recebiveis': (context) => RecebiveisScreen(),
        '/despesas': (context) => DespesasScreen(),
        '/devedores': (context) => DevedoresScreen(),
        '/caixa': (context) => CaixaScreen(),
      },*/
    );
  }
}
