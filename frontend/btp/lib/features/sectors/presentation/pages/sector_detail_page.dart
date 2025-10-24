import 'package:flutter/material.dart';

class SectorDetailPage extends StatelessWidget {
  final String sector;
  
  const SectorDetailPage({
    super.key,
    required this.sector,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secteur: $sector'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Détails du secteur: $sector'),
      ),
    );
  }
}
