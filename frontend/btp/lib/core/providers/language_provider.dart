import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Language state
class LanguageState {
  final Locale locale;
  final String languageCode;
  final String countryCode;

  const LanguageState({
    required this.locale,
    required this.languageCode,
    required this.countryCode,
  });

  LanguageState copyWith({
    Locale? locale,
    String? languageCode,
    String? countryCode,
  }) {
    return LanguageState(
      locale: locale ?? this.locale,
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}

// Language notifier
class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier() : super(const LanguageState(
    locale: Locale('fr', 'FR'),
    languageCode: 'fr',
    countryCode: 'FR',
  ));

  Future<void> initializeLanguage() async {
    final savedLanguage = StorageService.getLanguage();
    final parts = savedLanguage.split('_');
    final languageCode = parts[0];
    final countryCode = parts.length > 1 ? parts[1] : 'FR';
    
    final locale = Locale(languageCode, countryCode);
    
    state = LanguageState(
      locale: locale,
      languageCode: languageCode,
      countryCode: countryCode,
    );
  }

  Future<void> setLanguage(String languageCode, {String? countryCode}) async {
    final country = countryCode ?? _getDefaultCountryCode(languageCode);
    final locale = Locale(languageCode, country);
    
    await StorageService.saveLanguage('${languageCode}_$country');
    
    state = LanguageState(
      locale: locale,
      languageCode: languageCode,
      countryCode: country,
    );
  }

  Future<void> setLocale(Locale locale) async {
    await setLanguage(locale.languageCode, countryCode: locale.countryCode);
  }

  String _getDefaultCountryCode(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'FR';
      case 'en':
        return 'US';
      case 'ar':
        return 'DZ';
      default:
        return 'FR';
    }
  }

  Future<void> setFrench() async {
    await setLanguage('fr', countryCode: 'FR');
  }

  Future<void> setEnglish() async {
    await setLanguage('en', countryCode: 'US');
  }

  Future<void> setArabic() async {
    await setLanguage('ar', countryCode: 'DZ');
  }

  bool isRTL() {
    return state.languageCode == 'ar';
  }

  TextDirection get textDirection {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }
}

// Providers
final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
  return LanguageNotifier();
});

final localeProvider = Provider<Locale>((ref) {
  return ref.watch(languageProvider).locale;
});

final languageCodeProvider = Provider<String>((ref) {
  return ref.watch(languageProvider).languageCode;
});

final isRTLProvider = Provider<bool>((ref) {
  return ref.watch(languageProvider).languageCode == 'ar';
});

final textDirectionProvider = Provider<TextDirection>((ref) {
  final languageCode = ref.watch(languageProvider).languageCode;
  return languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
});

// Language names
final languageNames = {
  'fr': 'Français',
  'en': 'English',
  'ar': 'العربية',
};

// Country flags
final countryFlags = {
  'FR': '🇫🇷',
  'US': '🇺🇸',
  'DZ': '🇩🇿',
};