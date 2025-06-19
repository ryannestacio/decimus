import 'package:decimus/services/services_recebiveis.dart';
import 'package:flutter/material.dart';
import 'package:decimus/models/models_recebiveis.dart';

class RecebiveisScreen extends StatelessWidget {
  const RecebiveisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recebíveis',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
      ),
      body: BodyRecebiveis(),
    );
  }
}

class BodyRecebiveis extends StatefulWidget {
  const BodyRecebiveis({super.key});

  @override
  State<BodyRecebiveis> createState() => _BodyRecebiveisState();
}

class _BodyRecebiveisState extends State<BodyRecebiveis> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _dataSelecionada;

  //Lista onde vou armazenar as informações dos campos de recebimento
  final listaRecebimento = FinanceiroServiceRecebiveis.listaRecebimentos;
  void _criarRecebimento() {
    if (_formKey.currentState!.validate()) {
      final meuRecebimento = Recebimento(
        tipo: _typeController.text,
        valor: double.tryParse(_valueController.text) ?? 0.0,
        // Tranforma de bool para sting
        data: _dataSelecionada!,
      );

      if (_dataSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, selecione uma data.')),
        );
        return;
      }

      setState(() {
        FinanceiroServiceRecebiveis.listaRecebimentos.add(meuRecebimento);
        _typeController.clear();
        _dateController.clear();
        _valueController.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Recebimento salvo!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Adicione um Recebimento',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 80),
              SizedBox(
                width: 300,
                child: TextFormField(
                  controller: _typeController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                    label: Text('Tipo'),
                    hintText: 'Digite o tipo de recebimento...',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                ),
              ),
              SizedBox(
                width: 300,
                child: TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.attach_money),
                    label: Text('Valor'),
                    hintText: 'Digite o valor recebido...',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                width: 300,
                child: TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    label: Text('Data de recebimento'),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedData = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (pickedData != null) {
                      _dataSelecionada = pickedData;
                      _dateController.text =
                          '${pickedData.day}/${pickedData.month}/${pickedData.year}';
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 30),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () => _criarRecebimento(),
                      child: Text('Receber'),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      FinanceiroServiceRecebiveis.listaRecebimentos.length,
                  itemBuilder: (context, index) {
                    final item =
                        FinanceiroServiceRecebiveis.listaRecebimentos[index];
                    return ListTile(
                      leading: Icon(Icons.monetization_on),
                      title: Text(item.tipo),
                      subtitle: Text(
                        'Entrada: ${item.data.day}/${item.data.month}/${item.data.year} \nValor: R\$${item.valor.toStringAsFixed(2)}',
                      ),
                    );
                  },
                ),
              ),
              Text(
                'Teste:\n\nTotal recebido: ${FinanceiroServiceRecebiveis.totalRecebiveis}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
