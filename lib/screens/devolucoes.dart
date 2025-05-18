import 'package:flutter/material.dart';

class DevolucoesScreen extends StatelessWidget {
  const DevolucoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tela de devoluções',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
      ),
    );
  }
}
