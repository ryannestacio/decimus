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

class _BodyDespesasState extends State<BodyDespesas> {
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
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Cadastrar tipo de conta'),
                        content: SizedBox(
                          height: 150,
                          width: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Digite um novo tipo de conta...',
                                    label: Text('Novo'),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text('Salvar conta'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
