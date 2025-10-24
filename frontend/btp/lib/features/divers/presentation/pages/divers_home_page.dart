import 'package:flutter/material.dart';

class DiversHomePage extends StatelessWidget {
  const DiversHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divers'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Page Divers - En construction'),
      ),
    );
  }
}
