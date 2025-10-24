import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/maps/presentation/pages/maps_page.dart';
import '../../features/help/presentation/pages/help_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/splash_page.dart';
import '../../features/about/presentation/pages/about_page.dart';
import '../../features/btp/presentation/pages/btp_home_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/camera/presentation/pages/camera_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/sectors/presentation/pages/sectors_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/mining/presentation/pages/mining_home_page.dart';
import '../../features/divers/presentation/pages/divers_home_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/sectors/presentation/pages/sector_detail_page.dart';
import '../../features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/agribusiness/presentation/pages/agribusiness_home_page.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ProviderScope.containerOf(context).read(authProvider);
      
      // If user is not authenticated and trying to access protected routes
      if (!authState.isAuthenticated && 
          !state.uri.path.startsWith('/auth') && 
          state.uri.path != '/splash') {
        return '/auth/login';
      }
      
      // If user is authenticated and trying to access auth routes
      if (authState.isAuthenticated && state.uri.path.startsWith('/auth')) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      // Splash route
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Auth routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/auth/verify-email',
        name: 'verify-email',
        builder: (context, state) => const VerifyEmailPage(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          // Profile routes
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-profile',
                builder: (context, state) => const EditProfilePage(),
              ),
            ],
          ),
          
          // Sectors routes
          GoRoute(
            path: 'sectors',
            name: 'sectors',
            builder: (context, state) => const SectorsPage(),
            routes: [
              GoRoute(
                path: ':sector',
                name: 'sector-detail',
                builder: (context, state) {
                  final sector = state.pathParameters['sector']!;
                  return SectorDetailPage(sector: sector);
                },
              ),
            ],
          ),
          
          // BTP routes
          GoRoute(
            path: 'btp',
            name: 'btp',
            builder: (context, state) => const BTPHomePage(),
          ),
          
          // Agribusiness routes
          GoRoute(
            path: 'agribusiness',
            name: 'agribusiness',
            builder: (context, state) => const AgribusinessHomePage(),
          ),
          
          // Mining routes
          GoRoute(
            path: 'mining',
            name: 'mining',
            builder: (context, state) => const MiningHomePage(),
          ),
          
          // Divers routes
          GoRoute(
            path: 'divers',
            name: 'divers',
            builder: (context, state) => const DiversHomePage(),
          ),
          
          // Common routes
          GoRoute(
            path: 'search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: 'notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: 'chat',
            name: 'chat-list',
            builder: (context, state) => const ChatListPage(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'chat',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ChatPage(chatId: int.parse(id));
                },
              ),
            ],
          ),
          GoRoute(
            path: 'maps',
            name: 'maps',
            builder: (context, state) => const MapsPage(),
          ),
          GoRoute(
            path: 'camera',
            name: 'camera',
            builder: (context, state) => const CameraPage(),
          ),
          GoRoute(
            path: 'qr-scanner',
            name: 'qr-scanner',
            builder: (context, state) => const QRScannerPage(),
          ),
          GoRoute(
            path: 'payments',
            name: 'payments',
            builder: (context, state) => const PaymentsPage(),
          ),
          GoRoute(
            path: 'analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: 'help',
            name: 'help',
            builder: (context, state) => const HelpPage(),
          ),
          GoRoute(
            path: 'about',
            name: 'about',
            builder: (context, state) => const AboutPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'La page ${state.uri.path} n\'existe pas',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
}
