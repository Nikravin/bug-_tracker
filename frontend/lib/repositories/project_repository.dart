import '../services/api_service.dart';
import '../services/rbac_service.dart';
import '../models/project.dart';
import '../utils/jwt_utils.dart';

class ProjectRepository {
  final ApiService _apiService;
  late final RBACService _rbacService;

  ProjectRepository(this._apiService) {
    _rbacService = RBACService(_apiService);
  }

  Future<Map<String, dynamic>> createProject(
    String title,
    String description,
    String status,
  ) async {
    try {
      final data = {
        'title': title,
        'description': description,
        // Note: Backend doesn't support status field for projects
      };

      final response = await _apiService.post(
        'project/add_project/',
        data: data,
      );

      if (response.statusCode == 201) {
        return {'success': true, 'project': Project.fromJson(response.data)};
      }
      return {'success': false, 'message': 'Failed to create project'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAllProjects() async {
    try {
      final response = await _apiService.get('project/show_all_project/');

      if (response.statusCode == 200) {
        final projects = (response.data as List)
            .map((project) => Project.fromJson(project))
            .toList();
        return {'success': true, 'projects': projects};
      }
      return {'success': false, 'message': 'Failed to get projects'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Gets projects based on user role - now includes member projects
  Future<Map<String, dynamic>> getProjectsBasedOnRole() async {
    try {
      final response = await _apiService.get('project/show_all_project/');
      
      if (response.statusCode == 200) {
        final projects = (response.data as List)
            .map((project) => Project.fromJson(project))
            .toList();
        return {'success': true, 'projects': projects};
      } else if (response.statusCode == 400) {
        // Backend returns 400 when user has no associated projects
        return {'success': true, 'projects': <Project>[]};
      } else {
        return {'success': false, 'message': 'Failed to get projects'};
      }
    } catch (e) {
      // Handle the case where the API call fails
      String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('400') || errorMessage.contains('bad request')) {
        // Return empty list if user has no accessible projects
        return {'success': true, 'projects': <Project>[]};
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Checks if current user can access a specific project
  Future<bool> canAccessProject(String projectId) async {
    try {
      // Admin and Project Manager can access all projects
      final canViewAll = await _rbacService.canViewAllProjects();
      if (canViewAll) {
        return true;
      }

      // For developers and testers, check if they are members
      final projectResult = await getProject(projectId);
      if (!projectResult['success']) {
        return false;
      }

      final project = projectResult['project'] as Project;
      final currentUserId = await _rbacService.getCurrentUserId();
      if (currentUserId == null) {
        return false;
      }

      return project.members.any((member) => member.id == currentUserId);
    } catch (e) {
      print('Error checking project access: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getProject(String projectId) async {
    try {
      final response = await _apiService.get(
        'project/show_project/$projectId/',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'project': Project.fromJson(response.data)};
      }
      return {'success': false, 'message': 'Failed to get project'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProject(
    String projectId,
    String title,
    String description,
  ) async {
    try {
      final data = {'title': title, 'description': description};

      final response = await _apiService.put(
        'project/update_project/$projectId/',
        data: data,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'project': Project.fromJson(response.data)};
      }
      return {'success': false, 'message': 'Failed to update project'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteProject(String projectId) async {
    try {
      final response = await _apiService.delete(
        'project/delete_project/$projectId/',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Project deleted successfully'};
      }
      return {'success': false, 'message': 'Failed to delete project'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addMember(
    String projectId,
    String userId,
  ) async {
    try {
      final response = await _apiService.post(
        'project/$projectId/add_member/$userId',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'project': Project.fromJson(response.data)};
      }
      return {'success': false, 'message': 'Failed to add member'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> removeMember(
    String projectId,
    String userId,
  ) async {
    try {
      final response = await _apiService.delete(
        'project/$projectId/delete_member/$userId',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'project': Project.fromJson(response.data)};
      }
      return {'success': false, 'message': 'Failed to remove member'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
