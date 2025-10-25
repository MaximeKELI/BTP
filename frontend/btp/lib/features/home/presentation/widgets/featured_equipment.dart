import 'package:flutter/material.dart';
import '../../../../core/models/equipment_model.dart';

class FeaturedEquipment extends StatelessWidget {
  const FeaturedEquipment({super.key});

  @override
  Widget build(BuildContext context) {
    // Données d'exemple - à remplacer par des données réelles
    final featuredEquipment = [
      _EquipmentData(
        name: 'Excavatrice CAT 320',
        category: 'Terrassement',
        rating: 4.6,
        reviews: 12,
        dailyRate: 150000,
        image: null,
        isAvailable: true,
      ),
      _EquipmentData(
        name: 'Bétonnière 500L',
        category: 'Béton',
        rating: 4.8,
        reviews: 8,
        dailyRate: 25000,
        image: null,
        isAvailable: true,
      ),
      _EquipmentData(
        name: 'Échafaudage 3m',
        category: 'Levage',
        rating: 4.5,
        reviews: 15,
        dailyRate: 15000,
        image: null,
        isAvailable: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Équipements populaires',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Naviguer vers tous les équipements
              },
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredEquipment.length,
            itemBuilder: (context, index) {
              final equipment = featuredEquipment[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < featuredEquipment.length - 1 ? 12 : 0,
                ),
                child: _EquipmentCard(equipment: equipment),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EquipmentData {
  final String name;
  final String category;
  final double rating;
  final int reviews;
  final double dailyRate;
  final String? image;
  final bool isAvailable;

  _EquipmentData({
    required this.name,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.dailyRate,
    this.image,
    required this.isAvailable,
  });
}

class _EquipmentCard extends StatelessWidget {
  final _EquipmentData equipment;

  const _EquipmentCard({required this.equipment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Naviguer vers le profil de l'équipement
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de l'équipement
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: equipment.image != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        equipment.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      ),
                    )
                  : _buildPlaceholderImage(),
            ),
            
            // Informations
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          equipment.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (equipment.isAvailable)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    equipment.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber[600],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        equipment.rating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${equipment.reviews})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${equipment.dailyRate.toStringAsFixed(0)} FCFA/jour',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.build,
          size: 40,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
