import 'package:flutter/material.dart';
import '../../../../core/models/worker_model.dart';

class FeaturedWorkers extends StatelessWidget {
  const FeaturedWorkers({super.key});

  @override
  Widget build(BuildContext context) {
    // Données d'exemple - à remplacer par des données réelles
    final featuredWorkers = [
      _WorkerData(
        name: 'Jean Kouassi',
        type: 'Maçon',
        rating: 4.8,
        reviews: 24,
        hourlyRate: 5000,
        image: null,
        isAvailable: true,
      ),
      _WorkerData(
        name: 'Marie Traoré',
        type: 'Électricienne',
        rating: 4.9,
        reviews: 18,
        hourlyRate: 6000,
        image: null,
        isAvailable: true,
      ),
      _WorkerData(
        name: 'Amadou Diallo',
        type: 'Plombier',
        rating: 4.7,
        reviews: 31,
        hourlyRate: 5500,
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
              'Ouvriers en vedette',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Naviguer vers tous les ouvriers
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
            itemCount: featuredWorkers.length,
            itemBuilder: (context, index) {
              final worker = featuredWorkers[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < featuredWorkers.length - 1 ? 12 : 0,
                ),
                child: _WorkerCard(worker: worker),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorkerData {
  final String name;
  final String type;
  final double rating;
  final int reviews;
  final double hourlyRate;
  final String? image;
  final bool isAvailable;

  _WorkerData({
    required this.name,
    required this.type,
    required this.rating,
    required this.reviews,
    required this.hourlyRate,
    this.image,
    required this.isAvailable,
  });
}

class _WorkerCard extends StatelessWidget {
  final _WorkerData worker;

  const _WorkerCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Naviguer vers le profil de l'ouvrier
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
            // Photo de profil
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: worker.image != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        worker.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderAvatar();
                        },
                      ),
                    )
                  : _buildPlaceholderAvatar(),
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
                          worker.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (worker.isAvailable)
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
                    worker.type,
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
                        worker.rating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${worker.reviews})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${worker.hourlyRate.toStringAsFixed(0)} FCFA/h',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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

  Widget _buildPlaceholderAvatar() {
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
          Icons.person,
          size: 40,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
