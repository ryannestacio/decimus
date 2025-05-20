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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListTile(
                onTap: () => Navigator.pushNamed(context, '/recebiveis'),
                leading: Icon(Icons.attach_money_sharp),
                trailing: Icon(Icons.arrow_forward_ios),
                title: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Text(
                    'Recebiveis',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    'Doações, dizimo, leilões e eventos.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                tileColor: Colors.yellow,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              SizedBox(height: 4),
              ListTile(
                onTap: () => Navigator.pushNamed(context, '/despesas'),
                leading: Icon(Icons.import_export_outlined),
                trailing: Icon(Icons.arrow_forward_ios),
                title: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Text(
                    'Despesas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    'Contas de energia, luz, reformas, etc.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                tileColor: Colors.yellow,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              SizedBox(height: 4),
              ListTile(
                onTap: () => Navigator.pushNamed(context, '/devedores'),
                leading: Icon(Icons.person_search_sharp),
                trailing: Icon(Icons.arrow_forward_ios),
                title: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Text(
                    'Devedores',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    'Devedores e bonificações pendentes.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                tileColor: Colors.yellow,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              SizedBox(height: 4),
              ListTile(
                onTap: () => Navigator.pushNamed(context, '/caixa'),
                leading: Icon(Icons.monetization_on),
                trailing: Icon(Icons.arrow_forward_ios),
                title: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Text(
                    'Caixa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    'Info. financeiro, relatórios, etc.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                tileColor: Colors.yellow,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              SizedBox(height: 4),

              ListTile(
                onTap: () => Navigator.pushNamed(context, '/devolucoes'),
                leading: Icon(Icons.loop_rounded),
                trailing: Icon(Icons.arrow_forward_ios),
                title: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Text(
                    'Devoluções',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    'Devolução de saídas e entradas.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                tileColor: Colors.yellow,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
