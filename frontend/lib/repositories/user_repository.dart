import '../services/api_service.dart';
import '../models/user.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      // Build query parameters for different search fields
      final Map<String, String> queryParams = {};
      
      // If query looks like an email (contains @), search by email
      if (query.contains('@')) {
        queryParams['email'] = query;
      }
      // If query is numeric or looks like a user ID, search by ID
      else if (RegExp(r'^\d+$').hasMatch(query)) {
        queryParams['id'] = query;
      }
      // Otherwise, search by general query (name, username)
      else {
        queryParams['q'] = query;
      }
      
      // Build the query string
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final response = await _apiService.get(
        'user/search/?$queryString',
      );

      if (response.statusCode == 200) {
        final users = (response.data as List)
            .map((user) => User.fromJson(user))
            .toList();
        return {'success': true, 'users': users};
      }
      return {'success': false, 'message': 'Failed to search users'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  Future<Map<String, dynamic>> searchUsersByMultipleFields(String query) async {
    try {
      print('🔍 Starting user search for query: "$query"');
      
      // Use the general search endpoint which searches across multiple fields
      final response = await _apiService.get(
        'user/search/?q=${Uri.encodeComponent(query)}',
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final users = (response.data as List)
            .map((user) => User.fromJson(user))
            .toList();
        print('✅ Successfully found ${users.length} users matching "$query"');
        return {'success': true, 'users': users};
      }
      
      print('⚠️ No users found for query: "$query"');
      return {'success': true, 'users': <User>[]};
    } catch (e) {
      print('❌ Search failed with error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final response = await _apiService.get('user/list/');

      if (response.statusCode == 200) {
        final users = (response.data as List)
            .map((user) => User.fromJson(user))
            .toList();
        return {'success': true, 'users': users};
      }
      return {'success': false, 'message': 'Failed to get users'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
