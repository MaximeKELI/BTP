// Modèles pour les matériels/équipements
class Equipment {
  final int id;
  final String name;
  final String? description;
  final EquipmentCategory category;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final int ownerId;
  final Map<String, dynamic> specifications;
  final Map<String, dynamic>? dimensions;
  final double? weight;
  final String? powerRating;
  final String? fuelType;
  final double? hourlyRate;
  final double? dailyRate;
  final double? weeklyRate;
  final double? monthlyRate;
  final double? depositAmount;
  final EquipmentStatus status;
  final bool isAvailable;
  final Map<String, dynamic>? availabilitySchedule;
  final List<String> images;
  final List<String> documents;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String? maintenanceNotes;
  final double rating;
  final int totalReviews;
  final int totalRentals;
  final EquipmentLocation? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Equipment({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.brand,
    this.model,
    this.serialNumber,
    required this.ownerId,
    required this.specifications,
    this.dimensions,
    this.weight,
    this.powerRating,
    this.fuelType,
    this.hourlyRate,
    this.dailyRate,
    this.weeklyRate,
    this.monthlyRate,
    this.depositAmount,
    required this.status,
    required this.isAvailable,
    this.availabilitySchedule,
    required this.images,
    required this.documents,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.maintenanceNotes,
    required this.rating,
    required this.totalReviews,
    required this.totalRentals,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: EquipmentCategory.fromString(json['category'] as String),
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serial_number'] as String?,
      ownerId: json['owner_id'] as int,
      specifications: Map<String, dynamic>.from(json['specifications'] as Map? ?? {}),
      dimensions: json['dimensions'] != null ? Map<String, dynamic>.from(json['dimensions'] as Map) : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      powerRating: json['power_rating'] as String?,
      fuelType: json['fuel_type'] as String?,
      hourlyRate: json['hourly_rate'] != null ? (json['hourly_rate'] as num).toDouble() : null,
      dailyRate: json['daily_rate'] != null ? (json['daily_rate'] as num).toDouble() : null,
      weeklyRate: json['weekly_rate'] != null ? (json['weekly_rate'] as num).toDouble() : null,
      monthlyRate: json['monthly_rate'] != null ? (json['monthly_rate'] as num).toDouble() : null,
      depositAmount: json['deposit_amount'] != null ? (json['deposit_amount'] as num).toDouble() : null,
      status: EquipmentStatus.fromString(json['status'] as String),
      isAvailable: json['is_available'] as bool? ?? true,
      availabilitySchedule: json['availability_schedule'] as Map<String, dynamic>?,
      images: List<String>.from(json['images'] as List? ?? []),
      documents: List<String>.from(json['documents'] as List? ?? []),
      lastMaintenanceDate: json['last_maintenance_date'] != null 
          ? DateTime.parse(json['last_maintenance_date'] as String) 
          : null,
      nextMaintenanceDate: json['next_maintenance_date'] != null 
          ? DateTime.parse(json['next_maintenance_date'] as String) 
          : null,
      maintenanceNotes: json['maintenance_notes'] as String?,
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalRentals: json['total_rentals'] as int? ?? 0,
      location: json['location'] != null 
          ? EquipmentLocation.fromJson(json['location'] as Map<String, dynamic>) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.value,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'owner_id': ownerId,
      'specifications': specifications,
      'dimensions': dimensions,
      'weight': weight,
      'power_rating': powerRating,
      'fuel_type': fuelType,
      'hourly_rate': hourlyRate,
      'daily_rate': dailyRate,
      'weekly_rate': weeklyRate,
      'monthly_rate': monthlyRate,
      'deposit_amount': depositAmount,
      'status': status.value,
      'is_available': isAvailable,
      'availability_schedule': availabilitySchedule,
      'images': images,
      'documents': documents,
      'last_maintenance_date': lastMaintenanceDate?.toIso8601String(),
      'next_maintenance_date': nextMaintenanceDate?.toIso8601String(),
      'maintenance_notes': maintenanceNotes,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_rentals': totalRentals,
      'location': location?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => model != null ? '$brand $model' : name;
  String get priceRange {
    if (hourlyRate != null) return '${hourlyRate!.toStringAsFixed(0)} FCFA/h';
    if (dailyRate != null) return '${dailyRate!.toStringAsFixed(0)} FCFA/jour';
    if (weeklyRate != null) return '${weeklyRate!.toStringAsFixed(0)} FCFA/semaine';
    if (monthlyRate != null) return '${monthlyRate!.toStringAsFixed(0)} FCFA/mois';
    return 'Prix sur demande';
  }

  Equipment copyWith({
    int? id,
    String? name,
    String? description,
    EquipmentCategory? category,
    String? brand,
    String? model,
    String? serialNumber,
    int? ownerId,
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
    EquipmentStatus? status,
    bool? isAvailable,
    Map<String, dynamic>? availabilitySchedule,
    List<String>? images,
    List<String>? documents,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String? maintenanceNotes,
    double? rating,
    int? totalReviews,
    int? totalRentals,
    EquipmentLocation? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      ownerId: ownerId ?? this.ownerId,
      specifications: specifications ?? this.specifications,
      dimensions: dimensions ?? this.dimensions,
      weight: weight ?? this.weight,
      powerRating: powerRating ?? this.powerRating,
      fuelType: fuelType ?? this.fuelType,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      dailyRate: dailyRate ?? this.dailyRate,
      weeklyRate: weeklyRate ?? this.weeklyRate,
      monthlyRate: monthlyRate ?? this.monthlyRate,
      depositAmount: depositAmount ?? this.depositAmount,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      availabilitySchedule: availabilitySchedule ?? this.availabilitySchedule,
      images: images ?? this.images,
      documents: documents ?? this.documents,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      maintenanceNotes: maintenanceNotes ?? this.maintenanceNotes,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalRentals: totalRentals ?? this.totalRentals,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class EquipmentLocation {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? location;

  const EquipmentLocation({
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.location,
  });

  factory EquipmentLocation.fromJson(Map<String, dynamic> json) {
    return EquipmentLocation(
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
      'postal_code': postalCode,
      'location': location,
    };
  }
}

enum EquipmentCategory {
  excavation('excavation', 'Terrassement'),
  concrete('concrete', 'Béton'),
  lifting('lifting', 'Levage'),
  transport('transport', 'Transport'),
  electrical('electrical', 'Électrique'),
  plumbing('plumbing', 'Plomberie'),
  painting('painting', 'Peinture'),
  welding('welding', 'Soudure'),
  measurement('measurement', 'Mesure'),
  safety('safety', 'Sécurité'),
  other('other', 'Autre');

  const EquipmentCategory(this.value, this.label);
  final String value;
  final String label;

  static EquipmentCategory fromString(String value) {
    return EquipmentCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => EquipmentCategory.other,
    );
  }
}

enum EquipmentStatus {
  available('available', 'Disponible'),
  rented('rented', 'Loué'),
  maintenance('maintenance', 'Maintenance'),
  outOfService('out_of_service', 'Hors service');

  const EquipmentStatus(this.value, this.label);
  final String value;
  final String label;

  static EquipmentStatus fromString(String value) {
    return EquipmentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => EquipmentStatus.outOfService,
    );
  }
}

class EquipmentReview {
  final int id;
  final int equipmentId;
  final int clientId;
  final int? bookingId;
  final int rating;
  final String? comment;
  final int? conditionRating;
  final int? easeOfUse;
  final int? valueForMoney;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EquipmentReview({
    required this.id,
    required this.equipmentId,
    required this.clientId,
    this.bookingId,
    required this.rating,
    this.comment,
    this.conditionRating,
    this.easeOfUse,
    this.valueForMoney,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EquipmentReview.fromJson(Map<String, dynamic> json) {
    return EquipmentReview(
      id: json['id'] as int,
      equipmentId: json['equipment_id'] as int,
      clientId: json['client_id'] as int,
      bookingId: json['booking_id'] as int?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      conditionRating: json['condition_rating'] as int?,
      easeOfUse: json['ease_of_use'] as int?,
      valueForMoney: json['value_for_money'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipment_id': equipmentId,
      'client_id': clientId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'condition_rating': conditionRating,
      'ease_of_use': easeOfUse,
      'value_for_money': valueForMoney,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
