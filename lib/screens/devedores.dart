import 'package:flutter/material.dart';
import 'package:decimus/services/services_devedores.dart';
import 'package:decimus/models/models_devedores.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class DevedoresScreen extends StatelessWidget {
  const DevedoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
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
  final TextEditingController _cadDevedor = TextEditingController();
  final TextEditingController _valDevedor = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final listaDevedor = FinanceiroServiceDevedores.listDevedor;

  @override
  void initState() {
    super.initState();
    _carregarDevedores();
  }

  Future<void> _carregarDevedores() async {
    await FinanceiroServiceDevedores.carregarDevedores();
    setState(() {});
  }

  void marcarComoPago(int index) async {
    final antigo = listaDevedor[index];
    final atualizado = Devedor(
      nome: antigo.nome,
      valor: antigo.valor,
      pago: true,
    );

    await FinanceiroServiceDevedores.marcarComoPago(listaDevedor[index].id!);
    await _carregarDevedores();

    setState(() {
      listaDevedor[index] = atualizado;
    });
  }

  void validator() async {
    final valorLimpo = toNumericString(_valDevedor.text, allowPeriod: false);

    final valorDouble = double.parse(valorLimpo) / 100;
    if (_formKey.currentState!.validate()) {
      final addConta = Devedor(nome: _cadDevedor.text, valor: valorDouble);

      await FinanceiroServiceDevedores.salvarDevedor(addConta);
      await _carregarDevedores(); // recarrega e dá setState

      setState(() {
        listaDevedor.add(addConta);
        _cadDevedor.clear();
        _valDevedor.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Devedor salvo com sucesso, verifique em devedores.'),
        ),
      );
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
        height: 200,
        width: 300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _cadDevedor,
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
    return AlertDialog(
      title: Text(
        'Devedores',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                  listaDevedor.isEmpty
                      ? Center(child: const Text('Nenhum devedor cadastrado.'))
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
                            itemCount: listaDevedor.length,
                            itemBuilder: (context, index) {
                              final item = listaDevedor[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5.0,
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.supervised_user_circle_outlined,
                                        color: Colors.white,
                                      ),
                                      title: Text(
                                        item.nome,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        'R\$ ${item.valor.toStringAsFixed(2)}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      trailing:
                                          listaDevedor[index].pago
                                              ? Icon(
                                                Icons.check_box,
                                                color: Colors.green,
                                              )
                                              : IconButton(
                                                icon: Icon(
                                                  Icons.check_box_outline_blank,
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
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
      ],
    );
  }
}
