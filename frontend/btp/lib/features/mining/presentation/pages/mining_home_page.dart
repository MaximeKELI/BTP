import 'package:flutter/material.dart';

class MiningHomePage extends StatelessWidget {
  const MiningHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exploitation Minière'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Page Mining - En construction'),
      ),
    );
  }
}
