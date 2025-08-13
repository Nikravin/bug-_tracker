import '../services/api_service.dart';
import '../models/issue.dart';

class IssueRepository {
  final ApiService _apiService;

  IssueRepository(this._apiService);

  Future<Map<String, dynamic>> createIssue(
    String projectId,
    String title,
    String description,
    String priority,
    String status,
  ) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'priority': priority,
        'status': status,
      };

      final response = await _apiService.post(
        'project/issue/add_issue/$projectId/',
        data: data,
      );

      if (response.statusCode == 201) {
        return {'success': true, 'issue': Issue.fromJson(response.data)};
      }
      return {'success': false, 'message': 'Failed to create issue'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getProjectIssues(String projectId) async {
    try {
      final response = await _apiService.get(
        'project/issue/show_all_issues_in_project/$projectId/',
      );

      if (response.statusCode == 200) {
        final issues = (response.data as List)
            .map((issue) => Issue.fromJson(issue))
            .toList();
        return {'success': true, 'issues': issues};
      }
      return {'success': false, 'message': 'Failed to get issues'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getIssue(String issueId) async {
    try {
      final response = await _apiService.get(
        'project/issue/show_issue/$issueId/',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'issue': Issue.fromJson(response.data)};
      }
      return {'success': false, 'message': 'Failed to get issue'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateIssue(
    String issueId,
    String title,
    String description,
    String priority,
    String status,
  ) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'priority': priority,
        'status': status,
      };

      final response = await _apiService.put(
        'project/issue/update/$issueId/',
        data: data,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'issue': Issue.fromJson(response.data)};
      }
      return {'success': false, 'message': 'Failed to update issue'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteIssue(String issueId) async {
    try {
      print('🗑️ Attempting to delete issue: $issueId');
      final response = await _apiService.delete(
        'project/issue/delete/$issueId/',
      );

      print('📡 Delete response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Issue deleted successfully'};
      }
      return {'success': false, 'message': 'Failed to delete issue'};
    } catch (e) {
      print('❌ Delete issue error: $e');
      // Extract more specific error message from DioException
      if (e.toString().contains('status code of 400')) {
        return {
          'success': false,
          'message':
              'Permission denied: You don\'t have permission to delete this issue',
        };
      } else if (e.toString().contains('status code of 403')) {
        return {
          'success': false,
          'message':
              'Permission denied: You don\'t have permission to delete this issue',
        };
      } else if (e.toString().contains('status code of 404')) {
        return {'success': false, 'message': 'Issue not found'};
      }
      return {
        'success': false,
        'message': 'Failed to delete issue: ${e.toString()}',
      };
    }
  }
}
