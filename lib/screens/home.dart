import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
          icon: Icon(Icons.logout, color: Colors.white),
        ),
        title: const Text(
          'Menu principal',
          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 8,
        shadowColor: Colors.indigo,
      ),
      body: BodyHome(),
    );
  }
}

class BodyHome extends StatefulWidget {
  const BodyHome({super.key});

  @override
  State<BodyHome> createState() => _CorpoBotoesState();
}

class _CorpoBotoesState extends State<BodyHome> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/tomas.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  constraints: BoxConstraints(maxWidth: 420), // largura máxima
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMenuTile(
                        context,
                        title: 'Recebíveis',
                        subtitle: 'Doações, dízimo, leilões e eventos.',
                        icon: Icons.attach_money_sharp,
                        route: '/recebiveis',
                      ),
                      SizedBox(height: 4),
                      _buildMenuTile(
                        context,
                        title: 'Despesas',
                        subtitle: 'Contas a pagar, despesas em geral.',
                        icon: Icons.attach_money_sharp,
                        route: '/despesas',
                      ),
                      SizedBox(height: 4),
                      _buildMenuTile(
                        context,
                        title: 'Devedores',
                        subtitle: 'Devedores e bonificações pendentes.',
                        icon: Icons.person_search_sharp,
                        route: '/devedores',
                      ),
                      SizedBox(height: 4),
                      _buildMenuTile(
                        context,
                        title: 'Caixa',
                        subtitle: 'Info. financeiro, relatórios, etc.',
                        icon: Icons.monetization_on,
                        route: '/caixa',
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Close the SafeArea widget
      ],
    );
  }
}

Widget _buildMenuTile(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required String route,
}) {
  return Card(
    color: Colors.amber,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 18,
    child: ListTile(
      onTap: () => Navigator.pushNamed(context, route),
      leading: Icon(icon, color: Colors.black),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
  );
}
