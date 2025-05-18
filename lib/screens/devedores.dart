import 'package:flutter/material.dart';

class DevedoresScreen extends StatelessWidget {
  const DevedoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Devedores',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
      ),
      body: BodyDevedores(),
    );
  }
}

class BodyDevedores extends StatefulWidget {
  const BodyDevedores({super.key});

  @override
  State<BodyDevedores> createState() => _BodyDevedoresState();
}

class _BodyDevedoresState extends State<BodyDevedores>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
