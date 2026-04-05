import 'package:decimus/models/models_devedores.dart';
import 'package:decimus/services/services_devedores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DevedoresScreen extends StatelessWidget {
  const DevedoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: BodyDevedores());
  }
}

class _SacredPalette {
  static const Color marianBlue = Color(0xFF1F3A5F);
  static const Color ivory = Color(0xFFF7F4EE);
  static const Color matteGold = Color(0xFFC8A96B);
  static const Color graphite = Color(0xFF2B2B2B);
  static const Color hopeGreen = Color(0xFF4F7A5A);
}

class BodyDevedores extends StatefulWidget {
  const BodyDevedores({super.key});

  @override
  State<BodyDevedores> createState() => _BodyDevedoresState();
}

class _BodyDevedoresState extends State<BodyDevedores> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();

  final GlobalKey<FormState> _cadastroFormKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  DateTime? _dataVencimento;
  String _filtroAtual = 'emAberto';
  bool _loading = true;
  bool _showContent = false;

  List<Devedor> get _devedores => FinanceiroServiceDevedores.listDevedor;

  List<Devedor> get _listaFiltrada {
    switch (_filtroAtual) {
      case 'emAberto':
        return _devedores.where((item) => !item.pago && item.valor > 0).toList()
          ..sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
      case 'pagos':
        return _devedores.where((item) => item.pago || item.valor <= 0).toList()
          ..sort((a, b) => b.dataVencimento.compareTo(a.dataVencimento));
      default:
        return _devedores;
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarDevedores();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _showContent = true;
      });
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _enderecoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _carregarDevedores() async {
    try {
      await FinanceiroServiceDevedores.carregarDevedores();
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

  Future<DateTime?> _pickDate(DateTime? initialDate) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
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

  Future<void> _abrirDialogCadastro() async {
    _nomeController.clear();
    _descricaoController.clear();
    _enderecoController.clear();
    _valorController.clear();
    _dataController.clear();
    _dataVencimento = null;

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
                'Novo devedor',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: _SacredPalette.graphite,
                ),
              ),
              content: SizedBox(
                width: 520,
                child: Form(
                  key: _cadastroFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          decoration: _inputDecoration(
                            labelText: 'Nome do devedor',
                            hintText: 'Digite o nome',
                            icon: Icons.person_outline_rounded,
                          ),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _SacredPalette.graphite,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome do devedor.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descricaoController,
                          decoration: _inputDecoration(
                            labelText: 'Descricao',
                            hintText: 'Ex.: Prestacao, servico, emprestimo',
                            icon: Icons.description_outlined,
                          ),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _SacredPalette.graphite,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe uma descricao.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _enderecoController,
                          decoration: _inputDecoration(
                            labelText: 'Endereco',
                            hintText: 'Rua, numero e bairro',
                            icon: Icons.location_on_outlined,
                          ),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _SacredPalette.graphite,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o endereco.';
                            }
                            return null;
                          },
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
                              return 'Informe o valor da divida.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dataController,
                          readOnly: true,
                          onTap: () async {
                            final selectedDate = await _pickDate(
                              _dataVencimento,
                            );
                            if (selectedDate == null) return;
                            setDialogState(() {
                              _dataVencimento = selectedDate;
                              _dataController.text = _dateFormat.format(
                                selectedDate,
                              );
                            });
                          },
                          decoration: _inputDecoration(
                            labelText: 'Data de vencimento',
                            hintText: 'Selecione a data',
                            icon: Icons.calendar_today_outlined,
                            suffixIcon: IconButton(
                              onPressed: () async {
                                final selectedDate = await _pickDate(
                                  _dataVencimento,
                                );
                                if (selectedDate == null) return;
                                setDialogState(() {
                                  _dataVencimento = selectedDate;
                                  _dataController.text = _dateFormat.format(
                                    selectedDate,
                                  );
                                });
                              },
                              icon: const Icon(
                                Icons.edit_calendar_rounded,
                                color: _SacredPalette.marianBlue,
                              ),
                            ),
                          ),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _SacredPalette.graphite,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Selecione a data de vencimento.';
                            }
                            return null;
                          },
                        ),
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
                    if (!_cadastroFormKey.currentState!.validate()) {
                      _showFeedback(
                        'Revise os campos destacados antes de salvar.',
                        isError: true,
                      );
                      return;
                    }

                    if (_dataVencimento == null) {
                      _showFeedback(
                        'Selecione a data de vencimento.',
                        isError: true,
                      );
                      return;
                    }

                    final valorLimpo = toNumericString(
                      _valorController.text,
                      allowPeriod: false,
                    );

                    if (valorLimpo.isEmpty) {
                      _showFeedback(
                        'Informe um valor valido para a divida.',
                        isError: true,
                      );
                      return;
                    }

                    final valorDouble =
                        (double.tryParse(valorLimpo) ?? 0) / 100;
                    if (valorDouble <= 0) {
                      _showFeedback(
                        'O valor deve ser maior que zero.',
                        isError: true,
                      );
                      return;
                    }

                    final navigator = Navigator.of(dialogContext);
                    final devedor = Devedor(
                      nome: _nomeController.text.trim(),
                      descricao: _descricaoController.text.trim(),
                      endereco: _enderecoController.text.trim(),
                      dataVencimento: _dataVencimento!,
                      valorOriginal: valorDouble,
                      valor: valorDouble,
                    );

                    try {
                      await FinanceiroServiceDevedores.salvarDevedor(devedor);
                      await _carregarDevedores();
                      if (navigator.mounted) {
                        navigator.pop();
                      }
                      _showFeedback('Devedor cadastrado com sucesso.');
                    } catch (_) {
                      _showFeedback(
                        'Nao foi possivel cadastrar o devedor agora.',
                        isError: true,
                      );
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
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _abrirDialogPagamentoParcial({
    required Devedor item,
    required VoidCallback refreshDialog,
  }) async {
    if (item.id == null) {
      _showFeedback(
        'Este devedor nao possui identificador valido.',
        isError: true,
      );
      return;
    }

    final TextEditingController valorPagoController = TextEditingController();
    final formKeyPagamento = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _SacredPalette.ivory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Pagamento parcial',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: _SacredPalette.graphite,
            ),
          ),
          content: SizedBox(
            width: 430,
            child: Form(
              key: formKeyPagamento,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Devedor: ${item.nome}',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _SacredPalette.graphite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Original: ${_currencyFormatter.format(item.valorOriginal)}',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _SacredPalette.graphite.withValues(alpha: 0.76),
                    ),
                  ),
                  Text(
                    'Restante: ${_currencyFormatter.format(item.valor)}',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _SacredPalette.marianBlue,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: valorPagoController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      CurrencyInputFormatter(
                        leadingSymbol: 'R\$',
                        thousandSeparator: ThousandSeparator.Period,
                      ),
                    ],
                    decoration: _inputDecoration(
                      labelText: 'Valor a pagar',
                      hintText: 'R\$ 0,00',
                      icon: Icons.payments_outlined,
                    ),
                    style: GoogleFonts.sourceSans3(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _SacredPalette.graphite,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o valor a pagar.';
                      }
                      final valorLimpo = toNumericString(
                        value,
                        allowPeriod: false,
                      );
                      final valorDouble =
                          (double.tryParse(valorLimpo) ?? 0) / 100;
                      if (valorDouble <= 0) {
                        return 'O valor deve ser maior que zero.';
                      }
                      if (valorDouble > item.valor) {
                        return 'O valor nao pode ser maior que a divida.';
                      }
                      return null;
                    },
                  ),
                ],
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
                if (!formKeyPagamento.currentState!.validate()) {
                  return;
                }

                final valorLimpo = toNumericString(
                  valorPagoController.text,
                  allowPeriod: false,
                );
                final valorDouble = (double.tryParse(valorLimpo) ?? 0) / 100;
                final navigator = Navigator.of(dialogContext);

                try {
                  await FinanceiroServiceDevedores.registrarPagamentoParcial(
                    item.id!,
                    valorDouble,
                  );
                  await _carregarDevedores();
                  if (navigator.mounted) {
                    navigator.pop();
                  }
                  refreshDialog();
                  _showFeedback('Pagamento parcial registrado com sucesso.');
                } catch (_) {
                  _showFeedback(
                    'Erro ao processar pagamento parcial.',
                    isError: true,
                  );
                }
              },
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
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    valorPagoController.dispose();
  }

  Future<void> _confirmarPagamentoTotal({
    required Devedor item,
    required VoidCallback refreshDialog,
  }) async {
    if (item.id == null) {
      _showFeedback(
        'Este devedor nao possui identificador valido.',
        isError: true,
      );
      return;
    }

    final bool confirmar =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: _SacredPalette.ivory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Confirmar pagamento total',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: _SacredPalette.graphite,
                ),
              ),
              content: Text(
                'Deseja quitar totalmente a divida de ${item.nome}?',
                style: GoogleFonts.sourceSans3(
                  fontSize: 16,
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

    try {
      await FinanceiroServiceDevedores.marcarComoPago(item.id!);
      await _carregarDevedores();
      refreshDialog();
      _showFeedback('Pagamento total confirmado com sucesso.');
    } catch (_) {
      _showFeedback('Erro ao confirmar pagamento total.', isError: true);
    }
  }

  Widget _buildDevedorTile({
    required Devedor item,
    required VoidCallback refreshDialog,
  }) {
    final vencimento = _dateFormat.format(item.dataVencimento);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _SacredPalette.ivory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _SacredPalette.marianBlue.withValues(alpha: 0.14),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _SacredPalette.matteGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.supervised_user_circle_outlined,
                    color: _SacredPalette.marianBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.nome,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _SacredPalette.graphite,
                    ),
                  ),
                ),
                if (item.pago || item.valor <= 0)
                  const Icon(
                    Icons.check_circle,
                    color: _SacredPalette.hopeGreen,
                    size: 26,
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Pagamento parcial',
                        onPressed: () {
                          _abrirDialogPagamentoParcial(
                            item: item,
                            refreshDialog: refreshDialog,
                          );
                        },
                        icon: const Icon(
                          Icons.payments_rounded,
                          color: _SacredPalette.marianBlue,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Pagamento total',
                        onPressed: () {
                          _confirmarPagamentoTotal(
                            item: item,
                            refreshDialog: refreshDialog,
                          );
                        },
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFFB5473A),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (item.descricao.isNotEmpty)
              Text(
                'Descricao: ${item.descricao}',
                style: GoogleFonts.sourceSans3(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _SacredPalette.graphite.withValues(alpha: 0.75),
                ),
              ),
            if (item.endereco.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Endereco: ${item.endereco}',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _SacredPalette.graphite.withValues(alpha: 0.75),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Original: ${_currencyFormatter.format(item.valorOriginal)}',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _SacredPalette.hopeGreen,
                        ),
                      ),
                      Text(
                        'Restante: ${_currencyFormatter.format(item.valor)}',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:
                              item.valor > 0
                                  ? const Color(0xFF9A5E12)
                                  : _SacredPalette.marianBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: _SacredPalette.marianBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vencimento,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _SacredPalette.marianBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirDialogVerificacao() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final lista = _listaFiltrada;

            return AlertDialog(
              backgroundColor: _SacredPalette.ivory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Devedores',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: _SacredPalette.graphite,
                    ),
                  ),
                  Text(
                    '${lista.length} de ${_devedores.length}',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _SacredPalette.graphite.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 640,
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
                      lista.isEmpty
                          ? Center(
                            child: Text(
                              _filtroAtual == 'emAberto'
                                  ? 'Nenhum devedor em aberto.'
                                  : 'Nenhum devedor pago.',
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
                            itemCount: lista.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = lista[index];
                              return _buildDevedorTile(
                                item: item,
                                refreshDialog: () => setDialogState(() {}),
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
            'Devedores',
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

  Widget _buildFilterField() {
    return DropdownButtonFormField<String>(
      initialValue: _filtroAtual,
      decoration: _inputDecoration(
        labelText: 'Filtrar por',
        icon: Icons.filter_list_rounded,
      ),
      style: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _SacredPalette.graphite,
      ),
      borderRadius: BorderRadius.circular(12),
      dropdownColor: Colors.white,
      items: const [
        DropdownMenuItem<String>(
          value: 'emAberto',
          child: Text('Devedores em aberto'),
        ),
        DropdownMenuItem<String>(
          value: 'pagos',
          child: Text('Devedores pagos'),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _filtroAtual = value;
        });
      },
    );
  }

  Widget _buildSummary() {
    final pendentes =
        _devedores.where((item) => !item.pago && item.valor > 0).length;
    final pagos =
        _devedores.where((item) => item.pago || item.valor <= 0).length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _SacredPalette.marianBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Em aberto: $pendentes',
            style: GoogleFonts.sourceSans3(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _SacredPalette.marianBlue,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _SacredPalette.hopeGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Pagos: $pagos',
            style: GoogleFonts.sourceSans3(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _SacredPalette.hopeGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _abrirDialogCadastro,
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
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Cadastrar devedor'),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _abrirDialogVerificacao,
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
        label: const Text('Verificar devedores'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/miguel.png', fit: BoxFit.cover),
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
                              'Cadastre devedores, filtre por status e registre pagamentos.',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: _SacredPalette.graphite.withValues(
                                  alpha: 0.80,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _buildFilterField(),
                            const SizedBox(height: 10),
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
