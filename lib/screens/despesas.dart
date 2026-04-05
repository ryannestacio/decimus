import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimus/models/models_despesas.dart';
import 'package:decimus/services/services_despesas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DespesasScreen extends StatelessWidget {
  const DespesasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: BodyDespesas());
  }
}

class _SacredPalette {
  static const Color marianBlue = Color(0xFF1F3A5F);
  static const Color ivory = Color(0xFFF7F4EE);
  static const Color matteGold = Color(0xFFC8A96B);
  static const Color graphite = Color(0xFF2B2B2B);
  static const Color hopeGreen = Color(0xFF4F7A5A);
}

class BodyDespesas extends StatefulWidget {
  const BodyDespesas({super.key});

  @override
  State<BodyDespesas> createState() => _BodyDespesasState();
}

class _BodyDespesasState extends State<BodyDespesas> {
  final TextEditingController _novoTipoContaController =
      TextEditingController();
  final TextEditingController _tipoContaController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  final GlobalKey<FormState> _formKeyTipoConta = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyNovaConta = GlobalKey<FormState>();

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  bool _despesaRecorrente = false;
  String _frequenciaRecorrencia = FrequenciaRecorrencia.mensal.value;
  DateTime _proximaExecucaoRecorrente = DateTime.now();

  bool _loading = true;
  bool _showContent = false;
  List<Conta> _listaTipoConta = <Conta>[];

  @override
  void initState() {
    super.initState();
    _inicializarDados();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _showContent = true;
      });
    });
  }

  @override
  void dispose() {
    _novoTipoContaController.dispose();
    _tipoContaController.dispose();
    _descricaoController.dispose();
    _observacoesController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _inicializarDados() async {
    try {
      await carregarTiposDeConta();
      await carregarDespesasDoFirestore();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _resetFormularioNovaConta() {
    _tipoContaController.clear();
    _descricaoController.clear();
    _observacoesController.clear();
    _valorController.clear();
    _despesaRecorrente = false;
    _frequenciaRecorrencia = FrequenciaRecorrencia.mensal.value;
    _proximaExecucaoRecorrente = DateTime.now();
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

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: _SacredPalette.marianBlue.withValues(alpha: 0.24),
        width: 1.1,
      ),
    );

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: GoogleFonts.sourceSans3(
        fontSize: 16,
        color: _SacredPalette.graphite.withValues(alpha: 0.50),
      ),
      labelStyle: GoogleFonts.sourceSans3(
        fontSize: 16,
        color: _SacredPalette.graphite.withValues(alpha: 0.75),
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, size: 22, color: _SacredPalette.marianBlue),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _SacredPalette.matteGold,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.8),
      ),
    );
  }

  Future<DateTime?> _pickDate(DateTime initialDate) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _SacredPalette.marianBlue,
              onPrimary: _SacredPalette.ivory,
              onSurface: _SacredPalette.graphite,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: _SacredPalette.ivory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  Future<void> _selecionarDataProximaExecucao(
    StateSetter setStateDialog,
  ) async {
    final dataSelecionada = await _pickDate(_proximaExecucaoRecorrente);

    if (dataSelecionada != null && mounted) {
      setStateDialog(() {
        _proximaExecucaoRecorrente = dataSelecionada;
      });
    }
  }

  Future<void> carregarTiposDeConta() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('tipos_despesas')
            .orderBy('createdAt', descending: false)
            .get();

    final tipos =
        snapshot.docs
            .map((doc) => Conta(tipoConta: (doc['tipoConta'] ?? '').toString()))
            .toList();

    if (!mounted) return;
    setState(() {
      _listaTipoConta = tipos;
    });
  }

  Future<void> carregarDespesasDoFirestore() async {
    try {
      await FinanceiroServiceDespesas.sincronizarECarregarDespesas();
      if (!mounted) return;
      setState(() {});
    } catch (_) {
      _showFeedback('Erro ao carregar despesas.', isError: true);
    }
  }

  Future<bool> _validarESalvarTipoConta() async {
    if (!_formKeyTipoConta.currentState!.validate()) {
      return false;
    }

    final tipo = _novoTipoContaController.text.trim();

    try {
      await FirebaseFirestore.instance.collection('tipos_despesas').add({
        'tipoConta': tipo,
        'createdAt': Timestamp.now(),
      });

      _novoTipoContaController.clear();
      await carregarTiposDeConta();
      _showFeedback('Tipo de conta salvo com sucesso.');
      return true;
    } catch (_) {
      _showFeedback('Erro ao salvar tipo de conta.', isError: true);
      return false;
    }
  }

  Future<bool> _validarESalvarNovaConta() async {
    FocusScope.of(context).unfocus();

    if (!_formKeyNovaConta.currentState!.validate()) {
      _showFeedback('Revise os campos destacados.', isError: true);
      return false;
    }

    final valorLimpo = toNumericString(
      _valorController.text,
      allowPeriod: false,
    );
    if (valorLimpo.isEmpty) {
      _showFeedback('Informe um valor valido para a conta.', isError: true);
      return false;
    }

    final valorParseado = double.tryParse(valorLimpo);
    if (valorParseado == null) {
      _showFeedback('Informe um valor numerico valido.', isError: true);
      return false;
    }

    final valorDouble = valorParseado / 100;
    final novaConta = ContaCad(
      tipoConta: _tipoContaController.text.trim(),
      descricao: _descricaoController.text.trim(),
      observacao: _observacoesController.text.trim(),
      valor: valorDouble,
      pago: false,
      recorrente: _despesaRecorrente,
      isTemplateRecorrente: _despesaRecorrente,
      frequenciaRecorrencia: _despesaRecorrente ? _frequenciaRecorrencia : null,
      proximaExecucao: _despesaRecorrente ? _proximaExecucaoRecorrente : null,
    );

    try {
      await FinanceiroServiceDespesas.salvarConta(novaConta);
      await carregarDespesasDoFirestore();
      if (!mounted) return false;

      setState(_resetFormularioNovaConta);
      final mensagem =
          _despesaRecorrente
              ? 'Despesa recorrente agendada com sucesso.'
              : 'Conta cadastrada com sucesso.';
      _showFeedback(mensagem);
      return true;
    } catch (_) {
      _showFeedback('Erro ao salvar conta no Firestore.', isError: true);
      return false;
    }
  }

  Future<bool> _marcarComoPago(ContaCad conta) async {
    if (conta.id == null || conta.id!.isEmpty) {
      _showFeedback(
        'Nao foi possivel confirmar: despesa sem ID no Firestore.',
        isError: true,
      );
      return false;
    }

    try {
      await FinanceiroServiceDespesas.marcarComoPago(conta.id!);
      await carregarDespesasDoFirestore();
      _showFeedback('Pagamento confirmado com sucesso.');
      return true;
    } catch (_) {
      _showFeedback('Erro ao confirmar pagamento.', isError: true);
      return false;
    }
  }

  String _montarDescricaoConta(ContaCad item) {
    final buffer = StringBuffer(
      'Descricao: ${item.descricao}\n'
      'Valor: ${_currencyFormatter.format(item.valor)}\n'
      'Observacoes: ${item.observacao}',
    );

    if (item.recorrente) {
      buffer.write(
        '\nRecorrencia: ${FinanceiroServiceDespesas.rotuloFrequencia(item.frequenciaRecorrencia)}',
      );
      if (item.proximaExecucao != null) {
        buffer.write(
          '\nVencimento: ${_dateFormatter.format(item.proximaExecucao!)}',
        );
      }
    }

    return buffer.toString();
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/home'),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            backgroundColor: _SacredPalette.marianBlue,
            foregroundColor: _SacredPalette.ivory,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 12),
        const SizedBox(
          width: 26,
          height: 26,
          child: CustomPaint(
            painter: _CrossMarkPainter(_SacredPalette.matteGold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Despesas',
            style: GoogleFonts.playfairDisplay(
              fontSize: 38,
              fontWeight: FontWeight.w600,
              color: _SacredPalette.graphite,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final total = FinanceiroServiceDespesas.listaConta.length;
    final pagas =
        FinanceiroServiceDespesas.listaConta.where((c) => c.pago).length;
    final pendentes = total - pagas;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTag(
          label: 'Pendentes: $pendentes',
          color: const Color(0xFF9A5E12),
          bg: const Color(0xFF9A5E12).withValues(alpha: 0.12),
        ),
        _buildTag(
          label: 'Pagas: $pagas',
          color: _SacredPalette.hopeGreen,
          bg: _SacredPalette.hopeGreen.withValues(alpha: 0.12),
        ),
        _buildTag(
          label: 'Total: $total',
          color: _SacredPalette.marianBlue,
          bg: _SacredPalette.marianBlue.withValues(alpha: 0.12),
        ),
      ],
    );
  }

  Widget _buildTag({
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.sourceSans3(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Future<void> _abrirDialogTiposConta() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: _SacredPalette.ivory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                'Tipos de conta',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: _SacredPalette.graphite,
                ),
              ),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: _formKeyTipoConta,
                      child: TextFormField(
                        controller: _novoTipoContaController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          labelText: 'Novo tipo',
                          hintText: 'Digite um tipo de conta...',
                          icon: Icons.credit_score_outlined,
                        ),
                        style: GoogleFonts.sourceSans3(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _SacredPalette.graphite,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Digite um tipo de conta.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contas salvas',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _SacredPalette.graphite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 260),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _SacredPalette.marianBlue.withValues(
                            alpha: 0.14,
                          ),
                        ),
                      ),
                      child:
                          _listaTipoConta.isEmpty
                              ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Nenhum tipo cadastrado ainda.',
                                    style: GoogleFonts.sourceSans3(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _SacredPalette.graphite.withValues(
                                        alpha: 0.70,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _listaTipoConta.length,
                                itemBuilder: (context, index) {
                                  final item = _listaTipoConta[index];
                                  return ListTile(
                                    leading: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _SacredPalette.matteGold
                                            .withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.credit_score,
                                        color: _SacredPalette.marianBlue,
                                      ),
                                    ),
                                    title: Text(
                                      item.tipoConta,
                                      style: GoogleFonts.sourceSans3(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _SacredPalette.graphite,
                                      ),
                                    ),
                                  );
                                },
                              ),
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
                FilledButton(
                  onPressed: () async {
                    final ok = await _validarESalvarTipoConta();
                    if (!ok) return;
                    if (!mounted) return;
                    setDialogState(() {});
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _SacredPalette.marianBlue,
                    foregroundColor: _SacredPalette.ivory,
                    textStyle: GoogleFonts.sourceSans3(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _abrirDialogNovaConta() async {
    _resetFormularioNovaConta();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: _SacredPalette.ivory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                'Lancar nova conta',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: _SacredPalette.graphite,
                ),
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKeyNovaConta,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue:
                              _tipoContaController.text.isNotEmpty
                                  ? _tipoContaController.text
                                  : null,
                          decoration: _inputDecoration(
                            labelText: 'Tipo de conta',
                            hintText: 'Selecione um tipo',
                            icon: Icons.category_outlined,
                          ),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _SacredPalette.graphite,
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          items:
                              _listaTipoConta
                                  .map(
                                    (conta) => DropdownMenuItem<String>(
                                      value: conta.tipoConta,
                                      child: Text(conta.tipoConta),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (newValue) {
                            setDialogState(() {
                              _tipoContaController.text = newValue ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Selecione um tipo de conta.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descricaoController,
                          decoration: _inputDecoration(
                            labelText: 'Descricao',
                            hintText: 'Digite uma descricao...',
                            icon: Icons.description_outlined,
                          ),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _SacredPalette.graphite,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Campo obrigatorio.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _observacoesController,
                          decoration: _inputDecoration(
                            labelText: 'Observacoes (Opcional)',
                            hintText: 'Digite uma observacao...',
                            icon: Icons.announcement_outlined,
                          ),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _SacredPalette.graphite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _valorController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            CurrencyInputFormatter(
                              leadingSymbol: 'R\$',
                              thousandSeparator: ThousandSeparator.Period,
                            ),
                          ],
                          decoration: _inputDecoration(
                            labelText: 'Valor',
                            hintText: 'R\$ 0,00',
                            icon: Icons.attach_money_rounded,
                          ),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _SacredPalette.graphite,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Campo obrigatorio.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile.adaptive(
                          value: _despesaRecorrente,
                          onChanged: (value) {
                            setDialogState(() {
                              _despesaRecorrente = value;
                              if (_frequenciaRecorrencia.isEmpty) {
                                _frequenciaRecorrencia =
                                    FrequenciaRecorrencia.mensal.value;
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Despesa recorrente',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _SacredPalette.graphite,
                            ),
                          ),
                          subtitle: Text(
                            'Ative para gerar automaticamente.',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _SacredPalette.graphite.withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ),
                          activeThumbColor: _SacredPalette.ivory,
                          activeTrackColor: _SacredPalette.marianBlue,
                        ),
                        if (_despesaRecorrente) ...[
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _frequenciaRecorrencia,
                            decoration: _inputDecoration(
                              labelText: 'Frequencia',
                              icon: Icons.autorenew_rounded,
                            ),
                            style: GoogleFonts.sourceSans3(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _SacredPalette.graphite,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (valor) {
                              if (valor == null) return;
                              setDialogState(() {
                                _frequenciaRecorrencia = valor;
                              });
                            },
                            items:
                                FinanceiroServiceDespesas
                                    .frequenciasRecorrenciaDisponiveis
                                    .map(
                                      (frequencia) => DropdownMenuItem<String>(
                                        value: frequencia.value,
                                        child: Text(frequencia.label),
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Primeiro vencimento: ${_dateFormatter.format(_proximaExecucaoRecorrente)}',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _SacredPalette.graphite,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await _selecionarDataProximaExecucao(
                                  setDialogState,
                                );
                              },
                              icon: const Icon(Icons.date_range_rounded),
                              label: const Text('Selecionar data'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _SacredPalette.marianBlue,
                                side: BorderSide(
                                  color: _SacredPalette.marianBlue.withValues(
                                    alpha: 0.45,
                                  ),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    final sucesso = await _validarESalvarNovaConta();
                    if (sucesso && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _SacredPalette.marianBlue,
                    foregroundColor: _SacredPalette.ivory,
                    textStyle: GoogleFonts.sourceSans3(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cadastrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _abrirDialogContasLancadas() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final contas = [...FinanceiroServiceDespesas.listaConta]
              ..sort((a, b) {
                final dataA =
                    a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                final dataB =
                    b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                return dataB.compareTo(dataA);
              });

            return AlertDialog(
              backgroundColor: _SacredPalette.ivory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                'Contas lancadas',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: _SacredPalette.graphite,
                ),
              ),
              content: SizedBox(
                width: 660,
                height: 500,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _SacredPalette.marianBlue.withValues(alpha: 0.14),
                    ),
                  ),
                  child:
                      contas.isEmpty
                          ? Center(
                            child: Text(
                              'Nenhuma conta lancada ainda.',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _SacredPalette.graphite.withValues(
                                  alpha: 0.70,
                                ),
                              ),
                            ),
                          )
                          : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: contas.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = contas[index];
                              return _buildContaTile(
                                conta: item,
                                onPagoConfirmado: () => setDialogState(() {}),
                              );
                            },
                          ),
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
      },
    );
  }

  Future<void> _confirmarPagamentoDialog({
    required ContaCad conta,
    required VoidCallback onPagoConfirmado,
  }) async {
    final confirmar =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: _SacredPalette.ivory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Confirmar pagamento',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: _SacredPalette.graphite,
                ),
              ),
              content: Text(
                'Deseja confirmar o pagamento desta conta?',
                style: GoogleFonts.sourceSans3(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _SacredPalette.graphite,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: _SacredPalette.marianBlue,
                    textStyle: GoogleFonts.sourceSans3(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Nao'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: _SacredPalette.marianBlue,
                    foregroundColor: _SacredPalette.ivory,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: GoogleFonts.sourceSans3(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Sim'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmar) return;

    final sucesso = await _marcarComoPago(conta);
    if (sucesso) {
      onPagoConfirmado();
    }
  }

  Widget _buildContaTile({
    required ContaCad conta,
    required VoidCallback onPagoConfirmado,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _SacredPalette.ivory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _SacredPalette.marianBlue.withValues(alpha: 0.14),
          width: 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _SacredPalette.matteGold.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            conta.recorrente ? Icons.autorenew_rounded : Icons.wallet_outlined,
            color: _SacredPalette.marianBlue,
          ),
        ),
        title: Text(
          'Tipo: ${conta.tipoConta}',
          style: GoogleFonts.sourceSans3(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _SacredPalette.graphite,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _montarDescricaoConta(conta),
            style: GoogleFonts.sourceSans3(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: _SacredPalette.graphite.withValues(alpha: 0.76),
            ),
          ),
        ),
        trailing:
            conta.pago
                ? const Icon(
                  Icons.check_box_rounded,
                  color: _SacredPalette.hopeGreen,
                )
                : IconButton(
                  icon: const Icon(
                    Icons.check_box_outline_blank_rounded,
                    color: Color(0xFFB5473A),
                  ),
                  tooltip: 'Confirmar pagamento',
                  onPressed: () {
                    _confirmarPagamentoDialog(
                      conta: conta,
                      onPagoConfirmado: onPagoConfirmado,
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _abrirDialogTiposConta,
        style: ElevatedButton.styleFrom(
          elevation: 2.5,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          backgroundColor: _SacredPalette.marianBlue,
          foregroundColor: _SacredPalette.ivory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: const Icon(Icons.credit_score_rounded),
        label: const Text('Tipos de conta'),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _abrirDialogNovaConta,
        style: ElevatedButton.styleFrom(
          elevation: 2.5,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          backgroundColor: _SacredPalette.marianBlue,
          foregroundColor: _SacredPalette.ivory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: const Icon(Icons.post_add_rounded),
        label: const Text('Lancar nova conta'),
      ),
    );
  }

  Widget _buildTertiaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _abrirDialogContasLancadas,
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
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: const Icon(Icons.visibility_rounded),
        label: const Text('Contas lancadas'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/sbento.png', fit: BoxFit.cover),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _showContent ? 1 : 0,
                  curve: Curves.easeOut,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 220),
                    offset: _showContent ? Offset.zero : const Offset(0, 0.05),
                    curve: Curves.easeOut,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _SacredPalette.ivory.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(30),
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
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 10),
                            Text(
                              'Gerencie tipos, lance contas e confirme pagamentos.',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: _SacredPalette.graphite.withValues(
                                  alpha: 0.80,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _buildSummary(),
                            const SizedBox(height: 20),
                            if (_loading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                child: Center(
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.8,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _SacredPalette.marianBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else ...[
                              _buildPrimaryButton(),
                              const SizedBox(height: 10),
                              _buildSecondaryButton(),
                              const SizedBox(height: 10),
                              _buildTertiaryButton(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
