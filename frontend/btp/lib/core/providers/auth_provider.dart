import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;
  final String? token;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.token,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
    String? token,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      token: token ?? this.token,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> initializeAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final token = StorageService.getAuthToken();
      final userData = StorageService.getUserData();
      
      if (token != null && userData != null) {
        final user = User.fromJson(userData);
        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          token: token,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de l\'initialisation: ${e.toString()}',
      );
    }
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final request = LoginRequest(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      
      final response = await ApiService.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );
      
      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);
        
        // Save tokens and user data
        await StorageService.saveAuthToken(authResponse.accessToken);
        await StorageService.saveRefreshToken(authResponse.refreshToken);
        await StorageService.saveUserData(authResponse.user.toJson());
        
        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          user: authResponse.user,
          token: authResponse.accessToken,
        );
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Erreur de connexion',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de connexion: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await ApiService.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
      );
      
      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);
        
        // Save tokens and user data
        await StorageService.saveAuthToken(authResponse.accessToken);
        await StorageService.saveRefreshToken(authResponse.refreshToken);
        await StorageService.saveUserData(authResponse.user.toJson());
        
        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          user: authResponse.user,
          token: authResponse.accessToken,
        );
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Erreur d\'inscription',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur d\'inscription: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final request = ForgotPasswordRequest(email: email);
      
      final response = await ApiService.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: request.toJson(),
      );
      
      state = state.copyWith(isLoading: false);
      
      if (response.isSuccess) {
        return true;
      } else {
        state = state.copyWith(error: response.error ?? 'Erreur lors de l\'envoi');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> resetPassword(String token, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final request = ResetPasswordRequest(token: token, password: password);
      
      final response = await ApiService.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: request.toJson(),
      );
      
      state = state.copyWith(isLoading: false);
      
      if (response.isSuccess) {
        return true;
      } else {
        state = state.copyWith(error: response.error ?? 'Erreur lors de la réinitialisation');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      final response = await ApiService.put<Map<String, dynamic>>(
        '/auth/change-password',
        data: request.toJson(),
      );
      
      state = state.copyWith(isLoading: false);
      
      if (response.isSuccess) {
        return true;
      } else {
        state = state.copyWith(error: response.error ?? 'Erreur lors du changement de mot de passe');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> updateProfile(UpdateProfileRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await ApiService.put<User>(
        '/users/profile',
        data: request.toJson(),
      );
      
      if (response.isSuccess && response.data != null) {
        final updatedUser = response.data!;
        
        // Update stored user data
        await StorageService.saveUserData(updatedUser.toJson());
        
        state = state.copyWith(
          isLoading: false,
          user: updatedUser,
        );
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Erreur lors de la mise à jour',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = StorageService.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }
      
      final response = await ApiService.post<AuthResponse>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      if (response.isSuccess && response.data != null) {
        final authResponse = response.data!;
        
        // Update tokens
        await StorageService.saveAuthToken(authResponse.accessToken);
        await StorageService.saveRefreshToken(authResponse.refreshToken);
        
        state = state.copyWith(token: authResponse.accessToken);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Call logout API if needed
      await ApiService.post('/auth/logout');
    } catch (e) {
      // Ignore logout API errors
    }
    
    // Clear local storage
    await StorageService.clearAuthToken();
    await StorageService.clearRefreshToken();
    await StorageService.clearUserData();
    
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final response = await ApiService.get<User>('/users/profile');
      
      if (response.isSuccess && response.data != null) {
        final user = response.data!;
        
        // Update stored user data
        await StorageService.saveUserData(user.toJson());
        
        state = state.copyWith(
          isLoading: false,
          user: user,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});