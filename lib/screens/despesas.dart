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

class ContaCad {
  final String? tipoConta;
  final String? descricao;
  final String? observacao;
  final double? valor;

  ContaCad({
    required this.tipoConta,
    required this.descricao,
    required this.observacao,
    required this.valor,
  });
}

class _BodyDespesasState extends State<BodyDespesas> {
  final TextEditingController _novoTipoConta = TextEditingController();
  final TextEditingController _tipoConta = TextEditingController();
  final TextEditingController _descricao = TextEditingController();
  final TextEditingController _observacoes = TextEditingController();
  final TextEditingController _valor = TextEditingController();

  final _formKeyTipoConta = GlobalKey<FormState>();
  final _formKeyNovaConta = GlobalKey<FormState>();
  final List<Conta> _listaContas = [];

  String? tipoSelecionado;

  void validacao() {
    if (_formKeyTipoConta.currentState!.validate()) {
      final addConta = Conta(tipoConta: _novoTipoConta.text);

      setState(() {
        _listaContas.add(addConta);
        _novoTipoConta.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tipo de conta salvo!')));
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
                child: Text('Tipos de conta'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Cadastrar tipo de conta'),
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
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.wallet),
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
                                SizedBox(height: 40),
                                Text(
                                  'Contas salvas:',
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    itemCount: _listaContas.length,
                                    itemBuilder: (context, index) {
                                      final item = _listaContas[index];
                                      return ListTile(
                                        onTap: () {},
                                        leading: Icon(Icons.attachment),
                                        title: Text(item.tipoConta),
                                        shape: BeveledRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
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
                              onPressed: () => Navigator.pop(context),
                              child: Text('Fechar'),
                            ),
                            TextButton(
                              onPressed: () {
                                validacao();
                                FocusScope.of(context).unfocus();
                              },
                              child: Text('Salvar'),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 60,
              width: 350,
              child: OutlinedButton(
                child: Text('Cadastrar nova conta'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          backgroundColor: Colors.yellow,
                          title: Text('CADASTRAR NOVA CONTA'),
                          content: SizedBox(
                            height: 400,
                            width: 300,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Form(
                                  key: _formKeyNovaConta,
                                  child: DropdownButtonFormField<String>(
                                    value:
                                        _tipoConta.text.isEmpty
                                            ? null
                                            : _tipoConta.text,
                                    decoration: InputDecoration(
                                      label: Text('Tipo de conta'),
                                      prefixIcon: Icon(Icons.wallet),
                                    ),
                                    items:
                                        _listaContas.map((conta) {
                                          return DropdownMenuItem(
                                            value: conta.tipoConta,
                                            child: Text(conta.tipoConta),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _tipoConta.text = value!;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Selecione o tipo da conta';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: _descricao,
                                  decoration: InputDecoration(
                                    label: Text('Descrição'),
                                    prefixIcon: Icon(Icons.label),
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: _observacoes,
                                  decoration: InputDecoration(
                                    label: Text('Observações(Opcional)'),
                                    prefixIcon: Icon(Icons.abc),
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: _valor,
                                  decoration: InputDecoration(
                                    label: Text('Valor R\$'),
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('Cadastrar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 60,
              width: 350,
              child: OutlinedButton(
                child: Text('Verificar contas'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
