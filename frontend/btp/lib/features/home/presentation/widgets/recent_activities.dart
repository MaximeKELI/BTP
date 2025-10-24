import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - in real app, this would come from a provider
    final activities = [
      {
        'title': 'Nouveau projet BTP',
        'subtitle': 'Construction d\'un immeuble résidentiel',
        'time': 'Il y a 2 heures',
        'icon': Icons.construction,
        'color': Colors.blue,
      },
      {
        'title': 'Récolte terminée',
        'subtitle': 'Parcelle de maïs - 5 hectares',
        'time': 'Il y a 4 heures',
        'icon': Icons.agriculture,
        'color': Colors.green,
      },
      {
        'title': 'Rapport de production',
        'subtitle': 'Mine de cuivre - Extraction journalière',
        'time': 'Il y a 6 heures',
        'icon': Icons.diamond,
        'color': Colors.orange,
      },
      {
        'title': 'Nouveau client',
        'subtitle': 'Entreprise de services généraux',
        'time': 'Hier',
        'icon': Icons.business,
        'color': Colors.purple,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(AppConfig.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activités Récentes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to activities page
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
          
          const SizedBox(height: AppConfig.spacingM),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityItem(context, activity);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> activity) {
    final color = activity['color'] as Color;
    final icon = activity['icon'] as IconData;
    final title = activity['title'] as String;
    final subtitle = activity['subtitle'] as String;
    final time = activity['time'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConfig.spacingS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle activity tap
          },
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.spacingM),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: AppConfig.spacingM),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 2),
                      
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Time
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
