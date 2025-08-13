import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String name;
  final String email;
  final String password;
  final String role;

  const AuthRegisterRequested(this.username, this.name, this.email, this.password, this.role);

  @override
  List<Object> get props => [username, name, email, password, role];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthProfileRequested extends AuthEvent {}
