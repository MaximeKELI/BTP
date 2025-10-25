import 'dart:io';
import 'firebase_options.dart';
import 'core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/theme_config.dart';
import 'core/config/route_config.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/location_service.dart';
import 'core/providers/language_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (optional for development)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed (this is OK for development): $e');
  }
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await StorageService.init();
  
  // Initialize services
  ApiService.init();
  await NotificationService.init();
  await LocationService.init();
  
  // Request permissions
  await _requestPermissions();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: BTPMultiSectorApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  // Only request permissions on mobile platforms (Android/iOS)
  // Linux doesn't support permission_handler natively
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      await [
        Permission.location,
        Permission.camera,
        Permission.storage,
        Permission.notification,
        Permission.microphone,
      ].request();
    } catch (e) {
      print('Permission request failed: $e');
    }
  } else {
    print('Skipping permission requests on ${Platform.operatingSystem}');
  }
}

class BTPMultiSectorApp extends ConsumerWidget {
  const BTPMultiSectorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: themeMode.themeMode,
      locale: locale.locale,
      supportedLocales: AppConfig.supportedLocales,
      localizationsDelegates: AppConfig.localizationsDelegates,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}