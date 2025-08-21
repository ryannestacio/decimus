import 'package:decimus/services/services_despesas.dart';
import 'package:decimus/services/services_devedores.dart';
import 'package:decimus/services/services_caixa.dart';
import 'package:decimus/services/services_recebiveis.dart';
import 'package:decimus/services/services_relatorios.dart';
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
  bool _isGeneratingReport = false;

  Widget _buildElevatedButton(
    String text,
    Color corBorder,
    Color corBackground,
    Color corForegraund,
    VoidCallback? onPressed,
  ) {
    return ElevatedButton(
      onPressed: _isGeneratingReport ? null : onPressed,
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
      child:
          _isGeneratingReport
              ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(corForegraund),
                ),
              )
              : Text(
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
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    // Carrega todos os dados necessários para o caixa
    await FinanceiroServiceRecebiveis.calcularTotalRecebiveis();
    await FinanceiroServiceRecebiveis.carregarRecebiveis(); // Carrega lista de recebíveis
    await FinanceiroServiceDevedores.carregarDevedores(); // Isso também carrega o total de pagamentos
    if (!mounted) return; // Garante que o widget ainda está ativo
    setState(() {}); // Atualiza a tela com os novos dados
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildElevatedButton(
                            'Relatório de caixa',
                            Colors.white,
                            const Color.fromARGB(255, 32, 117, 185),
                            Colors.white,
                            () => _gerarRelatorioCaixa(),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _carregarDados,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(16),
                          ),
                          child: Icon(Icons.refresh, size: 24),
                        ),
                      ],
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
                      () => _gerarRelatorioRecebiveis(),
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
                      () => _gerarRelatorioDespesas(),
                    ),
                    _espacador(50),
                    _buildElevatedButton(
                      'Relatório Geral',
                      Colors.blue,
                      Colors.white,
                      const Color.fromARGB(255, 32, 117, 185),
                      () => _gerarRelatorioGeral(),
                    ),
                    _espacador(20),
                    _buildElevatedButton(
                      'Relatório Excel',
                      Colors.green,
                      Colors.white,
                      Colors.green,
                      () => _gerarRelatorioExcel(),
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

  // Métodos para gerar relatórios
  Future<void> _gerarRelatorioCaixa() async {
    setState(() {
      _isGeneratingReport = true;
    });

    try {
      await RelatoriosService.gerarRelatorioCaixa();
      _mostrarMensagemSucesso('Relatório de caixa gerado com sucesso!');
    } catch (e) {
      _mostrarMensagemErro('Erro ao gerar relatório: $e');
    } finally {
      setState(() {
        _isGeneratingReport = false;
      });
    }
  }

  Future<void> _gerarRelatorioRecebiveis() async {
    setState(() {
      _isGeneratingReport = true;
    });

    try {
      await RelatoriosService.gerarRelatorioRecebiveis();
      _mostrarMensagemSucesso('Relatório de recebíveis gerado com sucesso!');
    } catch (e) {
      _mostrarMensagemErro('Erro ao gerar relatório: $e');
    } finally {
      setState(() {
        _isGeneratingReport = false;
      });
    }
  }

  Future<void> _gerarRelatorioDespesas() async {
    setState(() {
      _isGeneratingReport = true;
    });

    try {
      await RelatoriosService.gerarRelatorioDespesas();
      _mostrarMensagemSucesso('Relatório de despesas gerado com sucesso!');
    } catch (e) {
      _mostrarMensagemErro('Erro ao gerar relatório: $e');
    } finally {
      setState(() {
        _isGeneratingReport = false;
      });
    }
  }

  Future<void> _gerarRelatorioGeral() async {
    setState(() {
      _isGeneratingReport = true;
    });

    try {
      await RelatoriosService.gerarRelatorioGeral();
      _mostrarMensagemSucesso('Relatório geral gerado com sucesso!');
    } catch (e) {
      _mostrarMensagemErro('Erro ao gerar relatório: $e');
    } finally {
      setState(() {
        _isGeneratingReport = false;
      });
    }
  }

  Future<void> _gerarRelatorioExcel() async {
    setState(() {
      _isGeneratingReport = true;
    });

    try {
      await RelatoriosService.gerarRelatorioExcel();
      _mostrarMensagemSucesso('Relatório Excel gerado com sucesso!');
    } catch (e) {
      _mostrarMensagemErro('Erro ao gerar relatório Excel: $e');
    } finally {
      setState(() {
        _isGeneratingReport = false;
      });
    }
  }

  void _mostrarMensagemSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _mostrarMensagemErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }
}
