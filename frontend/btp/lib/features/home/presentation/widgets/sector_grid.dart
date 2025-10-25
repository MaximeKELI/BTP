import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';

class SectorGrid extends StatelessWidget {
  const SectorGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Secteurs d\'Activités',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/home/sectors'),
                child: const Text('Voir tout'),
              ),
            ],
          ),
          
          const SizedBox(height: AppConfig.spacingM),
          
          // Sectors Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppConfig.gridCrossAxisCount,
              childAspectRatio: AppConfig.gridChildAspectRatio,
              crossAxisSpacing: AppConfig.gridSpacing,
              mainAxisSpacing: AppConfig.gridSpacing,
            ),
            itemCount: AppConfig.sectors.length,
            itemBuilder: (context, index) {
              final sectorKey = AppConfig.sectors.keys.elementAt(index);
              final sector = AppConfig.sectors[sectorKey]!;
              
              return _buildSectorCard(
                context,
                sectorKey,
                sector,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectorCard(
    BuildContext context,
    String sectorKey,
    Map<String, dynamic> sector,
  ) {
    final color = Color(sector['color'] as int);
    final icon = _getSectorIcon(sectorKey);
    
    return GestureDetector(
      onTap: () => context.go('/home/$sectorKey'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.spacingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              
              const SizedBox(height: AppConfig.spacingS),
              
              // Title
              Flexible(
                child: Text(
                  sector['name'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: AppConfig.spacingXS),
              
              // Description
              Flexible(
                child: Text(
                  sector['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSectorIcon(String sectorKey) {
    switch (sectorKey) {
      case 'btp':
        return Icons.construction;
      case 'agribusiness':
        return Icons.agriculture;
      case 'mining':
        return Icons.diamond;
      case 'divers':
        return Icons.business;
      default:
        return Icons.work;
    }
  }
}
