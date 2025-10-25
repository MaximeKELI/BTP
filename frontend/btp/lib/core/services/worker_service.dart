import 'dart:convert';
import '../config/app_config.dart';
import '../models/worker_model.dart';
import 'package:http/http.dart' as http;

class WorkerService {
  static const String _baseUrl = '${AppConfig.apiBaseUrl}/api/workers/workers';

  // Récupérer la liste des ouvriers avec filtres
  static Future<WorkerListResponse> getWorkers({
    int page = 1,
    int perPage = 20,
    WorkerType? type,
    double? minRating,
    double? maxHourlyRate,
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

      if (type != null) queryParams['type'] = type.value;
      if (minRating != null) queryParams['min_rating'] = minRating.toString();
      if (maxHourlyRate != null) queryParams['max_hourly_rate'] = maxHourlyRate.toString();
      if (isAvailable != null) queryParams['is_available'] = isAvailable.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WorkerListResponse.fromJson(data);
      } else {
        throw Exception('Failed to load workers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading workers: $e');
    }
  }

  // Récupérer un ouvrier spécifique
  static Future<Worker> getWorker(int workerId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$workerId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Worker.fromJson(data);
      } else {
        throw Exception('Failed to load worker: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading worker: $e');
    }
  }

  // Créer un profil d'ouvrier
  static Future<Worker> createWorker({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required WorkerType workerType,
    List<String>? specializations,
    List<String>? skills,
    int? experienceYears,
    required double hourlyRate,
    double? dailyRate,
    String? description,
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
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'worker_type': workerType.value,
        'specializations': specializations ?? [],
        'skills': skills ?? [],
        'experience_years': experienceYears ?? 0,
        'hourly_rate': hourlyRate,
        'daily_rate': dailyRate,
        'description': description,
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
        return Worker.fromJson(data);
      } else {
        throw Exception('Failed to create worker: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating worker: $e');
    }
  }

  // Mettre à jour un profil d'ouvrier
  static Future<Worker> updateWorker({
    required int workerId,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    WorkerType? workerType,
    List<String>? specializations,
    List<String>? skills,
    int? experienceYears,
    double? hourlyRate,
    double? dailyRate,
    String? description,
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
      
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (phone != null) body['phone'] = phone;
      if (email != null) body['email'] = email;
      if (workerType != null) body['worker_type'] = workerType.value;
      if (specializations != null) body['specializations'] = specializations;
      if (skills != null) body['skills'] = skills;
      if (experienceYears != null) body['experience_years'] = experienceYears;
      if (hourlyRate != null) body['hourly_rate'] = hourlyRate;
      if (dailyRate != null) body['daily_rate'] = dailyRate;
      if (description != null) body['description'] = description;
      if (isAvailable != null) body['is_available'] = isAvailable;
      if (availabilitySchedule != null) body['availability_schedule'] = availabilitySchedule;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (address != null) body['address'] = address;
      if (city != null) body['city'] = city;
      if (country != null) body['country'] = country;
      if (postalCode != null) body['postal_code'] = postalCode;

      final response = await http.put(
        Uri.parse('$_baseUrl/$workerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Worker.fromJson(data);
      } else {
        throw Exception('Failed to update worker: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating worker: $e');
    }
  }

  // Récupérer les avis d'un ouvrier
  static Future<WorkerReviewListResponse> getWorkerReviews({
    required int workerId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri = Uri.parse('$_baseUrl/$workerId/reviews').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WorkerReviewListResponse.fromJson(data);
      } else {
        throw Exception('Failed to load worker reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading worker reviews: $e');
    }
  }

  // Créer un avis pour un ouvrier
  static Future<WorkerReview> createWorkerReview({
    required int workerId,
    required int rating,
    String? comment,
    int? workQuality,
    int? punctuality,
    int? communication,
    int? professionalism,
    int? projectId,
    int? bookingId,
    required String accessToken,
  }) async {
    try {
      final body = {
        'rating': rating,
        'comment': comment,
        'work_quality': workQuality,
        'punctuality': punctuality,
        'communication': communication,
        'professionalism': professionalism,
        'project_id': projectId,
        'booking_id': bookingId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/$workerId/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return WorkerReview.fromJson(data);
      } else {
        throw Exception('Failed to create worker review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating worker review: $e');
    }
  }

  // Récupérer les types d'ouvriers
  static Future<List<WorkerTypeOption>> getWorkerTypes() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/types'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final types = (data['types'] as List)
            .map((type) => WorkerTypeOption.fromJson(type))
            .toList();
        return types;
      } else {
        throw Exception('Failed to load worker types: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading worker types: $e');
    }
  }
}

class WorkerListResponse {
  final List<Worker> workers;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  const WorkerListResponse({
    required this.workers,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory WorkerListResponse.fromJson(Map<String, dynamic> json) {
    return WorkerListResponse(
      workers: (json['workers'] as List)
          .map((worker) => Worker.fromJson(worker as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      pages: json['pages'] as int,
    );
  }
}

class WorkerReviewListResponse {
  final List<WorkerReview> reviews;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  const WorkerReviewListResponse({
    required this.reviews,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory WorkerReviewListResponse.fromJson(Map<String, dynamic> json) {
    return WorkerReviewListResponse(
      reviews: (json['reviews'] as List)
          .map((review) => WorkerReview.fromJson(review as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      pages: json['pages'] as int,
    );
  }
}

class WorkerTypeOption {
  final String value;
  final String label;

  const WorkerTypeOption({
    required this.value,
    required this.label,
  });

  factory WorkerTypeOption.fromJson(Map<String, dynamic> json) {
    return WorkerTypeOption(
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }
}
