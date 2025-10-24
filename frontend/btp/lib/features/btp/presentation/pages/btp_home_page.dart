import 'package:flutter/material.dart';

class BTPHomePage extends StatelessWidget {
  const BTPHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bâtiments et Travaux Publics'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Page BTP - En construction'),
      ),
    );
  }
}
