import 'package:equatable/equatable.dart';
import 'user.dart';

class Project extends Equatable {
  final String id;
  final String name;
  final String title;
  final String description;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<User> members;

  const Project({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.members = const [],
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'] ?? json['title'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      status:
          json['status'] ??
          'active', // Default status since backend doesn't provide it
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      members: json['members'] != null
          ? (json['members'] as List)
                .map((member) => User.fromJson(member))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'members': members.map((member) => member.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    title,
    description,
    status,
    createdBy,
    createdAt,
    updatedAt,
    members,
  ];
}
