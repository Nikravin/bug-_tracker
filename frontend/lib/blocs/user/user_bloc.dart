import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/user.dart';
import '../../repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(UserInitial()) {
    on<UserSearchRequested>(_onSearchUsers);
    on<UserListRequested>(_onLoadAllUsers);
    on<UserSearchCleared>(_onClearSearch);
  }

  Future<void> _onSearchUsers(
    UserSearchRequested event,
    Emitter<UserState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(UserInitial());
      return;
    }

    emit(UserLoading());
    try {
      // Use the enhanced multi-field search for better results
      final result = await _userRepository.searchUsersByMultipleFields(event.query);
      if (result['success']) {
        final users = result['users'] as List<User>;
        // Sort results to prioritize exact matches
        users.sort((a, b) {
          final query = event.query.toLowerCase();
          
          // Prioritize exact ID matches
          if (a.id == event.query) return -1;
          if (b.id == event.query) return 1;
          
          // Prioritize exact username matches
          if (a.username.toLowerCase() == query) return -1;
          if (b.username.toLowerCase() == query) return 1;
          
          // Prioritize exact email matches
          if (a.email.toLowerCase() == query) return -1;
          if (b.email.toLowerCase() == query) return 1;
          
          // Prioritize exact name matches
          if (a.name.toLowerCase() == query) return -1;
          if (b.name.toLowerCase() == query) return 1;
          
          // Then prioritize starts with matches for username
          if (a.username.toLowerCase().startsWith(query) && !b.username.toLowerCase().startsWith(query)) return -1;
          if (b.username.toLowerCase().startsWith(query) && !a.username.toLowerCase().startsWith(query)) return 1;
          
          // Then prioritize starts with matches for name
          if (a.name.toLowerCase().startsWith(query) && !b.name.toLowerCase().startsWith(query)) return -1;
          if (b.name.toLowerCase().startsWith(query) && !a.name.toLowerCase().startsWith(query)) return 1;
          
          // Finally sort alphabetically by name
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        
        emit(UserLoaded(users));
      } else {
        emit(UserError(result['message']));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onLoadAllUsers(
    UserListRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final result = await _userRepository.getAllUsers();
      if (result['success']) {
        emit(UserLoaded(result['users']));
      } else {
        emit(UserError(result['message']));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void _onClearSearch(
    UserSearchCleared event,
    Emitter<UserState> emit,
  ) {
    emit(UserInitial());
  }
}
