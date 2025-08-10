import 'package:decimus/screens/caixa.dart';
import 'package:decimus/screens/despesas.dart';
import 'package:decimus/screens/devedores.dart';
import 'package:decimus/screens/recebiveis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:page_transition/page_transition.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

final loginRouter = '/login';
final homeRouter = '/home';
final recebiveisRouter = '/recebiveis';
final despesasRouter = '/despesas';
final devedoresRouter = '/devedores';
final caixaRouter = '/caixa';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      redirect: (BuildContext context, GoRouterState state) {
        // Se o usuário já estiver logado, vá para a home
        if (FirebaseAuth.instance.currentUser != null) {
          return homeRouter;
        }
        // Caso contrário, vá para a tela de login
        return loginRouter;
      },
    ),
    GoRoute(
      path: loginRouter,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: homeRouter,
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: recebiveisRouter,
      builder: (BuildContext context, GoRouterState state) {
        return const RecebiveisScreen();
      },
    ),
    GoRoute(
      path: despesasRouter,
      builder: (BuildContext context, GoRouterState state) {
        return const DespesasScreen();
      },
    ),
    GoRoute(
      path: devedoresRouter,
      builder: (BuildContext context, GoRouterState state) {
        return const DevedoresScreen();
      },
    ),
    GoRoute(
      path: caixaRouter,
      builder: (BuildContext context, GoRouterState state) {
        return const CaixaScreen();
      },
    ),
    GoRoute(
      path: loginRouter,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    //Obtendo o estado de login do usuário
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    //Verificar se o usuário está indo para uma rota protegida sem permissão
    final goingHome = state.fullPath == homeRouter;
    final goingRecebiveis = state.fullPath == recebiveisRouter;
    final goingDespesas = state.fullPath == despesasRouter;
    final goingDevedores = state.fullPath == devedoresRouter;
    final goingCaixa = state.fullPath == caixaRouter;

    //se o usuário quer ir para qualquer outra rota mas  não está logado
    if (!isLoggedIn && goingHome) {
      //Ele irá retornar para o login
      return loginRouter;
    }
    if (!isLoggedIn && goingRecebiveis) {
      //Ele irá retornar para o login
      return loginRouter;
    }
    if (!isLoggedIn && goingDespesas) {
      //Ele irá retornar para o login
      return loginRouter;
    }
    if (!isLoggedIn && goingDevedores) {
      //Ele irá retornar para o login
      return loginRouter;
    }
    if (!isLoggedIn && goingCaixa) {
      //Ele irá retornar para o login
      return loginRouter;
    }

    //Se o usuário está lgado e quer
    if (isLoggedIn && state.fullPath == loginRouter) {
      return homeRouter;
    }
    return null;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Decimus',
      routerConfig: router,

      /*onGenerateRoute: (settings) {
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
      },*/

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
