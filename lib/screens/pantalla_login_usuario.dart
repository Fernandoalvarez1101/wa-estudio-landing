import 'package:flutter/material.dart';

class PantallaLoginUsuario extends StatelessWidget {
  const PantallaLoginUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Usuario')),
      body: const Center(child: Text('Pantalla de login para usuario')),
    );
  }
}
