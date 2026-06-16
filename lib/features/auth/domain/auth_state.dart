import '../../../models/user_profile.dart';

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.rememberMe = true,
    this.user,
    this.errorMessage,
    this.rememberedUser,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final bool rememberMe;
  final UserProfile? user;
  final String? errorMessage;
  final String? rememberedUser;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? rememberMe,
    UserProfile? user,
    String? errorMessage,
    String? rememberedUser,
    bool clearError = false,
    bool clearUser = false,
    bool clearRememberedUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      rememberMe: rememberMe ?? this.rememberMe,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      rememberedUser: clearRememberedUser
          ? null
          : rememberedUser ?? this.rememberedUser,
    );
  }
}
