import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object> get props => [];
}

class ProjectFetchRequested extends ProjectEvent {}

class ProjectFetchByIdRequested extends ProjectEvent {
  final String projectId;

  const ProjectFetchByIdRequested(this.projectId);

  @override
  List<Object> get props => [projectId];
}

class ProjectCreateRequested extends ProjectEvent {
  final String name;
  final String description;
  final String status;

  const ProjectCreateRequested({
    required this.name,
    required this.description,
    required this.status,
  });

  @override
  List<Object> get props => [name, description, status];
}

class ProjectUpdateRequested extends ProjectEvent {
  final String projectId;
  final String name;
  final String description;

  const ProjectUpdateRequested(this.projectId, this.name, this.description);

  @override
  List<Object> get props => [projectId, name, description];
}

class ProjectDeleteRequested extends ProjectEvent {
  final String projectId;

  const ProjectDeleteRequested(this.projectId);

  @override
  List<Object> get props => [projectId];
}

class AddProjectMember extends ProjectEvent {
  final String projectId;
  final String userId;

  const AddProjectMember(this.projectId, this.userId);

  @override
  List<Object> get props => [projectId, userId];
}

class RemoveProjectMember extends ProjectEvent {
  final String projectId;
  final String userId;

  const RemoveProjectMember(this.projectId, this.userId);

  @override
  List<Object> get props => [projectId, userId];
}
