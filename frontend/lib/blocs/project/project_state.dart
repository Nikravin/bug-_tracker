import 'package:equatable/equatable.dart';
import '../../models/project.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;

  const ProjectLoaded(this.projects);

  @override
  List<Object> get props => [projects];
}

class ProjectDetailLoaded extends ProjectState {
  final Project project;

  const ProjectDetailLoaded(this.project);

  @override
  List<Object> get props => [project];
}

class ProjectCreated extends ProjectState {
  final Project project;

  const ProjectCreated(this.project);

  @override
  List<Object> get props => [project];
}

class ProjectUpdated extends ProjectState {
  final Project project;

  const ProjectUpdated(this.project);

  @override
  List<Object> get props => [project];
}

class ProjectDeleted extends ProjectState {}

class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object> get props => [message];
}
