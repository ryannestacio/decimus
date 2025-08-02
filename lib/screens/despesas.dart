import 'package:decimus/services/services_despesas.dart';
import 'package:flutter/material.dart';
import 'package:decimus/models/models_despesas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';

class DespesasScreen extends StatelessWidget {
  const DespesasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Despesas',
          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 7,
      ),
      body: BodyDespesas(),
    );
  }
}

class BodyDespesas extends StatefulWidget {
  const BodyDespesas({super.key});

  @override
  State<BodyDespesas> createState() => _BodyDespesasState();
}

class _BodyDespesasState extends State<BodyDespesas> {
  final TextEditingController _novoTipoConta = TextEditingController();
  final TextEditingController _tipoConta = TextEditingController();
  final TextEditingController _descricao = TextEditingController();
  final TextEditingController _observacoes = TextEditingController();
  final TextEditingController _valor = TextEditingController();
  final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    carregarTiposDeConta();
    carregarDespesasDoFirestore();
  }

  final _formKeyTipoConta = GlobalKey<FormState>();
  final _formKeyNovaConta = GlobalKey<FormState>();
  List<Conta> _listaTipoConta = [];
  String? tipoSelecionado;

  void validacaoTipoConta() async {
    if (_formKeyTipoConta.currentState!.validate()) {
      final tipo = _novoTipoConta.text;

      try {
        await FirebaseFirestore.instance.collection('tipos_despesas').add({
          'tipoConta': tipo,
          'createdAt': Timestamp.now(),
        });

        _novoTipoConta.clear();
        await carregarTiposDeConta();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tipo de conta salvo no Firestore!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar no Firestore: $e')),
        );
      }
    }
  }

  void marcarComoPagoLocal(int index) {
    final antigo = FinanceiroServiceDespesas.listaConta[index];
    final atualizado = ContaCad(
      tipoConta: antigo.tipoConta,
      descricao: antigo.descricao,
      valor: antigo.valor,
      observacao: antigo.observacao,
      pago: true,
    );
    setState(() {
      FinanceiroServiceDespesas.listaConta[index] = atualizado;
    });
  }

  bool validacaoNovaConta() {
    final valorLimpo = toNumericString(_valor.text, allowPeriod: false);

    final valorDouble = double.parse(valorLimpo) / 100;

    if (_formKeyNovaConta.currentState!.validate()) {
      final novaConta = ContaCad(
        tipoConta: _tipoConta.text,
        descricao: _descricao.text,
        observacao: _observacoes.text,
        valor: valorDouble,
        pago: false,
      );

      FirebaseFirestore.instance.collection('despesas').add({
        'tipoConta': novaConta.tipoConta,
        'descricao': novaConta.descricao,
        'observacao': novaConta.observacao,
        'valor': novaConta.valor,
        'pago': false,
        'createdAt': Timestamp.now(),
      });

      setState(() {
        FinanceiroServiceDespesas.listaConta.add(novaConta);
        _tipoConta.clear();
        _descricao.clear();
        _observacoes.clear();
        _valor.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conta cadastrada e salva no Firestore!')),
      );

      return true;
    }
    return false;
  }

  Future<void> carregarDespesasDoFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('despesas')
            .orderBy('createdAt', descending: false)
            .get();

    final lista =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return ContaCad(
            id: doc.id,
            tipoConta: data['tipoConta'] ?? '',
            descricao: data['descricao'] ?? '',
            observacao: data['observacao'] ?? '',
            valor: (data['valor'] ?? 0).toDouble(),
            pago: data['pago'] ?? false,
          );
        }).toList();

    setState(() {
      FinanceiroServiceDespesas.listaConta = lista;
    });
  }

  Future<void> carregarTiposDeConta() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('tipos_despesas')
            .orderBy('createdAt', descending: false)
            .get();

    final tipos =
        snapshot.docs.map((doc) {
          return Conta(tipoConta: doc['tipoConta']);
        }).toList();

    setState(() {
      _listaTipoConta = tipos;
    });
  }

  Future<void> marcarComoPago(int index) async {
    final antigo = FinanceiroServiceDespesas.listaConta[index];

    // Verifique se você tem o ID do documento
    if (antigo.id == null) {
      print('ID do documento não encontrado. Não é possível atualizar.');
      return;
    }

    final atualizado = ContaCad(
      id: antigo.id, // mantemos o mesmo ID
      tipoConta: antigo.tipoConta,
      descricao: antigo.descricao,
      valor: antigo.valor,
      observacao: antigo.observacao,
      pago: true, // marcar como pago
    );

    try {
      // Atualiza no Firestore
      await FirebaseFirestore.instance
          .collection('despesas')
          .doc(antigo.id) // importante usar o ID do documento
          .update({'pago': true});

      // Atualiza localmente também
      setState(() {
        FinanceiroServiceDespesas.listaConta[index] = atualizado;
      });
    } catch (e) {
      print('Erro ao atualizar documento: $e');
    }
  }

  Widget espacador([double altura = 20]) => SizedBox(height: altura);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/sbento.png'),
              opacity: 0.3,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 350,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 32, 117, 185),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.white, width: 2),
                      ),
                      elevation: 8,
                    ),

                    child: Text('Tipos de conta'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(
                                'Cadastrar tipo de conta',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.yellow,
                              content: SizedBox(
                                height: 300,
                                width: 300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      child: Form(
                                        key: _formKeyTipoConta,
                                        child: TextFormField(
                                          controller: _novoTipoConta,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          /*decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.wallet),
                                            hintText:
                                                'Digite um novo tipo de conta...',
                                            label: Text('Novo'),
                                          ),*/
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.credit_score,
                                              color: Colors.black,
                                            ),
                                            label: Text(
                                              'Novo',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            hintText:
                                                'Digite um novo tipo de conta...',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Digite um tipo de conta';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    espacador(40),
                                    Text(
                                      'Contas salvas:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 150,
                                      child: Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: ListView.builder(
                                          itemCount: _listaTipoConta.length,
                                          itemBuilder: (context, index) {
                                            final item = _listaTipoConta[index];
                                            return ListTile(
                                              onTap: () {},
                                              leading: Icon(
                                                Icons.credit_score,
                                                color: Colors.white,
                                              ),
                                              title: Text(
                                                item.tipoConta,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              shape: BeveledRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Fechar',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    validacaoTipoConta();
                                    FocusScope.of(context).unfocus();
                                    // FocusScope.of(context).unfocus(); Fecha o teclado
                                  },
                                  child: Text(
                                    'Salvar',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ),
                espacador(10),
                SizedBox(
                  height: 60,
                  width: 350,
                  child: ElevatedButton(
                    child: Text('Lançar nova conta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 32, 117, 185),
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
                        builder:
                            (context) => AlertDialog(
                              backgroundColor: Colors.yellow,
                              title: Text(
                                'Cadastrar nova conta',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: SizedBox(
                                height: 350,
                                width: 300,
                                child: Form(
                                  //obs: O widget Form, tem que está fora da column.
                                  //Ou seja, a column tem que está dentro do form.
                                  key: _formKeyNovaConta,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      DropdownButtonFormField<String>(
                                        value:
                                            _tipoConta.text.isNotEmpty
                                                ? _tipoConta.text
                                                : null,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _tipoConta.text = newValue!;
                                          });
                                        },
                                        items:
                                            _listaTipoConta.map((conta) {
                                              return DropdownMenuItem<String>(
                                                value: conta.tipoConta,
                                                child: Text(conta.tipoConta),
                                              );
                                            }).toList(),
                                        /*decoration: InputDecoration(
                                          labelText: 'Tipo de Conta',
                                        ),*/
                                        decoration: InputDecoration(
                                          label: Text(
                                            'Tipo de conta',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor, selecione um tipo de conta';
                                          }
                                          return null;
                                        },
                                      ),

                                      espacador(20),
                                      TextFormField(
                                        controller: _descricao,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.wallet,
                                            color: Colors.black,
                                          ),
                                          label: Text(
                                            'Descrição',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          hintText: 'Digite uma descrição...',
                                          hintStyle: TextStyle(
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        /*decoration: InputDecoration(
                                          labelText: 'Descrição',
                                          prefixIcon: Icon(Icons.label),
                                        ),*/
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'O campo é obrigatório';
                                          }
                                          return null;
                                        },
                                      ),
                                      espacador(20),
                                      TextFormField(
                                        controller: _observacoes,
                                        /*decoration: InputDecoration(
                                          labelText: 'Observações(Opcional)',
                                          prefixIcon: Icon(Icons.abc),
                                        ),*/
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.announcement_rounded,
                                            color: Colors.black,
                                          ),
                                          label: Text(
                                            'Observações(Opcional)',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          hintText: 'Digite uma observação...',
                                          hintStyle: TextStyle(
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) => null,
                                      ),
                                      espacador(20),
                                      TextFormField(
                                        controller: _valor,
                                        /*decoration: InputDecoration(
                                          labelText: 'Valor R\$',
                                          prefixIcon: Icon(Icons.attach_money),
                                        ),*/
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.attach_money,
                                            color: Colors.black,
                                          ),
                                          label: Text(
                                            'Valor R\$',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          hintText:
                                              'Digite o valor da conta...',
                                          hintStyle: TextStyle(
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          CurrencyInputFormatter(
                                            leadingSymbol: 'R\$',
                                            thousandSeparator:
                                                ThousandSeparator.Period,
                                          ),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'O campo é obrigatório';
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
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final sucesso = validacaoNovaConta();
                                    if (sucesso == true) Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Cadastrar',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ),
                espacador(10),
                SizedBox(
                  height: 60,
                  width: 350,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 32, 117, 185),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.white, width: 2),
                      ),
                      elevation: 8,
                    ),

                    child: Text('Contas lançadas'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(
                                'Contas lançadas',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.yellow,
                              content: SizedBox(
                                height: 400,
                                width: 300,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ListView.builder(
                                    itemCount:
                                        FinanceiroServiceDespesas
                                            .listaConta
                                            .length,
                                    itemBuilder: (context, index) {
                                      final item =
                                          FinanceiroServiceDespesas
                                              .listaConta[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 1.0,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 5.0,
                                            ),
                                            child: ListTile(
                                              contentPadding: EdgeInsets.all(
                                                10,
                                              ),
                                              onTap: () {},
                                              leading: Icon(
                                                Icons.wallet,
                                                color: Colors.white,
                                              ),
                                              title: Text(
                                                'Tipo: ${item.tipoConta}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              subtitle: Text(
                                                'Descrição: ${item.descricao}\nValor: ${formatter.format(item.valor)}\nObservações: ${item.observacao}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              trailing:
                                                  FinanceiroServiceDespesas
                                                          .listaConta[index]
                                                          .pago
                                                      ? Icon(
                                                        Icons.check_box,
                                                        color: Colors.green,
                                                      )
                                                      : IconButton(
                                                        icon: Icon(
                                                          Icons
                                                              .check_box_outline_blank,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => AlertDialog(
                                                                  title: Text(
                                                                    'Confirmar pagamento',
                                                                  ),
                                                                  content: Text(
                                                                    'Deseja confirmar o pagamento?',
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
                                                      ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
