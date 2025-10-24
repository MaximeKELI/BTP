import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';
import 'core/config/route_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Démarrage de l\'application BTP Multi-Sector (Mode Minimal)');
  
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
  runApp(const BTPMultiSectorApp());
}

class BTPMultiSectorApp extends StatelessWidget {
  const BTPMultiSectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.system,
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
