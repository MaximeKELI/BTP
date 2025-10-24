import 'core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/theme_config.dart';
import 'core/config/route_config.dart';
import 'core/services/storage_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/location_service.dart';
import 'core/providers/language_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Démarrage de l\'application BTP Multi-Sector (Mode Développement)');
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await StorageService.init();
  
  // Initialize services (sans Firebase)
  await NotificationService.init();
  await LocationService.init();
  
  // Request permissions
  await _requestPermissions();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Run the app
  runApp(
    const ProviderScope(
      child: BTPMultiSectorApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  // Request location permission
  await Permission.location.request();
  
  // Request camera permission
  await Permission.camera.request();
  
  // Request notification permission
  await Permission.notification.request();
  
  print('✅ Permissions demandées');
}

class BTPMultiSectorApp extends ConsumerWidget {
  const BTPMultiSectorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final languageState = ref.watch(languageProvider);
    
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: themeState.themeMode,
      locale: languageState.locale,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
