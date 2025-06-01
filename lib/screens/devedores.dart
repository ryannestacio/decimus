import 'package:flutter/material.dart';
import 'package:decimus/models/devedor.dart';

class DevedoresScreen extends StatelessWidget {
  const DevedoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Devedores',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
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

Widget espacador([double altura = 20]) => SizedBox(height: altura);

class _BodyDevedoresState extends State<BodyDevedores> {
  final TextEditingController _cadDevedor = TextEditingController();
  final TextEditingController _valDevedor = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<Devedor> _listDevedor = [];

  double calcularTotalDevedoresNaoPagos() {
    return _listDevedor
        .where((d) => !d.pago)
        .fold(0.0, (total, d) => total + d.valor);
  }

  double calcularTotalDevedoresPagos() {
    return _listDevedor
        .where((d) => d.pago)
        .fold(0.0, (total, d) => total + d.valor);
  }

  void marcarComoPago(int index) {
    final antigo = _listDevedor[index];
    final atualizado = Devedor(
      nome: antigo.nome,
      valor: antigo.valor,
      pago: true,
    );
    setState(() {
      _listDevedor[index] = atualizado;
    });
  }

  void validator() {
    if (_formKey.currentState!.validate()) {
      final addConta = Devedor(
        nome: _cadDevedor.text,
        valor: double.tryParse(_valDevedor.text) ?? 0.0,
      );

      setState(() {
        _listDevedor.add(addConta);
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
      title: Text('Novo devedor'),
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
                  prefixIcon: Icon(Icons.supervised_user_circle_outlined),
                  labelText: 'Nome',
                  hintText: 'Digite o nome do devedor...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome do devedor';
                  }
                  return null;
                },
              ),
              espacador(10),
              TextFormField(
                controller: _valDevedor,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o valor a pagar';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Digite um valor numérico válido';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.attach_money),
                  labelText: 'Valor',
                  hintText: 'Digite o valor a pagar...',
                ),
                keyboardType: TextInputType.number,
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
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            validator();
          },
          child: Text('Confirmar'),
        ),
      ],
    );
  }

  Widget _dialogVerificacao() {
    return AlertDialog(
      backgroundColor: Colors.yellow,
      title: Text('Devedores'),
      content: SizedBox(
        height: 500,
        width: 600,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child:
                  _listDevedor.isEmpty
                      ? Center(child: const Text('Nenhum devedor cadastrado.'))
                      : ListView.builder(
                        itemCount: _listDevedor.length,
                        itemBuilder: (context, index) {
                          final item = _listDevedor[index];
                          return ListTile(
                            leading: Icon(
                              Icons.supervised_user_circle_outlined,
                            ),
                            title: Text(item.nome),
                            subtitle: Text(
                              'R\$ ${item.valor.toStringAsFixed(2)}',
                            ),
                            trailing:
                                _listDevedor[index].pago
                                    ? Icon(Icons.check_box, color: Colors.green)
                                    : IconButton(
                                      icon: Icon(
                                        Icons.check_box_outline_blank,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: Text(
                                                  'Confirmar pagamento',
                                                ),
                                                content: Text(
                                                  'Deseja confirmar o pagamento?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Não'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      marcarComoPago(index);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Sim'),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                    ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 350,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _dialogCadastro(),
                  );
                },
                child: Text('Cadastrar devedor'),
              ),
            ),
            espacador(10),
            SizedBox(
              height: 60,
              width: 350,
              child: OutlinedButton(
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
    );
  }
}
