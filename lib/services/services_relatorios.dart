import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:decimus/utils/file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:decimus/services/services_caixa.dart';
import 'package:decimus/services/services_despesas.dart';
import 'package:decimus/services/services_devedores.dart';
import 'package:decimus/services/services_recebiveis.dart';
import 'package:decimus/services/global_services.dart';

class RelatoriosService {
  static final DateFormat _formatter = DateFormat('dd/MM/yyyy HH:mm');

  // Relatório Geral do Caixa
  static Future<void> gerarRelatorioGeral() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader('RELATÓRIO GERAL DO CAIXA'),
                pw.SizedBox(height: 20),

                // Resumo Financeiro
                _buildSection('RESUMO FINANCEIRO'),
                _buildInfoRow(
                  'Saldo Atual do Caixa',
                  'R\$ ${FinanceiroServiceCaixa.saldoFinalDoCaixa.toStringAsFixed(2)}',
                ),
                _buildInfoRow(
                  'Total em Caixa',
                  'R\$ ${FinanceiroServicesGlobal.totalEmCaixa.toStringAsFixed(2)}',
                ),
                _buildInfoRow(
                  'Total de Despesas Pagas',
                  'R\$ ${FinanceiroServiceDespesas.totalDespesasPagas.toStringAsFixed(2)}',
                ),
                pw.SizedBox(height: 15),

                // Recebíveis
                _buildSection('RECEBÍVEIS'),
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

                // Despesas
                _buildSection('DESPESAS'),
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
                pw.SizedBox(height: 20),

                // Data e Hora
                _buildInfoRow(
                  'Data do Relatório',
                  _formatter.format(DateTime.now()),
                ),
              ],
            );
          },
        ),
      );

      await _salvarECompartilharPDF(pdf, 'relatorio_geral_caixa.pdf');
    } catch (e) {
      print('Erro ao gerar relatório geral: $e');
      rethrow;
    }
  }

  // Relatório de Caixa
  static Future<void> gerarRelatorioCaixa() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
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
            );
          },
        ),
      );

      await _salvarECompartilharPDF(pdf, 'relatorio_caixa.pdf');
    } catch (e) {
      print('Erro ao gerar relatório de caixa: $e');
      rethrow;
    }
  }

  // Relatório de Recebíveis
  static Future<void> gerarRelatorioRecebiveis() async {
    try {
      // Carregar recebíveis antes de gerar o relatório
      await FinanceiroServiceRecebiveis.carregarRecebiveis();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
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
            );
          },
        ),
      );

      await _salvarECompartilharPDF(pdf, 'relatorio_recebiveis.pdf');
    } catch (e) {
      print('Erro ao gerar relatório de recebíveis: $e');
      rethrow;
    }
  }

  // Relatório de Despesas
  static Future<void> gerarRelatorioDespesas() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
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
            );
          },
        ),
      );

      await _salvarECompartilharPDF(pdf, 'relatorio_despesas.pdf');
    } catch (e) {
      print('Erro ao gerar relatório de despesas: $e');
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
    } catch (e) {
      print('Erro ao gerar relatório Excel: $e');
      rethrow;
    }
  }

  // Métodos auxiliares para construção do PDF
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
    return FinanceiroServicesGlobal.totalEmCaixa > 0
        ? ((FinanceiroServiceDevedores.totalPagamentosRecebidos /
                FinanceiroServicesGlobal.totalEmCaixa) *
            100)
        : 0.0;
  }

  static double _calcularPercentualPago() {
    return FinanceiroServiceDespesas.totalDespesas > 0
        ? ((FinanceiroServiceDespesas.totalDespesasPagas /
                FinanceiroServiceDespesas.totalDespesas) *
            100)
        : 0.0;
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
                  'Tipo: ${recebivel.tipo}',
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
}
