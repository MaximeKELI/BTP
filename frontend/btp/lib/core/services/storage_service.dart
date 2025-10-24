import 'dart:convert';
import '../config/app_config.dart';

// Version simplifiée sans dépendances externes
class StorageService {
  static final Map<String, dynamic> _storage = {};
  
  static Future<void> init() async {
    // Initialize storage
    print('StorageService initialized');
  }
  
  // String methods
  static Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }
  
  static String? getString(String key) {
    return _storage[key] as String?;
  }
  
  static Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }
  
  static int? getInt(String key) {
    return _storage[key] as int?;
  }
  
  static Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }
  
  static bool? getBool(String key) {
    return _storage[key] as bool?;
  }
  
  static Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }
  
  static double? getDouble(String key) {
    return _storage[key] as double?;
  }
  
  static Future<bool> setStringList(String key, List<String> value) async {
    _storage[key] = value;
    return true;
  }
  
  static List<String>? getStringList(String key) {
    return _storage[key] as List<String>?;
  }
  
  static Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }
  
  static Future<bool> clear() async {
    _storage.clear();
    return true;
  }
  
  // Hive methods for complex data
  static Future<void> put(String key, dynamic value) async {
    _storage[key] = value;
  }
  
  static T? get<T>(String key) {
    return _storage[key] as T?;
  }
  
  static Future<void> delete(String key) async {
    _storage.remove(key);
  }
  
  static Future<void> clearBox() async {
    _storage.clear();
  }
  
  // JSON methods
  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }
  
  static Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
  
  // User data methods
  static Future<bool> saveUserData(Map<String, dynamic> userData) async {
    return await setJson('user_data', userData);
  }
  
  static Map<String, dynamic>? getUserData() {
    return getJson('user_data');
  }
  
  static Future<bool> clearUserData() async {
    return await remove('user_data');
  }
  
  // Auth token methods
  static Future<bool> saveAuthToken(String token) async {
    return await setString('auth_token', token);
  }
  
  static String? getAuthToken() {
    return getString('auth_token');
  }
  
  static Future<bool> clearAuthToken() async {
    return await remove('auth_token');
  }
  
  // Refresh token methods
  static Future<bool> saveRefreshToken(String token) async {
    return await setString('refresh_token', token);
  }
  
  static String? getRefreshToken() {
    return getString('refresh_token');
  }
  
  static Future<bool> clearRefreshToken() async {
    return await remove('refresh_token');
  }
  
  // Theme methods
  static Future<bool> saveThemeMode(String themeMode) async {
    return await setString('theme_mode', themeMode);
  }
  
  static String getThemeMode() {
    return getString('theme_mode') ?? 'system';
  }
  
  // Language methods
  static Future<bool> saveLanguage(String languageCode) async {
    return await setString('language', languageCode);
  }
  
  static String getLanguage() {
    return getString('language') ?? 'fr';
  }
  
  // First launch methods
  static Future<bool> setFirstLaunch(bool isFirstLaunch) async {
    return await setBool('first_launch', isFirstLaunch);
  }
  
  static bool isFirstLaunch() {
    return getBool('first_launch') ?? true;
  }
  
  // Notification settings
  static Future<bool> setNotificationEnabled(bool enabled) async {
    return await setBool('notifications_enabled', enabled);
  }
  
  static bool isNotificationEnabled() {
    return getBool('notifications_enabled') ?? true;
  }
  
  // Location settings
  static Future<bool> setLocationEnabled(bool enabled) async {
    return await setBool('location_enabled', enabled);
  }
  
  static bool isLocationEnabled() {
    return getBool('location_enabled') ?? true;
  }
  
  // Cache methods
  static Future<void> saveCache(String key, dynamic data) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await put('cache_$key', cacheData);
  }
  
  static T? getCache<T>(String key) {
    final cacheData = get<Map>('cache_$key');
    if (cacheData != null) {
      final timestamp = cacheData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      final age = now - timestamp;
      
      // Check if cache is still valid
      if (age < AppConfig.cacheExpiration.inMilliseconds) {
        return cacheData['data'] as T?;
      } else {
        // Cache expired, remove it
        delete('cache_$key');
      }
    }
    return null;
  }
  
  static Future<void> clearCache() async {
    final keys = _storage.keys.where((key) => key.toString().startsWith('cache_'));
    for (final key in keys) {
      await delete(key);
    }
  }
  
  // Offline data methods
  static Future<void> saveOfflineData(String key, dynamic data) async {
    await put('offline_$key', data);
  }
  
  static T? getOfflineData<T>(String key) {
    return get<T>('offline_$key');
  }
  
  static Future<void> clearOfflineData() async {
    final keys = _storage.keys.where((key) => key.toString().startsWith('offline_'));
    for (final key in keys) {
      await delete(key);
    }
  }
  
  // Search history methods
  static Future<void> addSearchHistory(String query) async {
    final history = getStringList('search_history') ?? [];
    history.remove(query); // Remove if already exists
    history.insert(0, query); // Add to beginning
    
    // Keep only last 20 searches
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    
    await setStringList('search_history', history);
  }
  
  static List<String> getSearchHistory() {
    return getStringList('search_history') ?? [];
  }
  
  static Future<void> clearSearchHistory() async {
    await remove('search_history');
  }
  
  // Favorites methods
  static Future<void> addFavorite(String type, String id) async {
    final favorites = getStringList('favorites_$type') ?? [];
    if (!favorites.contains(id)) {
      favorites.add(id);
      await setStringList('favorites_$type', favorites);
    }
  }
  
  static Future<void> removeFavorite(String type, String id) async {
    final favorites = getStringList('favorites_$type') ?? [];
    favorites.remove(id);
    await setStringList('favorites_$type', favorites);
  }
  
  static List<String> getFavorites(String type) {
    return getStringList('favorites_$type') ?? [];
  }
  
  static bool isFavorite(String type, String id) {
    final favorites = getFavorites(type);
    return favorites.contains(id);
  }
  
  // Settings methods
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await setJson('app_settings', settings);
  }
  
  static Map<String, dynamic> getSettings() {
    return getJson('app_settings') ?? {};
  }
  
  // Storage info
  static Future<Map<String, int>> getStorageInfo() async {
    final prefsSize = await _getSharedPreferencesSize();
    final boxSize = _storage.length;
    
    return {
      'prefs_size': prefsSize,
      'box_size': boxSize,
      'total_size': prefsSize + boxSize,
    };
  }
  
  static Future<int> _getSharedPreferencesSize() async {
    // This is an approximation
    int size = 0;
    for (final key in _storage.keys) {
      size += key.length;
      final value = _storage[key];
      if (value is String) {
        size += value.length;
      } else if (value is List<String>) {
        size += value.join().length;
      }
    }
    return size;
  }
}