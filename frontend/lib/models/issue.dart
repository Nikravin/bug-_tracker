import 'package:equatable/equatable.dart';

enum IssueStatus { open, inProgress, resolved }

extension IssueStatusExtension on IssueStatus {
  String get value {
    switch (this) {
      case IssueStatus.inProgress:
        return 'in_progress';
      default:
        return toString().split('.').last;
    }
  }

  String toLowerCase() => value.toLowerCase();

  String replaceAll(String from, String replace) {
    return value.replaceAll(from, replace);
  }
}

enum IssuePriority { low, medium, high, critical }

extension IssuePriorityExtension on IssuePriority {
  String get value => toString().split('.').last;

  String toLowerCase() => value.toLowerCase();
}

enum IssueType { bug, feature, enhancement, task }

extension IssueTypeExtension on IssueType {
  String get value => toString().split('.').last;

  String toLowerCase() => value.toLowerCase();
  String toUpperCase() => value.toUpperCase();
}

class Issue extends Equatable {
  final String id;
  final String title;
  final String description;
  final IssuePriority priority;
  final IssueStatus status;
  final IssueType type;
  final String reporterId;
  final String projectId;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.type,
    required this.reporterId,
    required this.projectId,
    this.assignedTo,
    required this.createdAt,
    this.updatedAt,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: IssuePriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => IssuePriority.medium,
      ),
      status: IssueStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => IssueStatus.open,
      ),
      type: IssueType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => IssueType.bug,
      ),
      reporterId: json['reporter_id'],
      projectId: json['project_id'],
      assignedTo: json['assigned_to'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.toString().split('.').last,
      'status': status.value,
      'type': type.toString().split('.').last,
      'reporter_id': reporterId,
      'project_id': projectId,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Issue copyWith({
    String? id,
    String? title,
    String? description,
    IssuePriority? priority,
    IssueStatus? status,
    IssueType? type,
    String? reporterId,
    String? projectId,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Issue(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      type: type ?? this.type,
      reporterId: reporterId ?? this.reporterId,
      projectId: projectId ?? this.projectId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    priority,
    status,
    type,
    reporterId,
    projectId,
    assignedTo,
    createdAt,
    updatedAt,
  ];
}
