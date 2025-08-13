import 'api_service.dart';
import '../utils/jwt_utils.dart';

enum UserRole {
  admin,
  projectManager,
  developer,
  tester,
}

class RBACService {
  final ApiService _apiService;

  RBACService(this._apiService);

  /// Gets the current user's role from the JWT token
  Future<UserRole?> getCurrentUserRole() async {
    try {
      final token = await _apiService.getToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      final userInfo = JwtUtils.getUserInfoFromToken(token);
      if (userInfo == null) {
        return null;
      }

      final role = userInfo['role'] as String?;
      if (role == null) {
        return null;
      }

      return _mapStringToUserRole(role.toLowerCase());
    } catch (e) {
      print('Error getting current user role: $e');
      return null;
    }
  }

  /// Gets the current user ID from the JWT token
  Future<String?> getCurrentUserId() async {
    try {
      final token = await _apiService.getToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      final userInfo = JwtUtils.getUserInfoFromToken(token);
      if (userInfo == null) {
        return null;
      }

      return userInfo['user_id'] as String? ?? userInfo['id'] as String?;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  /// Maps string role to UserRole enum
  UserRole _mapStringToUserRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'project_manager':
      case 'projectmanager':
      case 'project manager':
        return UserRole.projectManager;
      case 'developer':
        return UserRole.developer;
      case 'tester':
      case 'qa':
        return UserRole.tester;
      default:
        return UserRole.developer; // Default to developer for unknown roles
    }
  }

  /// Checks if the current user can manage projects (create, update, delete)
  Future<bool> canManageProjects() async {
    final role = await getCurrentUserRole();
    if (role == null) return false;

    return role == UserRole.admin || role == UserRole.projectManager;
  }

  /// Checks if the current user can manage project members (add, remove)
  Future<bool> canManageProjectMembers() async {
    final role = await getCurrentUserRole();
    if (role == null) return false;

    return role == UserRole.admin || role == UserRole.projectManager;
  }

  /// Checks if the current user can view all projects or only member projects
  Future<bool> canViewAllProjects() async {
    final role = await getCurrentUserRole();
    if (role == null) return false;

    return role == UserRole.admin || role == UserRole.projectManager;
  }

  /// Checks if the current user can create issues
  Future<bool> canCreateIssues() async {
    // All authenticated users can create issues
    final role = await getCurrentUserRole();
    return role != null;
  }

  /// Checks if the current user can update issues
  Future<bool> canUpdateIssues() async {
    // All authenticated users can update issues
    final role = await getCurrentUserRole();
    return role != null;
  }

  /// Checks if the current user can delete issues
  Future<bool> canDeleteIssues() async {
    final role = await getCurrentUserRole();
    if (role == null) return false;

    // Only admins and project managers can delete issues
    return role == UserRole.admin || role == UserRole.projectManager;
  }

  /// Gets user-friendly role name for display
  Future<String> getRoleDisplayName() async {
    final role = await getCurrentUserRole();
    if (role == null) return 'Unknown';

    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.projectManager:
        return 'Project Manager';
      case UserRole.developer:
        return 'Developer';
      case UserRole.tester:
        return 'Tester';
    }
  }

  /// Checks if user is restricted (developer or tester)
  Future<bool> isRestrictedUser() async {
    final role = await getCurrentUserRole();
    if (role == null) return true; // If no role, consider restricted

    return role == UserRole.developer || role == UserRole.tester;
  }

  /// Checks if the current user has admin privileges
  Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();
    return role == UserRole.admin;
  }

  /// Checks if the current user is a project manager
  Future<bool> isProjectManager() async {
    final role = await getCurrentUserRole();
    return role == UserRole.projectManager;
  }

  /// Checks if the current user is a developer
  Future<bool> isDeveloper() async {
    final role = await getCurrentUserRole();
    return role == UserRole.developer;
  }

  /// Checks if the current user is a tester
  Future<bool> isTester() async {
    final role = await getCurrentUserRole();
    return role == UserRole.tester;
  }

  /// Gets permission description for UI display
  String getPermissionDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Full access to all features and projects';
      case UserRole.projectManager:
        return 'Can manage projects, members, and all issues';
      case UserRole.developer:
        return 'Can view assigned projects and manage issues';
      case UserRole.tester:
        return 'Can view assigned projects and manage issues';
    }
  }
}
