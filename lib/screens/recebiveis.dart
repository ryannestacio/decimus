import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RecebiveisScreen extends StatelessWidget {
  const RecebiveisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: BodyRecebiveis());
  }
}

class _SacredPalette {
  static const Color marianBlue = Color(0xFF1F3A5F);
  static const Color ivory = Color(0xFFF7F4EE);
  static const Color matteGold = Color(0xFFC8A96B);
  static const Color graphite = Color(0xFF2B2B2B);
  static const Color hopeGreen = Color(0xFF4F7A5A);
}

class BodyRecebiveis extends StatefulWidget {
  const BodyRecebiveis({super.key});

  @override
  State<BodyRecebiveis> createState() => _BodyRecebiveisState();
}

class _BodyRecebiveisState extends State<BodyRecebiveis> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  DateTime? _selectedDate;
  bool _saving = false;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _showContent = true;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _dateController.dispose();
    super.dispose();
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

  void _debugError(String scope, Object error, StackTrace stackTrace) {
    assert(() {
      debugPrint('[BodyRecebiveis][$scope] $error');
      debugPrint('$stackTrace');
      return true;
    }());
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
            textTheme: TextTheme(
              titleLarge: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: _SacredPalette.graphite,
              ),
              bodyMedium: GoogleFonts.sourceSans3(
                fontSize: 16,
                color: _SacredPalette.graphite,
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
      _dateController.text = _dateFormatter.format(pickedDate);
    });
  }

  Future<void> _criarRecebimento() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showFeedback(
        'Revise os campos destacados antes de salvar.',
        isError: true,
      );
      return;
    }

    if (_selectedDate == null) {
      _showFeedback('Selecione uma data de recebimento.', isError: true);
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final valorLimpo = toNumericString(
        _valueController.text,
        allowPeriod: false,
      );

      if (valorLimpo.isEmpty) {
        _showFeedback(
          'Informe um valor valido para o recebimento.',
          isError: true,
        );
        return;
      }

      final valorDouble = double.parse(valorLimpo) / 100;
      final descricaoOuTipo = _descriptionController.text.trim();

      final novoRecebimento = {
        'nome': _nameController.text.trim(),
        'tipo': descricaoOuTipo,
        'descricao': descricaoOuTipo,
        'valor': valorDouble,
        'data': Timestamp.fromDate(_selectedDate!),
        'pago': true,
      };

      await FirebaseFirestore.instance
          .collection('recebiveis')
          .add(novoRecebimento);

      if (!mounted) return;
      setState(() {
        _nameController.clear();
        _descriptionController.clear();
        _valueController.clear();
        _dateController.clear();
        _selectedDate = null;
      });

      _showFeedback('Recebimento salvo com sucesso.');
    } catch (e, s) {
      _debugError('_criarRecebimento', e, s);
      _showFeedback(
        'Nao foi possivel salvar agora. Tente novamente.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _showRecebiveisDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _SacredPalette.ivory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          title: Row(
            children: [
              const Icon(
                Icons.history_rounded,
                color: _SacredPalette.marianBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Historico de recebiveis',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: _SacredPalette.graphite,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 540,
            height: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _SacredPalette.marianBlue.withValues(alpha: 0.15),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('recebiveis')
                        .orderBy('data', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _SacredPalette.marianBlue,
                          ),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar os recebiveis.',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? <QueryDocumentSnapshot>[];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhum recebivel cadastrado ate agora.',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _SacredPalette.graphite.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final dataMap = doc.data() as Map<String, dynamic>;

                      final nome = (dataMap['nome'] ?? 'Sem nome').toString();
                      final tipo =
                          (dataMap['tipo'] ??
                                  dataMap['descricao'] ??
                                  'Nao informado')
                              .toString();
                      final valorRaw = dataMap['valor'];
                      final valor =
                          valorRaw is num
                              ? valorRaw.toDouble()
                              : double.tryParse(valorRaw?.toString() ?? '') ??
                                  0.0;

                      final dataField = dataMap['data'];
                      DateTime? dataRecebimento;
                      if (dataField is Timestamp) {
                        dataRecebimento = dataField.toDate();
                      }

                      final dateLabel =
                          dataRecebimento != null
                              ? _dateFormatter.format(dataRecebimento)
                              : 'Data nao informada';

                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: _SacredPalette.ivory,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _SacredPalette.marianBlue.withValues(
                              alpha: 0.14,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _SacredPalette.matteGold.withValues(
                                alpha: 0.18,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.attach_money_rounded,
                              color: _SacredPalette.marianBlue,
                            ),
                          ),
                          title: Text(
                            nome,
                            style: GoogleFonts.sourceSans3(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _SacredPalette.graphite,
                            ),
                          ),
                          subtitle: Text(
                            'Entrada: $dateLabel\nDescricao: $tipo',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _SacredPalette.graphite.withValues(
                                alpha: 0.76,
                              ),
                              height: 1.25,
                            ),
                          ),
                          trailing: Text(
                            _currencyFormatter.format(valor),
                            style: GoogleFonts.sourceSans3(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _SacredPalette.marianBlue,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
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
            'Recebiveis',
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

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _saving ? null : _criarRecebimento,
        style: ElevatedButton.styleFrom(
          elevation: 2.5,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          backgroundColor: _SacredPalette.marianBlue,
          foregroundColor: _SacredPalette.ivory,
          disabledBackgroundColor: _SacredPalette.marianBlue.withValues(
            alpha: 0.78,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child:
              _saving
                  ? Row(
                    key: const ValueKey('saving'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _SacredPalette.ivory,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Salvando...',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                  : Text(
                    'Receber',
                    key: const ValueKey('idle'),
                    style: GoogleFonts.sourceSans3(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _showRecebiveisDialog,
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
        label: const Text('Verificar recebiveis'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/saofrancisco.png',
            fit: BoxFit.cover,
          ),
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
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 10),
                              Text(
                                'Registre entradas e acompanhe o historico financeiro.',
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: _SacredPalette.graphite.withValues(
                                    alpha: 0.80,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _SacredPalette.graphite,
                                ),
                                decoration: _inputDecoration(
                                  labelText: 'Nome do pagador',
                                  hintText: 'Digite o nome',
                                  icon: Icons.person_outline_rounded,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe o nome do pagador.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _descriptionController,
                                keyboardType: TextInputType.text,
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _SacredPalette.graphite,
                                ),
                                decoration: _inputDecoration(
                                  labelText: 'Descricao',
                                  hintText: 'Ex.: Dizimo, oferta, evento',
                                  icon: Icons.description_outlined,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe uma descricao.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _valueController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _SacredPalette.graphite,
                                ),
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
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe o valor recebido.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: _pickDate,
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _SacredPalette.graphite,
                                ),
                                decoration: _inputDecoration(
                                  labelText: 'Data de recebimento',
                                  hintText: 'Selecione uma data',
                                  icon: Icons.calendar_today_outlined,
                                  suffixIcon: IconButton(
                                    onPressed: _pickDate,
                                    icon: const Icon(
                                      Icons.edit_calendar_rounded,
                                      color: _SacredPalette.marianBlue,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Selecione a data do recebimento.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),
                              _buildPrimaryButton(),
                              const SizedBox(height: 10),
                              _buildSecondaryButton(),
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
