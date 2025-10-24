import 'package:flutter/material.dart';

class SectorsPage extends StatelessWidget {
  const SectorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secteurs d\'Activités'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Page des secteurs'),
      ),
    );
  }
}
