import 'package:decimus/services/services_despesas.dart';
import 'package:decimus/services/services_devedores.dart';
import 'package:decimus/services/services_caixa.dart';
import 'package:decimus/services/services_recebiveis.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaixaScreen extends StatelessWidget {
  const CaixaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Caixa',
          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 8,
        shadowColor: Colors.indigo,
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.yellow, Colors.black]),
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        height: 100,
        child: Card(
          elevation: 3,
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(5),
            ),
            tileColor: cor,
            title: Text(
              title,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            subtitle: Text(
              content,
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
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
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/agostinho.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                SizedBox(
                  height: 150,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        colors: [
                          Colors.amberAccent,
                          const Color.fromARGB(255, 105, 86, 28),
                        ],
                      ),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      tileColor: Colors.amber,
                      title: Text(
                        'Caixa Atual',
                        style: GoogleFonts.bebasNeue(
                          textStyle: TextStyle(fontSize: 50),
                        ),
                      ),
                      subtitle: Text(
                        'R\$${FinanceiroServiceCaixa.saldoFinalDoCaixa}',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ),
                _espacador(10),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gerando relatório em PDF...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(20, 60),
                    backgroundColor: const Color.fromARGB(255, 32, 117, 185),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),
                    elevation: 8,
                  ),
                  child: Text('Gerar Relatório de Caixa'),
                ),
                _espacador(20),
                _buildCard(
                  'Recebiveis previstos:',
                  'R\$${FinanceiroServiceDevedores.devedoresPendentes}',
                  Colors.green,
                ),
                _espacador(10),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gerando relatório em PDF...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(20, 60),
                    backgroundColor: const Color.fromARGB(255, 32, 117, 185),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),
                    elevation: 8,
                  ),
                  child: Text('Gerar Relatório de Recebíveis'),
                ),
                _espacador(20),
                _buildCard(
                  'Despesas previstas:',
                  'R\$${FinanceiroServiceDespesas.totalDespesasPendentes}',
                  Colors.red,
                ),
                _espacador(10),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gerando relatório em PDF...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(20, 60),
                    backgroundColor: const Color.fromARGB(255, 32, 117, 185),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),
                    elevation: 8,
                  ),
                  child: Text('Gerar Relatório de Despesas'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
