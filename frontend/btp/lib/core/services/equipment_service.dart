import 'dart:convert';
import '../config/app_config.dart';
import 'package:http/http.dart' as http;
import '../models/equipment_model.dart';

class EquipmentService {
  static const String _baseUrl = '${AppConfig.apiBaseUrl}/api/equipment/equipment';

  // Récupérer la liste des équipements avec filtres
  static Future<EquipmentListResponse> getEquipment({
    int page = 1,
    int perPage = 20,
    EquipmentCategory? category,
    double? minRating,
    double? maxDailyRate,
    bool? isAvailable,
    String? search,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (category != null) queryParams['category'] = category.value;
      if (minRating != null) queryParams['min_rating'] = minRating.toString();
      if (maxDailyRate != null) queryParams['max_daily_rate'] = maxDailyRate.toString();
      if (isAvailable != null) queryParams['is_available'] = isAvailable.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return EquipmentListResponse.fromJson(data);
      } else {
        throw Exception('Failed to load equipment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading equipment: $e');
    }
  }

  // Récupérer un équipement spécifique
  static Future<Equipment> getEquipment(int equipmentId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$equipmentId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Equipment.fromJson(data);
      } else {
        throw Exception('Failed to load equipment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading equipment: $e');
    }
  }

  // Créer un équipement
  static Future<Equipment> createEquipment({
    required String name,
    String? description,
    required EquipmentCategory category,
    String? brand,
    String? model,
    String? serialNumber,
    Map<String, dynamic>? specifications,
    Map<String, dynamic>? dimensions,
    double? weight,
    String? powerRating,
    String? fuelType,
    double? hourlyRate,
    double? dailyRate,
    double? weeklyRate,
    double? monthlyRate,
    double? depositAmount,
    List<String>? images,
    List<String>? documents,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    required String accessToken,
  }) async {
    try {
      final body = {
        'name': name,
        'description': description,
        'category': category.value,
        'brand': brand,
        'model': model,
        'serial_number': serialNumber,
        'specifications': specifications ?? {},
        'dimensions': dimensions,
        'weight': weight,
        'power_rating': powerRating,
        'fuel_type': fuelType,
        'hourly_rate': hourlyRate,
        'daily_rate': dailyRate,
        'weekly_rate': weeklyRate,
        'monthly_rate': monthlyRate,
        'deposit_amount': depositAmount,
        'images': images ?? [],
        'documents': documents ?? [],
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'city': city,
        'country': country,
        'postal_code': postalCode,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Equipment.fromJson(data);
      } else {
        throw Exception('Failed to create equipment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating equipment: $e');
    }
  }

  // Mettre à jour un équipement
  static Future<Equipment> updateEquipment({
    required int equipmentId,
    String? name,
    String? description,
    EquipmentCategory? category,
    String? brand,
    String? model,
    String? serialNumber,
    Map<String, dynamic>? specifications,
    Map<String, dynamic>? dimensions,
    double? weight,
    String? powerRating,
    String? fuelType,
    double? hourlyRate,
    double? dailyRate,
    double? weeklyRate,
    double? monthlyRate,
    double? depositAmount,
    List<String>? images,
    List<String>? documents,
    bool? isAvailable,
    Map<String, dynamic>? availabilitySchedule,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    required String accessToken,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (category != null) body['category'] = category.value;
      if (brand != null) body['brand'] = brand;
      if (model != null) body['model'] = model;
      if (serialNumber != null) body['serial_number'] = serialNumber;
      if (specifications != null) body['specifications'] = specifications;
      if (dimensions != null) body['dimensions'] = dimensions;
      if (weight != null) body['weight'] = weight;
      if (powerRating != null) body['power_rating'] = powerRating;
      if (fuelType != null) body['fuel_type'] = fuelType;
      if (hourlyRate != null) body['hourly_rate'] = hourlyRate;
      if (dailyRate != null) body['daily_rate'] = dailyRate;
      if (weeklyRate != null) body['weekly_rate'] = weeklyRate;
      if (monthlyRate != null) body['monthly_rate'] = monthlyRate;
      if (depositAmount != null) body['deposit_amount'] = depositAmount;
      if (images != null) body['images'] = images;
      if (documents != null) body['documents'] = documents;
      if (isAvailable != null) body['is_available'] = isAvailable;
      if (availabilitySchedule != null) body['availability_schedule'] = availabilitySchedule;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (address != null) body['address'] = address;
      if (city != null) body['city'] = city;
      if (country != null) body['country'] = country;
      if (postalCode != null) body['postal_code'] = postalCode;

      final response = await http.put(
        Uri.parse('$_baseUrl/$equipmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Equipment.fromJson(data);
      } else {
        throw Exception('Failed to update equipment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating equipment: $e');
    }
  }

  // Récupérer les avis d'un équipement
  static Future<EquipmentReviewListResponse> getEquipmentReviews({
    required int equipmentId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri = Uri.parse('$_baseUrl/$equipmentId/reviews').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return EquipmentReviewListResponse.fromJson(data);
      } else {
        throw Exception('Failed to load equipment reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading equipment reviews: $e');
    }
  }

  // Créer un avis pour un équipement
  static Future<EquipmentReview> createEquipmentReview({
    required int equipmentId,
    required int rating,
    String? comment,
    int? conditionRating,
    int? easeOfUse,
    int? valueForMoney,
    int? bookingId,
    required String accessToken,
  }) async {
    try {
      final body = {
        'rating': rating,
        'comment': comment,
        'condition_rating': conditionRating,
        'ease_of_use': easeOfUse,
        'value_for_money': valueForMoney,
        'booking_id': bookingId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/$equipmentId/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return EquipmentReview.fromJson(data);
      } else {
        throw Exception('Failed to create equipment review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating equipment review: $e');
    }
  }

  // Récupérer les catégories d'équipements
  static Future<List<EquipmentCategoryOption>> getEquipmentCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = (data['categories'] as List)
            .map((category) => EquipmentCategoryOption.fromJson(category))
            .toList();
        return categories;
      } else {
        throw Exception('Failed to load equipment categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading equipment categories: $e');
    }
  }
}

class EquipmentListResponse {
  final List<Equipment> equipment;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  const EquipmentListResponse({
    required this.equipment,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory EquipmentListResponse.fromJson(Map<String, dynamic> json) {
    return EquipmentListResponse(
      equipment: (json['equipment'] as List)
          .map((eq) => Equipment.fromJson(eq as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      pages: json['pages'] as int,
    );
  }
}

class EquipmentReviewListResponse {
  final List<EquipmentReview> reviews;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  const EquipmentReviewListResponse({
    required this.reviews,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory EquipmentReviewListResponse.fromJson(Map<String, dynamic> json) {
    return EquipmentReviewListResponse(
      reviews: (json['reviews'] as List)
          .map((review) => EquipmentReview.fromJson(review as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      pages: json['pages'] as int,
    );
  }
}

class EquipmentCategoryOption {
  final String value;
  final String label;

  const EquipmentCategoryOption({
    required this.value,
    required this.label,
  });

  factory EquipmentCategoryOption.fromJson(Map<String, dynamic> json) {
    return EquipmentCategoryOption(
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }
}
