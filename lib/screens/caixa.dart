import 'package:decimus/services/services_despesas.dart';
import 'package:decimus/services/services_devedores.dart';
import 'package:decimus/services/services_caixa.dart';
import 'package:decimus/services/services_recebiveis.dart';
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
  //Widget reutilizável tipo ListTile
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

  @override
  void initState() {
    super.initState();
    _carregarTotalRecebido();
  }

  Future<void> _carregarTotalRecebido() async {
    await FinanceiroServiceRecebiveis.calcularTotalRecebiveis();
    setState(() {}); // Atualiza a tela com o novo total
  }

  //Widget reutilizável tipo SizedBox que recebe o parametro como altura
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
                    borderRadius: BorderRadius.circular(5),
                  ),
                  tileColor: Colors.yellow,
                  title: Text('Caixa Atual', style: TextStyle(fontSize: 50)),
                  subtitle: Text(
                    'R\$${FinanceiroServiceCaixa.saldoFinalDoCaixa}',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),
            _espacador(10),
            _buildCard(
              'Recebiveis previstos:',
              'R\$${FinanceiroServiceDevedores.devedoresPendentes}',
              Colors.green,
            ),
            _espacador(10),
            _buildCard(
              'Despesas previstas:',
              'R\$${FinanceiroServiceDespesas.totalDespesasPendentes}',
              Colors.red,
            ),
            _espacador(20),
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
