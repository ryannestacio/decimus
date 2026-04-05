import 'package:decimus/services/services_caixa.dart';
import 'package:decimus/services/services_devedores.dart';
import 'package:decimus/services/services_despesas.dart';
import 'package:decimus/services/services_recebiveis.dart';
import 'package:decimus/services/services_relatorios.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CaixaScreen extends StatelessWidget {
  const CaixaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: BodyCaixa());
  }
}

class _SacredPalette {
  static const Color marianBlue = Color(0xFF1F3A5F);
  static const Color ivory = Color(0xFFF7F4EE);
  static const Color matteGold = Color(0xFFC8A96B);
  static const Color graphite = Color(0xFF2B2B2B);
  static const Color hopeGreen = Color(0xFF4F7A5A);
}

class BodyCaixa extends StatefulWidget {
  const BodyCaixa({super.key});

  @override
  State<BodyCaixa> createState() => _BodyCaixaState();
}

class _BodyCaixaState extends State<BodyCaixa> {
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  bool _isGeneratingReport = false;
  bool _loading = true;
  bool _showContent = false;
  DateTime? _lastUpdated;

  double get _caixaAtual => FinanceiroServiceCaixa.saldoFinalDoCaixa;
  double get _entradasRecebiveis => FinanceiroServiceRecebiveis.totalRecebiveis;
  double get _entradasDevedores =>
      FinanceiroServiceDevedores.totalPagamentosRecebidos;
  double get _despesasPagas => FinanceiroServiceDespesas.totalDespesasPagas;
  double get _despesasPendentes =>
      FinanceiroServiceDespesas.totalDespesasPendentes;
  double get _recebiveisPrevistos =>
      FinanceiroServiceDevedores.devedoresPendentes;

  double get _saldoProjetado =>
      _caixaAtual + _recebiveisPrevistos - _despesasPendentes;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _showContent = true;
      });
    });
  }

  Future<void> _carregarDados() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      await FinanceiroServiceRecebiveis.calcularTotalRecebiveis();
      await FinanceiroServiceRecebiveis.carregarRecebiveis();
      await FinanceiroServiceDevedores.carregarDevedores();
      await FinanceiroServiceDespesas.sincronizarECarregarDespesas();

      if (!mounted) return;
      setState(() {
        _lastUpdated = DateTime.now();
      });
    } catch (_) {
      _showFeedback(
        'Nao foi possivel atualizar os dados do caixa.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;

    final backgroundColor =
        isError ? Colors.red.shade700 : _SacredPalette.hopeGreen;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.sourceSans3(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: backgroundColor,
        ),
      );
  }

  String _money(double value) => _currencyFormatter.format(value);

  double _metricCardWidth(double availableWidth) {
    if (availableWidth >= 760) {
      return 250;
    }
    if (availableWidth >= 480) {
      return 230;
    }
    return 210;
  }

  Future<void> _executarRelatorio({
    required Future<void> Function() task,
    required String successMessage,
    required String errorMessage,
  }) async {
    if (_isGeneratingReport) return;

    setState(() {
      _isGeneratingReport = true;
    });

    try {
      await task();
      _showFeedback(successMessage);
    } catch (_) {
      _showFeedback(errorMessage, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingReport = false;
        });
      }
    }
  }

  Future<void> _gerarRelatorioCaixa() async {
    await _executarRelatorio(
      task: RelatoriosService.gerarRelatorioCaixa,
      successMessage: 'Relatorio de caixa gerado com sucesso.',
      errorMessage: 'Erro ao gerar relatorio de caixa.',
    );
  }

  Future<void> _gerarRelatorioRecebiveis() async {
    await _executarRelatorio(
      task: RelatoriosService.gerarRelatorioRecebiveis,
      successMessage: 'Relatorio de recebiveis gerado com sucesso.',
      errorMessage: 'Erro ao gerar relatorio de recebiveis.',
    );
  }

  Future<void> _gerarRelatorioDespesas() async {
    await _executarRelatorio(
      task: RelatoriosService.gerarRelatorioDespesas,
      successMessage: 'Relatorio de despesas gerado com sucesso.',
      errorMessage: 'Erro ao gerar relatorio de despesas.',
    );
  }

  Future<void> _gerarRelatorioGeral() async {
    await _executarRelatorio(
      task: RelatoriosService.gerarRelatorioGeral,
      successMessage: 'Relatorio geral gerado com sucesso.',
      errorMessage: 'Erro ao gerar relatorio geral.',
    );
  }

  Future<void> _gerarRelatorioExcel() async {
    await _executarRelatorio(
      task: RelatoriosService.gerarRelatorioExcel,
      successMessage: 'Relatorio em Excel gerado com sucesso.',
      errorMessage: 'Erro ao gerar relatorio em Excel.',
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/home'),
          style: IconButton.styleFrom(
            minimumSize: const Size(44, 44),
            backgroundColor: _SacredPalette.marianBlue,
            foregroundColor: _SacredPalette.ivory,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 10),
        const SizedBox(
          width: 22,
          height: 22,
          child: CustomPaint(
            painter: _CrossMarkPainter(_SacredPalette.matteGold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Caixa',
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: _SacredPalette.graphite,
            ),
          ),
        ),
        IconButton(
          onPressed: _isGeneratingReport ? null : _carregarDados,
          style: IconButton.styleFrom(
            minimumSize: const Size(44, 44),
            backgroundColor: _SacredPalette.hopeGreen,
            foregroundColor: _SacredPalette.ivory,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _buildBalanceBanner() {
    final isNegative = _caixaAtual < 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _SacredPalette.marianBlue,
            _SacredPalette.marianBlue.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _SacredPalette.matteGold.withValues(alpha: 0.52),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caixa atual da igreja',
            style: GoogleFonts.sourceSans3(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _SacredPalette.ivory.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _money(_caixaAtual),
            style: GoogleFonts.playfairDisplay(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              color:
                  isNegative ? const Color(0xFFFFB4AB) : _SacredPalette.ivory,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isNegative
                ? 'Atencao: saldo atual esta negativo.'
                : 'Saldo atualizado com entradas e saidas confirmadas.',
            style: GoogleFonts.sourceSans3(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _SacredPalette.ivory.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required double width,
    required String title,
    required String value,
    required String helper,
    required IconData icon,
    required Color accent,
  }) {
    return SizedBox(
      width: width,
      height: 126,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _SacredPalette.marianBlue.withValues(alpha: 0.14),
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _SacredPalette.graphite,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _SacredPalette.graphite,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    helper,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _SacredPalette.graphite.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRail(double availableWidth) {
    final cardWidth = _metricCardWidth(availableWidth);
    final cards = <Widget>[
      _buildMetricCard(
        width: cardWidth,
        title: 'Entradas de recebiveis',
        value: _money(_entradasRecebiveis),
        helper: 'Doacoes, dizimos e eventos',
        icon: Icons.call_received_rounded,
        accent: _SacredPalette.hopeGreen,
      ),
      _buildMetricCard(
        width: cardWidth,
        title: 'Pagamentos de devedores',
        value: _money(_entradasDevedores),
        helper: 'Pagamentos parciais e totais',
        icon: Icons.payments_rounded,
        accent: _SacredPalette.marianBlue,
      ),
      _buildMetricCard(
        width: cardWidth,
        title: 'Despesas pagas',
        value: _money(_despesasPagas),
        helper: 'Saidas ja confirmadas',
        icon: Icons.arrow_circle_down_rounded,
        accent: const Color(0xFFB5473A),
      ),
      _buildMetricCard(
        width: cardWidth,
        title: 'Despesas pendentes',
        value: _money(_despesasPendentes),
        helper: 'Compromissos a quitar',
        icon: Icons.schedule_rounded,
        accent: const Color(0xFF9A5E12),
      ),
      _buildMetricCard(
        width: cardWidth,
        title: 'Recebiveis previstos',
        value: _money(_recebiveisPrevistos),
        helper: 'Valores ainda a receber',
        icon: Icons.trending_up_rounded,
        accent: _SacredPalette.hopeGreen,
      ),
      _buildMetricCard(
        width: cardWidth,
        title: 'Saldo projetado',
        value: _money(_saldoProjetado),
        helper: 'Caixa + previstos - pendentes',
        icon: Icons.insights_rounded,
        accent:
            _saldoProjetado >= 0
                ? _SacredPalette.marianBlue
                : const Color(0xFFB5473A),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 126,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => cards[index],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Arraste para o lado para ver todos os indicadores.',
          style: GoogleFonts.sourceSans3(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _SacredPalette.graphite.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }

  Widget _buildReadabilityPanel() {
    final entradasConfirmadas = _entradasRecebiveis + _entradasDevedores;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _SacredPalette.marianBlue.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leitura clara do caixa',
            style: GoogleFonts.sourceSans3(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _SacredPalette.graphite,
            ),
          ),
          const SizedBox(height: 6),
          _buildInsightRow(
            'Entradas confirmadas',
            _money(entradasConfirmadas),
            _SacredPalette.hopeGreen,
          ),
          _buildInsightRow(
            'Saidas confirmadas',
            _money(_despesasPagas),
            const Color(0xFFB5473A),
          ),
          _buildInsightRow(
            'Compromissos pendentes',
            _money(_despesasPendentes),
            const Color(0xFF9A5E12),
          ),
          _buildInsightRow(
            'Saldo projetado (caixa + previstos - pendentes)',
            _money(_saldoProjetado),
            _saldoProjetado >= 0
                ? _SacredPalette.marianBlue
                : const Color(0xFFB5473A),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _SacredPalette.graphite.withValues(alpha: 0.82),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.sourceSans3(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton({
    required double width,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool outlined = false,
  }) {
    if (outlined) {
      return SizedBox(
        width: width,
        height: 46,
        child: OutlinedButton.icon(
          onPressed: _isGeneratingReport ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _SacredPalette.marianBlue,
            side: BorderSide(
              color: _SacredPalette.marianBlue.withValues(alpha: 0.38),
              width: 1.4,
            ),
            backgroundColor: Colors.white.withValues(alpha: 0.60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.sourceSans3(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          icon:
              _isGeneratingReport
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  )
                  : Icon(icon),
          label: Text(label),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: _isGeneratingReport ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 2.0,
          shadowColor: Colors.black.withValues(alpha: 0.20),
          backgroundColor: _SacredPalette.marianBlue,
          foregroundColor: _SacredPalette.ivory,
          disabledBackgroundColor: _SacredPalette.marianBlue.withValues(
            alpha: 0.76,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon:
            _isGeneratingReport
                ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _SacredPalette.ivory,
                    ),
                  ),
                )
                : Icon(icon),
        label: Text(label),
      ),
    );
  }

  Future<void> _abrirDialogExportarRelatorios() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _SacredPalette.ivory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Exportar relatorios',
            style: GoogleFonts.playfairDisplay(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: _SacredPalette.graphite,
            ),
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReportButton(
                  width: double.infinity,
                  label: 'Relatorio de caixa',
                  icon: Icons.account_balance_wallet_rounded,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _gerarRelatorioCaixa();
                  },
                ),
                const SizedBox(height: 8),
                _buildReportButton(
                  width: double.infinity,
                  label: 'Relatorio de recebiveis',
                  icon: Icons.trending_up_rounded,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _gerarRelatorioRecebiveis();
                  },
                ),
                const SizedBox(height: 8),
                _buildReportButton(
                  width: double.infinity,
                  label: 'Relatorio de despesas',
                  icon: Icons.trending_down_rounded,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _gerarRelatorioDespesas();
                  },
                ),
                const SizedBox(height: 8),
                _buildReportButton(
                  width: double.infinity,
                  label: 'Relatorio geral',
                  icon: Icons.summarize_rounded,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _gerarRelatorioGeral();
                  },
                ),
                const SizedBox(height: 8),
                _buildReportButton(
                  width: double.infinity,
                  label: 'Relatorio Excel',
                  icon: Icons.table_chart_rounded,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _gerarRelatorioExcel();
                  },
                  outlined: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _SacredPalette.marianBlue,
                textStyle: GoogleFonts.sourceSans3(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isGeneratingReport ? null : _abrirDialogExportarRelatorios,
        style: ElevatedButton.styleFrom(
          elevation: 2.0,
          shadowColor: Colors.black.withValues(alpha: 0.20),
          backgroundColor: _SacredPalette.marianBlue,
          foregroundColor: _SacredPalette.ivory,
          disabledBackgroundColor: _SacredPalette.marianBlue.withValues(
            alpha: 0.76,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon:
            _isGeneratingReport
                ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _SacredPalette.ivory,
                    ),
                  ),
                )
                : const Icon(Icons.ios_share_rounded),
        label: const Text('Exportar Relatorios'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/agostinho.png', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _SacredPalette.marianBlue.withValues(alpha: 0.70),
                  const Color(0xFF14263E).withValues(alpha: 0.84),
                ],
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _SacredBackdropPainter()),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: LayoutBuilder(
              builder: (context, viewportConstraints) {
                final viewPadding = MediaQuery.of(context).viewPadding;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    14,
                    10,
                    14,
                    16 + viewPadding.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: _showContent ? 1 : 0,
                      curve: Curves.easeOut,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 220),
                        offset:
                            _showContent ? Offset.zero : const Offset(0, 0.05),
                        curve: Curves.easeOut,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _SacredPalette.ivory.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _SacredPalette.matteGold.withValues(
                                alpha: 0.45,
                              ),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.30),
                                blurRadius: 26,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 8),
                                Text(
                                  'Visao clara dos dados do caixa da igreja.',
                                  style: GoogleFonts.sourceSans3(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _SacredPalette.graphite.withValues(
                                      alpha: 0.80,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _lastUpdated != null
                                      ? 'Ultima atualizacao: ${_dateFormatter.format(_lastUpdated!)}'
                                      : 'Ultima atualizacao: carregando...',
                                  style: GoogleFonts.sourceSans3(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _SacredPalette.graphite.withValues(
                                      alpha: 0.65,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_loading)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 26),
                                    child: Center(
                                      child: SizedBox(
                                        height: 34,
                                        width: 34,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.8,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                _SacredPalette.marianBlue,
                                              ),
                                        ),
                                      ),
                                    ),
                                  )
                                else ...[
                                  _buildBalanceBanner(),
                                  const SizedBox(height: 10),
                                  _buildMetricsRail(
                                    viewportConstraints.maxWidth > 860
                                        ? 860
                                        : viewportConstraints.maxWidth,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildReadabilityPanel(),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Relatorios',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: _SacredPalette.graphite,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildExportButton(),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CrossMarkPainter extends CustomPainter {
  const _CrossMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.8;

    final centerX = size.width / 2;
    canvas.drawLine(
      Offset(centerX, size.height * 0.1),
      Offset(centerX, size.height * 0.9),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.42),
      Offset(size.width * 0.72, size.height * 0.42),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrossMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SacredBackdropPainter extends CustomPainter {
  const _SacredBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

    final stainedGlassPaint =
        Paint()
          ..color = _SacredPalette.matteGold.withValues(alpha: 0.08)
          ..style = PaintingStyle.fill;

    final outerArch =
        Path()
          ..moveTo(size.width * 0.15, size.height)
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.24,
            size.width * 0.85,
            size.height,
          );
    canvas.drawPath(outerArch, linePaint);

    final innerArch =
        Path()
          ..moveTo(size.width * 0.28, size.height)
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.42,
            size.width * 0.72,
            size.height,
          );
    canvas.drawPath(innerArch, linePaint);

    final stainedGlassLeft =
        Path()
          ..moveTo(size.width * 0.03, size.height * 0.14)
          ..lineTo(size.width * 0.34, size.height * 0.04)
          ..lineTo(size.width * 0.45, size.height * 0.20)
          ..lineTo(size.width * 0.12, size.height * 0.30)
          ..close();
    canvas.drawPath(stainedGlassLeft, stainedGlassPaint);

    final stainedGlassRight =
        Path()
          ..moveTo(size.width * 0.62, size.height * 0.08)
          ..lineTo(size.width * 0.97, size.height * 0.20)
          ..lineTo(size.width * 0.84, size.height * 0.37)
          ..lineTo(size.width * 0.58, size.height * 0.24)
          ..close();
    canvas.drawPath(stainedGlassRight, stainedGlassPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
