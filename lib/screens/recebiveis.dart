import 'package:decimus/services/services_recebiveis.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class RecebiveisScreen extends StatelessWidget {
  const RecebiveisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Recebíveis',
          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 8,
        shadowColor: Colors.indigo,
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
  Future<void> _criarRecebimento() async {
    if (_formKey.currentState!.validate()) {
      if (_dataSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, selecione uma data.')),
        );
        return;
      }

      final novoRecebimento = {
        'tipo': _typeController.text,
        'valor': double.tryParse(_valueController.text) ?? 0.0,
        'data': Timestamp.fromDate(_dataSelecionada!),
      };

      await FirebaseFirestore.instance
          .collection('recebiveis')
          .add(novoRecebimento);

      setState(() {
        _typeController.clear();
        _valueController.clear();
        _dateController.clear();
        _dataSelecionada = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Recebimento salvo!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/saofrancisco.png'),
              opacity: 0.3,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 80),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: _typeController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Tipo',
                          style: TextStyle(color: Colors.white),
                        ),
                        hintText: 'Digite o tipo de recebimento...',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        border: OutlineInputBorder(),
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
                  SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                      ), //Cor do texto digitado pelo usuário
                      controller: _valueController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Valor',
                          style: TextStyle(color: Colors.white),
                        ),
                        hintText: 'Digite o valor recebido...',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        border: OutlineInputBorder(),
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
                  SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: _dateController,
                      decoration: InputDecoration(
                        label: Text(
                          'Data de recebimento',
                          style: TextStyle(color: Colors.white),
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        border: OutlineInputBorder(),
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
                        height: 40,
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () => _criarRecebimento(),
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
                          child: Text('Receber'),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      constraints: BoxConstraints(maxWidth: 420), //
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('recebiveis')
                                .orderBy('data', descending: true)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: SpinKitFadingCircle(color: Colors.amber),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final tipo = doc['tipo'];
                              final valor = doc['valor'];
                              final data = (doc['data'] as Timestamp).toDate();

                              return ListTile(
                                leading: Icon(
                                  Icons.monetization_on,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  tipo,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Text(
                                  'Entrada: ${data.day}/${data.month}/${data.year}\nValor: R\$${valor.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
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
