import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../repositories/auth_repository.dart';
import '../domain/auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() => const AuthState();

  Future<void> bootstrap() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rememberedUser = await _repository.rememberedUser().timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      final user = await _repository.restoreSession().timeout(
        const Duration(seconds: 4),
        onTimeout: () => null,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
        rememberedUser: rememberedUser,
      );
    } on Object catch (error) {
      debugPrint('LOGIN ERROR: bootstrap failed: $error');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        clearUser: true,
        errorMessage: _friendlyLoginError(error.toString()),
      );
    }
  }

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      debugPrint('LOGIN START');
      final user = await _repository.login(
        username: username.trim(),
        password: password,
        rememberMe: state.rememberMe,
      );
      debugPrint('LOGIN SUCCESS');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        rememberedUser: state.rememberMe ? username.trim() : null,
        clearRememberedUser: !state.rememberMe,
      );
      return true;
    } on TimeoutException catch (error) {
      debugPrint('LOGIN ERROR: $error');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Server timeout. Please try again.',
      );
      return false;
    } on ApiException catch (error) {
      debugPrint('LOGIN ERROR: ${error.message}');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: _friendlyLoginError(error.message),
      );
      return false;
    } on Object catch (error) {
      debugPrint('LOGIN ERROR: $error');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: _friendlyLoginError(error.toString()),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _repository.logout();
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: false,
      clearUser: true,
    );
  }

  String _friendlyLoginError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid') ||
        lower.contains('incorrect') ||
        lower.contains('password') ||
        lower.contains('authentication')) {
      return 'Invalid login credentials.';
    }
    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('host lookup')) {
      return 'Network error. Please check your internet connection.';
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return 'Server timeout. Please try again.';
    }
    return message.isEmpty ? 'Unable to login. Please try again.' : message;
  }
}
