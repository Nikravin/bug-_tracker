import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../utils/jwt_utils.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  /// Checks if the authentication token is valid
  /// Returns true if valid, false if invalid or expired
  Future<bool> isTokenValid() async {
    try {
      final token = await _apiService.getToken();

      // If no token exists, it's invalid
      if (token == null || token.isEmpty) {
        return false;
      }

      // First check if token is expired (if it's a JWT)
      if (JwtUtils.isTokenExpired(token)) {
        print('🔐 Token is expired');
        return false;
      }

      // Try to make a test API call to validate the token
      final response = await _apiService.get('dashboard');

      // If the call succeeds, token is valid
      return response.statusCode == 200;
    } on DioException catch (e) {
      // Check if it's an authentication error
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        print('🔐 Token validation failed: ${e.response?.statusCode}');
        return false;
      }
      // For other errors, assume token might still be valid
      // (could be network issues, server down, etc.)
      print('⚠️ Network error during token validation: ${e.message}');
      return true;
    } catch (e) {
      // For any other error, assume token might still be valid
      print('⚠️ Unexpected error during token validation: $e');
      return true;
    }
  }

  /// Validates token and redirects to login if invalid
  /// Call this method in screens that require authentication
  Future<bool> validateTokenAndRedirect(BuildContext context) async {
    final isValid = await isTokenValid();

    if (!isValid) {
      await _handleInvalidToken(context);
      return false;
    }

    return true;
  }

  /// Handles invalid token by clearing it and redirecting to login
  Future<void> _handleInvalidToken(BuildContext context) async {
    // Clear the invalid token
    await _apiService.deleteToken();

    // Update auth state to unauthenticated
    if (context.mounted) {
      context.read<AuthBloc>().add(AuthLogoutRequested());

      // Show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please login again.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      // Redirect to login page
      context.go('/login');
    }
  }

  /// Middleware function to check authentication before API calls
  /// Use this as an interceptor or call before important API operations
  Future<bool> checkAuthBeforeApiCall(BuildContext context) async {
    final token = await _apiService.getToken();

    if (token == null || token.isEmpty) {
      await _handleInvalidToken(context);
      return false;
    }

    return true;
  }

  /// Validates token with a specific endpoint
  /// Useful for checking permissions for specific operations
  Future<bool> validateTokenWithEndpoint(String endpoint) async {
    try {
      final token = await _apiService.getToken();

      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await _apiService.get(endpoint);
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return false;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Refreshes token if your backend supports token refresh
  /// Modify this method based on your backend's refresh token implementation
  Future<bool> refreshToken() async {
    try {
      // If your backend has a refresh token endpoint, implement it here
      // For now, this is a placeholder

      // Example implementation:
      // final refreshToken = await _apiService.getRefreshToken();
      // if (refreshToken != null) {
      //   final response = await _apiService.post('auth/refresh', data: {
      //     'refresh_token': refreshToken,
      //   });
      //
      //   if (response.statusCode == 200) {
      //     final newToken = response.data['access_token'];
      //     await _apiService.saveToken(newToken);
      //     return true;
      //   }
      // }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Periodic token validation
  /// Call this method periodically to check token validity
  Future<void> periodicTokenCheck(BuildContext context) async {
    final isValid = await isTokenValid();

    if (!isValid) {
      // Try to refresh token first (if implemented)
      final refreshed = await refreshToken();

      if (!refreshed) {
        await _handleInvalidToken(context);
      }
    }
  }

  /// Gets token expiration information
  /// Returns a map with expiration details or null if token is invalid
  Future<Map<String, dynamic>?> getTokenExpirationInfo() async {
    try {
      final token = await _apiService.getToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      final expirationTime = JwtUtils.getTokenExpirationTime(token);
      final timeUntilExpiration = JwtUtils.getTimeUntilExpiration(token);
      final isExpired = JwtUtils.isTokenExpired(token);

      return {
        'expiration_time': expirationTime,
        'time_until_expiration': timeUntilExpiration,
        'is_expired': isExpired,
        'expires_in_minutes': timeUntilExpiration?.inMinutes,
        'expires_in_hours': timeUntilExpiration?.inHours,
      };
    } catch (e) {
      print('Error getting token expiration info: $e');
      return null;
    }
  }

  /// Shows a warning if token is about to expire
  /// Call this method to warn users before their session expires
  Future<void> checkAndWarnTokenExpiration(
    BuildContext context, {
    int warningMinutes = 5,
  }) async {
    try {
      final tokenInfo = await getTokenExpirationInfo();

      if (tokenInfo == null) return;

      final timeUntilExpiration =
          tokenInfo['time_until_expiration'] as Duration?;
      final isExpired = tokenInfo['is_expired'] as bool;

      if (isExpired) {
        await _handleInvalidToken(context);
        return;
      }

      if (timeUntilExpiration != null &&
          timeUntilExpiration.inMinutes <= warningMinutes &&
          timeUntilExpiration.inMinutes > 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Your session will expire in ${timeUntilExpiration.inMinutes} minutes. Please save your work.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Extend Session',
                onPressed: () {
                  // You can implement session extension here
                  // For now, just validate the token again
                  isTokenValid();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking token expiration warning: $e');
    }
  }
}
