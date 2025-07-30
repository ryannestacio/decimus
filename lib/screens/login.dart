import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text(
          'Decimus App',
          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 8,
        shadowColor: Colors.indigo,
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

  bool _isLoading = false;

  void _validation() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
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
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: SpinKitFadingCube(color: Colors.amber, size: 60))
        : Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Container(
                constraints: BoxConstraints(maxWidth: 420),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 10),

                    TextFormField(
                      controller: _emailControler,
                      decoration: const InputDecoration(
                        labelText: 'Digite seu e-mail',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.mail),
                      ),
                      onFieldSubmitted: (_) {
                        _validation(); // Chama o login quando aperta Enter
                      },
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
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        labelText: 'Digite sua senha',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      autofocus: false,
                      obscureText: true,
                      onFieldSubmitted: (_) {
                        _validation(); // Chama o login quando aperta Enter
                      },
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

                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
