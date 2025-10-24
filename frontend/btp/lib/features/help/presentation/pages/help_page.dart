import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Page d\'aide - En construction'),
      ),
    );
  }
}
