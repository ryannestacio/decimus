import 'package:flutter/material.dart';

class DespesasScreen extends StatelessWidget {
  const DespesasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Despesas',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
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

class Conta {
  String tipoConta;

  Conta({required this.tipoConta});
}

class _BodyDespesasState extends State<BodyDespesas> {
  final TextEditingController _tipoConta = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Conta> listaContas = [];

  void validacao() {
    if (_formKey.currentState!.validate()) {
      final addConta = Conta(tipoConta: _tipoConta.text);

      setState(() {
        listaContas.add(addConta);
        _tipoConta.clear();
      });
    }
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
                    builder:
                        (context) => AlertDialog(
                          title: Text('Cadastrar tipo de conta'),
                          content: SizedBox(
                            height: 100,
                            width: 300,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Form(
                                    key: _formKey,
                                    child: TextFormField(
                                      controller: _tipoConta,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Digite um novo tipo de conta...',
                                        label: Text('Novo'),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Digite um tipo de conta';
                                        }
                                        return null;
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
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Tipo de conta salvo!'),
                                  ),
                                );
                              },
                              child: Text('Salvar'),
                            ),
                          ],
                        ),
                  );
                },
                child: Text('Tipos de conta'),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 60,
              width: 350,
              child: OutlinedButton(
                onPressed: () {},
                child: Text('Cadastrar conta'),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 60,
              width: 350,
              child: OutlinedButton(
                onPressed: () {},
                child: Text('Verificar contas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
