import 'package:flutter/material.dart';

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
  State<BodyRecebiveis> createState() => _CorpoRecebimentosState();
}

class Recebimento {
  String tipo;
  double valor;
  DateTime data;

  Recebimento({required this.tipo, required this.valor, required this.data});
}

class _CorpoRecebimentosState extends State<BodyRecebiveis> {
  final TextEditingController _typeControler = TextEditingController();
  final TextEditingController _valueControler = TextEditingController();
  final TextEditingController _dateControler = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _dataSelecionada;

  //Lista onde vou armazenar as informações dos campos de recebimento
  final List<Recebimento> _listaRecebimento = [];

  void _criarRecebimento() {
    if (_formKey.currentState!.validate()) {
      final meuRecebimento = Recebimento(
        tipo: _typeControler.text,
        valor: double.tryParse(_valueControler.text) ?? 0.0,
        // Tranforma de bool para sting
        data: _dataSelecionada!,
      );

      _dataSelecionada = null;

      setState(() {
        _listaRecebimento.add(meuRecebimento);
        _typeControler.clear();
        _dateControler.clear();
        _valueControler.clear();
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
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Adicione um Recebimento',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ],
              ),
              SizedBox(height: 80),
              SingleChildScrollView(
                child: SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _typeControler,
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
                  ),
                ),
              ),

              SingleChildScrollView(
                child: SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _valueControler,
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
              ),
              SingleChildScrollView(
                child: SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _dateControler,
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
                        _dateControler.text =
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
              ),
              SingleChildScrollView(
                child: Column(
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
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _listaRecebimento.length,
                  itemBuilder: (context, index) {
                    final item = _listaRecebimento[index];
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
            ],
          ),
        ),
      ),
    );
  }
}
