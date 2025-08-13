import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/issue_repository.dart';
import 'issue_event.dart';
import 'issue_state.dart';

class IssueBloc extends Bloc<IssueEvent, IssueState> {
  final IssueRepository _issueRepository;

  IssueBloc(this._issueRepository) : super(IssueInitial()) {
    on<IssueFetchByProjectRequested>(_onLoadProjectIssues);
    on<IssueFetchByIdRequested>(_onLoadIssue);
    on<IssueCreateRequested>(_onCreateIssue);
    on<IssueUpdateRequested>(_onUpdateIssue);
    on<IssueDeleteRequested>(_onDeleteIssue);
    on<IssueTextFieldValidated>(_onIssueTextFieldValidated);
  }

  Future<void> _onLoadProjectIssues(
    IssueFetchByProjectRequested event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssueLoading());
    try {
      final result = await _issueRepository.getProjectIssues(event.projectId);
      if (result['success']) {
        emit(IssueLoaded(result['issues']));
      } else {
        emit(IssueError(result['message']));
        print(
          "----------------------get the error in Result success:-  ${result['message']} ----------------------",
        );
      }
    } catch (e) {
      emit(IssueError(e.toString()));
      print(
        "----------------------get the error to fetch project issues :-  ${e.toString()} ----------------------",
      );
    }
  }

  Future<void> _onLoadIssue(
    IssueFetchByIdRequested event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssueLoading());
    try {
      final result = await _issueRepository.getIssue(event.issueId);
      if (result['success']) {
        emit(IssueDetailLoaded(result['issue']));
      } else {
        emit(IssueError(result['message']));
      }
    } catch (e) {
      emit(IssueError(e.toString()));
    }
  }

  Future<void> _onCreateIssue(
    IssueCreateRequested event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssueLoading());
    try {
      if (event.title.isEmpty || event.description.isEmpty) {
        emit(IssueError('Title and Description are required'));
      } else {
        final result = await _issueRepository.createIssue(
          event.projectId,
          event.title,
          event.description,
          event.priority,
          event.status,
        );
        if (result['success']) {
          emit(IssueCreated(result['issue']));
        } else {
          emit(IssueError(result['message']));
        }
      }
    } catch (e) {
      emit(IssueError(e.toString()));
    }
  }

  Future<void> _onUpdateIssue(
    IssueUpdateRequested event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssueLoading());
    try {
      final result = await _issueRepository.updateIssue(
        event.issueId,
        event.title,
        event.description,
        event.priority,
        event.status,
      );
      if (result['success']) {
        emit(IssueUpdated(result['issue']));
      } else {
        emit(IssueError(result['message']));
      }
    } catch (e) {
      emit(IssueError(e.toString()));
    }
  }

  Future<void> _onDeleteIssue(
    IssueDeleteRequested event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssueLoading());
    try {
      final result = await _issueRepository.deleteIssue(event.issueId);
      if (result['success']) {
        emit(IssueDeleted());
      } else {
        emit(IssueError(result['message']));
      }
    } catch (e) {
      emit(IssueError(e.toString()));
    }
  }

  void _onIssueTextFieldValidated(
    IssueTextFieldValidated event,
    Emitter<IssueState> emit,
  ) {
    emit(IssueTextFieldValidatedState(event.message));
  }
}
