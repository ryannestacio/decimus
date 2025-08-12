import 'package:flutter/material.dart';
import 'package:decimus/services/services_devedores.dart';
import 'package:decimus/models/models_devedores.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:go_router/go_router.dart';

class DevedoresScreen extends StatelessWidget {
  const DevedoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            /* Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);*/
            context.go('/home');
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Devedores',
          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 8,
        shadowColor: Colors.indigo,
      ),
      body: BodyDevedores(),
    );
  }
}

class BodyDevedores extends StatefulWidget {
  const BodyDevedores({super.key});

  @override
  State<BodyDevedores> createState() => _BodyDevedoresState();
}

Widget _espacador([double altura = 20]) => SizedBox(height: altura);

class _BodyDevedoresState extends State<BodyDevedores> {
  final TextEditingController _nomeDevedor = TextEditingController();
  final TextEditingController _descricaoDevedor = TextEditingController();
  final TextEditingController _enderecoDevedor = TextEditingController();

  final TextEditingController _valDevedor = TextEditingController();
  DateTime? _dataDeVencimento;
  final _formKey = GlobalKey<FormState>();
  List<Devedor> get listaDevedor => FinanceiroServiceDevedores.listDevedor;

  // Filtro
  String _filtroAtual = 'todos';
  List<Devedor> get listaFiltrada {
    switch (_filtroAtual) {
      case 'todos':
        return listaDevedor;
      case 'comDebito':
        return listaDevedor.where((devedor) => devedor.valor > 0).toList();
      default:
        return listaDevedor;
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarDevedores();
  }

  Future<void> _carregarDevedores() async {
    print('_carregarDevedores: Iniciando...');
    await FinanceiroServiceDevedores.carregarDevedores();
    print('_carregarDevedores: Dados carregados, atualizando tela...');
    setState(() {});
    print('_carregarDevedores: Tela atualizada');
  }

  void marcarComoPago(
    int index,
    void Function(void Function()) setStateDialog,
  ) async {
    final item = listaFiltrada[index];

    await FinanceiroServiceDevedores.marcarComoPago(item.id!);

    // Recarrega os dados para garantir sincronização
    await _carregarDevedores();

    setState(() {}); // atualiza tela principal
    setStateDialog(() {}); // atualiza diálogo
  }

  void _mostrarDialogoPagamentoParcial(
    BuildContext context,
    int index,
    void Function(void Function()) setStateDialog,
  ) {
    final TextEditingController valorPagoController = TextEditingController();
    final formKeyPagamento = GlobalKey<FormState>();
    final item = listaFiltrada[index];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Pagamento Parcial',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: formKeyPagamento,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Devedor: ${item.nome}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Valor total: R\$ ${item.valor.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: valorPagoController,
                    decoration: InputDecoration(
                      labelText: 'Valor a pagar',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      CurrencyInputFormatter(
                        leadingSymbol: 'R\$',
                        thousandSeparator: ThousandSeparator.Period,
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite o valor a pagar';
                      }
                      final valorLimpo = toNumericString(
                        value,
                        allowPeriod: false,
                      );
                      final valorDouble = double.parse(valorLimpo) / 100;
                      if (valorDouble <= 0) {
                        return 'O valor deve ser maior que zero';
                      }
                      if (valorDouble > item.valor) {
                        return 'O valor não pode ser maior que o débito';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKeyPagamento.currentState!.validate()) {
                    try {
                      final valorLimpo = toNumericString(
                        valorPagoController.text,
                        allowPeriod: false,
                      );
                      final valorDouble = double.parse(valorLimpo) / 100;

                      // Teste simples primeiro
                      print('Testando pagamento parcial...');
                      print('ID: ${listaDevedor[index].id}');
                      print('Valor: $valorDouble');

                      await FinanceiroServiceDevedores.registrarPagamentoParcial(
                        item.id!,
                        valorDouble,
                      );

                      print('Pagamento processado, fechando diálogo...');

                      print('Recarregando dados...');
                      // Força recarregamento dos dados
                      await _carregarDevedores();

                      print('Atualizando tela principal...');
                      // Atualiza a tela principal
                      setState(() {});

                      print('Atualizando diálogo...');
                      // Atualiza o diálogo também
                      setStateDialog(() {});

                      // Fecha o diálogo
                      Navigator.pop(context);

                      // Mostra mensagem de sucesso (após fechar o diálogo)
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pagamento parcial registrado com sucesso!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      // Verifica se o context ainda é válido antes de usar
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao processar pagamento: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text('Confirmar'),
              ),
            ],
          ),
    );
  }

  void validator() async {
    final valorLimpo = toNumericString(_valDevedor.text, allowPeriod: false);

    final valorDouble = double.parse(valorLimpo) / 100;

    if (_dataDeVencimento == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor, selecione uma data de vencimento.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_formKey.currentState!.validate()) {
      final addConta = Devedor(
        nome: _nomeDevedor.text,
        descricao: _descricaoDevedor.text,
        endereco: _enderecoDevedor.text,
        dataVencimento: _dataDeVencimento ?? DateTime.now(),
        valor: valorDouble,
      );

      await FinanceiroServiceDevedores.salvarDevedor(addConta);
      await _carregarDevedores(); // recarrega e dá setState

      setState(() {
        _nomeDevedor.clear();
        _valDevedor.clear();
        _dataDeVencimento = null;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Devedor salvo com sucesso, verifique em devedores.'),
          ),
        );
      }
      Navigator.pop(context);
    }
  }

  Widget _dialogCadastro() {
    return AlertDialog(
      backgroundColor: Colors.yellow,
      title: Text(
        'Novo devedor',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        height: 380,
        width: 300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nomeDevedor,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.supervised_user_circle_outlined,
                    color: Colors.black,
                  ),
                  label: Text('Nome', style: TextStyle(color: Colors.black)),
                  hintText: 'Digite o nome do devedor...',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome do devedor';
                  }
                  return null;
                },
              ),
              _espacador(10),
              TextFormField(
                controller: _descricaoDevedor,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.clear_all_sharp, color: Colors.black),
                  label: Text(
                    'Descrição',
                    style: TextStyle(color: Colors.black),
                  ),
                  hintText: 'Digite a descrição...',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome do devedor';
                  }
                  return null;
                },
              ),
              _espacador(10),
              TextFormField(
                controller: _enderecoDevedor,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.maps_home_work_outlined,
                    color: Colors.black,
                  ),
                  label: Text(
                    'Endereço',
                    style: TextStyle(color: Colors.black),
                  ),
                  hintText: 'Digite o endereço do devedor...',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome do devedor';
                  }
                  return null;
                },
              ),
              _espacador(10),
              TextFormField(
                controller: _valDevedor,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o valor a pagar';
                  }

                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.attach_money, color: Colors.black),
                  label: Text('Valor', style: TextStyle(color: Colors.black)),
                  hintText: 'Digite o valor a pagar...',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(),
                ),

                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyInputFormatter(
                    leadingSymbol: 'R\$',
                    thousandSeparator: ThousandSeparator.Period,
                  ),
                ],
              ),
              _espacador(10),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dataDeVencimento ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365 * 10)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _dataDeVencimento = picked;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        _dataDeVencimento != null
                            ? '${_dataDeVencimento!.day.toString().padLeft(2, '0')}/${_dataDeVencimento!.month.toString().padLeft(2, '0')}/${_dataDeVencimento!.year}'
                            : 'Selecione a data de vencimento',
                        style: TextStyle(
                          color:
                              _dataDeVencimento != null
                                  ? Colors.black
                                  : Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () {
            validator();
          },
          child: Text(
            'Confirmar',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _dialogVerificacao() {
    return StatefulBuilder(
      builder:
          (context, setStateDialog) => AlertDialog(
            title: Column(
              children: [
                Text(
                  'Devedores',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${listaFiltrada.length} de ${listaDevedor.length}',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.yellow,

            content: SizedBox(
              height: 500,
              width: 600,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child:
                        listaFiltrada.isEmpty
                            ? Center(
                              child: Text(
                                _filtroAtual == 'comDebito'
                                    ? 'Nenhum devedor com débito pendente.'
                                    : 'Nenhum devedor cadastrado.',
                              ),
                            )
                            : SizedBox(
                              height: 400,
                              width: 300,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListView.builder(
                                  itemCount: listaFiltrada.length,
                                  itemBuilder: (context, index) {
                                    final item = listaFiltrada[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 1.0,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .supervised_user_circle_outlined,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      item.nome,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  listaDevedor[index].pago
                                                      ? Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                        size: 28,
                                                      )
                                                      : Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.payment,
                                                              color:
                                                                  Colors.blue,
                                                              size: 24,
                                                            ),
                                                            onPressed: () {
                                                              _mostrarDialogoPagamentoParcial(
                                                                context,
                                                                index,
                                                                setStateDialog,
                                                              );
                                                            },
                                                            tooltip:
                                                                'Pagamento parcial',
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons
                                                                  .check_circle_outline,
                                                              color: Colors.red,
                                                              size: 24,
                                                            ),
                                                            onPressed: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => AlertDialog(
                                                                      title: Text(
                                                                        'Confirmar pagamento total',
                                                                      ),
                                                                      content: Text(
                                                                        'Deseja confirmar o pagamento total?',
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            Navigator.pop(
                                                                              context,
                                                                            );
                                                                          },
                                                                          child: Text(
                                                                            'Não',
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            marcarComoPago(
                                                                              index,
                                                                              setStateDialog,
                                                                            );
                                                                            Navigator.pop(
                                                                              context,
                                                                            );
                                                                          },
                                                                          child: Text(
                                                                            'Sim',
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                              );
                                                            },
                                                            tooltip:
                                                                'Pagamento total',
                                                          ),
                                                        ],
                                                      ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              if (item.descricao.isNotEmpty)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 4,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.description,
                                                        color: Colors.white70,
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          item.descricao,
                                                          style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (item.endereco.isNotEmpty)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 4,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        color: Colors.white70,
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          item.endereco,
                                                          style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.attach_money,
                                                    color:
                                                        item.valor > 0
                                                            ? Colors.orange
                                                            : Colors.green,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 6),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'R\$ ${item.valor.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          color:
                                                              item.valor > 0
                                                                  ? Colors
                                                                      .orange
                                                                  : Colors
                                                                      .green,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      if (item.valor > 0)
                                                        Text(
                                                          'Valor restante',
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: 12,
                                                            fontStyle:
                                                                FontStyle
                                                                    .italic,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  Icon(
                                                    Icons.calendar_today,
                                                    color: Colors.orange,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    '${item.dataVencimento.day.toString().padLeft(2, '0')}/${item.dataVencimento.month.toString().padLeft(2, '0')}/${item.dataVencimento.year}',
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Fechar',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/miguel.png'),
              opacity: 0.3,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: BoxConstraints(maxWidth: 420, maxHeight: 250),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Filtro
                  Container(
                    width: 350,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _filtroAtual,
                      decoration: InputDecoration(
                        labelText: 'Filtrar por:',
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.filter_list, color: Colors.blue),
                      ),
                      dropdownColor: Colors.white,
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                      items: [
                        DropdownMenuItem(
                          value: 'todos',
                          child: Text('Todos os devedores'),
                        ),
                        DropdownMenuItem(
                          value: 'comDebito',
                          child: Text('Devedor com débito'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _filtroAtual = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  _espacador(15),
                  SizedBox(
                    height: 60,
                    width: 350,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          32,
                          117,
                          185,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.white, width: 2),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _dialogCadastro(),
                        );
                      },
                      child: Text('Cadastrar devedor'),
                    ),
                  ),
                  _espacador(10),
                  SizedBox(
                    height: 60,
                    width: 350,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          32,
                          117,
                          185,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.white, width: 2),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _dialogVerificacao(),
                        );
                      },
                      child: Text('Verificar Devedores'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
