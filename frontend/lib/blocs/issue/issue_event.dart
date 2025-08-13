import 'package:equatable/equatable.dart';

abstract class IssueEvent extends Equatable {
  const IssueEvent();

  @override
  List<Object> get props => [];
}

class IssueFetchByProjectRequested extends IssueEvent {
  final String projectId;

  const IssueFetchByProjectRequested(this.projectId);

  @override
  List<Object> get props => [projectId];
}

class IssueFetchByIdRequested extends IssueEvent {
  final String issueId;

  const IssueFetchByIdRequested(this.issueId);

  @override
  List<Object> get props => [issueId];
}

class IssueCreateRequested extends IssueEvent {
  final String projectId;
  final String title;
  final String description;
  final String priority;
  final String status;

  const IssueCreateRequested(
    this.projectId,
    this.title,
    this.description,
    this.priority,
    this.status,
  );

  @override
  List<Object> get props => [projectId, title, description, priority, status];
}

class IssueUpdateRequested extends IssueEvent {
  final String issueId;
  final String title;
  final String description;
  final String priority;
  final String status;

  const IssueUpdateRequested(
    this.issueId,
    this.title,
    this.description,
    this.priority,
    this.status,
  );

  @override
  List<Object> get props => [issueId, title, description, priority, status];
}

class IssueDeleteRequested extends IssueEvent {
  final String issueId;

  const IssueDeleteRequested(this.issueId);

  @override
  List<Object> get props => [issueId];
}

class IssueTextFieldValidated extends IssueEvent {
  final String message;
  const IssueTextFieldValidated(this.message);
  @override
  List<Object> get props => [message];
}
