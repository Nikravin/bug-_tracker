import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/project_repository.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository _projectRepository;

  ProjectBloc(this._projectRepository) : super(ProjectInitial()) {
    on<ProjectFetchRequested>(_onLoadProjects);
    on<ProjectFetchByIdRequested>(_onLoadProject);
    on<ProjectCreateRequested>(_onCreateProject);
    on<ProjectUpdateRequested>(_onUpdateProject);
    on<ProjectDeleteRequested>(_onDeleteProject);
    on<AddProjectMember>(_onAddProjectMember);
    on<RemoveProjectMember>(_onRemoveProjectMember);
  }

  Future<void> _onLoadProjects(
    ProjectFetchRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      // Use role-based project filtering
      final result = await _projectRepository.getProjectsBasedOnRole();
      if (result['success']) {
        emit(ProjectLoaded(result['projects']));
      } else {
        emit(ProjectError(result['message']));
      }
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onLoadProject(
    ProjectFetchByIdRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final result = await _projectRepository.getProject(event.projectId);
      if (result['success']) {
        emit(ProjectDetailLoaded(result['project']));
      } else {
        emit(ProjectError(result['message']));
      }
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onCreateProject(
    ProjectCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final result = await _projectRepository.createProject(
        event.name,
        event.description,
        event.status,
      );
      if (result['success']) {
        emit(ProjectCreated(result['project']));
      } else {
        emit(ProjectError(result['message']));
      }
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onUpdateProject(
    ProjectUpdateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final result = await _projectRepository.updateProject(
        event.projectId,
        event.name,
        event.description,
      );
      if (result['success']) {
        emit(ProjectUpdated(result['project']));
      } else {
        emit(ProjectError(result['message']));
      }
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onDeleteProject(
    ProjectDeleteRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final result = await _projectRepository.deleteProject(event.projectId);
      if (result['success']) {
        emit(ProjectDeleted());
      } else {
        emit(ProjectError(result['message']));
      }
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onAddProjectMember(
    AddProjectMember event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final result = await _projectRepository.addMember(
        event.projectId,
        event.userId,
      );
      if (result['success']) {
        emit(ProjectUpdated(result['project']));
      } else {
        emit(ProjectError(result['message']));
      }
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onRemoveProjectMember(
    RemoveProjectMember event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final result = await _projectRepository.removeMember(
        event.projectId,
        event.userId,
      );
      if (result['success']) {
        emit(ProjectUpdated(result['project']));
      } else {
        emit(ProjectError(result['message']));
      }
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }
}
