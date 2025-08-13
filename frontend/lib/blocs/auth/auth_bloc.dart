import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthProfileRequested>(_onProfileRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.login(event.email, event.password);
      if (result['success']) {
        // After successful login, get user profile
        final profileResult = await _authRepository.getUserProfile();
        if (profileResult['success']) {
          emit(AuthAuthenticated(profileResult['user']));
        } else {
          emit(AuthError('Login successful but failed to get user profile'));
        }
      } else {
        emit(AuthError(result['message']));
        print(
          "--------------------------------------${result['message']}----------------------------------",
        );
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      print(
        '---------------------------------------------- error: $e ----------------------------------------------',
      );
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.register(
        event.username,
        event.name,
        event.email,
        event.password,
        event.role,
      );
      if (result['success']) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthError(result['message']));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final result = await _authRepository.getUserProfile();
        if (result['success']) {
          emit(AuthAuthenticated(result['user']));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onProfileRequested(
    AuthProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _authRepository.getUserProfile();
      if (result['success']) {
        emit(AuthAuthenticated(result['user']));
      } else {
        emit(AuthError(result['message']));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
