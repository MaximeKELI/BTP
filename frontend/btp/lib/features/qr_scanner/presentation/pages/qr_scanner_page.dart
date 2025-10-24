import 'package:flutter/material.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Page de scanner QR - En construction'),
      ),
    );
  }
}
