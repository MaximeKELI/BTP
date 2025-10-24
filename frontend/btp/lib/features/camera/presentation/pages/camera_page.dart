import 'package:flutter/material.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caméra'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Page de caméra - En construction'),
      ),
    );
  }
}
