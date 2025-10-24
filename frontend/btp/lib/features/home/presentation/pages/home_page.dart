import '../widgets/sector_grid.dart';
import '../widgets/home_app_bar.dart';
import 'package:flutter/material.dart';
import '../widgets/quick_actions.dart';
import 'package:go_router/go_router.dart';
import '../widgets/recent_activities.dart';
import '../widgets/notifications_banner.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConfig.mediumAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: HomeAppBar(
                  user: user,
                  isAuthenticated: isAuthenticated,
                ),
              ),
              
              // Notifications Banner
              const SliverToBoxAdapter(
                child: NotificationsBanner(),
              ),
              
              // Quick Actions
              const SliverToBoxAdapter(
                child: QuickActions(),
              ),
              
              // Sectors Grid
              const SliverToBoxAdapter(
                child: SectorGrid(),
              ),
              
              // Recent Activities
              const SliverToBoxAdapter(
                child: RecentActivities(),
              ),
              
              // Bottom Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/search'),
        icon: const Icon(Icons.search),
        label: const Text('Rechercher'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) => _onBottomNavTap(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: 'BTP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Agriculture',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond),
            label: 'Mining',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Divers',
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        context.go('/home/btp');
        break;
      case 2:
        context.go('/home/agribusiness');
        break;
      case 3:
        context.go('/home/mining');
        break;
      case 4:
        context.go('/home/divers');
        break;
    }
  }
}
