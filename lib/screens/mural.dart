import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:decimus/models/models_mural.dart';
import 'package:decimus/services/services_mural.dart';
import 'package:decimus/services/services_mural_upload.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class MuralScreen extends StatelessWidget {
  const MuralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Nuestra-Senora-de-Lujan.jpg',
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
          const SafeArea(child: BodyMural()),
        ],
      ),
    );
  }
}

class _SacredPalette {
  static const Color marianBlue = Color(0xFF1F3A5F);
  static const Color ivory = Color(0xFFF7F4EE);
  static const Color matteGold = Color(0xFFC8A96B);
  static const Color graphite = Color(0xFF2B2B2B);
  static const Color hopeGreen = Color(0xFF4F7A5A);
}

class BodyMural extends StatefulWidget {
  const BodyMural({super.key});

  @override
  State<BodyMural> createState() => _BodyMuralState();
}

class _BodyMuralState extends State<BodyMural> {
  bool _showContent = false;

  Color _getCorPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'missa':
        return _SacredPalette.marianBlue;
      case 'aviso':
        return _SacredPalette.matteGold;
      case 'evento':
        return _SacredPalette.hopeGreen;
      case 'culto':
        return const Color(0xFF9B5973);
      default:
        return _SacredPalette.graphite;
    }
  }

  IconData _getIconePorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'missa':
        return Icons.church_outlined;
      case 'aviso':
        return Icons.notification_important_outlined;
      case 'evento':
        return Icons.event_outlined;
      case 'culto':
        return Icons.groups_outlined;
      default:
        return Icons.info_outlined;
    }
  }

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = data.difference(agora).inDays;

    if (diferenca == 0) {
      return 'Hoje às ${DateFormat('HH:mm').format(data)}';
    } else if (diferenca == 1) {
      return 'Amanhã às ${DateFormat('HH:mm').format(data)}';
    } else if (diferenca > 0 && diferenca <= 7) {
      return '${DateFormat('EEEE').format(data)} às ${DateFormat('HH:mm').format(data)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(data);
    }
  }

  void _abrirFormularioMural({MuralItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FormularioMuralFiel(item: item),
    );
  }

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
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Column(
      children: [
        // Header com botão de voltar (só aparece se logado)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botão de voltar (apenas se autenticado)
              if (isLoggedIn)
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
                )
              else
                const SizedBox(width: 48), // Espaço para manter alinhamento
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mural da',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: _SacredPalette.ivory,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'Paróquia',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: _SacredPalette.matteGold,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              // FAB (apenas se autenticado)
              if (isLoggedIn)
                FloatingActionButton(
                  onPressed: () => _abrirFormularioMural(),
                  backgroundColor: _SacredPalette.matteGold,
                  elevation: 4,
                  child: const Icon(
                    Icons.add,
                    color: _SacredPalette.graphite,
                    size: 28,
                  ),
                )
              else
                const SizedBox(width: 48), // Espaço para manter alinhamento
            ],
          ),
        ),
        // Content
        Expanded(
          child: AnimatedOpacity(
            opacity: _showContent ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            child: AnimatedSlide(
              offset: _showContent ? Offset.zero : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: StreamBuilder<List<MuralItem>>(
                stream: MuralService.obterMuralItemsPublicos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _SacredPalette.matteGold,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: _SacredPalette.ivory.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Erro ao carregar mural',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.sourceSans3(
                                fontSize: 14,
                                color: _SacredPalette.ivory.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 64,
                            color: _SacredPalette.ivory.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum aviso no momento',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 16,
                              color: _SacredPalette.ivory.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final corTipo = _getCorPorTipo(item.tipo);
                      final iconeTipo = _getIconePorTipo(item.tipo);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header com cor
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: corTipo,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    iconeTipo,
                                    color: _SacredPalette.ivory,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.tipo.toUpperCase(),
                                          style: GoogleFonts.sourceSans3(
                                            color: _SacredPalette.ivory,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatarData(item.data),
                                          style: GoogleFonts.sourceSans3(
                                            color: _SacredPalette.ivory
                                                .withValues(alpha: 0.8),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Imagem (se houver)
                            if (item.imagemUrl != null &&
                                item.imagemUrl!.isNotEmpty)
                              Container(
                                width: double.infinity,
                                height: 180,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                ),
                                child: Image.network(
                                  item.imagemUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              _SacredPalette.matteGold,
                                            ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported_outlined,
                                            color: Colors.grey[400],
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Erro ao carregar imagem',
                                            style: GoogleFonts.sourceSans3(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),

                            // Conteúdo
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.titulo,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: _SacredPalette.graphite,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.descricao,
                                    style: GoogleFonts.sourceSans3(
                                      fontSize: 14,
                                      color: _SacredPalette.graphite.withValues(
                                        alpha: 0.8,
                                      ),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FormularioMuralFiel extends StatefulWidget {
  final MuralItem? item;

  const FormularioMuralFiel({super.key, this.item});

  @override
  State<FormularioMuralFiel> createState() => _FormularioMuralFielState();
}

class _FormularioMuralFielState extends State<FormularioMuralFiel> {
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _imagemUrlController;
  late String _tipoSelecionado;
  late DateTime _dataSelecionada;
  bool _isLoading = false;
  File? _imagemSelecionada; // Para mobile/desktop
  Uint8List? _imagemBytesWeb; // Para web

  final List<String> _tipos = ['aviso', 'missa', 'evento', 'culto'];

  void _debugLog(String message) {
    assert(() {
      debugPrint('[FormularioMuralFiel] $message');
      return true;
    }());
  }

  void _debugError(String scope, Object error, StackTrace stackTrace) {
    assert(() {
      debugPrint('[FormularioMuralFiel][$scope] $error');
      debugPrint('$stackTrace');
      return true;
    }());
  }

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.item?.titulo ?? '');
    _descricaoController = TextEditingController(
      text: widget.item?.descricao ?? '',
    );
    _imagemUrlController = TextEditingController(
      text: widget.item?.imagemUrl ?? '',
    );
    _tipoSelecionado = widget.item?.tipo ?? 'aviso';
    _dataSelecionada = widget.item?.data ?? DateTime.now();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _imagemUrlController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (dataSelecionada != null && mounted) {
      final horaSelecionada = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dataSelecionada),
      );

      if (horaSelecionada != null) {
        setState(() {
          _dataSelecionada = DateTime(
            dataSelecionada.year,
            dataSelecionada.month,
            dataSelecionada.day,
            horaSelecionada.hour,
            horaSelecionada.minute,
          );
        });
      }
    }
  }

  /// Seleciona um arquivo de imagem
  Future<void> _selecionarImagem() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (resultado != null && resultado.files.isNotEmpty) {
        final arquivo = resultado.files.first;

        setState(() {
          if (kIsWeb) {
            // Web: usar bytes
            _imagemBytesWeb = arquivo.bytes;
            _imagemSelecionada = null;
          } else {
            // Mobile/Desktop: usar path
            _imagemSelecionada = File(arquivo.path!);
            _imagemBytesWeb = null;
          }
          // Limpar URL se tinha uma antes
          _imagemUrlController.clear();
        });
      }
    } catch (e, s) {
      _debugError('_selecionarImagem', e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  Future<void> _salvar() async {
    _debugLog('Iniciando salvamento');

    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Se uma imagem local foi selecionada, fazer upload
      String? imagemUrl =
          _imagemUrlController.text.isEmpty ? null : _imagemUrlController.text;

      // Upload de arquivo (mobile/desktop)
      if (_imagemSelecionada != null) {
        _debugLog('Upload mobile detectado: ${_imagemSelecionada!.path}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fazendo upload da imagem...')),
        );
        imagemUrl = await MuralUploadService.uploadImagemMural(
          _imagemSelecionada!,
        );
        _debugLog('Upload mobile concluido');
      }
      // Upload de bytes (web)
      else if (_imagemBytesWeb != null) {
        _debugLog('Upload web detectado: ${_imagemBytesWeb!.length} bytes');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fazendo upload da imagem...')),
        );
        imagemUrl = await MuralUploadService.uploadImagemMuralBytes(
          _imagemBytesWeb!,
        );
        _debugLog('Upload web concluido');
      }

      _debugLog('Preparando para salvar no Firestore');
      final muralItem = MuralItem(
        id: widget.item?.id ?? '',
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        tipo: _tipoSelecionado,
        data: _dataSelecionada,
        imagemUrl: imagemUrl,
        publicado:
            true, // Fiéis sempre publicam como rascunho (falso) ou publicado
        criadoEm: widget.item?.criadoEm ?? DateTime.now(),
      );

      if (widget.item != null) {
        // Editar
        _debugLog('Editando item');
        await MuralService.atualizarMuralItem(widget.item!.id, muralItem);
        _debugLog('Item editado');
      } else {
        // Criar novo
        _debugLog('Criando novo item');
        await MuralService.criarMuralItem(muralItem);
        _debugLog('Item criado');
      }

      if (mounted) {
        _debugLog('Fechando modal');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.item != null ? 'Item atualizado' : 'Item criado',
            ),
          ),
        );
      }
    } catch (e, s) {
      _debugError('_salvar', e, s);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) {
        _debugLog('Finalizando salvamento');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: padding + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.item != null ? 'Editar Aviso' : 'Novo Aviso',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tipo
            DropdownButtonFormField<String>(
              initialValue: _tipoSelecionado,
              decoration: InputDecoration(
                labelText: 'Tipo',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items:
                  _tipos
                      .map(
                        (tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo.toUpperCase()),
                        ),
                      )
                      .toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => _tipoSelecionado = valor);
                }
              },
            ),
            const SizedBox(height: 12),

            // Título
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título *',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Descrição
            TextField(
              controller: _descricaoController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descrição *',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Data e Hora
            InkWell(
              onTap: _selecionarData,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data e Hora *',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(_dataSelecionada),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Seção de Imagem
            Text(
              'Imagem (opcional)',
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _SacredPalette.graphite,
              ),
            ),
            const SizedBox(height: 8),

            // Preview da imagem selecionada ou URL existente
            if (_imagemSelecionada != null)
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _imagemSelecionada!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed:
                            () => setState(() {
                              _imagemSelecionada = null;
                            }),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_imagemBytesWeb != null)
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _imagemBytesWeb!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed:
                            () => setState(() {
                              _imagemBytesWeb = null;
                            }),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_imagemUrlController.text.isNotEmpty)
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imagemUrlController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // Botão para selecionar arquivo ou input de URL
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selecionarImagem,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Selecionar Imagem'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _SacredPalette.marianBlue,
                      foregroundColor: _SacredPalette.ivory,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Ou usar URL
            TextField(
              controller: _imagemUrlController,
              onChanged: (_) => setState(() {}),
              enabled: _imagemSelecionada == null && _imagemBytesWeb == null,
              decoration: InputDecoration(
                labelText: 'Ou cole uma URL da imagem',
                prefixIcon: const Icon(Icons.link),
                hintText: 'https://exemplo.com/imagem.jpg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8A96B),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(
                          widget.item != null ? 'Atualizar' : 'Criar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
