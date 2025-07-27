import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void _validation() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailControler.text.trim();
      final senha = _senhaController.text.trim();

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: senha,
        );

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');

        _emailControler.clear();
        _senhaController.clear();
      } on FirebaseException catch (e) {
        String mensagemErro;
        if (e.code == 'user-not-found') {
          mensagemErro = 'Usuário não cadastrado';
        } else if (e.code == 'wrong-password') {
          mensagemErro = 'Senha incorreta';
        } else {
          mensagemErro = 'Erro: ${e.message}';
        }

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mensagemErro)));
        }
      }
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
              Image.asset(
                'assets/images/imagem1login.png',
                width: 150,
                height: 200,
              ),
              //SizedBox(height: 20),
              const Text(
                'Bem Vindo!\nSalve Maria!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),

              SizedBox(height: 10),
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
                  prefixIcon: Icon(Icons.lock_outline_rounded),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.white, width: 2),
                        ),
                        elevation: 8,
                      ),

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
