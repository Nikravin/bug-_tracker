import 'dart:convert';

class JwtUtils {
  /// Decodes a JWT token and returns the payload
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding JWT token: $e');
      return null;
    }
  }

  /// Checks if a JWT token is expired
  static bool isTokenExpired(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) {
        return true;
      }

      final exp = payload['exp'];
      if (exp == null) {
        // If no expiration time, consider it as not expired
        return false;
      }

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      return now.isAfter(expirationTime);
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
  }

  /// Gets the expiration time of a JWT token
  static DateTime? getTokenExpirationTime(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) {
        return null;
      }

      final exp = payload['exp'];
      if (exp == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      print('Error getting token expiration time: $e');
      return null;
    }
  }

  /// Gets the time remaining before token expires
  static Duration? getTimeUntilExpiration(String token) {
    try {
      final expirationTime = getTokenExpirationTime(token);
      if (expirationTime == null) {
        return null;
      }

      final now = DateTime.now();
      if (now.isAfter(expirationTime)) {
        return Duration.zero;
      }

      return expirationTime.difference(now);
    } catch (e) {
      print('Error calculating time until expiration: $e');
      return null;
    }
  }

  /// Gets user information from JWT token
  static Map<String, dynamic>? getUserInfoFromToken(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) {
        return null;
      }

      // Extract common user fields (adjust based on your token structure)
      return {
        'user_id': payload['user_id'] ?? payload['sub'],
        'email': payload['email'],
        'username': payload['username'],
        'role': payload['role'],
        'name': payload['name'],
        'exp': payload['exp'],
        'iat': payload['iat'],
      };
    } catch (e) {
      print('Error extracting user info from token: $e');
      return null;
    }
  }
}
