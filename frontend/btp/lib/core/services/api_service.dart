import 'dart:io';
import 'dart:convert';
import 'storage_service.dart';
import '../config/app_config.dart';
import 'package:http/http.dart' as http;

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;
  
  ApiResponse._({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });
  
  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse._(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }
  
  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse._(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
  
  bool get isSuccess => success;
  bool get isError => !success;
}

class ApiService {
  static late String _baseUrl;
  
  static void init() {
    _baseUrl = '${AppConfig.apiBaseUrl}/${AppConfig.apiVersion}';
  }
  
  // GET request
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool useCache = false,
  }) async {
    try {
      final cacheKey = _getCacheKey('GET', endpoint, queryParameters);
      
      if (useCache) {
        final cachedData = StorageService.getCache<T>(cacheKey);
        if (cachedData != null) {
          return ApiResponse.success(cachedData);
        }
      }
      
      final uri = Uri.parse('$_baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map((key, value) => MapEntry(key, value.toString())),
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
      );
      
      if (response.statusCode == 200) {
        final data = _parseResponse<T>(jsonDecode(response.body));
        
        if (useCache) {
          StorageService.saveCache(cacheKey, data);
        }
        
        return ApiResponse.success(data, statusCode: response.statusCode);
      } else {
        return ApiResponse.error(
          'Erreur HTTP ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Erreur inattendue: ${e.toString()}');
    }
  }
  
  // POST request
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map((key, value) => MapEntry(key, value.toString())),
      );
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        body: data != null ? jsonEncode(data) : null,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = _parseResponse<T>(jsonDecode(response.body));
        return ApiResponse.success(result, statusCode: response.statusCode);
      } else {
        return ApiResponse.error(
          'Erreur HTTP ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Erreur inattendue: ${e.toString()}');
    }
  }
  
  // PUT request
  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map((key, value) => MapEntry(key, value.toString())),
      );
      
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        body: data != null ? jsonEncode(data) : null,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = _parseResponse<T>(jsonDecode(response.body));
        return ApiResponse.success(result, statusCode: response.statusCode);
      } else {
        return ApiResponse.error(
          'Erreur HTTP ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Erreur inattendue: ${e.toString()}');
    }
  }
  
  // DELETE request
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map((key, value) => MapEntry(key, value.toString())),
      );
      
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = _parseResponse<T>(jsonDecode(response.body));
        return ApiResponse.success(result, statusCode: response.statusCode);
      } else {
        return ApiResponse.error(
          'Erreur HTTP ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Erreur inattendue: ${e.toString()}');
    }
  }
  
  // Parse response data
  static T _parseResponse<T>(dynamic data) {
    if (data is T) {
      return data;
    } else if (data is Map<String, dynamic>) {
      if (T == Map<String, dynamic>) {
        return data as T;
      } else if (data.containsKey('data')) {
        return data['data'] as T;
      }
    } else if (data is List && T == List) {
      return data as T;
    }
    
    return data as T;
  }
  
  // Get cache key
  static String _getCacheKey(String method, String endpoint, Map<String, dynamic>? queryParameters) {
    final queryString = queryParameters?.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&') ?? '';
    return '${method}_${endpoint}_$queryString';
  }
  
  // Clear cache
  static Future<void> clearCache() async {
    await StorageService.clearCache();
  }
  
  // Check internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}