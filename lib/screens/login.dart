import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        title: const Text(
          'Decimus App',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow,
      ),
      body: BodyLogin(),
    );
  }
}

class BodyLogin extends StatefulWidget {
  const BodyLogin({super.key});

  @override
  State<BodyLogin> createState() => _BodyLoginState();
}

class _BodyLoginState extends State<BodyLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailControler = TextEditingController();
  final _senhaController = TextEditingController();

  void _validation() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _emailControler.clear();
        _senhaController.clear();
      });
      Navigator.pushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bem Vindo!\nSalve Maria!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),

              SizedBox(height: 100),
              TextFormField(
                controller: _emailControler,
                decoration: const InputDecoration(
                  labelText: 'Digite seu e-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.mail),
                ),
                autofocus: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite o e-mail';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: 'Digite sua senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password_rounded),
                ),
                autofocus: false,
                obscureText: true,
                validator: (value) {
                  if (value == null) {
                    return 'Por favor digite a sua senha';
                  }
                  if (value.length < 6) {
                    return 'Sua senhha tem que ser maior que 6 dígitos';
                  }
                  return null;
                },
              ),

              // SizedBox(height: 10),
              Column(
                children: [
                  SizedBox(height: 40),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        _validation();
                      },
                      child: const Text(
                        'Entrar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
