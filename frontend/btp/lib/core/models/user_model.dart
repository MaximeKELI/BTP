// Modèle utilisateur simplifié sans dépendances externes
class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatar;
  final String role;
  final List<String> sectors;
  final UserProfile? profile;
  final UserSettings? settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime? lastLoginAt;
  final String? fcmToken;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatar,
    required this.role,
    required this.sectors,
    this.profile,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.isEmailVerified,
    this.lastLoginAt,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String,
      sectors: json['sectors'] != null 
          ? List<String>.from(json['sectors'] as List)
          : <String>[],
      profile: json['profile'] != null 
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['created_at'] as String), // Fallback to created_at
      isActive: json['is_active'] as bool,
      isEmailVerified: json['is_verified'] as bool,
      lastLoginAt: json['last_login'] != null 
          ? DateTime.parse(json['last_login'] as String)
          : null,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'sectors': sectors,
      'profile': profile?.toJson(),
      'settings': settings?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
  
  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isWorker => role == 'worker';
  bool get isClient => role == 'client';
  bool get isSupplier => role == 'supplier';
  bool get isInvestor => role == 'investor';
  
  bool hasSector(String sector) => sectors.contains(sector);
  
  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
    String? role,
    List<String>? sectors,
    UserProfile? profile,
    UserSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isEmailVerified,
    DateTime? lastLoginAt,
    String? fcmToken,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      sectors: sectors ?? this.sectors,
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

class UserProfile {
  final int id;
  final int userId;
  final String? bio;
  final String? company;
  final String? jobTitle;
  final String? avatarUrl;
  final String? birthDate;
  final String? gender;
  final int? experienceYears;
  final String? currency;
  final String? timezone;
  final String? language;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final List<String>? skills;
  final List<String>? certifications;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    this.bio,
    this.company,
    this.jobTitle,
    this.avatarUrl,
    this.birthDate,
    this.gender,
    this.experienceYears,
    this.currency,
    this.timezone,
    this.language,
    required this.emailNotifications,
    required this.pushNotifications,
    required this.smsNotifications,
    this.skills,
    this.certifications,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      bio: json['bio'] as String?,
      company: json['company'] as String?,
      jobTitle: json['job_title'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String?,
      experienceYears: json['experience_years'] as int?,
      currency: json['currency'] as String?,
      timezone: json['timezone'] as String?,
      language: json['language'] as String?,
      emailNotifications: json['email_notifications'] as bool,
      pushNotifications: json['push_notifications'] as bool,
      smsNotifications: json['sms_notifications'] as bool,
      skills: json['skills'] != null 
          ? List<String>.from(json['skills'] as List)
          : null,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'] as List)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bio': bio,
      'company': company,
      'job_title': jobTitle,
      'avatar_url': avatarUrl,
      'birth_date': birthDate,
      'gender': gender,
      'experience_years': experienceYears,
      'currency': currency,
      'timezone': timezone,
      'language': language,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'sms_notifications': smsNotifications,
      'skills': skills,
      'certifications': certifications,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    int? id,
    int? userId,
    String? bio,
    String? company,
    String? jobTitle,
    String? avatarUrl,
    String? birthDate,
    String? gender,
    int? experienceYears,
    String? currency,
    String? timezone,
    String? language,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    List<String>? skills,
    List<String>? certifications,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bio: bio ?? this.bio,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      experienceYears: experienceYears ?? this.experienceYears,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserSettings {
  final bool notificationsEnabled;
  final bool locationEnabled;
  final bool biometricEnabled;
  final String theme;
  final String language;
  final Map<String, bool> notificationTypes;
  final Map<String, dynamic> privacySettings;
  final Map<String, dynamic> displaySettings;

  const UserSettings({
    required this.notificationsEnabled,
    required this.locationEnabled,
    required this.biometricEnabled,
    required this.theme,
    required this.language,
    required this.notificationTypes,
    required this.privacySettings,
    required this.displaySettings,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notificationsEnabled: json['notificationsEnabled'] as bool,
      locationEnabled: json['locationEnabled'] as bool,
      biometricEnabled: json['biometricEnabled'] as bool,
      theme: json['theme'] as String,
      language: json['language'] as String,
      notificationTypes: Map<String, bool>.from(json['notificationTypes'] as Map),
      privacySettings: Map<String, dynamic>.from(json['privacySettings'] as Map),
      displaySettings: Map<String, dynamic>.from(json['displaySettings'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'locationEnabled': locationEnabled,
      'biometricEnabled': biometricEnabled,
      'theme': theme,
      'language': language,
      'notificationTypes': notificationTypes,
      'privacySettings': privacySettings,
      'displaySettings': displaySettings,
    };
  }

  factory UserSettings.defaultSettings() {
    return const UserSettings(
      notificationsEnabled: true,
      locationEnabled: true,
      biometricEnabled: false,
      theme: 'system',
      language: 'fr',
      notificationTypes: {
        'push': true,
        'email': true,
        'sms': false,
        'in_app': true,
      },
      privacySettings: {
        'profile_visibility': 'public',
        'location_sharing': 'friends',
        'activity_status': 'visible',
      },
      displaySettings: {
        'font_size': 'medium',
        'high_contrast': false,
        'reduce_motion': false,
      },
    );
  }

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? locationEnabled,
    bool? biometricEnabled,
    String? theme,
    String? language,
    Map<String, bool>? notificationTypes,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? displaySettings,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationTypes: notificationTypes ?? this.notificationTypes,
      privacySettings: privacySettings ?? this.privacySettings,
      displaySettings: displaySettings ?? this.displaySettings,
    );
  }
}

class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (json['expiresAt'] as num).toInt(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      rememberMe: json['rememberMe'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  final List<String> sectors;
  final String? company;
  final String? position;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.sectors,
    this.company,
    this.position,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      sectors: List<String>.from(json['sectors'] as List),
      company: json['company'] as String?,
      position: json['position'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'sectors': sectors,
      'company': company,
      'position': position,
    };
  }
}

class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({
    required this.email,
  });

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequest(
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResetPasswordRequest {
  final String token;
  final String password;

  const ResetPasswordRequest({
    required this.token,
    required this.password,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      token: json['token'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'password': password,
    };
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      currentPassword: json['currentPassword'] as String,
      newPassword: json['newPassword'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}

class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final UserProfile? profile;

  const UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    this.profile,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequest(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatar': avatar,
      'profile': profile?.toJson(),
    };
  }
}