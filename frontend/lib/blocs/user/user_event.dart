import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class UserSearchRequested extends UserEvent {
  final String query;

  const UserSearchRequested(this.query);

  @override
  List<Object> get props => [query];
}

class UserListRequested extends UserEvent {
  const UserListRequested();
}

class UserSearchCleared extends UserEvent {
  const UserSearchCleared();
}
