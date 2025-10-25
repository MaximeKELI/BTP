import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppConfig {
  static const String appName = 'BTP Multi-Sector';
  static const String appVersion = '1.0.0';
  static const String apiBaseUrl = 'http://localhost:5000/api';
  static const String apiVersion = '';
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'), // French
    Locale('en', 'US'), // English
    Locale('ar', 'DZ'), // Arabic (Algeria)
  ];
  
  // Localization delegates
  static const List<LocalizationsDelegate> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  // API Endpoints
  static const Map<String, String> endpoints = {
    'auth': '/auth',
    'users': '/users',
    'btp': '/btp',
    'agribusiness': '/agribusiness',
    'mining': '/mining',
    'divers': '/divers',
    'common': '/common',
  };
  
  // Sector configurations
  static const Map<String, Map<String, dynamic>> sectors = {
    'btp': {
      'name': 'Bâtiments et Travaux Publics',
      'icon': 'construction',
      'color': 0xFF2196F3,
      'description': 'Construction, infrastructure, travaux publics',
    },
    'agribusiness': {
      'name': 'Agribusiness',
      'icon': 'agriculture',
      'color': 0xFF4CAF50,
      'description': 'Agriculture, élevage, transformation alimentaire',
    },
    'mining': {
      'name': 'Exploitation Minière',
      'icon': 'mining',
      'color': 0xFFFF9800,
      'description': 'Extraction, géologie, ressources naturelles',
    },
    'divers': {
      'name': 'Divers',
      'icon': 'business',
      'color': 0xFF9C27B0,
      'description': 'Services généraux, consulting, autres secteurs',
    },
  };
  
  // User roles
  static const Map<String, String> userRoles = {
    'admin': 'Administrateur',
    'manager': 'Manager',
    'worker': 'Ouvrier',
    'client': 'Client',
    'supplier': 'Fournisseur',
    'investor': 'Investisseur',
  };
  
  // File upload limits
  static const int maxFileSize = 16 * 1024 * 1024; // 16MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];
  
  // Map configuration
  static const double defaultZoom = 15.0;
  static const double maxZoom = 20.0;
  static const double minZoom = 5.0;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Validation rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 1000;
  
  // Notification settings
  static const Duration notificationTimeout = Duration(seconds: 5);
  static const int maxNotificationRetries = 3;
  
  // Location settings
  static const Duration locationTimeout = Duration(seconds: 10);
  static const double locationAccuracy = 10.0; // meters
  static const Duration locationUpdateInterval = Duration(minutes: 1);
  
  // Payment settings
  static const List<String> supportedCurrencies = ['XOF', 'USD', 'EUR', 'GBP'];
  static const String defaultCurrency = 'XOF';
  
  // Theme settings
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double appBarElevation = 0.0;
  
  // Grid settings
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 1.2;
  static const double gridSpacing = 16.0;
  
  // List settings
  static const double listItemHeight = 80.0;
  static const double listItemSpacing = 8.0;
  
  // Button settings
  static const double buttonHeight = 48.0;
  static const double buttonBorderRadius = 8.0;
  
  // Input field settings
  static const double inputFieldHeight = 56.0;
  static const double inputFieldBorderRadius = 8.0;
  
  // Icon settings
  static const double defaultIconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}
