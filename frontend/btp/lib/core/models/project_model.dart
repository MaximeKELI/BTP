// Modèles pour les projets de construction
class Project {
  final int id;
  final String title;
  final String description;
  final ProjectType projectType;
  final ProjectStatus status;
  final int clientId;
  final double? estimatedBudget;
  final double? actualBudget;
  final int? estimatedDurationDays;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? actualStartDate;
  final DateTime? actualEndDate;
  final Map<String, dynamic> specifications;
  final List<String> requiredSkills;
  final List<String> requiredEquipment;
  final List<String> images;
  final List<String> documents;
  final List<int> assignedWorkers;
  final int? projectManagerId;
  final double progressPercentage;
  final List<ProjectMilestone> milestones;
  final ProjectLocation? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.projectType,
    required this.status,
    required this.clientId,
    this.estimatedBudget,
    this.actualBudget,
    this.estimatedDurationDays,
    this.startDate,
    this.endDate,
    this.actualStartDate,
    this.actualEndDate,
    required this.specifications,
    required this.requiredSkills,
    required this.requiredEquipment,
    required this.images,
    required this.documents,
    required this.assignedWorkers,
    this.projectManagerId,
    required this.progressPercentage,
    required this.milestones,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      projectType: ProjectType.fromString(json['project_type'] as String),
      status: ProjectStatus.fromString(json['status'] as String),
      clientId: json['client_id'] as int,
      estimatedBudget: json['estimated_budget'] != null ? (json['estimated_budget'] as num).toDouble() : null,
      actualBudget: json['actual_budget'] != null ? (json['actual_budget'] as num).toDouble() : null,
      estimatedDurationDays: json['estimated_duration_days'] as int?,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      actualStartDate: json['actual_start_date'] != null ? DateTime.parse(json['actual_start_date'] as String) : null,
      actualEndDate: json['actual_end_date'] != null ? DateTime.parse(json['actual_end_date'] as String) : null,
      specifications: Map<String, dynamic>.from(json['specifications'] as Map? ?? {}),
      requiredSkills: List<String>.from(json['required_skills'] as List? ?? []),
      requiredEquipment: List<String>.from(json['required_equipment'] as List? ?? []),
      images: List<String>.from(json['images'] as List? ?? []),
      documents: List<String>.from(json['documents'] as List? ?? []),
      assignedWorkers: List<int>.from(json['assigned_workers'] as List? ?? []),
      projectManagerId: json['project_manager_id'] as int?,
      progressPercentage: (json['progress_percentage'] as num? ?? 0.0).toDouble(),
      milestones: json['milestones'] != null 
          ? (json['milestones'] as List).map((m) => ProjectMilestone.fromJson(m as Map<String, dynamic>)).toList()
          : [],
      location: json['location'] != null 
          ? ProjectLocation.fromJson(json['location'] as Map<String, dynamic>) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'project_type': projectType.value,
      'status': status.value,
      'client_id': clientId,
      'estimated_budget': estimatedBudget,
      'actual_budget': actualBudget,
      'estimated_duration_days': estimatedDurationDays,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'actual_start_date': actualStartDate?.toIso8601String(),
      'actual_end_date': actualEndDate?.toIso8601String(),
      'specifications': specifications,
      'required_skills': requiredSkills,
      'required_equipment': requiredEquipment,
      'images': images,
      'documents': documents,
      'assigned_workers': assignedWorkers,
      'project_manager_id': projectManagerId,
      'progress_percentage': progressPercentage,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'location': location?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get budgetDisplay {
    if (actualBudget != null) return '${actualBudget!.toStringAsFixed(0)} FCFA';
    if (estimatedBudget != null) return '~${estimatedBudget!.toStringAsFixed(0)} FCFA';
    return 'Budget non défini';
  }

  String get durationDisplay {
    if (estimatedDurationDays != null) {
      if (estimatedDurationDays! < 30) return '$estimatedDurationDays jours';
      if (estimatedDurationDays! < 365) return '${(estimatedDurationDays! / 30).toStringAsFixed(1)} mois';
      return '${(estimatedDurationDays! / 365).toStringAsFixed(1)} ans';
    }
    return 'Durée non définie';
  }

  Project copyWith({
    int? id,
    String? title,
    String? description,
    ProjectType? projectType,
    ProjectStatus? status,
    int? clientId,
    double? estimatedBudget,
    double? actualBudget,
    int? estimatedDurationDays,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? actualStartDate,
    DateTime? actualEndDate,
    Map<String, dynamic>? specifications,
    List<String>? requiredSkills,
    List<String>? requiredEquipment,
    List<String>? images,
    List<String>? documents,
    List<int>? assignedWorkers,
    int? projectManagerId,
    double? progressPercentage,
    List<ProjectMilestone>? milestones,
    ProjectLocation? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectType: projectType ?? this.projectType,
      status: status ?? this.status,
      clientId: clientId ?? this.clientId,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      actualBudget: actualBudget ?? this.actualBudget,
      estimatedDurationDays: estimatedDurationDays ?? this.estimatedDurationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      actualStartDate: actualStartDate ?? this.actualStartDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      specifications: specifications ?? this.specifications,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      requiredEquipment: requiredEquipment ?? this.requiredEquipment,
      images: images ?? this.images,
      documents: documents ?? this.documents,
      assignedWorkers: assignedWorkers ?? this.assignedWorkers,
      projectManagerId: projectManagerId ?? this.projectManagerId,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      milestones: milestones ?? this.milestones,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProjectLocation {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? location;

  const ProjectLocation({
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.location,
  });

  factory ProjectLocation.fromJson(Map<String, dynamic> json) {
    return ProjectLocation(
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

class ProjectMilestone {
  final int id;
  final int projectId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final bool isCompleted;
  final double completionPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectMilestone({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.dueDate,
    this.completedDate,
    required this.isCompleted,
    required this.completionPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) {
    return ProjectMilestone(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      completedDate: json['completed_date'] != null ? DateTime.parse(json['completed_date'] as String) : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      completionPercentage: (json['completion_percentage'] as num? ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'is_completed': isCompleted,
      'completion_percentage': completionPercentage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum ProjectType {
  residential('residential', 'Résidentiel'),
  commercial('commercial', 'Commercial'),
  industrial('industrial', 'Industriel'),
  infrastructure('infrastructure', 'Infrastructure'),
  renovation('renovation', 'Rénovation'),
  newConstruction('new_construction', 'Construction neuve'),
  maintenance('maintenance', 'Maintenance'),
  other('other', 'Autre');

  const ProjectType(this.value, this.label);
  final String value;
  final String label;

  static ProjectType fromString(String value) {
    return ProjectType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ProjectType.other,
    );
  }
}

enum ProjectStatus {
  draft('draft', 'Brouillon'),
  published('published', 'Publié'),
  inProgress('in_progress', 'En cours'),
  completed('completed', 'Terminé'),
  cancelled('cancelled', 'Annulé'),
  onHold('on_hold', 'En attente');

  const ProjectStatus(this.value, this.label);
  final String value;
  final String label;

  static ProjectStatus fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProjectStatus.draft,
    );
  }
}
