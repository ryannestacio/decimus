import 'package:decimus/services/services_despesas.dart';
import 'package:decimus/services/services_devedores.dart';
import 'package:decimus/services/services_caixa.dart';
import 'package:decimus/services/services_recebiveis.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CaixaScreen extends StatelessWidget {
  const CaixaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            /*Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);*/
            context.go('/home');
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
  Widget _buildElevatedButton(
    String text,
    Color corBorder,
    Color corBackground,
    Color corForegraund,
  ) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gerando relatório em PDF...')));
      },

      style: ElevatedButton.styleFrom(
        fixedSize: Size(20, 60),
        backgroundColor: corBackground,
        foregroundColor: corForegraund,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: corBorder, width: 2),
        ),
        elevation: 8,
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  //Widget reutilizável tipo ListTile
  Widget _buildCard(
    String title,
    String content,
    Color cor,
    Icon icon,
    Color corBorda,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [corBorda, Colors.black]),
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        height: 100,
        child: Card(
          elevation: 3,
          child: ListTile(
            leading: icon,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(5),
            ),
            tileColor: cor,
            title: Text(
              title,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(color: Colors.black, fontSize: 25),
              ),
            ),
            subtitle: Text(
              content,
              style: TextStyle(color: Colors.black, fontSize: 20),
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
    if (!mounted) return; // Garante que o widget ainda está ativo
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
              opacity: 0.7,
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                constraints: BoxConstraints(maxWidth: 420),
                child: ListView(
                  children: [
                    SizedBox(
                      height: 150,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber,
                              const Color.fromARGB(255, 105, 86, 28),
                            ],
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.attach_money, size: 50),
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
                    _espacador(5),
                    _buildElevatedButton(
                      'Relatório de caixa',
                      Colors.white,
                      const Color.fromARGB(255, 32, 117, 185),
                      Colors.white,
                    ),
                    _espacador(50),
                    _buildCard(
                      'Recebiveis previstos:',
                      'R\$${FinanceiroServiceDevedores.devedoresPendentes}',

                      Colors.amber,
                      Icon(Icons.trending_up, color: Colors.green),
                      Colors.green,
                    ),
                    _espacador(5),
                    _buildElevatedButton(
                      'Relatório de Recebíveis',
                      Colors.white,
                      const Color.fromARGB(255, 32, 117, 185),
                      Colors.white,
                    ),
                    _espacador(50),
                    _buildCard(
                      'Despesas previstas:',
                      'R\$${FinanceiroServiceDespesas.totalDespesasPendentes}',
                      Colors.amber,
                      Icon(Icons.trending_down, color: Colors.red),
                      Colors.red,
                    ),
                    _espacador(5),
                    _buildElevatedButton(
                      'Relatório de Despesas',
                      Colors.white,
                      const Color.fromARGB(255, 32, 117, 185),
                      Colors.white,
                    ),
                    _espacador(50),
                    _buildElevatedButton(
                      'Relatório Geral',
                      Colors.blue,
                      Colors.white,
                      const Color.fromARGB(255, 32, 117, 185),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
