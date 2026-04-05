import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:decimus/models/models_mural.dart';
import 'package:decimus/services/services_mural.dart';
import 'package:intl/intl.dart';

class GestaoMuralScreen extends StatefulWidget {
  const GestaoMuralScreen({super.key});

  @override
  State<GestaoMuralScreen> createState() => _GestaoMuralScreenState();
}

class _GestaoMuralScreenState extends State<GestaoMuralScreen> {
  void _compartilharLinkMural() {
    final linkMural = 'decimus://mural';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Compartilhar Mural'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Link para os fiéis acessarem o mural:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          linkMural,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copiar',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: linkMural));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copiado!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'O fiél pode clicar neste link ou procurar pelo "Mural" no menu principal do app.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Mural'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F3A5F),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar Link',
            onPressed: _compartilharLinkMural,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioMural(context),
        backgroundColor: const Color(0xFFC8A96B),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<MuralItem>>(
        stream: MuralService.obterMuralItemsAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum item no mural',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _abrirFormularioMural(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8A96B),
                    ),
                    child: const Text('Criar Primeiro Item'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    item.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        item.tipo.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1F3A5F),
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(item.data),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão publicar/despublicar
                      IconButton(
                        icon: Icon(
                          item.publicado
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: item.publicado ? Colors.green : Colors.grey,
                        ),
                        tooltip: item.publicado ? 'Despublicar' : 'Publicar',
                        onPressed: () => _togglePublicar(item),
                      ),
                      // Botão editar
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar',
                        onPressed:
                            () => _abrirFormularioMural(context, item: item),
                      ),
                      // Botão deletar
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Deletar',
                        onPressed: () => _confirmarDelecao(item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _togglePublicar(MuralItem item) async {
    try {
      final atualizado = item.copyWith(publicado: !item.publicado);
      await MuralService.atualizarMuralItem(item.id, atualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              item.publicado ? 'Item despublicado' : 'Item publicado',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  Future<void> _confirmarDelecao(String id) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text('Deseja deletar este item do mural?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Deletar'),
              ),
            ],
          ),
    );

    if (confirmou == true) {
      try {
        await MuralService.deletarMuralItem(id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Item deletado')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro: $e')));
        }
      }
    }
  }

  void _abrirFormularioMural(BuildContext context, {MuralItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FormularioMural(item: item),
    );
  }
}

class FormularioMural extends StatefulWidget {
  final MuralItem? item;

  const FormularioMural({super.key, this.item});

  @override
  State<FormularioMural> createState() => _FormularioMuralState();
}

class _FormularioMuralState extends State<FormularioMural> {
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _imagemUrlController;
  late String _tipoSelecionado;
  late DateTime _dataSelecionada;
  bool _isLoading = false;

  final List<String> _tipos = ['aviso', 'missa', 'evento', 'culto'];

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

  Future<void> _salvar() async {
    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final muralItem = MuralItem(
        id: widget.item?.id ?? '',
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        tipo: _tipoSelecionado,
        data: _dataSelecionada,
        imagemUrl:
            _imagemUrlController.text.isEmpty
                ? null
                : _imagemUrlController.text,
        publicado: widget.item?.publicado ?? false,
        criadoEm: widget.item?.criadoEm ?? DateTime.now(),
      );

      if (widget.item != null) {
        // Editar
        await MuralService.atualizarMuralItem(widget.item!.id, muralItem);
      } else {
        // Criar novo
        await MuralService.criarMuralItem(muralItem);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.item != null ? 'Item atualizado' : 'Item criado',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) {
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
                  widget.item != null ? 'Editar Item' : 'Novo Item',
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
            const SizedBox(height: 12),

            // URL da Imagem (opcional)
            TextField(
              controller: _imagemUrlController,
              decoration: InputDecoration(
                labelText: 'URL da Imagem (opcional)',
                prefixIcon: const Icon(Icons.image_outlined),
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
