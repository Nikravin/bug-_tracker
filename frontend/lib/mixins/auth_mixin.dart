import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

/// Mixin to add authentication checking capabilities to StatefulWidget screens
mixin AuthMixin<T extends StatefulWidget> on State<T> {
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiService());

    // Check authentication when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthenticationOnInit();
    });
  }

  /// Override this method in your screen if you want custom authentication checking
  Future<void> _checkAuthenticationOnInit() async {
    await checkAuthentication();
  }

  /// Main method to check authentication
  /// Returns true if authenticated, false if redirected to login
  Future<bool> checkAuthentication() async {
    return await _authService.validateTokenAndRedirect(context);
  }

  /// Check authentication before performing a specific action
  /// Use this before important operations like creating, updating, or deleting data
  Future<bool> checkAuthBeforeAction() async {
    return await _authService.checkAuthBeforeApiCall(context);
  }

  /// Validate token with a specific endpoint
  /// Useful for checking if user has permission for specific operations
  Future<bool> validateWithEndpoint(String endpoint) async {
    return await _authService.validateTokenWithEndpoint(endpoint);
  }

  /// Call this method periodically (e.g., every 5 minutes) to check token validity
  void startPeriodicAuthCheck() {
    // Check every 5 minutes
    const duration = Duration(minutes: 5);

    // You can store this timer and cancel it in dispose() if needed
    Stream.periodic(duration).listen((_) {
      if (mounted) {
        _authService.periodicTokenCheck(context);
      }
    });
  }
}

/// Extension to add authentication checking to any StatefulWidget
extension AuthenticationCheck on State {
  /// Quick authentication check for any screen
  Future<bool> quickAuthCheck() async {
    final authService = AuthService(ApiService());
    return await authService.validateTokenAndRedirect(context);
  }
}
