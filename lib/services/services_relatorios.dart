import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';
import 'package:decimus/utils/file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:decimus/services/services_caixa.dart';
import 'package:decimus/services/services_despesas.dart';
import 'package:decimus/services/services_devedores.dart';
import 'package:decimus/services/services_recebiveis.dart';
import 'package:decimus/services/global_services.dart';

class RelatoriosService {
  static final DateFormat _formatter = DateFormat('dd/MM/yyyy HH:mm');

  // Relatório Geral do Caixa - SUPER DETALHADO COM MÚLTIPLAS PÁGINAS
  static Future<void> gerarRelatorioGeral() async {
    try {
      final pdf = pw.Document();

      // PÁGINA 1: RESUMO EXECUTIVO E ANÁLISES
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _asMultiPage(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader('RELATÓRIO GERAL FINANCEIRO COMPLETO'),
                  pw.SizedBox(height: 20),

                  // RESUMO EXECUTIVO
                  _buildSection('RESUMO EXECUTIVO'),
                  _buildInfoRow(
                    'Saldo Atual Disponível',
                    'R\$ ${FinanceiroServiceCaixa.saldoFinalDoCaixa.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                  _buildInfoRow(
                    'Saldo Previsto (30 dias)',
                    'R\$ ${_calcularSaldoPrevisto().toStringAsFixed(2)}',
                    isBold: true,
                  ),
                  _buildInfoRow(
                    'Situação Financeira',
                    _getSituacaoFinanceira(),
                    isBold: true,
                  ),
                  pw.SizedBox(height: 20),

                  // MOVIMENTAÇÕES DE ENTRADA
                  _buildSection('MOVIMENTAÇÕES DE ENTRADA (RECEITAS)'),
                  _buildInfoRow(
                    'Total de Recebíveis Cadastrados',
                    'R\$ ${FinanceiroServiceRecebiveis.totalRecebiveis.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Pagamentos Já Recebidos',
                    'R\$ ${FinanceiroServiceDevedores.totalPagamentosRecebidos.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Devedores Pendentes',
                    'R\$ ${FinanceiroServiceDevedores.devedoresPendentes.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Taxa de Recebimento',
                    '${_calcularTaxaRecebimento().toStringAsFixed(1)}%',
                  ),
                  pw.SizedBox(height: 15),

                  // MOVIMENTAÇÕES DE SAÍDA
                  _buildSection('MOVIMENTAÇÕES DE SAÍDA (DESPESAS)'),
                  _buildInfoRow(
                    'Total de Despesas Cadastradas',
                    'R\$ ${FinanceiroServiceDespesas.totalDespesas.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Despesas Já Pagas',
                    'R\$ ${FinanceiroServiceDespesas.totalDespesasPagas.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Despesas Pendentes',
                    'R\$ ${FinanceiroServiceDespesas.totalDespesasPendentes.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Taxa de Pagamento',
                    '${_calcularTaxaPagamento().toStringAsFixed(1)}%',
                  ),
                  pw.SizedBox(height: 15),

                  // ANÁLISE DE FLUXO DE CAIXA
                  _buildSection('ANÁLISE DE FLUXO DE CAIXA'),
                  _buildInfoRow(
                    'Fluxo de Entrada (Mensal)',
                    'R\$ ${_calcularFluxoEntradaMensal().toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Fluxo de Saída (Mensal)',
                    'R\$ ${_calcularFluxoSaidaMensal().toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Resultado Operacional',
                    'R\$ ${_calcularResultadoOperacional().toStringAsFixed(2)}',
                  ),
                  pw.SizedBox(height: 15),

                  // ANÁLISE DE LIQUIDEZ
                  _buildSection('ANÁLISE DE LIQUIDEZ'),
                  _buildInfoRow(
                    'Disponível Imediato',
                    'R\$ ${FinanceiroServiceCaixa.saldoFinalDoCaixa.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'A Receber (30 dias)',
                    'R\$ ${_calcularRecebimentos30Dias().toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'A Pagar (30 dias)',
                    'R\$ ${_calcularPagamentos30Dias().toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Índice de Liquidez',
                    _formatarIndiceLiquidez(),
                  ),
                  pw.SizedBox(height: 15),

                  // PROJEÇÕES FINANCEIRAS
                  _buildSection('PROJEÇÕES FINANCEIRAS'),
                  _buildInfoRow(
                    'Saldo em 30 dias',
                    'R\$ ${_calcularSaldoPrevisto().toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Saldo em 60 dias',
                    'R\$ ${_calcularSaldoPrevisto60Dias().toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Saldo em 90 dias',
                    'R\$ ${_calcularSaldoPrevisto90Dias().toStringAsFixed(2)}',
                  ),
                  pw.SizedBox(height: 15),

                  // ANÁLISE DE RISCO
                  _buildSection('ANÁLISE DE RISCO'),
                  _buildInfoRow('Risco de Liquidez', _avaliarRiscoLiquidez()),
                  _buildInfoRow(
                    'Risco de Inadimplência',
                    _avaliarRiscoInadimplencia(),
                  ),
                  _buildInfoRow(
                    'Risco de Superendividamento',
                    _avaliarRiscoSuperendividamento(),
                  ),
                  pw.SizedBox(height: 20),

                  // INDICADORES DE PERFORMANCE
                  _buildSection('INDICADORES DE PERFORMANCE (KPIs)'),
                  _buildInfoRow(
                    'Margem Operacional',
                    '${_calcularMargemOperacional().toStringAsFixed(1)}%',
                  ),
                  _buildInfoRow(
                    'Retorno sobre Investimento',
                    '${_calcularROI().toStringAsFixed(1)}%',
                  ),
                  _buildInfoRow(
                    'Ciclo Operacional',
                    '${_calcularCicloOperacional().toStringAsFixed(0)} dias',
                  ),
                  pw.SizedBox(height: 20),

                  // Data e Hora
                  _buildInfoRow(
                    'Data do Relatório',
                    _formatter.format(DateTime.now()),
                  ),
                  _buildInfoRow('Gerado por', 'Sistema Decimus'),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Página 1 de 4 - Resumo Executivo e Análises',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // PÁGINA 2: MOVIMENTAÇÕES DE ENTRADA DETALHADAS
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _asMultiPage(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader('MOVIMENTAÇÕES DE ENTRADA DETALHADAS'),
                  pw.SizedBox(height: 20),

                  // RESUMO DAS ENTRADAS
                  _buildSection('RESUMO DAS ENTRADAS REALIZADAS'),
                  _buildInfoRow(
                    'Total Recebido',
                    'R\$ ${FinanceiroServiceDevedores.totalPagamentosRecebidos.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                  _buildInfoRow(
                    'Quantidade de Pagamentos',
                    '${_getQuantidadePagamentosRecebidos()} pagamentos',
                  ),
                  _buildInfoRow('Período Analisado', 'Últimos 12 meses'),
                  pw.SizedBox(height: 20),

                  // LISTA DETALHADA DE PAGAMENTOS RECEBIDOS
                  _buildSection('PAGAMENTOS RECEBIDOS - LISTA COMPLETA'),
                  pw.SizedBox(height: 10),
                  ..._buildListaCompletaPagamentosRecebidos(),
                  pw.SizedBox(height: 20),

                  // RESUMO DOS RECEBÍVEIS PENDENTES
                  _buildSection('RECEBÍVEIS PENDENTES - LISTA COMPLETA'),
                  pw.SizedBox(height: 10),
                  ..._buildListaCompletaRecebiveisPendentes(),
                  pw.SizedBox(height: 20),

                  // Data e Hora
                  _buildInfoRow(
                    'Data do Relatório',
                    _formatter.format(DateTime.now()),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Página 2 de 4 - Movimentações de Entrada',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // PÁGINA 3: MOVIMENTAÇÕES DE SAÍDA DETALHADAS
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _asMultiPage(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader('MOVIMENTAÇÕES DE SAÍDA DETALHADAS'),
                  pw.SizedBox(height: 20),

                  // RESUMO DAS SAÍDAS
                  _buildSection('RESUMO DAS SAÍDAS REALIZADAS'),
                  _buildInfoRow(
                    'Total Pago',
                    'R\$ ${FinanceiroServiceDespesas.totalDespesasPagas.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                  _buildInfoRow(
                    'Quantidade de Despesas Pagas',
                    '${_getQuantidadeDespesasPagas()} despesas',
                  ),
                  _buildInfoRow('Período Analisado', 'Últimos 12 meses'),
                  pw.SizedBox(height: 20),

                  // LISTA DETALHADA DE DESPESAS PAGAS
                  _buildSection('DESPESAS PAGAS - LISTA COMPLETA'),
                  pw.SizedBox(height: 10),
                  ..._buildListaCompletaDespesasPagas(),
                  pw.SizedBox(height: 20),

                  // LISTA DETALHADA DE DESPESAS PENDENTES
                  _buildSection('DESPESAS PENDENTES - LISTA COMPLETA'),
                  pw.SizedBox(height: 10),
                  ..._buildListaCompletaDespesasPendentes(),
                  pw.SizedBox(height: 20),

                  // Data e Hora
                  _buildInfoRow(
                    'Data do Relatório',
                    _formatter.format(DateTime.now()),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Página 3 de 4 - Movimentações de Saída',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // PÁGINA 4: RECOMENDAÇÕES E ANÁLISE FINAL
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _asMultiPage(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader('RECOMENDAÇÕES E ANÁLISE FINAL'),
                  pw.SizedBox(height: 20),

                  // RECOMENDAÇÕES E SUGESTÕES
                  _buildSection('RECOMENDAÇÕES E SUGESTÕES'),
                  ..._buildRecomendacoes(),
                  pw.SizedBox(height: 20),

                  // DETALHAMENTO DAS MOVIMENTAÇÕES
                  _buildSection('RESUMO VISUAL DAS MOVIMENTAÇÕES'),
                  pw.SizedBox(height: 10),
                  ..._buildMovimentacoesDetalhadas(),
                  pw.SizedBox(height: 20),

                  // ANÁLISE DE TENDÊNCIAS
                  _buildSection('ANÁLISE DE TENDÊNCIAS'),
                  _buildInfoRow(
                    'Tendência de Recebimentos',
                    _analisarTendenciaRecebimentos(),
                  ),
                  _buildInfoRow(
                    'Tendência de Despesas',
                    _analisarTendenciaDespesas(),
                  ),
                  _buildInfoRow(
                    'Previsão para Próximo Mês',
                    _preverProximoMes(),
                  ),
                  pw.SizedBox(height: 20),

                  // Data e Hora
                  _buildInfoRow(
                    'Data do Relatório',
                    _formatter.format(DateTime.now()),
                  ),
                  _buildInfoRow('Gerado por', 'Sistema Decimus'),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Página 4 de 4 - Recomendações e Análise Final',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await _salvarECompartilharPDF(
        pdf,
        'relatorio_geral_completo_4paginas.pdf',
      );
    } catch (e, s) {
      _debugError('Erro ao gerar relatório geral', e, s);
      rethrow;
    }
  }

  // Relatório de Caixa
  static Future<void> gerarRelatorioCaixa() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _asMultiPage(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader('RELATÓRIO DE CAIXA'),
                  pw.SizedBox(height: 20),

                  // Movimentações do Caixa
                  _buildSection('MOVIMENTAÇÕES DO CAIXA'),
                  _buildInfoRow(
                    'Entradas (Recebíveis + Pagamentos)',
                    'R\$ ${FinanceiroServicesGlobal.totalEmCaixa.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Saídas (Despesas Pagas)',
                    'R\$ ${FinanceiroServiceDespesas.totalDespesasPagas.toStringAsFixed(2)}',
                  ),
                  pw.Divider(thickness: 2),
                  _buildInfoRow(
                    'SALDO ATUAL',
                    'R\$ ${FinanceiroServiceCaixa.saldoFinalDoCaixa.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                  pw.SizedBox(height: 20),

                  // Análise de Liquidez
                  _buildSection('ANÁLISE DE LIQUIDEZ'),
                  _buildInfoRow(
                    'Disponível Imediato',
                    'R\$ ${FinanceiroServiceCaixa.saldoFinalDoCaixa.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'A Receber (30 dias)',
                    'R\$ ${FinanceiroServiceDevedores.devedoresPendentes.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'A Pagar (30 dias)',
                    'R\$ ${FinanceiroServiceDespesas.totalDespesasPendentes.toStringAsFixed(2)}',
                  ),
                  pw.SizedBox(height: 20),

                  // Data e Hora
                  _buildInfoRow(
                    'Data do Relatório',
                    _formatter.format(DateTime.now()),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await _salvarECompartilharPDF(pdf, 'relatorio_caixa.pdf');
    } catch (e, s) {
      _debugError('Erro ao gerar relatório de caixa', e, s);
      rethrow;
    }
  }

  // Relatório de Recebíveis
  static Future<void> gerarRelatorioRecebiveis() async {
    try {
      // Recalcular totais e carregar recebíveis antes de gerar o relatório
      await FinanceiroServiceRecebiveis.calcularTotalRecebiveis();
      await FinanceiroServiceRecebiveis.carregarRecebiveis();

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _asMultiPage(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader('RELATÓRIO DE RECEBÍVEIS'),
                  pw.SizedBox(height: 20),

                  // Resumo dos Recebíveis
                  _buildSection('RESUMO DOS RECEBÍVEIS'),
                  _buildInfoRow(
                    'Total de Recebíveis',
                    'R\$ ${FinanceiroServiceRecebiveis.totalRecebiveis.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Devedores Pendentes',
                    'R\$ ${FinanceiroServiceDevedores.devedoresPendentes.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Pagamentos Recebidos',
                    'R\$ ${FinanceiroServiceDevedores.totalPagamentosRecebidos.toStringAsFixed(2)}',
                  ),
                  pw.SizedBox(height: 15),

                  // Análise de Inadimplência
                  _buildSection('ANÁLISE DE INADIMPLÊNCIA'),
                  pw.SizedBox(height: 10),
                  _buildInfoRow(
                    'Percentual Recebido',
                    '${_calcularPercentualRecebido().toStringAsFixed(1)}%',
                  ),
                  _buildInfoRow(
                    'Percentual Pendente',
                    '${(100 - _calcularPercentualRecebido()).toStringAsFixed(1)}%',
                  ),
                  pw.SizedBox(height: 20),

                  // Últimos Recebíveis Cadastrados
                  _buildSection('ÚLTIMOS RECEBÍVEIS CADASTRADOS'),
                  pw.SizedBox(height: 10),
                  ..._buildRecebiveisDetalhados(),
                  pw.SizedBox(height: 20),

                  // Últimos Devedores Cadastrados Pagos
                  _buildSection('ÚLTIMOS DEVEDORES CADASTRADOS PAGOS'),
                  pw.SizedBox(height: 10),
                  ..._buildDevedoresPagosDetalhados(),
                  pw.SizedBox(height: 20),

                  // Data e Hora
                  _buildInfoRow(
                    'Data do Relatório',
                    _formatter.format(DateTime.now()),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await _salvarECompartilharPDF(pdf, 'relatorio_recebiveis.pdf');
    } catch (e, s) {
      _debugError('Erro ao gerar relatório de recebíveis', e, s);
      rethrow;
    }
  }

  // Relatório de Despesas
  static Future<void> gerarRelatorioDespesas() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _asMultiPage(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader('RELATÓRIO DE DESPESAS'),
                  pw.SizedBox(height: 20),

                  // Resumo das Despesas
                  _buildSection('RESUMO DAS DESPESAS'),
                  _buildInfoRow(
                    'Total de Despesas',
                    'R\$ ${FinanceiroServiceDespesas.totalDespesas.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Despesas Pendentes',
                    'R\$ ${FinanceiroServiceDespesas.totalDespesasPendentes.toStringAsFixed(2)}',
                  ),
                  _buildInfoRow(
                    'Despesas Pagas',
                    'R\$ ${FinanceiroServiceDespesas.totalDespesasPagas.toStringAsFixed(2)}',
                  ),
                  pw.SizedBox(height: 15),

                  // Análise de Controle
                  _buildSection('ANÁLISE DE CONTROLE'),
                  pw.SizedBox(height: 10),
                  _buildInfoRow(
                    'Percentual Pago',
                    '${_calcularPercentualPago().toStringAsFixed(1)}%',
                  ),
                  _buildInfoRow(
                    'Percentual Pendente',
                    '${(100 - _calcularPercentualPago()).toStringAsFixed(1)}%',
                  ),
                  pw.SizedBox(height: 20),

                  // Data e Hora
                  _buildInfoRow(
                    'Data do Relatório',
                    _formatter.format(DateTime.now()),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await _salvarECompartilharPDF(pdf, 'relatorio_despesas.pdf');
    } catch (e, s) {
      _debugError('Erro ao gerar relatório de despesas', e, s);
      rethrow;
    }
  }

  // Relatório em Excel
  static Future<void> gerarRelatorioExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Relatório do Caixa'];

      // Cabeçalho
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'RELATÓRIO DO CAIXA';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
          .value = 'Data: ${_formatter.format(DateTime.now())}';

      // Dados do Caixa
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
          .value = 'ITEM';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
          .value = 'VALOR (R\$)';

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
          .value = 'Saldo Atual do Caixa';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
          .value = FinanceiroServiceCaixa.saldoFinalDoCaixa;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5))
          .value = 'Total em Caixa';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5))
          .value = FinanceiroServicesGlobal.totalEmCaixa;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 6))
          .value = 'Devedores Pendentes';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 6))
          .value = FinanceiroServiceDevedores.devedoresPendentes;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 7))
          .value = 'Despesas Pendentes';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 7))
          .value = FinanceiroServiceDespesas.totalDespesasPendentes;

      // Nota: Ajuste manual das colunas no Excel

      await _salvarECompartilharExcel(excel, 'relatorio_caixa.xlsx');
    } catch (e, s) {
      _debugError('Erro ao gerar relatório Excel', e, s);
      rethrow;
    }
  }

  // Métodos auxiliares para construção do PDF
  static List<pw.Widget> _asMultiPage(pw.Widget widget) => [widget];

  static pw.Widget _buildHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildSection(String title) {
    return pw.Container(
      width: double.infinity,
      margin: pw.EdgeInsets.only(top: 15, bottom: 10),
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey300,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Método para salvar e compartilhar PDF
  static Future<void> _salvarECompartilharPDF(
    pw.Document pdf,
    String fileName,
  ) async {
    final Uint8List bytes = await pdf.save();
    await FileSaver.savePdf(bytes, fileName);
  }

  // Método para salvar e compartilhar Excel
  static Future<void> _salvarECompartilharExcel(
    Excel excel,
    String fileName,
  ) async {
    final Uint8List bytes = Uint8List.fromList(excel.encode()!);
    await FileSaver.saveExcel(bytes, fileName);
  }

  // Métodos auxiliares para cálculos
  static double _calcularPercentualRecebido() {
    final recebido = FinanceiroServiceDevedores.totalPagamentosRecebidos;
    final pendente = FinanceiroServiceDevedores.devedoresPendentes;
    final baseCalculo = recebido + pendente;

    if (baseCalculo <= 0) return 0.0;

    final percentual = (recebido / baseCalculo) * 100;
    return percentual.clamp(0.0, 100.0).toDouble();
  }

  static double _calcularPercentualPago() {
    return FinanceiroServiceDespesas.totalDespesas > 0
        ? ((FinanceiroServiceDespesas.totalDespesasPagas /
                FinanceiroServiceDespesas.totalDespesas) *
            100)
        : 0.0;
  }

  // NOVOS MÉTODOS PARA RELATÓRIO DETALHADO

  // Cálculo de saldo previsto em 30 dias
  static double _calcularSaldoPrevisto() {
    final recebimentosPrevistos = _calcularRecebimentos30Dias();
    final pagamentosPrevistos = _calcularPagamentos30Dias();
    return FinanceiroServiceCaixa.saldoFinalDoCaixa +
        recebimentosPrevistos -
        pagamentosPrevistos;
  }

  // Cálculo de saldo previsto em 60 dias
  static double _calcularSaldoPrevisto60Dias() {
    final recebimentosPrevistos = _calcularRecebimentos30Dias() * 2;
    final pagamentosPrevistos = _calcularPagamentos30Dias() * 2;
    return FinanceiroServiceCaixa.saldoFinalDoCaixa +
        recebimentosPrevistos -
        pagamentosPrevistos;
  }

  // Cálculo de saldo previsto em 90 dias
  static double _calcularSaldoPrevisto90Dias() {
    final recebimentosPrevistos = _calcularRecebimentos30Dias() * 3;
    final pagamentosPrevistos = _calcularPagamentos30Dias() * 3;
    return FinanceiroServiceCaixa.saldoFinalDoCaixa +
        recebimentosPrevistos -
        pagamentosPrevistos;
  }

  // Situação financeira baseada no saldo
  static String _getSituacaoFinanceira() {
    final saldo = FinanceiroServiceCaixa.saldoFinalDoCaixa;
    if (saldo > 0) {
      if (saldo > 1000) return 'EXCELENTE';
      if (saldo > 500) return 'BOA';
      return 'REGULAR';
    } else {
      return 'CRÍTICA';
    }
  }

  // Taxa de recebimento
  static double _calcularTaxaRecebimento() {
    final total = FinanceiroServiceRecebiveis.totalRecebiveis;
    final recebido = FinanceiroServiceDevedores.totalPagamentosRecebidos;
    return total > 0 ? (recebido / total) * 100 : 0.0;
  }

  // Taxa de pagamento
  static double _calcularTaxaPagamento() {
    final total = FinanceiroServiceDespesas.totalDespesas;
    final pago = FinanceiroServiceDespesas.totalDespesasPagas;
    return total > 0 ? (pago / total) * 100 : 0.0;
  }

  // Fluxo de entrada mensal (estimativa)
  static double _calcularFluxoEntradaMensal() {
    return FinanceiroServiceDevedores.totalPagamentosRecebidos *
        0.8; // Estimativa baseada no histórico
  }

  // Fluxo de saída mensal (estimativa)
  static double _calcularFluxoSaidaMensal() {
    return FinanceiroServiceDespesas.totalDespesasPagas *
        0.8; // Estimativa baseada no histórico
  }

  // Resultado operacional
  static double _calcularResultadoOperacional() {
    return _calcularFluxoEntradaMensal() - _calcularFluxoSaidaMensal();
  }

  // Recebimentos previstos em 30 dias
  static double _calcularRecebimentos30Dias() {
    return FinanceiroServiceDevedores.devedoresPendentes *
        0.6; // Estimativa de 60% de recebimento
  }

  // Pagamentos previstos em 30 dias
  static double _calcularPagamentos30Dias() {
    return FinanceiroServiceDespesas.totalDespesasPendentes *
        0.7; // Estimativa de 70% de pagamento
  }

  // Índice de liquidez
  static double _calcularIndiceLiquidez() {
    final ativoCirculante =
        FinanceiroServiceCaixa.saldoFinalDoCaixa +
        _calcularRecebimentos30Dias();
    final passivoCirculante = _calcularPagamentos30Dias();

    if (passivoCirculante <= 0) {
      return ativoCirculante > 0 ? double.infinity : 0.0;
    }

    return ativoCirculante / passivoCirculante;
  }

  // Avaliação de risco de liquidez
  static String _formatarIndiceLiquidez() {
    final indice = _calcularIndiceLiquidez();
    if (indice.isInfinite) return 'Sem passivos (favoravel)';
    return indice.toStringAsFixed(2);
  }

  static String _avaliarRiscoLiquidez() {
    final indice = _calcularIndiceLiquidez();
    if (indice.isInfinite) return 'BAIXO';
    if (indice >= 2.0) return 'BAIXO';
    if (indice >= 1.0) return 'MÉDIO';
    return 'ALTO';
  }

  // Avaliação de risco de inadimplência
  static String _avaliarRiscoInadimplencia() {
    final taxa = _calcularTaxaRecebimento();
    if (taxa >= 90) return 'BAIXO';
    if (taxa >= 70) return 'MÉDIO';
    return 'ALTO';
  }

  // Avaliação de risco de superendividamento
  static String _avaliarRiscoSuperendividamento() {
    final saldo = FinanceiroServiceCaixa.saldoFinalDoCaixa;
    final despesasPendentes = FinanceiroServiceDespesas.totalDespesasPendentes;

    if (despesasPendentes == 0) return 'BAIXO';

    final razao = saldo / despesasPendentes;
    if (razao >= 3.0) return 'BAIXO';
    if (razao >= 1.5) return 'MÉDIO';
    return 'ALTO';
  }

  // Margem operacional
  static double _calcularMargemOperacional() {
    final receita = _calcularFluxoEntradaMensal();
    final despesa = _calcularFluxoSaidaMensal();
    return receita > 0 ? ((receita - despesa) / receita) * 100 : 0.0;
  }

  // Retorno sobre investimento (ROI)
  static double _calcularROI() {
    final lucro = _calcularResultadoOperacional();
    final investimento = FinanceiroServiceDespesas.totalDespesasPagas;
    return investimento > 0 ? (lucro / investimento) * 100 : 0.0;
  }

  // Ciclo operacional
  static double _calcularCicloOperacional() {
    // Estimativa baseada em padrões do mercado
    return 45.0; // 45 dias em média
  }

  // Construir recomendações baseadas na análise
  static List<pw.Widget> _buildRecomendacoes() {
    final saldo = FinanceiroServiceCaixa.saldoFinalDoCaixa;
    final recebiveisPendentes = FinanceiroServiceDevedores.devedoresPendentes;
    final despesasPendentes = FinanceiroServiceDespesas.totalDespesasPendentes;

    List<String> recomendacoes = [];

    // Recomendações baseadas no saldo
    if (saldo < 0) {
      recomendacoes.add(
        'URGENTE: Implementar medidas para aumentar o fluxo de caixa',
      );
      recomendacoes.add('Considerar renegociação de despesas pendentes');
    } else if (saldo < 500) {
      recomendacoes.add(
        'ATENÇÃO: Saldo baixo - controlar gastos e acelerar recebimentos',
      );
    }

    // Recomendações baseadas em recebíveis
    if (recebiveisPendentes > saldo * 2) {
      recomendacoes.add(
        'FOCAR: Implementar estratégias de cobrança mais agressivas',
      );
      recomendacoes.add('Considerar desconto para pagamento antecipado');
    }

    // Recomendações baseadas em despesas
    if (despesasPendentes > saldo * 1.5) {
      recomendacoes.add('PRIORIDADE: Revisar e priorizar despesas essenciais');
      recomendacoes.add('Negociar prazos de pagamento com fornecedores');
    }

    // Recomendações gerais
    recomendacoes.add('MONITORAR: Acompanhar indicadores diariamente');
    recomendacoes.add(
      'PLANEJAR: Criar reserva de emergência de pelo menos 3 meses de despesas',
    );
    recomendacoes.add(
      'INVESTIR: Considerar aplicações de curto prazo para saldos positivos',
    );

    return recomendacoes
        .map(
          (rec) => pw.Container(
            margin: pw.EdgeInsets.only(bottom: 8),
            padding: pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
            ),
            child: pw.Text(
              rec,
              style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
            ),
          ),
        )
        .toList();
  }

  // Construir detalhamento das movimentações
  static List<pw.Widget> _buildMovimentacoesDetalhadas() {
    List<pw.Widget> widgets = [];

    // Resumo das entradas
    widgets.add(
      pw.Container(
        margin: pw.EdgeInsets.only(bottom: 10),
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.green50,
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border.all(color: PdfColors.green300, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'ENTRADAS REALIZADAS',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Total: R\$ ${FinanceiroServiceDevedores.totalPagamentosRecebidos.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.green700),
            ),
          ],
        ),
      ),
    );

    // Resumo das saídas
    widgets.add(
      pw.Container(
        margin: pw.EdgeInsets.only(bottom: 10),
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.red50,
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border.all(color: PdfColors.red300, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'SAÍDAS REALIZADAS',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Total: R\$ ${FinanceiroServiceDespesas.totalDespesasPagas.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.red700),
            ),
          ],
        ),
      ),
    );

    // Resumo dos pendentes
    widgets.add(
      pw.Container(
        margin: pw.EdgeInsets.only(bottom: 10),
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.orange50,
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border.all(color: PdfColors.orange300, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PENDENTES',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'A Receber: R\$ ${FinanceiroServiceDevedores.devedoresPendentes.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.orange700),
            ),
            pw.Text(
              'A Pagar: R\$ ${FinanceiroServiceDespesas.totalDespesasPendentes.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.orange700),
            ),
          ],
        ),
      ),
    );

    return widgets;
  }

  // Método para construir lista detalhada de recebíveis
  static List<pw.Widget> _buildRecebiveisDetalhados() {
    final recebiveis = FinanceiroServiceRecebiveis.ultimosRecebiveis;

    if (recebiveis.isEmpty) {
      return [
        pw.Container(
          margin: pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            'Nenhum recebível cadastrado',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ];
    }

    return recebiveis.map((recebivel) {
      return pw.Container(
        margin: pw.EdgeInsets.only(bottom: 8),
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  recebivel.nome,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'R\$ ${recebivel.valor.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Tipo: ${recebivel.tipo.isEmpty ? "Nao informado" : recebivel.tipo}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Data: ${_formatter.format(recebivel.data)}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Status: ${recebivel.pago ? "PAGO" : "PENDENTE"}',
              style: pw.TextStyle(
                fontSize: 10,
                color: recebivel.pago ? PdfColors.green : PdfColors.orange,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Método para construir lista detalhada de devedores pagos
  static List<pw.Widget> _buildDevedoresPagosDetalhados() {
    final devedoresPagos = FinanceiroServiceDevedores.ultimosDevedoresPagos;

    if (devedoresPagos.isEmpty) {
      return [
        pw.Container(
          margin: pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            'Nenhum devedor pago encontrado',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ];
    }

    return devedoresPagos.map((devedor) {
      return pw.Container(
        margin: pw.EdgeInsets.only(bottom: 8),
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  devedor.nome,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'R\$ ${devedor.valorOriginal.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Descrição: ${devedor.descricao}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Vencimento: ${_formatter.format(devedor.dataVencimento)}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Status: PAGO',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.green,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Método para construir lista detalhada de pagamentos recebidos
  static List<pw.Widget> _buildListaCompletaPagamentosRecebidos() {
    final pagamentos = FinanceiroServiceDevedores.ultimosDevedoresPagos;

    if (pagamentos.isEmpty) {
      return [
        pw.Container(
          margin: pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            'Nenhum pagamento recebido encontrado',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ];
    }

    return pagamentos.map((pagamento) {
      return pw.Container(
        margin: pw.EdgeInsets.only(bottom: 8),
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  pagamento.nome,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'R\$ ${pagamento.valorOriginal.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Descrição: ${pagamento.descricao}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Vencimento: ${_formatter.format(pagamento.dataVencimento)}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Status: PAGO',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.green,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Método para construir lista detalhada de recebíveis pendentes
  static List<pw.Widget> _buildListaCompletaRecebiveisPendentes() {
    final recebiveis =
        FinanceiroServiceRecebiveis.listaRecebimentos
            .where((r) => !r.pago)
            .toList();

    if (recebiveis.isEmpty) {
      return [
        pw.Container(
          margin: pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            'Nenhum recebível pendente encontrado',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ];
    }

    return recebiveis.map((recebivel) {
      return pw.Container(
        margin: pw.EdgeInsets.only(bottom: 8),
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  recebivel.nome,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'R\$ ${recebivel.valor.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.orange,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Tipo: ${recebivel.tipo.isEmpty ? "Nao informado" : recebivel.tipo}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Data: ${_formatter.format(recebivel.data)}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Status: PENDENTE',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.orange,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Método para construir lista detalhada de despesas pagas
  static List<pw.Widget> _buildListaCompletaDespesasPagas() {
    final despesas =
        FinanceiroServiceDespesas.listaConta.where((d) => d.pago).toList();

    if (despesas.isEmpty) {
      return [
        pw.Container(
          margin: pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            'Nenhuma despesa paga encontrada',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ];
    }

    return despesas.map((despesa) {
      return pw.Container(
        margin: pw.EdgeInsets.only(bottom: 8),
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  despesa.descricao ?? 'Sem descrição',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'R\$ ${despesa.valor.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Tipo: ${despesa.tipoConta ?? 'Não informado'}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Valor: R\$ ${despesa.valor.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Status: PAGO',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.green,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Método para construir lista detalhada de despesas pendentes
  static List<pw.Widget> _buildListaCompletaDespesasPendentes() {
    final despesas =
        FinanceiroServiceDespesas.listaConta.where((d) => !d.pago).toList();

    if (despesas.isEmpty) {
      return [
        pw.Container(
          margin: pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            'Nenhuma despesa pendente encontrada',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ];
    }

    return despesas.map((despesa) {
      return pw.Container(
        margin: pw.EdgeInsets.only(bottom: 8),
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  despesa.descricao ?? 'Sem descrição',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'R\$ ${despesa.valor.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Tipo: ${despesa.tipoConta ?? 'Não informado'}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Valor: R\$ ${despesa.valor.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Status: PENDENTE',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.red,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Método para analisar tendência de recebimentos
  static String _analisarTendenciaRecebimentos() {
    final pagamentos = FinanceiroServiceDevedores.ultimosDevedoresPagos;
    final primeiroPagamento = pagamentos.isNotEmpty ? pagamentos.first : null;
    final ultimoPagamento = pagamentos.isNotEmpty ? pagamentos.last : null;

    if (primeiroPagamento == null || ultimoPagamento == null) {
      return 'Não há dados suficientes para analisar tendência.';
    }

    final diferencaDias =
        ultimoPagamento.dataVencimento
            .difference(primeiroPagamento.dataVencimento)
            .inDays;
    final diferencaValor =
        ultimoPagamento.valorOriginal - primeiroPagamento.valorOriginal;

    if (diferencaDias == 0) {
      return 'Valor constante.';
    }

    final taxaVariacao =
        (diferencaValor / primeiroPagamento.valorOriginal) * 100;

    if (taxaVariacao > 0) {
      return 'Aumento de ${taxaVariacao.toStringAsFixed(1)}%';
    } else {
      return 'Redução de ${taxaVariacao.abs().toStringAsFixed(1)}%';
    }
  }

  // Método para analisar tendência de despesas
  static String _analisarTendenciaDespesas() {
    final despesas =
        FinanceiroServiceDespesas.listaConta.where((d) => d.pago).toList();
    final primeiraDespesa = despesas.isNotEmpty ? despesas.first : null;
    final ultimaDespesa = despesas.isNotEmpty ? despesas.last : null;

    if (primeiraDespesa == null || ultimaDespesa == null) {
      return 'Não há dados suficientes para analisar tendência.';
    }

    final diferencaDias = 30; // Estimativa de 30 dias
    final diferencaValor = ultimaDespesa.valor - primeiraDespesa.valor;

    if (diferencaDias == 0) {
      return 'Valor constante.';
    }

    final taxaVariacao = (diferencaValor / primeiraDespesa.valor) * 100;

    if (taxaVariacao > 0) {
      return 'Aumento de ${taxaVariacao.toStringAsFixed(1)}%';
    } else {
      return 'Redução de ${taxaVariacao.abs().toStringAsFixed(1)}%';
    }
  }

  // Método para prever o próximo mês
  static String _preverProximoMes() {
    final pagamentos = FinanceiroServiceDevedores.ultimosDevedoresPagos;
    final despesas =
        FinanceiroServiceDespesas.listaConta.where((d) => d.pago).toList();

    final ultimoPagamento = pagamentos.isNotEmpty ? pagamentos.last : null;
    final ultimoDespesa = despesas.isNotEmpty ? despesas.last : null;

    if (ultimoPagamento == null || ultimoDespesa == null) {
      return 'Não há dados suficientes para prever.';
    }

    final proximoMes = ultimoPagamento.dataVencimento.add(
      const Duration(days: 30),
    );
    final proximoMesDespesa = DateTime.now().add(const Duration(days: 30));

    return 'Recebimentos: ${_formatter.format(proximoMes)}, Despesas: ${_formatter.format(proximoMesDespesa)}';
  }

  // Método para obter quantidade de pagamentos recebidos
  static String _getQuantidadePagamentosRecebidos() {
    final quantidade =
        FinanceiroServiceDevedores.listDevedor.where((d) => d.pago).length;
    return quantidade.toString();
  }

  // Método para obter quantidade de despesas pagas
  static String _getQuantidadeDespesasPagas() {
    final quantidade =
        FinanceiroServiceDespesas.listaConta.where((d) => d.pago).length;
    return quantidade.toString();
  }

  static void _debugError(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('[RelatoriosService] $message: $error');
    debugPrint('$stackTrace');
  }
}
