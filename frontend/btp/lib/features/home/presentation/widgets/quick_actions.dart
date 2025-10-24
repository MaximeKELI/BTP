import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'Rechercher',
        'icon': Icons.search,
        'color': Colors.blue,
        'route': '/home/search',
      },
      {
        'title': 'Carte',
        'icon': Icons.map,
        'color': Colors.green,
        'route': '/home/maps',
      },
      {
        'title': 'Chat',
        'icon': Icons.chat,
        'color': Colors.orange,
        'route': '/home/chat',
      },
      {
        'title': 'Paiements',
        'icon': Icons.payment,
        'color': Colors.purple,
        'route': '/home/payments',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(AppConfig.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions Rapides',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppConfig.spacingM),
          
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return _buildActionCard(context, action);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, Map<String, dynamic> action) {
    final color = action['color'] as Color;
    final icon = action['icon'] as IconData;
    final title = action['title'] as String;
    final route = action['route'] as String;

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppConfig.spacingM),
      child: GestureDetector(
        onTap: () => context.go(route),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            
            const SizedBox(height: AppConfig.spacingS),
            
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
