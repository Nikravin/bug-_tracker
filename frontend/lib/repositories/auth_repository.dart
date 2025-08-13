import '../services/api_service.dart';
import '../models/user.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final formData = FormData.fromMap({
        'username': email,
        'password': password,
      });

      final response = await _apiService.post('user/login/', data: formData);

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        await _apiService.saveToken(token);
        return {'success': true, 'token': token};
      }
      return {'success': false, 'message': 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final data = {
        'username': username, // Backend expects username field
        'name': name,
        'email': email,
        'hashed_password': password, // Backend expects hashed_password field
        'role': role,
      };

      final response = await _apiService.post('user/register/', data: data);

      if (response.statusCode == 201) {
        return {'success': true, 'user': User.fromJson(response.data)};
      }
      return {'success': false, 'message': 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiService.get('dashboard');

      if (response.statusCode == 200) {
        return {'success': true, 'user': User.fromJson(response.data)};
      }
      return {'success': false, 'message': 'Failed to get profile'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _apiService.get('dashboard');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': 'Failed to get dashboard'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await _apiService.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }
}
