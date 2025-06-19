import 'package:decimus/services/services_financeiro.dart';
import 'package:flutter/material.dart';
import 'package:decimus/models/models_despesas.dart';

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

class _BodyDespesasState extends State<BodyDespesas> {
  final TextEditingController _novoTipoConta = TextEditingController();
  final TextEditingController _tipoConta = TextEditingController();
  final TextEditingController _descricao = TextEditingController();
  final TextEditingController _observacoes = TextEditingController();
  final TextEditingController _valor = TextEditingController();

  final _formKeyTipoConta = GlobalKey<FormState>();
  final _formKeyNovaConta = GlobalKey<FormState>();
  final List<Conta> _listaTipoConta = [];
  final listaConta = FinanceiroService.listaConta;

  /*double calcularTotalDespesasPagos() {
    return _listaConta
        .where((valorC) => valorC.pago)
        .fold(0.0, (soma, valorC) => soma + valorC.valor);
  }

  double calcularTotalDevedoresNaoPagos() {
    return _listaConta
        .where((valorC) => !valorC.pago)
        .fold(0.0, (soma, valorC) => soma + valorC.valor);
  }*/

  String? tipoSelecionado;

  void validacaoTipoConta() {
    if (_formKeyTipoConta.currentState!.validate()) {
      final addConta = Conta(tipoConta: _novoTipoConta.text);

      setState(() {
        _listaTipoConta.add(addConta);
        _novoTipoConta.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tipo de conta salvo!')));
    }
  }

  void marcarComoPago(int index) {
    final antigo = listaConta[index];
    final atualizado = ContaCad(
      tipoConta: antigo.tipoConta,
      descricao: antigo.descricao,
      valor: antigo.valor,
      pago: true,
    );
    setState(() {
      listaConta[index] = atualizado;
    });
  }

  bool validacaoNovaConta() {
    if (_formKeyNovaConta.currentState!.validate()) {
      final addConta = ContaCad(
        tipoConta: _tipoConta.text,
        descricao: _descricao.text,
        observacao: _observacoes.text,
        valor: double.tryParse(_valor.text) ?? 0.0,
      );
      setState(() {
        FinanceiroService.listaConta.add(addConta);
        _tipoConta.clear();
        _descricao.clear();
        _observacoes.clear();
        _valor.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Conta cadastrada, verifique sua conta em "Verificar contas".',
          ),
        ),
      );

      return true;
    }
    return false;
  }

  Widget espacador([double altura = 20]) => SizedBox(height: altura);

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
                                espacador(40),
                                Text(
                                  'Contas salvas:',
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    itemCount: _listaTipoConta.length,
                                    itemBuilder: (context, index) {
                                      final item = _listaTipoConta[index];
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
                                validacaoTipoConta();
                                FocusScope.of(context).unfocus();
                                // FocusScope.of(context).unfocus(); Fecha o teclado
                              },
                              child: Text('Salvar'),
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
              child: OutlinedButton(
                child: Text('Cadastrar nova conta'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          backgroundColor: Colors.yellow,
                          title: Text('Cadastrar nova conta'),
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
                                        _tipoConta.text.isEmpty
                                            ? null
                                            : _tipoConta.text,
                                    decoration: InputDecoration(
                                      labelText: 'Tipo de conta',
                                      prefixIcon: Icon(Icons.wallet),
                                    ),
                                    items:
                                        _listaTipoConta.map((conta) {
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
                                  espacador(20),
                                  TextFormField(
                                    controller: _descricao,
                                    decoration: InputDecoration(
                                      labelText: 'Descrição',
                                      prefixIcon: Icon(Icons.label),
                                    ),
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
                                    decoration: InputDecoration(
                                      labelText: 'Observações(Opcional)',
                                      prefixIcon: Icon(Icons.abc),
                                    ),
                                    validator: (value) => null,
                                  ),
                                  espacador(20),
                                  TextFormField(
                                    controller: _valor,
                                    decoration: InputDecoration(
                                      labelText: 'Valor R\$',
                                      prefixIcon: Icon(Icons.attach_money),
                                    ),
                                    keyboardType: TextInputType.number,
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
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                final sucesso = validacaoNovaConta();
                                if (sucesso == true) Navigator.pop(context);
                              },
                              child: Text('Cadastrar'),
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
              child: OutlinedButton(
                child: Text('Verificar contas'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Contas cadastradas'),
                          backgroundColor: Colors.yellow,
                          content: SizedBox(
                            height: 400,
                            width: 300,
                            child: ListView.builder(
                              itemCount: listaConta.length,
                              itemBuilder: (context, index) {
                                final item = listaConta[index];
                                return ListTile(
                                  onTap: () {},
                                  leading: Icon(Icons.wallet),
                                  title: Text('Tipo: ${item.tipoConta}'),
                                  subtitle: Text(
                                    'Descrição: ${item.descricao}\nValor: ${item.valor}\nObservações: ${item.observacao}',
                                  ),
                                  trailing:
                                      listaConta[index].pago
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
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Text('Não'),
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
                        ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text('testes:'),
            Text('Despesas pagas: R\$${FinanceiroService.totalDespesasPagas}'),
            Text(
              'Despesas pendentes: R\$${FinanceiroService.totalDespesasPendentes}',
            ),
          ],
        ),
      ),
    );
  }
}
