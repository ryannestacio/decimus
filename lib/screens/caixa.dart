import 'package:decimus/screens/devedores.dart';
import 'package:flutter/material.dart';

class CaixaScreen extends StatelessWidget {
  const CaixaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Caixa',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
      ),
      body: BodyCaixa(),
    );
  }
}

class BodyCaixa extends StatefulWidget {
  const BodyCaixa({super.key});

  @override
  State<BodyCaixa> createState() => _BodyCaixaState();
}

class _BodyCaixaState extends State<BodyCaixa> {
  Widget _buildCard(String title, String content, Color cor) {
    return Card(
      elevation: 3,
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(5),
        ),
        tileColor: cor,
        title: Text(title, style: TextStyle(color: Colors.white)),
        subtitle: Text(content, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _espacador(double altura) {
    return SizedBox(height: altura);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            SizedBox(
              height: 150,
              child: Card(
                elevation: 3,
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(5),
                  ),
                  tileColor: Colors.yellow,
                  title: Text('Caixa Atual', style: TextStyle(fontSize: 50)),
                  subtitle: Text('R\$0,00', style: TextStyle(fontSize: 25)),
                ),
              ),
            ),
            espacador(10),
            _buildCard('Recebiveis previstos:', 'R\$ 0,00', Colors.green),
            _espacador(10),
            _buildCard('Despesas pendentes:', 'R\$0,00', Colors.red),
            espacador(20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gerando relatório em PDF...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: Text('Gerar Relatório'),
            ),
          ],
        ),
      ),
    );
  }
}
