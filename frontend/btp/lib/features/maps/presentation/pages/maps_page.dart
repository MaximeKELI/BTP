import 'package:flutter/material.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Page de carte - En construction'),
      ),
    );
  }
}
