import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu principal',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
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
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              onTap: () => Navigator.pushNamed(context, '/recebiveis'),
              leading: Icon(Icons.attach_money_sharp),
              title: const Text('Recebiveis'),
              subtitle: const Text('Doações, dizimo, leilões e eventos.'),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: Colors.grey[500],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            SizedBox(height: 4),
            ListTile(
              onTap: () => Navigator.pushNamed(context, '/despesas'),
              leading: Icon(Icons.import_export_outlined),
              title: const Text('Despesas'),
              subtitle: const Text('Contas de energia, luz, reformas, etc.'),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: Colors.grey[500],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            SizedBox(height: 4),
            ListTile(
              onTap: () => Navigator.pushNamed(context, '/devedores'),
              leading: Icon(Icons.person_search_sharp),
              title: const Text('Devedores'),
              subtitle: const Text('Devedores e bonificações pendentes.'),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: Colors.grey[500],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            SizedBox(height: 4),
            ListTile(
              onTap: () => Navigator.pushNamed(context, '/caixa'),
              leading: Icon(Icons.monetization_on),
              title: const Text('Caixa'),
              subtitle: const Text('Movimentações do caixa: Entradas e saídas'),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: Colors.grey[500],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            SizedBox(height: 4),

            ListTile(
              onTap: () => Navigator.pushNamed(context, '/devolucoes'),
              leading: Icon(Icons.loop_rounded),
              title: Text('Devoluções'),
              subtitle: Text('Devolução de saídas e entradas.'),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: Colors.grey[500],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
