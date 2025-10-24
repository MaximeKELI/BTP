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
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String,
      sectors: List<String>.from(json['sectors'] as List),
      profile: json['profile'] != null 
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool,
      isEmailVerified: json['isEmailVerified'] as bool,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      fcmToken: json['fcmToken'] as String?,
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
  final String? bio;
  final String? company;
  final String? position;
  final String? website;
  final String? location;
  final String? timezone;
  final String? language;
  final Map<String, dynamic>? preferences;
  final List<String>? skills;
  final List<String>? certifications;
  final Map<String, dynamic>? socialLinks;

  const UserProfile({
    this.bio,
    this.company,
    this.position,
    this.website,
    this.location,
    this.timezone,
    this.language,
    this.preferences,
    this.skills,
    this.certifications,
    this.socialLinks,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      bio: json['bio'] as String?,
      company: json['company'] as String?,
      position: json['position'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      timezone: json['timezone'] as String?,
      language: json['language'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      skills: json['skills'] != null 
          ? List<String>.from(json['skills'] as List)
          : null,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'] as List)
          : null,
      socialLinks: json['socialLinks'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'company': company,
      'position': position,
      'website': website,
      'location': location,
      'timezone': timezone,
      'language': language,
      'preferences': preferences,
      'skills': skills,
      'certifications': certifications,
      'socialLinks': socialLinks,
    };
  }

  UserProfile copyWith({
    String? bio,
    String? company,
    String? position,
    String? website,
    String? location,
    String? timezone,
    String? language,
    Map<String, dynamic>? preferences,
    List<String>? skills,
    List<String>? certifications,
    Map<String, dynamic>? socialLinks,
  }) {
    return UserProfile(
      bio: bio ?? this.bio,
      company: company ?? this.company,
      position: position ?? this.position,
      website: website ?? this.website,
      location: location ?? this.location,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      preferences: preferences ?? this.preferences,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      socialLinks: socialLinks ?? this.socialLinks,
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
      expiresAt: DateTime.parse(json['expiresAt'] as String),
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