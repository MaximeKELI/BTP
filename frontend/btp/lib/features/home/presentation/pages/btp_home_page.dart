import '../widgets/btp_header.dart';
import '../widgets/stats_cards.dart';
import 'package:flutter/material.dart';
import '../widgets/quick_actions.dart';
import '../widgets/category_grid.dart';
import '../widgets/featured_workers.dart';
import '../widgets/featured_equipment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BTPHomePage extends ConsumerStatefulWidget {
  const BTPHomePage({super.key});

  @override
  ConsumerState<BTPHomePage> createState() => _BTPHomePageState();
}

class _BTPHomePageState extends ConsumerState<BTPHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO: Refresh data
          },
          child: CustomScrollView(
            slivers: [
              // Header avec recherche
              const SliverToBoxAdapter(
                child: BTPHeader(),
              ),
              
              // Actions rapides
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: QuickActions(),
                ),
              ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
              
              // Statistiques
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: StatsCards(),
                ),
              ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
              
              // Catégories
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: CategoryGrid(),
                ),
              ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
              
              // Ouvriers en vedette
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: FeaturedWorkers(),
                ),
              ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
              
              // Équipements en vedette
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: FeaturedEquipment(),
                ),
              ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
