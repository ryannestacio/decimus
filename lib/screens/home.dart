import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu principal',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow,
      ),
      body: CorpoBotoes(),
    );
  }
}

class CorpoBotoes extends StatefulWidget {
  const CorpoBotoes({super.key});

  @override
  State<CorpoBotoes> createState() => _CorpoBotoesState();
}

class _CorpoBotoesState extends State<CorpoBotoes> {
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
              title: Text('Recebiveis'),
              subtitle: Text('Doações, dizimo, leilões e eventos.'),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: Colors.grey[100],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            SizedBox(height: 4),
            ListTile(
              onTap: () => Navigator.pushNamed(context, '/despesas'),
              leading: Icon(Icons.import_export_outlined),
              title: Text('Despesas'),
              subtitle: Text('Contas de energia, luz, reformas, etc.'),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: Colors.grey[100],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            SizedBox(height: 4),
            ListTile(
              onTap: () => Navigator.pushNamed(context, '/devedores'),
              leading: Icon(Icons.person_search_sharp),
              title: Text('Devedores'),
              subtitle: Text('Devedores e bonificações pendentes.'),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: Colors.grey[100],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            SizedBox(height: 4),
            ListTile(
              onTap: () => Navigator.pushNamed(context, '/caixa'),
              leading: Icon(Icons.monetization_on),
              title: Text('Caixa'),
              subtitle: Text('Movimentações do caixa: Entradas e saídas'),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: Colors.grey[100],
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
