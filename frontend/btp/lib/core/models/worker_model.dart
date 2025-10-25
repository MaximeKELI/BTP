// Modèles pour les ouvriers/artisans
class Worker {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String? avatarUrl;
  final WorkerType workerType;
  final List<String> specializations;
  final List<String> skills;
  final int experienceYears;
  final double hourlyRate;
  final double? dailyRate;
  final String? description;
  final WorkerStatus status;
  final bool isAvailable;
  final Map<String, dynamic>? availabilitySchedule;
  final double rating;
  final int totalReviews;
  final int completedProjects;
  final List<String> certifications;
  final List<String> portfolioImages;
  final String? identityDocument;
  final String? bankAccount;
  final String? bankName;
  final WorkerLocation? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Worker({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.avatarUrl,
    required this.workerType,
    required this.specializations,
    required this.skills,
    required this.experienceYears,
    required this.hourlyRate,
    this.dailyRate,
    this.description,
    required this.status,
    required this.isAvailable,
    this.availabilitySchedule,
    required this.rating,
    required this.totalReviews,
    required this.completedProjects,
    required this.certifications,
    required this.portfolioImages,
    this.identityDocument,
    this.bankAccount,
    this.bankName,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      workerType: WorkerType.fromString(json['worker_type'] as String),
      specializations: List<String>.from(json['specializations'] as List? ?? []),
      skills: List<String>.from(json['skills'] as List? ?? []),
      experienceYears: json['experience_years'] as int? ?? 0,
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      dailyRate: json['daily_rate'] != null ? (json['daily_rate'] as num).toDouble() : null,
      description: json['description'] as String?,
      status: WorkerStatus.fromString(json['status'] as String),
      isAvailable: json['is_available'] as bool? ?? true,
      availabilitySchedule: json['availability_schedule'] as Map<String, dynamic>?,
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] as int? ?? 0,
      completedProjects: json['completed_projects'] as int? ?? 0,
      certifications: List<String>.from(json['certifications'] as List? ?? []),
      portfolioImages: List<String>.from(json['portfolio_images'] as List? ?? []),
      identityDocument: json['identity_document'] as String?,
      bankAccount: json['bank_account'] as String?,
      bankName: json['bank_name'] as String?,
      location: json['location'] != null ? WorkerLocation.fromJson(json['location'] as Map<String, dynamic>) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'worker_type': workerType.value,
      'specializations': specializations,
      'skills': skills,
      'experience_years': experienceYears,
      'hourly_rate': hourlyRate,
      'daily_rate': dailyRate,
      'description': description,
      'status': status.value,
      'is_available': isAvailable,
      'availability_schedule': availabilitySchedule,
      'rating': rating,
      'total_reviews': totalReviews,
      'completed_projects': completedProjects,
      'certifications': certifications,
      'portfolio_images': portfolioImages,
      'identity_document': identityDocument,
      'bank_account': bankAccount,
      'bank_name': bankName,
      'location': location?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
  
  Worker copyWith({
    int? id,
    int? userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? avatarUrl,
    WorkerType? workerType,
    List<String>? specializations,
    List<String>? skills,
    int? experienceYears,
    double? hourlyRate,
    double? dailyRate,
    String? description,
    WorkerStatus? status,
    bool? isAvailable,
    Map<String, dynamic>? availabilitySchedule,
    double? rating,
    int? totalReviews,
    int? completedProjects,
    List<String>? certifications,
    List<String>? portfolioImages,
    String? identityDocument,
    String? bankAccount,
    String? bankName,
    WorkerLocation? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Worker(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      workerType: workerType ?? this.workerType,
      specializations: specializations ?? this.specializations,
      skills: skills ?? this.skills,
      experienceYears: experienceYears ?? this.experienceYears,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      dailyRate: dailyRate ?? this.dailyRate,
      description: description ?? this.description,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      availabilitySchedule: availabilitySchedule ?? this.availabilitySchedule,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      completedProjects: completedProjects ?? this.completedProjects,
      certifications: certifications ?? this.certifications,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      identityDocument: identityDocument ?? this.identityDocument,
      bankAccount: bankAccount ?? this.bankAccount,
      bankName: bankName ?? this.bankName,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WorkerLocation {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? location;

  const WorkerLocation({
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.location,
  });

  factory WorkerLocation.fromJson(Map<String, dynamic> json) {
    return WorkerLocation(
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

enum WorkerType {
  mason('mason', 'Maçon'),
  carpenter('carpenter', 'Menuisier'),
  electrician('electrician', 'Électricien'),
  plumber('plumber', 'Plombier'),
  painter('painter', 'Peintre'),
  welder('welder', 'Soudeur'),
  laborer('laborer', 'Ouvrier'),
  architect('architect', 'Architecte'),
  engineer('engineer', 'Ingénieur'),
  other('other', 'Autre');

  const WorkerType(this.value, this.label);
  final String value;
  final String label;

  static WorkerType fromString(String value) {
    return WorkerType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => WorkerType.other,
    );
  }
}

enum WorkerStatus {
  available('available', 'Disponible'),
  busy('busy', 'Occupé'),
  offline('offline', 'Hors ligne'),
  suspended('suspended', 'Suspendu');

  const WorkerStatus(this.value, this.label);
  final String value;
  final String label;

  static WorkerStatus fromString(String value) {
    return WorkerStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => WorkerStatus.offline,
    );
  }
}

class WorkerReview {
  final int id;
  final int workerId;
  final int clientId;
  final int? projectId;
  final int? bookingId;
  final int rating;
  final String? comment;
  final int? workQuality;
  final int? punctuality;
  final int? communication;
  final int? professionalism;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkerReview({
    required this.id,
    required this.workerId,
    required this.clientId,
    this.projectId,
    this.bookingId,
    required this.rating,
    this.comment,
    this.workQuality,
    this.punctuality,
    this.communication,
    this.professionalism,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkerReview.fromJson(Map<String, dynamic> json) {
    return WorkerReview(
      id: json['id'] as int,
      workerId: json['worker_id'] as int,
      clientId: json['client_id'] as int,
      projectId: json['project_id'] as int?,
      bookingId: json['booking_id'] as int?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      workQuality: json['work_quality'] as int?,
      punctuality: json['punctuality'] as int?,
      communication: json['communication'] as int?,
      professionalism: json['professionalism'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worker_id': workerId,
      'client_id': clientId,
      'project_id': projectId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'work_quality': workQuality,
      'punctuality': punctuality,
      'communication': communication,
      'professionalism': professionalism,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
