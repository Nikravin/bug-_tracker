import 'package:equatable/equatable.dart';
import '../../models/issue.dart';

abstract class IssueState extends Equatable {
  const IssueState();

  @override
  List<Object?> get props => [];
}

class IssueInitial extends IssueState {}

class IssueLoading extends IssueState {}

class IssueLoaded extends IssueState {
  final List<Issue> issues;

  const IssueLoaded(this.issues);

  @override
  List<Object> get props => [issues];
}

class IssueDetailLoaded extends IssueState {
  final Issue issue;

  const IssueDetailLoaded(this.issue);

  @override
  List<Object> get props => [issue];
}

class IssueCreated extends IssueState {
  final Issue issue;

  const IssueCreated(this.issue);

  @override
  List<Object> get props => [issue];
}

class IssueUpdated extends IssueState {
  final Issue issue;

  const IssueUpdated(this.issue);

  @override
  List<Object> get props => [issue];
}

class IssueDeleted extends IssueState {}

class IssueError extends IssueState {
  final String message;

  const IssueError(this.message);

  @override
  List<Object> get props => [message];
}

class IssueTextFieldValidatedState extends IssueState {
  final String message;
  const IssueTextFieldValidatedState(this.message);
}
